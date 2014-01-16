require 'rack'
require 'rack/contrib'

require 'sinatra/base'
require 'sinatra/param'
require 'rack'

require 'sequel'

module Rack
  class Passbook < Sinatra::Base

    use Rack::PostBodyContentTypeParser
    helpers Sinatra::Param

    autoload :Pass,         'rack/passbook/models/pass'
    autoload :Registration, 'rack/passbook/models/registration'

    disable :raise_errors, :show_exceptions

    configure do
      Sequel.extension :core_extensions, :migration, :pg_hstore, :pg_hstore_ops

      if ENV['DATABASE_URL']
        DB = Sequel.connect(ENV['DATABASE_URL'])
        Sequel::Migrator.run(DB, ::File.join(::File.dirname(__FILE__), "passbook/migrations"), table: 'passbook_schema_info')
      end
    end

    before do
      content_type :json
    end

    # Get the latest version of a pass.
    get '/passes/:pass_type_identifier/:serial_number/?' do
      @pass = Pass.filter(pass_type_identifier: params[:pass_type_identifier], serial_number: params[:serial_number]).first
      halt 404 if @pass.nil?
      filter_authorization_for_pass!(@pass)
  
      last_modified @pass.updated_at.utc

      @pass.to_json
    end


    # Get the serial numbers for passes associated with a device.
    # This happens the first time a device communicates with our web service.
    # Additionally, when a device gets a push notification, it asks our
    # web service for the serial numbers of passes that have changed since
    # a given update tag (timestamp).
    get '/devices/:device_library_identifier/registrations/:pass_type_identifier/?' do
      @passes = Pass.filter(pass_type_identifier: params[:pass_type_identifier]).join(Registration.dataset, device_library_identifier: params[:device_library_identifier])
      halt 404 if @passes.empty?

      @passes = @passes.filter("#{Pass.table_name}.updated_at > ?", Time.parse(params[:passesUpdatedSince])) if params[:passesUpdatedSince]

      if @passes.any?
        {
          lastUpdated: @passes.collect(&:updated_at).max,
          serialNumbers: @passes.collect(&:serial_number).collect(&:to_s)
        }.to_json
      else
        halt 204
      end
    end


    # Register a device to receive push notifications for a pass.
    post '/devices/:device_library_identifier/registrations/:pass_type_identifier/:serial_number/?' do
      @pass = Pass.where(pass_type_identifier: params[:pass_type_identifier], serial_number: params[:serial_number]).first
      halt 404 if @pass.nil?
      filter_authorization_for_pass!(@pass)

      param :pushToken, String, required: true

      @registration = @pass.registrations.detect{|registration| registration.device_library_identifier == params[:device_library_identifier]}
      @registration ||= Registration.new(pass_id: @pass.id, device_library_identifier: params[:device_library_identifier])
      @registration.push_token = params[:pushToken]

      status = @registration.new? ? 201 : 200

      @registration.save
      halt 406 unless @registration.valid?

      halt status
    end

    # Unregister a device so it no longer receives push notifications for a pass.
    delete '/devices/:device_library_identifier/registrations/:pass_type_identifier/:serial_number/?' do
      @pass = Pass.filter(pass_type_identifier: params[:pass_type_identifier], serial_number: params[:serial_number]).first
      halt 404 if @pass.nil?
      filter_authorization_for_pass!(@pass)

      @registration = @pass.registrations.detect{|registration| registration.device_library_identifier == params[:device_library_identifier]}
      halt 404 if @registration.nil?

      @registration.destroy

      halt 200
    end

    private

    def filter_authorization_for_pass!(pass)
      halt 401 if request.env['HTTP_AUTHORIZATION'] != "ApplePass #{pass.authentication_token}"
    end
  end
end
