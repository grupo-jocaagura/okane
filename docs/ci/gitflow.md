# Publication Flow (GitFlow)

This document describes the team’s release sequence for preparing and publishing changes.

1. Open the corresponding issue describing the requested work.

2. Create the contribution branch using the format:

   ```text
   feature/<issue_number>-<slug>
   ```

   Example:

   ```text
   feature/123-monthly-report
   ```

3. Add the relevant contribution notes to the `## Unreleased` section in `CHANGELOG.md`.

   `Unreleased` is the staging area for changes that have not yet been homologated into a VERSION.

4. Open a PR to `develop` and ensure all repository quality gates pass.

   The VERIFY boundary includes, as applicable:

   ```text
   verified commits
   dependency_overrides gate
   Dart format
   strict analyzer
   tests
   coverage
   ```

5. Merge the contribution into `develop`.

   Do not run VERSION preparation from a feature branch.

   `develop` is the canonical source used by the VERSION workflow.

6. When the current state of `develop` is ready to become a homologated version:

   - Prepare the canonical release-notes block.

   - Run the `prepare_version` GitHub Action.

   - Provide `version` using the Flutter version contract:

     ```text
     X.Y.Z+N
     ```

   - Provide the canonical release-notes block encoded as Base64 through:

     ```text
     changelog_base64
     ```

   Example release notes:

   ```markdown
   ### Added

   - Added monthly financial reports.

   ### Changed

   - Improved report navigation.
   ```

   Encode the file:

   ```bash
   NOTES_BASE64="$(base64 < release-notes.md | tr -d '\n')"
   ```

   Then execute:

   ```bash
   gh workflow run prepare_version.yaml \
     --ref develop \
     -f version='1.12.0+7' \
     -f changelog_base64="$NOTES_BASE64"
   ```

   The GitHub UI may also be used by pasting the generated Base64 value into `changelog_base64`.

7. Verify the VERSION evidence produced by the workflow.

   The expected result for a new version is:

   ```text
   VERSION_PREPARED
   ```

   Verify at minimum:

   ```text
   previous version
   target version
   SemVer monotonicity
   build-number monotonicity
   CHANGELOG homologation
   resulting commit SHA
   GitHub Verified signature
   ```

   Also verify that:

   ```text
   pubspec.yaml
   CHANGELOG.md
   ```

   contain the expected homologated VERSION state.

8. VERSION preparation is idempotent.

   Re-running the workflow with the exact same:

   ```text
   version
   changelog_base64
   ```

   must result in:

   ```text
   VERSION_ALREADY_PREPARED
   ```

   with:

   ```text
   no new commit
   no build-number change
   no duplicated CHANGELOG block
   no repository mutation
   ```

9. After VERSION is prepared, do not manually modify:

   ```text
   pubspec.yaml version
   homologated CHANGELOG release block
   ```

   Any inconsistency must be treated explicitly rather than silently repaired by BUILD or PUBLISH.

10. Open a PR from `develop` to `master`.

    `master` does not decide or prepare VERSION.

    It only receives an already homologated repository state through the normal promotion process.

11. Wait for the destination quality gates to pass and merge the PR.

    The resulting `master` SHA becomes the canonical source for subsequent BUILD operations.

12. Platform-specific BUILD and PUBLISH workflows begin only after promotion to `master`.

    Conceptually:

    ```text
    feature
       ↓
    VERIFY
       ↓
    develop
       ↓
    VERSION
       ↓
    PR → master
       ↓
    master SHA
       ↓
    BUILD
       ↓
    certified artifact
       ↓
    PUBLISH
    ```

## Rules

- VERIFY validates contributions and does not version them.
- VERSION can mutate only `develop`.
- VERSION never infers whether a release is patch, minor, or major.
- The human operator supplies the complete target version and canonical release notes.
- `pubspec.yaml` is the version authority using `X.Y.Z+N`.
- `CHANGELOG.md` is the release-history authority.
- Base64 is only a lossless transport mechanism for the release-notes payload.
- `master` receives already prepared versions and must not perform version bumps.
- BUILD consumes the exact homologated `master` SHA and must not modify VERSION state.
- PUBLISH consumes an already certified artifact and must not rebuild or re-version it.
- A failure to prove repository consistency must fail closed rather than guess or repair state automatically.
