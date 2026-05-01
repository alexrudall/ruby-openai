## Contributing

Bug reports, feature requests, and pull requests are welcome on GitHub at <https://github.com/alexrudall/ruby-openai>.

This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/alexrudall/ruby-openai/blob/main/CODE_OF_CONDUCT.md).

## Reporting Issues

Before opening a new issue, please search existing issues and pull requests to see whether the problem has already been reported.

For bugs, use the bug report template and include:

- The ruby-openai version.
- The Ruby version.
- Relevant Faraday or dependency versions.
- A minimal reproduction or code sample.
- The expected behavior and actual behavior.

For feature requests, use the feature request template and describe the OpenAI API endpoint or behavior you need.

Please report suspected security vulnerabilities through GitHub private vulnerability reporting, not public issues. See `SECURITY.md`.

## Issue Response Process

Issues are triaged by the maintainer as time allows. The typical process is:

1. Confirm whether the issue is a bug, feature request, usage question, duplicate, or security concern.
2. Ask for reproduction steps or logs when more information is needed.
3. Prioritize regressions, security concerns, and widely affecting API compatibility issues.
4. Accept a pull request or prepare a maintainer fix when the change is ready.
5. Close the issue after the fix is released or the question is answered.

## Pull Requests

Pull requests should explain the problem being solved, the user-visible behavior change, and any compatibility impact.

Run the test suite before opening a pull request when practical:

```bash
bundle exec rake
```
