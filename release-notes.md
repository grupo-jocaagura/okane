### Added

- Added explicit Android `dev`, `qa`, and `prod` product flavors with isolated
  application identities for non-production environments.
- Added environment-aware Android BUILD resolution using GitHub Environments.
- Added ephemeral Android signing reconstruction and canonical certificate
  verification for DEV, QA, and PROD.
- Added signed environment-specific Android artifact generation.
- Added SHA-256 integrity verification and internal build provenance manifests.
- Added verified GitHub Artifact persistence for certified Android build outputs.

### Changed

- Separated Android environment identity from `debug` and `release` build types.
- Bound Android BUILD execution to the exact authorized source SHA.
- Defined `develop` as the source authority for DEV/QA builds and `master` as
  the source authority for PROD builds.
- Documented the repository VERIFY → VERSION → BUILD → PUBLISH publication
  discipline.

### Quality

- Certified DEV and QA Android identities coexisting on the same device.
- Certified environment-specific signing identities and private-key usability.
- Certified signed DEV and QA release APK generation.
- Certified artifact application identity, version metadata, signature, and
  canonical signer.
- Certified artifact checksum, provenance, source binding, signing binding,
  and immutability.
- Certified persisted GitHub Artifacts by downloading and re-verifying the
  uploaded binary, checksum, and provenance manifest.
- Verified that PROD BUILD fails closed when requested from `develop`.
