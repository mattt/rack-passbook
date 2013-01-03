![Passbook](http://cl.ly/JPjc/title_passbook.png)

# Rack::Passbook

> This is still in early stages of development, so proceed with caution when using this in a production application. Any bug reports, feature requests, or general feedback at this point would be greatly appreciated.

[Passbook](http://www.apple.com/ios/whats-new/#passbook) is an iOS 6 feature that manages boarding passes, movie tickets, retail coupons, & loyalty cards. Using the [PassKit API](https://developer.apple.com/library/prerelease/ios/#documentation/UserExperience/Reference/PassKit_Framework/_index.html), developers can register web services to automatically update content on the pass, such as gate changes on a boarding pass, or adding credit to a loyalty card.

Apple [provides a specification](https://developer.apple.com/library/prerelease/ios/#documentation/PassKit/Reference/PassKit_WebService/WebService.html) for a REST-style web service protocol to communicate with Passbook, with endpoints to get the latest version of a pass, register / unregister devices to receive push notifications for a pass, and query for passes registered for a device.

This project is an example implementation of this web service specification in Rails, and will serve the basis for a more comprehensive Rails generator in the near future.

> If you're just starting out Passbook development, you should definitely check out [this great two-part tutorial](http://www.raywenderlich.com/20734/beginning-passbook-part-1) by [Marin Todorov](http://www.raywenderlich.com/about#marintodorov) ([Part 1](http://www.raywenderlich.com/20734/beginning-passbook-part-1) [Part 2](http://www.raywenderlich.com/20785/beginning-passbook-in-ios-6-part-22)).

## Installation

```
$ gem install rack-passbook
```

## Requirements

- Ruby 1.9
- PostgreSQL 9.1 running locally ([Postgres.app](http://postgresapp.com) is the easiest way to get a Postgres server running on your Mac)

## Example Usage

Rack::Passbook can be run as Rack middleware or as a single web application. All that is required is a connection to a Postgres database.

### config.ru

```ruby
require 'bundler'
Bundler.require

run Rack::Passbook
```

An example application can be found in the `/example` directory of this repository.

---

## Specification

What follows is a summary of the specification. The complete specification can be found in the [Passbook Web Service Reference](https://developer.apple.com/library/prerelease/ios/#documentation/PassKit/Reference/PassKit_WebService/WebService.html).

### Getting the Latest Version of a Pass

```
GET http://example.com/v1/passes/:passTypeIdentifier/:serialNumber
```

- **passTypeIdentifier** The pass’s type, as specified in the pass.
- **serialNumber** The unique pass identifier, as specified in the pass.

**Response**

- If request is authorized, return HTTP status 200 with a payload of the pass data.
- If the request is not authorized, return HTTP status 401.
- Otherwise, return the appropriate standard HTTP status.

### Getting the Serial Numbers for Passes Associated with a Device

```
GET http://example.com/v1/devices/:deviceLibraryIdentifier/registrations/:passTypeIdentifier[?passesUpdatedSince=tag]
```

- **deviceLibraryIdentifier** A unique identifier that is used to identify and authenticate the device.
- **passTypeIdentifier** The pass’s type, as specified in the pass.
- **serialNumber** The unique pass identifier, as specified in the pass.
- **passesUpdatedSince** _Optional_ A tag from a previous request. 

**Response**

If the `passesUpdatedSince` parameter is present, return only the passes that have been updated since the time indicated by tag. Otherwise, return all passes.

- If there are matching passes, return HTTP status 200 with a JSON dictionary with the following keys and values:
    - **lastUpdated** _(string)_ The current modification tag.
    - **serialNumbers** _(array of strings)_ The serial numbers of the matching passes.
- If there are no matching passes, return HTTP status 204.
- Otherwise, return the appropriate standard HTTP status.

### Registering a Device to Receive Push Notifications for a Pass

```
POST http://example.com/v1/devices/:deviceLibraryIdentifier/registrations/:passTypeIdentifier/:serialNumber
```

- **deviceLibraryIdentifier** A unique identifier that is used to identify and authenticate the device.
- **passTypeIdentifier** The pass’s type, as specified in the pass.
- **serialNumber** The unique pass identifier, as specified in the pass.

The POST payload is a JSON dictionary, containing a single key and value:

- **pushToken** The push token that the server can use to send push notifications to this device.

**Response**

- If the serial number is already registered for this device, return HTTP status 200.
- If registration succeeds, return HTTP status 201.
- If the request is not authorized, return HTTP status 401.
- Otherwise, return the appropriate standard HTTP status.

### Unregistering a Device

```
DELETE http://example.com/v1/devices/:deviceLibraryIdentifier/registrations/:passTypeIdentifier/:serialNumber
```

- **deviceLibraryIdentifier** A unique identifier that is used to identify and authenticate the device.
- **passTypeIdentifier** The pass’s type, as specified in the pass.
- **serialNumber** The unique pass identifier, as specified in the pass.

**Response**

- If disassociation succeeds, return HTTP status 200.
- If the request is not authorized, return HTTP status 401.
- Otherwise, return the appropriate standard HTTP status.

---

## Contact

Mattt Thompson

- http://github.com/mattt
- http://twitter.com/mattt
- m@mattt.me

## License

Rack::Passbook is available under the MIT license. See the LICENSE file for more info.
