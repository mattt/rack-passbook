# Rack::Passbook Example

## Instructions

To run the example application, ensure that you have Postgres running locally (see [Postgres.app](http://postgresapp.com) for an easy way to get set up on a Mac), and run the following commands:

```sh
$ cd example
$ psql -c "CREATE DATABASE passbook_example;"
$ echo "DATABASE_URL=postgres://localhost:5432/passbook_example" > .env
$ bundle
$ foreman start
```
