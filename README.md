# mobile-survey
Survey App for Mobile Offline Data Collection

### Testing

Performing acceptance tests requires a running instance of this application
on port :13000 (`make run`) in a separate terminal emulator instance.

To initiate the tests simply run `make test` within the 'app' directory.

This will execute .scripts/run-tests.sh which takes care of backing up
the current MongoDB data into a directory 'meteor' located in './tests/dump'.
As long as the local parse server is used (which relies on Meteor's
`mongod` instance running on port :13001), backing the data up and restoring
upon completion/interrupt works well for our testing purposes.

The code for testing can be borrowed from our past project
[Tater](https://github.com/ecohealthalliance/tater) which as well
utilized `chimp` to perform acceptance testing.
