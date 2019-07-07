# frozen_string_literal: true

module Rack
  class Passbook
    class Pass < Sequel::Model
      plugin :json_serializer, naked: true, except: :id
      plugin :validation_helpers
      plugin :timestamps, force: true, update_on_create: true
      plugin :schema
      plugin :typecast_on_load

      self.dataset = :passbook_passes
      self.strict_param_setting = false
      self.raise_on_save_failure = false

      one_to_many :registrations, class_name: 'Rack::Passbook::Registration'

      def validate
        super

        validates_presence %i[pass_type_identifier serial_number]
        validates_unique :pass_type_identifier
        validates_unique %i[serial_number pass_type_identifier]
      end
    end
  end
end
