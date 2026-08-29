# Version Preparation

`prepare_version.yaml` is the canonical VERSION preparation workflow for Okane.

Its responsibility is limited to preparing a deterministic and homologated
project version on the `develop` branch.

It does **not** build, sign, tag, publish, or deploy artifacts.

---

## Pipeline position

The Jocaagura development pipeline separates responsibilities into four
boundaries:

```text
VERIFY
   ↓
VERSION
   ↓
BUILD
   ↓
PUBLISH
```

### VERIFY

Certifies repository quality:

* verified commits;
* no `dependency_overrides`;
* Dart format;
* strict analyzer;
* tests;
* coverage gate.

### VERSION

Prepares the canonical project version:

* SemVer;
* build number;
* CHANGELOG;
* monotonicity;
* idempotency.

### BUILD

Produces platform-specific artifacts.

Examples:

* Android AAB/APK;
* iOS IPA/archive;
* Web build;
* package artifacts.

### PUBLISH

Publishes an already built artifact to a destination.

Examples:

* Google Play;
* App Store;
* pub.dev;
* hosting/deployment targets.

`prepare_version.yaml` belongs exclusively to **VERSION**.

---

# Authority

The only branch that VERSION is allowed to mutate is:

```text
develop
```

The destination branch is fixed by the workflow contract and cannot be
provided as user input.

`master` must never be versioned by this workflow.

A version reaches `master` only through the normal repository promotion
process after it has already been prepared and homologated in `develop`.

---

# Human authorization

Version preparation is manually authorized through:

```yaml
workflow_dispatch
```

The person executing the workflow explicitly supplies:

```text
version
changelog_base64
```

Example:

```text
version:
1.12.0+6
```

The human operator prepares the canonical Markdown release notes in a local file.
The file is encoded as Base64 only for transport through `workflow_dispatch`.
VERSION decodes it back to UTF-8 Markdown before validation and homologation.

Base64 is a transport mechanism only.
It does not change the release-note authority or canonical content.

The workflow does not infer whether a contribution is:

* patch;
* minor;
* major.

That decision belongs to the human release authority.

The workflow validates and materializes the declared intent.

---

# Version format

Okane uses the Flutter version contract:

```yaml
version: X.Y.Z+N
```

Example:

```yaml
version: 1.12.0+6
```

Where:

```text
1.12.0 → SemVer
6      → build number
```

Both values are part of the VERSION contract.

The target version must have:

```text
target SemVer > current SemVer
```

and:

```text
target build number > current build number
```

A lower version or build number is rejected.

---

# CHANGELOG contract

Development contributions accumulate under:

```markdown
## Unreleased
```

Example:

```markdown
## Unreleased

### Added

- Added controlled amount entry.

### Changed

- Refactored CI validation.
```

When VERSION is prepared, the workflow receives the canonical release notes
explicitly in `changelog_base64`, decodes it as UTF-8 Markdown, and then
validates/homologates it.

The human operator owns the release-note content.

VERSION owns:

* the version heading;
* the release date;
* the placement of the block;
* preservation of `## Unreleased`;
* prevention of duplicate release blocks.

The supplied changelog input must therefore contain only the release content.

Do not include:

```markdown
## Unreleased
```

or:

```markdown
## [1.12.0] - 2026-08-29
```

inside the workflow input.

The workflow generates the canonical release heading.

Example result:

```markdown
## Unreleased

## [1.12.0] - 2026-08-29

### Added

- Added controlled virtual amount input.

### Changed

- Added deterministic CI version preparation.
```

---

# Preconditions

Before preparing a version:

1. The contribution must already be present in `develop`.
2. Repository VERIFY checks must be healthy.
3. `pubspec.yaml` must contain a valid Flutter version:

   ```text
   X.Y.Z+N
   ```
4. `CHANGELOG.md` must contain exactly one:

   ```markdown
   ## Unreleased
   ```
5. `Unreleased` must contain material contribution notes.
6. `changelog_base64` must decode successfully as UTF-8.
7. The decoded Markdown must contain at least one level-3 section (`### ...`).
8. The target SemVer must be greater than the current SemVer.
9. The target build number must be greater than the current build number.
10. The build number must respect any previously homologated publication
    number for the target platform.

---

# Running the workflow

## GitHub UI

Open:

```text
GitHub
→ Actions
→ Prepare version
→ Run workflow
```

Provide:

```text
version
```

using:

```text
X.Y.Z+N
```

and provide the canonical Markdown release block in:

```text
changelog_base64
```

Generate:

```bash
base64 < release-notes.md | tr -d '\n'
```

then paste the output in:

```text
changelog_base64
```

---

## GitHub CLI

For multiline release notes, using a file is recommended.

Example `release-notes.md`:

```markdown
### Added

- Added controlled virtual amount input.
- Added deterministic version preparation.

### Changed

- Unified reusable validation workflows.
```

Run:

```bash
NOTES_BASE64="$(base64 < release-notes.md | tr -d '\n')"

gh workflow run prepare_version.yaml \
  --ref develop \
  -f version='1.12.0+7' \
  -f changelog_base64="$NOTES_BASE64"
```

The workflow always mutates `develop`, regardless of the caller context.

---

# Version states

VERSION is fail-closed.

The workflow classifies the repository before performing mutations.

## NEW_PREPARATION

A valid new version can be prepared.

Example:

```text
current: 1.11.1+5
target:  1.12.0+6
```

Expected result:

```text
VERSION_PREPARED
```

---

## VERSION_ALREADY_PREPARED

The exact version and canonical changelog block already exist.

Example:

```text
current: 1.12.0+6
target:  1.12.0+6
```

with the same homologated release notes.

Expected result:

```text
VERSION_ALREADY_PREPARED
```

This is a successful no-op.

No commit is created.

---

## VERSION_REGRESSION

The target SemVer is lower than the current version.

Expected result:

```text
FAIL
```

---

## BUILD_REGRESSION

The new release does not increase the build number.

Expected result:

```text
FAIL
```

---

## VERSION_REBUILD_UNSUPPORTED

The target keeps the same SemVer while changing only the build number.

Example:

```text
1.12.0+6
→
1.12.0+7
```

This workflow does not support this scenario in its current contract.

Expected result:

```text
FAIL
```

---

## VERSION_STATE_INCONSISTENT

The repository contains a contradictory or partially prepared state.

Examples:

* `pubspec.yaml` already points to the target version but CHANGELOG does not;
* CHANGELOG already contains the target release while `pubspec.yaml` is older;
* the target version exists more than once;
* the same version exists with different canonical release notes.

Expected result:

```text
FAIL
```

VERSION does not automatically repair inconsistent repository states.

---

## CHANGELOG_INPUT_INVALID

The canonical release-notes input cannot be decoded or validated.

This includes:

* Base64 decode failure.
* Invalid UTF-8 decoding.
* Empty decoded content.
* Missing minimum structure (no `### ...` level-3 section).

Expected result:

```text
FAIL
```

---

# Atomic materialization

A successful new preparation modifies exactly:

```text
pubspec.yaml
CHANGELOG.md
```

Both files are written through a single GitHub commit using
`createCommitOnBranch`.

The workflow uses the current `develop` HEAD as:

```text
expectedHeadOid
```

If `develop` changes between validation and commit creation, the operation
must fail instead of overwriting concurrent work.

This provides optimistic concurrency protection.

---

# Commit verification

The version commit is materialized by GitHub Actions.

The human operator authorizes:

```text
version + changelog_base64
```

GitHub Actions performs the repository mutation.

The resulting commit must be:

```text
GitHub Verified
```

The workflow verifies this as a postcondition.

The summary must distinguish:

```text
Human authority
→ who authorized the VERSION intent

Automated authority
→ workflow that validated it

Materialization authority
→ GitHub-signed commit
```

---

# Summary

Every execution writes a concise GitHub Actions summary.

Example:

```text
Version Preparation

Status              ✅ VERSION_PREPARED
Target branch       develop

Authorization
Requested by         @user
Triggered by         @user
Workflow attempt     1

Version
Previous             1.11.1+5
Target               1.12.0+6
SemVer monotonic     ✅
Build monotonic      ✅

CHANGELOG
Canonical notes      ✅
Version block        1.12.0
Release date         2026-08-29

Materialization
Mutation             atomic commit
Commit               <sha>
Signature            ✅ GitHub Verified

Idempotency
State                NEW_PREPARATION
```

For an exact rerun:

```text
Status               ✅ VERSION_ALREADY_PREPARED
Mutation             none
```

---

# Idempotency

Running the same VERSION preparation more than once must never result in
additional mutations.

An exact rerun must not:

* increment the build number;
* create another CHANGELOG block;
* create another commit;
* modify release notes;
* change the release date.

The expected result is:

```text
VERSION_ALREADY_PREPARED
```

---

# Development workflow

The expected team workflow is:

```text
feature / contribution branch
          │
          ▼
        VERIFY
          │
          ▼
      PR → develop
          │
          ▼
        develop
          │
          ▼
    prepare_version
          │
          ▼
  VERSION_PREPARED
```

When a version is ready for promotion:

```text
develop
   │
   ▼
PR → master
   │
   ▼
master
```

`master` receives an already homologated version.

Future BUILD and PUBLISH workflows will operate from that boundary.

---

# Responsibilities intentionally excluded

VERSION does not:

* infer patch/minor/major;
* execute product tests or coverage gates;
* create Git tags;
* create GitHub Releases;
* build APK;
* build AAB;
* build IPA;
* build Web artifacts;
* sign application artifacts;
* publish to Google Play;
* publish to App Store;
* deploy Web applications;
* publish packages.

These responsibilities belong to other pipeline boundaries.

---

# Operational rule

If VERSION cannot prove that the repository state is coherent, monotonic,
idempotent and authorized:

```text
do not mutate develop
```

Failing safely is preferable to automatically repairing or guessing the
intended version state.

```
```
