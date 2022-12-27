# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.0.2] - 2022-12-27

### Fixed

- Fixed Images#generate and Finetunes#create which were broken by a double call of to_json.
- Thanks [@konung](https://github.com/konung) for spotting this!

## [3.0.1] - 2022-12-26

### Removed

- [BREAKING] Remove deprecated answers, classifications, embeddings, engines and search endpoints.
- [BREAKING] Remove ability to pass engine to completions and embeddings outside of the parameters hash.

## [3.0.0] - 2022-12-26

### Added

- Add ability to set access_token via gem configuration.
- Thanks [@grjones](https://github.com/grjones) and [@aquaflamingo](https://github.com/aquaflamingo) for raising this and [@feministy](https://github.com/feministy) for the [excellent guide](https://github.com/feministy/lizabinante.com/blob/stable/source/2016-01-30-creating-a-configurable-ruby-gem.markdown#configuration-block-the-end-goal) to adding config to a gem.

### Removed

- [BREAKING] Remove ability to include access_token directly via ENV vars.
- [BREAKING] Remove ability to pass API version directly to endpoints.

## [2.3.0] - 2022-12-23

### Added

- Add Images#edit and Images#variations endpoint to modify images with DALL·E.

## [2.2.0] - 2022-12-15

### Added

- Add Organization ID to headers so users can charge credits to the correct organization.
- Thanks [@mridul911](https://github.com/mridul911) for raising this and [@maks112v](https://github.com/maks112v) for adding it!

## [2.1.0] - 2022-11-13

### Added

- Add Images#generate endpoint to generate images with DALL·E!

## [2.0.1] - 2022-10-22

### Removed

- Deprecate Client#answers endpoint.
- Deprecate Client#classifications endpoint.

## [2.0.0] - 2022-09-19

### Removed

- [BREAKING] Remove support for Ruby 2.5.
- [BREAKING] Remove support for passing `query`, `documents` or `file` as top-level parameters to `Client#search`.
- Deprecate Client#search endpoint.
- Deprecate Client#engines endpoints.

### Added

- Add Client#models endpoints to list and query available models.

## [1.5.0] - 2022-09-18

### Added

- Add Client#moderations endpoint to check OpenAI's Content Policy.
- Add Client#edits endpoints to transform inputs according to instructions.

## [1.4.0] - 2021-12-11

### Added

- Add Client#engines endpoints to list and query available engines.
- Add Client#finetunes endpoints to create and use fine-tuned models.
- Add Client#embeddings endpoint to get vector representations of inputs.
- Add tests and examples for more engines.

## [1.3.1] - 2021-07-14

### Changed

- Add backwards compatibility from Ruby 2.5+.

## [1.3.0] - 2021-04-18

### Added

- Add Client#classifications to predict the most likely labels based on examples or a file.

### Fixed

- Fixed Files#upload which was previously broken by the validation code!

## [1.2.2] - 2021-04-18

### Changed

- Add Client#search(parameters:) to allow passing `max_rerank` or `return_metadata`.
- Deprecate Client#search with query, file or document parameters at the top level.
- Thanks [@stevegeek](https://github.com/stevegeek) for pointing this issue out!

## [1.2.1] - 2021-04-11

### Added

- Add validation of JSONL files to make it easier to debug during upload.

## [1.2.0] - 2021-04-08

### Added

- Add Client#answers endpoint for question/answer response on documents or a file.

## [1.1.0] - 2021-04-07

### Added

- Add Client#files to allow file upload.
- Add Client#search(file:) so you can search a file.

## [1.0.0] - 2021-02-01

### Removed

- Remove deprecated method Client#call - use Client#completions instead.

### Changed

- Rename 'master' branch to 'main' branch.
- Bump dependencies.

## [0.3.0] - 2020-11-22

### Added

- Add Client#completions to allow all parameters.

### Changed

- Deprecate Client#call.
- Update README.

## [0.2.0] - 2020-11-22

### Added

- Add method to use the search endpoint.

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
