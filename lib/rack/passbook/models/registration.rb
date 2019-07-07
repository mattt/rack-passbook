# frozen_string_literal: true

module Rack
  class Passbook
    class Registration < Sequel::Model
      plugin :json_serializer, naked: true, except: :id
      plugin :validation_helpers
      plugin :timestamps, force: true, update_on_create: true
      plugin :schema

      self.dataset = :passbook_registrations
      self.strict_param_setting = false
      self.raise_on_save_failure = false

      def before_validation
        normalize_push_token! if push_token
      end

      def validate
        super

        validates_presence :device_library_identifier
        validates_unique %i[device_library_identifier pass_id]
        validates_format /[[:xdigit:]]+/, :push_token
        validates_exact_length 64, :push_token
      end

      private

      def normalize_push_token!
        self.push_token = push_token.strip.gsub(/[<\s>]/, '')
      end
    end
  end
end
