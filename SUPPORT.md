# Support Policy

Ruby OpenAI is maintained by a single volunteer maintainer with help from community contributors. This policy sets clear expectations for supported versions, end-of-life status, and where users should ask for help.

## Supported Versions

Users should run the latest released version of the latest major release line whenever possible.

| Release line | Status | Support |
| --- | --- | --- |
| 8.x | Supported | Bug fixes, compatibility updates, and security fixes. Use the latest 8.x patch or minor release. |
| 7.x and earlier | End of life | No routine fixes. Users should upgrade to 8.x. Security reports may still receive advisory guidance. |

This table is reviewed when each new major version is released.

## Support Tiers

- Supported: The current major release line. Receives bug fixes, compatibility updates, and security fixes.
- Security-only transition: A previous major release line may receive security fixes only for a defined transition period when a new major version is released.
- End of life: No fixes are planned. Users should migrate to a supported version.
- Development: The `main` branch and unreleased commits are for testing and development. Production users should depend on released gems.

## End-of-Life Process

For future major releases, the project aims to:

1. Document the support status of old and new release lines in this file, `CHANGELOG.md`, and release notes.
2. Provide 3-6 months of notice before ending support for a previous major release line when practical for a small maintainer-led project.
3. Encourage users to migrate to the supported major release line, or establish their own support solution if immediate migration is not possible.
4. Announce end-of-life events through the same channels used for releases.

Shorter timelines may be necessary when an upstream API change, dependency issue, or security issue requires faster action. In those cases, the reason will be documented in the release notes.

## Release and Announcement Channels

Release information is published through:

- GitHub Releases and git tags: <https://github.com/alexrudall/ruby-openai/releases>
- RubyGems: <https://rubygems.org/gems/ruby-openai>
- `CHANGELOG.md`: <https://github.com/alexrudall/ruby-openai/blob/main/CHANGELOG.md>

Major releases, security releases, and end-of-life notices may also be shared through the community channels linked from the README.

## Backports

Routine bug fixes and feature work are not normally backported. They target the supported release line.

Security fixes may be backported to a security-only release line when practical. If a backport is not provided, the release notes or security advisory will identify the affected versions and the supported upgrade path.

## Getting Help

- Bugs and regressions: Open a GitHub issue using the bug report template.
- Feature requests and API coverage gaps: Open a GitHub issue using the feature request template.
- Security issues: Use GitHub private vulnerability reporting from the repository Security tab.
- General community help: Use the community channels linked from the README.

## Third-Party Support Providers

Ruby OpenAI does not currently list or endorse third-party migration assistance, long-term support, or security support providers. Providers may be considered in the future if they have a clear history and reputation for competent Ruby OpenAI support.
