# Security Policy

Thank you for helping keep Ruby OpenAI and the systems it interacts with secure.

## Supported Versions

Security fixes target the supported release line documented in `SUPPORT.md`.

## Reporting Security Issues

Please do not create a public GitHub issue for a suspected vulnerability.

Use GitHub private vulnerability reporting instead: open the repository [Security tab](https://github.com/alexrudall/ruby-openai/security) and click "Report a vulnerability".

Helpful reports include:

- A description of the vulnerability and impact.
- Steps to reproduce, including affected ruby-openai versions.
- Whether the issue can expose tokens, request data, response data, files, or logs.
- Any known mitigations.

## Response Process

The maintainer will triage security reports privately, ask for more information when needed, and prioritize validated issues according to impact.

For validated vulnerabilities, the project will aim to:

1. Prepare a fix in private when public disclosure would increase user risk.
2. Release a patched gem for the supported release line.
3. Publish a GitHub Security Advisory and request a CVE when applicable.
4. Identify affected versions, patched versions, and any available mitigations.
5. State whether a backport is available for older release lines.

## Backports and Mitigations

Security fixes may be backported when practical, as described in `SUPPORT.md`. If a backport is not available, the security advisory or release notes will document the recommended upgrade path and any known mitigations.
