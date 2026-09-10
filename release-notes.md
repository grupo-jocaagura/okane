### Added

- Added controlled virtual amount input for income and expense forms.
- Added a dedicated virtual numeric keyboard for monetary amounts, preventing
  unsupported characters from being entered through the native keyboard.
- Added formatted amount magnification while editing, preserving Colombian
  accounting presentation with two decimal places.
- Added explicit Android `dev`, `qa`, and `prod` product flavors with isolated
  application identities.
- Added environment-aware Android BUILD resolution using GitHub Environments.
- Added ephemeral Android signing reconstruction with canonical certificate
  and private-key verification.
- Added signed environment-specific Android artifact generation.
- Added SHA-256 artifact integrity verification and internal BUILD provenance.
- Added verified GitHub Artifact persistence with download and content
  re-verification.
- Added final Android App Bundle analysis using a pinned and verified
  `bundletool`.

### Changed

- Separated Android environment identity from `debug` and `release` build
  types.
- Bound Android BUILD execution to the exact authorized source SHA.
- Defined `develop` as the source authority for DEV and QA builds and `master`
  as the source authority for PROD builds.
- Production AAB identity and version metadata are now verified from the
  generated bundle instead of being accepted only by BUILD contract.
- Formalized the repository publication sequence around the independent
  VERIFY, VERSION, BUILD, and PUBLISH boundaries.

### Fixed

- Prevented native keyboard input from interfering with controlled monetary
  amount entry.
- Preserved the entered amount when confirming or dismissing the controlled
  amount editor.
- Ensured Android signing material remains ephemeral and outside repository
  state throughout BUILD.

### Quality

- Certified DEV and QA applications coexisting on the same Android device.
- Certified environment-specific Android signing identities and private-key
  usability.
- Certified signed DEV and QA release APK generation.
- Certified application identity, version metadata, artifact signatures, and
  canonical signers.
- Certified artifact checksums, provenance, source binding, signing binding,
  and immutability.
- Certified GitHub Artifact persistence by downloading and re-verifying the
  uploaded binary, checksum, and provenance manifest.
- Certified PROD BUILD from `master` using the Google Play Upload Key.
- Added structural and manifest-level validation of the final production AAB
  before provenance and persistence.