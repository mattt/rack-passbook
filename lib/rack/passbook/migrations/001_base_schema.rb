# frozen_string_literal: true

Sequel.migration do
  up do
    run %(CREATE EXTENSION IF NOT EXISTS hstore;)

    create_table :passbook_passes do
      primary_key :id

      column :pass_type_identifier, :varchar, unique: true, empty: false
      column :serial_number,        :varchar, empty: false
      column :authentication_token, :varchar
      column :data,                 :hstore
      column :created_at,           :timestamp
      column :updated_at,           :timestamp

      index :pass_type_identifier
      index :serial_number
    end

    create_table :passbook_registrations do
      primary_key :id

      column :pass_id,                    :int8,    null: false
      column :device_library_identifier,  :varchar, empty: false
      column :push_token,                 :varchar
      column :created_at,                 :timestamp
      column :updated_at,                 :timestamp

      index :device_library_identifier
    end
  end

  down do
    drop_table :passbook_passes
    drop_table :passbook_registrations
  end
end
