# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.3.1] - 2023-08-13

### Fixed

- Tempfiles can now be sent to the API as well as Files, eg for Whisper. Thanks to [@codergeek121](https://github.com/codergeek121) for the fix!

## [4.3.0] - 2023-08-12

### Added

- Add extra-headers to config to allow setting openai-caching-proxy-worker TTL, Helicone Auth and anything else ya need. Ty to [@deltaguita](https://github.com/deltaguita) and [@marckohlbrugge](https://github.com/marckohlbrugge) for the PR!

## [4.2.0] - 2023-06-20

### Added

- Add Azure OpenAI Service support. Thanks to [@rmachielse](https://github.com/rmachielse) and [@steffansluis](https://github.com/steffansluis) for the PR and to everyone who requested this feature!

## [4.1.0] - 2023-05-15

### Added

- Add the ability to trigger any callable object as stream chunks come through, not just Procs. Big thanks to [@obie](https://github.com/obie) for this change.

## [4.0.0] - 2023-04-25

### Added

- Add the ability to stream Chat responses from the API! Thanks to everyone who requested this and made suggestions.
- Added instructions for streaming to the README.

### Changed

- Switch HTTP library from HTTParty to Faraday to allow streaming and future feature and performance improvements.
- [BREAKING] Endpoints now return JSON rather than HTTParty objects. You will need to update your code to handle this change, changing `JSON.parse(response.body)["key"]` and `response.parsed_response["key"]` to just `response["key"]`.

## [3.7.0] - 2023-03-25

### Added

- Allow the usage of proxy base URIs like https://www.helicone.ai/. Thanks to [@mmmaia](https://github.com/mmmaia) for the PR!

## [3.6.0] - 2023-03-22

### Added

- Add much-needed ability to increase HTTParty timeout, and set default to 120 seconds. Thanks to [@mbackermann](https://github.com/mbackermann) for the PR and to everyone who requested this!

## [3.5.0] - 2023-03-02

### Added

- Add Client#transcribe and Client translate endpoints - Whisper over the wire! Thanks to [@Clemalfroy](https://github.com/Clemalfroy)

## [3.4.0] - 2023-03-01

### Added

- Add Client#chat endpoint - ChatGPT over the wire!

## [3.3.0] - 2023-02-15

### Changed

- Replace ::Ruby::OpenAI namespace with ::OpenAI - thanks [@kmcphillips](https://github.com/kmcphillips) for this work!
- To upgrade, change `require 'ruby/openai'` to `require 'openai'` and change all references to `Ruby::OpenAI` to `OpenAI`.

## [3.2.0] - 2023-02-13

### Added

- Add Files#content endpoint - thanks [@unixneo](https://github.com/unixneo) for raising!

## [3.1.0] - 2023-02-13

### Added

- Add Finetunes#delete endpoint - thanks [@lancecarlson](https://github.com/lancecarlson) for flagging this.
- Add VCR header and body matching - thanks [@petergoldstein](https://github.com/petergoldstein)!

### Fixed

- Update File#upload specs to remove deprecated `answers` purpose.

## [3.0.3] - 2023-01-07

### Added

- Add ability to run the specs without VCR cassettes using `NO_VCR=true bundle exec rspec`.
- Add Ruby 3.2 to CircleCI config - thanks [@petergoldstein](https://github.com/petergoldstein)!
- A bit of detail added to the README on DALLE image sizes - thanks [@ndemianc](https://github.com/ndemianc)!

### Fixed

- Fix finetunes and files uploads endpoints - thanks [@chaadow](https://github.com/chaadow) for your PR on this and [@petergoldstein](https://github.com/petergoldstein) for the PR we ultimately went with.

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
