# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.4] - 2020-10-18

### Changed

- Bump Rubocop to 3.9.2.
- Bump Webmock to 3.9.1.

## [0.1.3] - 2020-09-09

### Changed

- Add ability to change API version in the future.
- Fix README typos.

## [0.1.2] - 2020-09-09

### Added

- Add tests and cached responses for the different engines.
- Add issue templates.

### Changed

- Add README instructions for using the gem without dotenv.
- Add list of engines to README.

## [0.1.1] - 2020-09-08

### Added

- Run Rubocop on pulls using CircleCI.

### Changed

- Clean up CircleCI config file.

## [0.1.0] - 2020-09-06

### Added

- Initialise repository.
- Add OpenAI::Client to connect to OpenAI API using user credentials.
- Add spec for Client with a cached response using VCR.
- Add CircleCI to run the specs on pull requests.
