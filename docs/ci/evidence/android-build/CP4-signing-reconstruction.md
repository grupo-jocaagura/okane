# CP-4 — Ephemeral Android Signing Reconstruction

## Objective

Certify that the Android BUILD workflow can reconstruct and validate the
environment-specific signing identity without persisting signing material,
modifying the repository, or generating Android artifacts.

The checkpoint validates:

```text
GitHub Environment
        ↓
canonical BUILD profile
        ↓
exact authorized source SHA
        ↓
environment signing variables + secrets
        ↓
ephemeral keystore reconstruction
        ↓
certificate identity verification
        ↓
private-key usability probe
        ↓
cleanup
````

Artifact generation remains explicitly outside this checkpoint.

---

## Canonical signing identities

### DEV

```text
Environment: dev
Source branch: develop
Android flavor: dev
applicationId: co.com.okane.okane.dev
Artifact policy: apk

Alias:
okane-dev

SHA-1:
B9:12:6E:1F:BD:69:74:40:31:25:24:FA:C6:62:96:5A:38:08:94:EC

SHA-256:
4B:C2:62:50:DA:A2:49:3D:41:1D:7F:2D:BD:21:25:18:90:EF:7B:55:94:FB:3C:6B:93:FA:77:D4:E6:C1:0B:A2
```

### QA

```text
Environment: qa
Source branch: develop
Android flavor: qa
applicationId: co.com.okane.okane.qa
Artifact policy: apk

Alias:
okane-qa

SHA-1:
08:C2:2B:9B:4E:1D:B3:F9:0B:67:E3:4E:1F:07:D4:09:2A:83:DF:77

SHA-256:
4B:98:74:79:A8:60:2B:C2:D3:A5:1A:4A:F0:EE:3E:E0:35:FE:58:07:74:66:5C:3A:61:D6:26:CC:82:88:C1:E5
```

### PROD

The production signing identity is the Google Play Upload Key.

Positive PROD signing reconstruction is intentionally deferred until the
workflow is promoted to and executed from `master`.

---

## CP4-A — DEV signing reconstruction

**Result:** PASS

```text
Status:
ANDROID_SIGNING_RECONSTRUCTED

Environment:
dev

Trigger ref:
develop

Trigger SHA:
22cd8fc18c4cca30d7ca5511590c100d96e4d8b4

Source SHA:
22cd8fc18c4cca30d7ca5511590c100d96e4d8b4

Android flavor:
dev

OKANE_ENV:
dev

applicationId:
co.com.okane.okane.dev

Artifact policy:
apk
```

Signing evidence:

```text
Alias                     okane-dev
SHA-1                     MATCH
SHA-256                   MATCH
Certificate identity      PASS
Private-key probe         PASS
Ephemeral cleanup         PASS
Repository state          ANDROID_REPOSITORY_CLEAN
```

Execution boundary:

```text
Repository mutation          none
Signing material persistence none
APK generation               not executed
AAB generation               not executed
Artifact upload              not executed
```

### Initial negative discovery

The first DEV execution failed with:

```text
ANDROID_SIGNING_IDENTITY_MISMATCH
```

because the GitHub Environment still contained placeholder signing
fingerprints.

After replacing the placeholders with the canonical DEV fingerprints, the
same BUILD source state completed successfully.

This demonstrates that signing identity validation fails closed before artifact
generation when the configured GitHub Environment identity does not match the
repository-owned canonical contract.

---

## CP4-B — QA signing reconstruction

**Result:** PASS

```text
Status:
ANDROID_SIGNING_RECONSTRUCTED

Environment:
qa

Trigger ref:
develop

Trigger SHA:
22cd8fc18c4cca30d7ca5511590c100d96e4d8b4

Source SHA:
22cd8fc18c4cca30d7ca5511590c100d96e4d8b4

Android flavor:
qa

OKANE_ENV:
qa

applicationId:
co.com.okane.okane.qa

Artifact policy:
apk
```

Signing evidence:

```text
Alias                     okane-qa
SHA-1                     MATCH
SHA-256                   MATCH
Certificate identity      PASS
Private-key probe         PASS
Ephemeral cleanup         PASS
Repository state          ANDROID_REPOSITORY_CLEAN
```

Execution boundary:

```text
Repository mutation          none
Signing material persistence none
APK generation               not executed
AAB generation               not executed
Artifact upload              not executed
```

---

## CP4-C — Signing identity mismatch guardrail

**Environment:** QA
**Result:** PASS — expected failure observed

The QA environment SHA-256 fingerprint was temporarily altered from the
canonical value.

Expected:

```text
ANDROID_SIGNING_IDENTITY_MISMATCH
```

Observed:

```text
ANDROID_SIGNING_IDENTITY_MISMATCH
```

The workflow failed closed before artifact generation.

Expected execution boundary remained intact:

```text
APK generation       not executed
AAB generation       not executed
Artifact upload      not executed
```

The canonical QA fingerprint must be restored after this test.

---

## Current certification state

| Check                                      | Result   |
| ------------------------------------------ | -------- |
| DEV canonical profile                      | PASS     |
| DEV signing reconstruction                 | PASS     |
| DEV certificate identity                   | PASS     |
| DEV private-key usability                  | PASS     |
| DEV ephemeral cleanup                      | PASS     |
| QA canonical profile                       | PASS     |
| QA signing reconstruction                  | PASS     |
| QA certificate identity                    | PASS     |
| QA private-key usability                   | PASS     |
| QA ephemeral cleanup                       | PASS     |
| QA identity-mismatch guardrail             | PASS     |
| Repository immutability                    | PASS     |
| Artifact generation prevented              | PASS     |
| QA restoration after negative test         | PASS     |
| PROD blocked from `develop` during CP-4    | PASS     |
| PROD positive reconstruction from `master` | DEFERRED |

---

## Security properties demonstrated

The checkpoint currently demonstrates that:

* signing secrets are scoped through GitHub Environments;
* the repository owns the expected signing identity contract;
* environment variables cannot silently redefine the canonical certificate;
* the reconstructed keystore must contain the expected certificate;
* the configured private-key password must unlock a usable private key;
* temporary signing material is removed after successful validation;
* signing reconstruction does not modify the checked-out repository;
* no APK or AAB is generated during CP-4;
* no signing secret is exposed in the workflow summary.

---

## Remaining CP-4 certification

Before closing CP-4:

1. Restore the canonical QA SHA-256 fingerprint.

2. Re-run `develop + qa`.

3. Confirm:

   ```text
   ANDROID_SIGNING_RECONSTRUCTED
   ```

4. Execute `develop + prod`.

5. Confirm that source authorization fails before signing:

   ```text
   ANDROID_SOURCE_REF_INVALID
   ```

6. Confirm signing reconstruction is not executed for PROD from `develop`.

Positive PROD signing reconstruction remains deferred until the workflow exists
on `master`.

---

## Exit criteria

CP-4 can be declared certified when:

```text
DEV signing reconstruction          PASS
QA signing reconstruction           PASS
Identity mismatch guardrail         PASS
QA restoration                      PASS
PROD blocked from develop           PASS

Repository mutation                 NONE
Signing material persistence        NONE
APK generation                      NOT EXECUTED
AAB generation                      NOT EXECUTED
Artifact upload                     NOT EXECUTED
```

Final state:

```text
CP-4 — CERTIFIED
```

Once certified, Android BUILD may proceed to:

```text
CP-5 — Signed environment-specific artifact generation
```