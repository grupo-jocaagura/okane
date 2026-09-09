# CP-5 — Signed Environment-Specific Artifact Generation

## Objective

Certify that Android BUILD can generate the correct signed release artifact for
each authorized environment while preserving:

- canonical source authority;
- exact source SHA;
- version authority;
- environment-specific Android identity;
- canonical signing identity;
- ephemeral signing material;
- repository immutability.

Artifact persistence and publication remain outside this checkpoint.

---

## Certified source

```text
Trigger ref:
develop

Source SHA:
9286f380403cb78676ef924ccba42761c6342d15

Flutter version:
1.12.0+7

SemVer:
1.12.0

Build number:
7
````

---

## CP5-A — DEV signed APK

**Result:** PASS

```text
Status:
ANDROID_ARTIFACT_GENERATED

Environment:
dev

Source branch:
develop

Source SHA:
9286f380403cb78676ef924ccba42761c6342d15

Android flavor:
dev

OKANE_ENV:
dev

applicationId:
co.com.okane.okane.dev

Artifact policy:
apk
```

### Signing

```text
Alias:
okane-dev

SHA-1:
B9:12:6E:1F:BD:69:74:40:31:25:24:FA:C6:62:96:5A:38:08:94:EC

SHA-256:
4B:C2:62:50:DA:A2:49:3D:41:1D:7F:2D:BD:21:25:18:90:EF:7B:55:94:FB:3C:6B:93:FA:77:D4:E6:C1:0B:A2
```

Validation:

```text
Certificate identity      PASS
Private-key probe         PASS
Ephemeral cleanup         PASS
```

### Artifact

```text
Type:
APK

Path:
build/app/outputs/flutter-apk/app-dev-release.apk

Size:
51989111 bytes
```

Artifact validation:

```text
applicationId             PASS
Version metadata          PASS
Signature                 PASS
Canonical signer          PASS
```

Execution boundary:

```text
Repository                ANDROID_REPOSITORY_CLEAN
Repository mutation       none
Signing persistence       none
GitHub Artifact upload    not executed
Publication               not executed
```

---

## CP5-B — QA signed APK

**Result:** PASS

```text
Status:
ANDROID_ARTIFACT_GENERATED

Environment:
qa

Source branch:
develop

Source SHA:
9286f380403cb78676ef924ccba42761c6342d15

Android flavor:
qa

OKANE_ENV:
qa

applicationId:
co.com.okane.okane.qa

Artifact policy:
apk
```

### Signing

```text
Alias:
okane-qa

SHA-1:
08:C2:2B:9B:4E:1D:B3:F9:0B:67:E3:4E:1F:07:D4:09:2A:83:DF:77

SHA-256:
4B:98:74:79:A8:60:2B:C2:D3:A5:1A:4A:F0:EE:3E:E0:35:FE:58:07:74:66:5C:3A:61:D6:26:CC:82:88:C1:E5
```

Validation:

```text
Certificate identity      PASS
Private-key probe         PASS
Ephemeral cleanup         PASS
```

### Artifact

```text
Type:
APK

Path:
build/app/outputs/flutter-apk/app-qa-release.apk

Size:
51989107 bytes
```

Artifact validation:

```text
applicationId             PASS
Version metadata          PASS
Signature                 PASS
Canonical signer          PASS
```

Execution boundary:

```text
Repository                ANDROID_REPOSITORY_CLEAN
Repository mutation       none
Signing persistence       none
GitHub Artifact upload    not executed
Publication               not executed
```

---

## CP5-C — PROD source authorization guardrail

**Result:** PASS — expected failure observed

Execution:

```text
Trigger ref:
develop

Environment:
prod
```

Expected:

```text
ANDROID_SOURCE_REF_INVALID
```

Observed:

```text
ANDROID_SOURCE_REF_INVALID
```

The workflow failed before:

```text
version resolution
signing reconstruction
artifact generation
artifact upload
publication
```

This confirms that the PROD profile cannot consume signing material or generate
a production artifact when BUILD is dispatched from `develop`.

---

## Certification matrix

| Check                         | Result       |
| ----------------------------- | ------------ |
| DEV canonical source          | PASS         |
| DEV signed APK generation     | PASS         |
| DEV applicationId             | PASS         |
| DEV version metadata          | PASS         |
| DEV artifact signature        | PASS         |
| DEV canonical signer          | PASS         |
| QA canonical source           | PASS         |
| QA signed APK generation      | PASS         |
| QA applicationId              | PASS         |
| QA version metadata           | PASS         |
| QA artifact signature         | PASS         |
| QA canonical signer           | PASS         |
| Ephemeral signing cleanup     | PASS         |
| Repository immutability       | PASS         |
| PROD blocked from `develop`   | PASS         |
| PROD signed AAB from `master` | DEFERRED     |
| GitHub Artifact upload        | NOT EXECUTED |
| Publication                   | NOT EXECUTED |

---

## Exit state

```text
CP-5 — CERTIFIED
```

Positive PROD artifact generation remains intentionally deferred until the
BUILD workflow is promoted to `master`.

The next checkpoint may proceed with artifact integrity and provenance.
