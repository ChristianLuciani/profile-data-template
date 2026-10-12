# Evidence packs — what proof looks like, per domain

Profiles are believed when they are proven. This doc is a **checklist of what
counts as evidence** in different fields, and how each item maps onto the
registry (`credentials[]` / `artifacts[]`).

The engine learns no domains ([OFICIAL] SPEC §18.10, profile-as-code) — this
file is knowledge, not code. It exists so you don't have to reverse-engineer
the mapping yourself.

## The three concepts (don't mix them up)

| Concept | Block | It is | Example |
|---|---|---|---|
| **Claim** | `projects[].evidence[]` | a textual assertion + source | "raised $2M" → TechCrunch link |
| **Credential** | `credentials[]` | a third-party attestation | AWS cert, degree, award, patent |
| **Artifact** | `artifacts[]` | a work or media item | portfolio, showreel, dataset |

Two rules the schema enforces:

- `credentials[]` and `artifacts[]` are **never** called "evidence" — evidence
  means claims only. Different blocks, different jobs.
- `publications[]` (papers, DOI) and `press[]` are **not** registry kinds. They
  keep their own blocks and **reference** registry ids via `artifactRefs`.

### How entries link (the wiring people get wrong)

References point **from** the claim/text block **to** the registry — never the
reverse, and never by copying fields:

| To connect… | Write it on | Field |
|---|---|---|
| A claim ↔ the credential that attests it | `projects[].evidence[]` | `credentialId` |
| A claim ↔ the artifact that proves it | `projects[].evidence[]` | `artifactId` |
| A paper ↔ its artifact (code, dataset) | `publications[]` | `artifactRefs: [id]` |
| Press ↔ the work it covers | `press[]` | `artifactRefs: [id]` |

A reference to an `id` that doesn't exist is a **dangling ref** — the load fails,
it is not silently ignored. And note the naming trap: on a *credential*,
`credentialId` is the **issuer's serial number**; on an *evidence item*,
`credentialId` is the **registry reference**. Same key, different blocks,
different meanings. Read the block you're editing.

## Field reference

**`credentials[].kind`** — one of: `certificate` · `title` · `award` · `patent`
**`artifacts[].kind`** — one of: `portfolio` · `gallery` · `showreel` ·
`dataset` · `document` · `code`

Required fields: credentials need `id`, `kind`, `title`, `issuer`. Artifacts
need `id`, `kind`, `title`, `locator`. Everything else is optional.

`visibility` on both: `public` (renderers emit it) · `unlisted` (shared on
request) · `private` (never leaves the workspace). Certificates carry PII — see
the privacy note at the end.

---

## Designer

| What you have | Block | Kind | Metadata worth filling |
|---|---|---|---|
| Portfolio case study | `artifacts[]` | `portfolio` | `locator.url` (your site / Behance), `tags`, `license` if it's someone else's brand work |
| Shot gallery | `artifacts[]` | `gallery` | `locator.path` for a few hero stills; `description` in **both** langs |
| Design award (Awwwards, D&AD) | `credentials[]` | `award` | `issuer` = awarding body, `verifyUrl` = award page, `issued` |
| Studio/agency title | `credentials[]` | `title` | only for formal accreditations, not job titles |
| Client press write-up | `press[]` | — | reference the artifact via `artifactRefs`, don't duplicate |

Notes: gallery images are the classic `media/` case — small, versionable. A
showreel is not — host it and use `url`. Tag by discipline (`tags: [branding]`,
`tags: [ux]`) if you work across areas; renderers select per platform + tag.

## Filmmaker

| What you have | Block | Kind | Metadata worth filling |
|---|---|---|---|
| Showreel / demo reel | `artifacts[]` | `showreel` | `locator.url` (Vimeo/YouTube) — **never** a versioned video file |
| A film you made | `artifacts[]` | `portfolio` or `document` | `license`, `tags: [film]`, `description` |
| Festival laurels / selection | `credentials[]` | `award` | `issuer` = festival, `issued` = year, `verifyUrl` = festival page |
| Filmography entry | `publications[]` | — | keep in `publications[]`; `artifactRefs` to the artifact |
| Press / review | `press[]` | — | `artifactRefs` to the film |
| Union/guild membership | `credentials[]` | `certificate` | `expires` if it renews — the expiry check will remind you |

Notes: the pattern is **`url` for anything video**. A 2 GB reel in git is the
single most common way people wreck a workspace. Festival selections are
`award` credentials — they are third-party attestations, which is exactly the
definition.

## Scientist / researcher

| What you have | Block | Kind | Metadata worth filling |
|---|---|---|---|
| Peer-reviewed paper | `publications[]` | — | `doi` + `orcidId` — the resolvable anchors |
| Dataset you published | `artifacts[]` | `dataset` | `locator.url` (Zenodo/Figshare DOI), **`checksum`** — datasets are immutable, this is the integrity promise |
| Code / replication package | `artifacts[]` | `code` | `locator.url` (repo or archived DOI), `license` |
| Conference talk / poster | `artifacts[]` | `document` | `issued`-style info in `description`; host the PDF and use `url` |
| PhD / degree | `credentials[]` | `title` | `issuer` = university, `issued`; `credentialId` only if you want it public |
| Grant / fellowship | `credentials[]` | `award` or `certificate` | `issuer` = funder, `expires` for time-boxed fellowships |
| Patent | `credentials[]` | `patent` | `credentialId` = patent number, `verifyUrl` = patent office record |

Notes: DOIs and ORCIDs are your highest-value anchors — they're resolvable and
machine-readable, which is what makes you citable. For datasets, **always**
declare `checksum`: it is the difference between "I published this" and "this
exact file is what I published".

## Engineer

| What you have | Block | Kind | Metadata worth filling |
|---|---|---|---|
| Open-source repo / demo | `artifacts[]` | `code` | `locator.url`, `license` (**required reading** for third-party deps), `tags` |
| Live product / demo | `artifacts[]` | `portfolio` | `locator.url` — the live-link check will keep it honest |
| Technical certification | `credentials[]` | `certificate` | `credentialId`, `verifyUrl`, `issued`, **`expires`** — cloud certs expire, and the check warns you |
| Patent | `credentials[]` | `patent` | `credentialId`, `verifyUrl` |
| Conference talk | `artifacts[]` | `document` | host slides/video → `url` |
| Award / hackathon win | `credentials[]` | `award` | `issuer`, `issued` |

Notes: the `expires` field on certifications is the highest-value optional
field in this whole registry — `pasco check` warns before a lapsed cert
embarrasses you on a live profile.

---

## Metadata cheat sheet

| Field | On | Why bother |
|---|---|---|
| `id` | both | Stable reference + the `assets/<id>/` bundle target. Keep it a slug. |
| `verifyUrl` | credentials | THE verification pointer — the one link a skeptic clicks |
| `issued` / `expires` | credentials | `expires` triggers the expiry check |
| `locator.url` | artifacts | Emitted verbatim + live-link checked |
| `locator.path` | artifacts | Local bytes → bundled to `assets/`, never hot-linked |
| `checksum` | artifacts | Integrity promise — use it for immutable files |
| `license` | artifacts | Usage rights; matters the moment someone reuses your work |
| `tags` | artifacts | Multi-area selection (one workspace, several fields) |
| `description` | artifacts | Bilingual (`en` required, `es` native) — GEO consistency |

## Privacy first

Credentials carry PII: full legal names, certificate serials, ID numbers.
`visibility: private` means exactly that — the file stays in your workspace and
renderers emit nothing. `pasco check` **fails the build**
(`no-private-in-public-output`) if a public artifact or claim references private
material, so a leak is caught before it deploys rather than after.

Ask of each entry: *would I paste this on a public profile?* If not →
`unlisted` or `private`. That decision is yours, and it is cheap to make at
entry time and expensive to walk back after a deploy.

## Adding your first entry

```bash
# 1. put small files in media/, big ones on a host you control
cp ~/scans/aws-ml.pdf media/certificates/

# 2. add the pointer in content/credentials.yaml (or artifacts.yaml)
# 3. verify
pasco validate    # schema (fails) + drift/geo (warns)
pasco check        # expiry, privacy, media transport
pasco build github-readme   # bundles assets/, writes the manifest
```

Per-platform rendering guidance lives in the engine's `skills/<platform>/`.
