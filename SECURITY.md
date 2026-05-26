# Security Policy

## Scope

FeedYourSpider is a thin wrapper around third-party network and recon
tools (nmap, netcat, tcpdump, tshark, hping3, arp-scan, masscan, nikto,
dnsenum, whatweb). This policy covers vulnerabilities in **the
wrapper itself** — for example:

- Command injection through unsanitized prompts.
- Path traversal in output-file handling.
- Privilege escalation paths introduced by the launcher (e.g.
  `sudo` invocations on untrusted input).
- Tampered automatic-installation flows.

Vulnerabilities in the **wrapped tools themselves** are out of scope —
please report those directly to their upstream maintainers.

## Reporting a vulnerability

Please **do not** open a public issue for security reports.

Use one of these private channels:

1. **GitHub Security Advisories**:
   <https://github.com/WhiteMuush/FeedYourSpider/security/advisories/new>
2. The maintainer's contact email listed on their GitHub profile.

Include:

- A description of the vulnerability and its impact.
- Steps to reproduce (menu choices, prompt inputs, environment).
- The commit SHA or release tag where you observed it.
- Whether you intend to publish your own write-up, and a target date.

## What to expect

- Acknowledgement within 7 days.
- A coordinated fix in a dedicated branch.
- Credit in the fix's release notes if you wish.

## Supported versions

Only the latest release on `main` is supported. There is no LTS line.

## Responsible use reminder

FeedYourSpider is intended for use on systems and networks you are
explicitly authorized to test. Unauthorized scanning, capture, or
probing may violate the laws of your jurisdiction.
