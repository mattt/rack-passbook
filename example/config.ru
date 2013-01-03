require 'bundler'
Bundler.require

run Rack::Passbook

# Seed data if no records currently exist
if Rack::Passbook::Pass.count == 0
  pass = Rack::Passbook::Pass.create(pass_type_identifier: "com.company.pass.example", serial_number: "ABC123", authentication_token: "XYZ456")
  pass.data = {
    foo: 57,
    bar: Time.now,
    baz: "Lorem ipsum dolar sit amet"
  }.hstore

  pass.save

  pass.registrations << Rack::Passbook::Registration.create(pass_id: pass.id, device_library_identifier: "123456789", push_token: "0" * 40)
  pass.save
end
