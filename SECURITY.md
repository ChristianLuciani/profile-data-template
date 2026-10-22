# Security Policy

This repository is a **template**. It ships no application code and no personal
data: it ships a YAML workspace layout, docs, and the CI that validates a copy.
The engine that reads the workspace is
[profile-as-code](https://github.com/ChristianLuciani/profile-as-code) — a
separate repository with its own policy.

## Supported versions

| Version | Supported | Notes |
|---|---|---|
| `v0.3.x` (engine `@profile-as-code/cli@0.3.0`) | ✅ | Current scaffold line |
| Pre-release history (no tag) | ❌ | Use the latest tag |

## Reporting a vulnerability

**Do not open a public issue for a security problem.**

Use GitHub's private vulnerability reporting:

→ https://github.com/ChristianLuciani/profile-data-template/security/advisories/new

Include, as far as you can:

- the affected file, workflow or documented step;
- the impact (what an attacker gains, what data is exposed);
- a minimal reproduction, or the exact conditions;
- a suggested fix, if you have one.

**Never include real personal data, live credentials, or a working exploit
against a third party in the report.** Redact tokens and identifiers.

If the private form is unavailable to you, open a public issue **with no
details** asking for a private channel; the maintainer will follow up there.

### What to expect

| Stage | Target |
|---|---|
| Acknowledgement | ≤ 3 business days |
| Triage + severity | ≤ 7 business days |
| Fix or mitigation plan | depends on severity; you get the plan, not silence |
| Coordinated disclosure | 90 days by default, sooner by agreement |

This is a best-effort, single-maintainer project — there is no SLA and no bug
bounty. Credit is given in the advisory unless you ask otherwise.

## Scope

**In scope**

- `.github/workflows/**`, `.github/scripts/**` — privilege, trigger, pinning and
  injection issues (e.g. untrusted input reaching a `run:` block).
- Guidance in `README.md`, `CONTRIBUTING.md`, `CHECKLIST.md`, `docs/**` that
  could lead a forker to publish personal data or to widen CI permissions.
- The template bootstrap flow (private-by-default, "Use this template", the
  `build.yml` commit guard).
- Example content in `content/**` and `media/**` — it must stay fictional.
- Compromise or typo-squatting of the pinned engine dependency.

**Out of scope**

- Bugs in the engine → report them at
  [profile-as-code/security](https://github.com/ChristianLuciani/profile-as-code/security).
- Data inside a fork. A fork is a separate repository; the maintainer has no
  access to it and cannot delete or inspect its content.
- Vulnerabilities in GitHub itself.
- Harassment or conduct issues → see `CODE_OF_CONDUCT.md`.
- Anything that requires write access to this repository or to a fork.

## What this repository already does

- **Least privilege.** Workflows default to `contents: read`; only
  `.github/workflows/build.yml` holds `contents: write`, and it never runs on
  `pull_request`. There is no `pull_request_target` anywhere.
- **Actions pinned by commit SHA** in every workflow, with Dependabot keeping
  the pins current. The repository setting *Require actions to be pinned to a
  full-length commit SHA* is enabled once the repo is public.
- **Pinned engine, no install scripts.** CI runs
  `npm i -g --ignore-scripts @profile-as-code/cli@<pin>` — the exact version,
  never a range, and no lifecycle scripts from the dependency tree.
- **Secret scanning in CI.** A pinned `gitleaks` CLI (version + SHA-256
  verified at download) scans the full history on every push/PR.
- **Example-data guard.** `.github/scripts/check-example-data.sh` fails the
  build if `content/` stops being fictional (non-`example.*` emails, absolute
  home paths, a changed example identity) or if `media/` ships bytes. It runs
  **only in this template repository**: a fork is supposed to hold a real
  identity, so the CI job skips there.
- **No secrets in history.** Full-history pattern scan on 2026-10-21: no
  credentials, keys or tokens. GitHub secret scanning and push protection are
  enabled when the repository becomes public.
- **Private by default for users.** The documented bootstrap creates the
  workspace private *before* data is written, and `build.yml` refuses to commit
  when the `is_template` flag is missing from the payload (fail-closed guard).

## For forkers — your data is your responsibility

1. Create your workspace **private** (README, step 1) before adding facts.
2. Never paste real profile data, media, or tokens into an issue or PR in this
   template repository. This repo is public; your data is not.
3. Keep the engine pinned. Review Dependabot PRs before merging them; a bumped
   action or engine is code that will run over your data.
4. If your workspace will hold secrets (it normally should not), enable secret
   scanning and push protection in your own repository.

## Safe harbor

Security research conducted in good faith under this policy is welcome, and the
maintainer will not pursue legal action for it. That applies as long as you: do
not access, modify or exfiltrate other people's data; do not degrade the service;
and give reasonable time to fix before public disclosure.
