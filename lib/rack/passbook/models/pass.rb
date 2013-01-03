module Rack
  class Passbook
    DB = Sequel.connect(ENV['DATABASE_URL'] || "postgres://localhost:5432/passbook_example")
    Sequel::Migrator.run(DB, ::File.join(::File.dirname(__FILE__), "../migrations"))

    class Pass < Sequel::Model
      plugin :json_serializer, naked: true, except: :id 
      plugin :validation_helpers
      plugin :timestamps, force: true, update_on_create: true
      plugin :schema
      plugin :typecast_on_load
      
      self.dataset = :passbook_devices
      self.strict_param_setting = false
      self.raise_on_save_failure = false

      one_to_many :registrations, class_name: "Rack::Passbook::Registration"

      def validate
        super
      
        validates_presence [:pass_type_identifier, :serial_number]
        validates_unique :pass_type_identifier
        validates_unique [:serial_number, :pass_type_identifier]
      end
    end
  end
end
