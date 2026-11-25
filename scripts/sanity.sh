#!/usr/bin/env bash
set -u
I=ghcr.io/mayanksekhar/distroless-java/zulu:25
F=0
ok(){ echo "PASS  $1"; }
bad(){ echo "FAIL  $1"; F=1; }

docker logout ghcr.io >/dev/null 2>&1
docker pull -q "$I" >/dev/null 2>&1 && ok "anonymous pull" || bad "anonymous pull"

docker run --rm "$I" -version 2>&1 | grep -q "Zulu25.38" && ok "runs, Zulu 25.38" || bad "runs"

docker image inspect "$I" --format '{{.Config.User}}' | grep -q 65532 && ok "default user is 65532" || bad "default user"

docker run --rm --entrypoint /bin/sh "$I" -c true >/dev/null 2>&1 && bad "shell present" || ok "no shell in image"

M=$(docker buildx imagetools inspect "$I" 2>/dev/null)
echo "$M" | grep -q "linux/amd64" && echo "$M" | grep -q "linux/arm64" && ok "amd64 and arm64 in manifest" || bad "platforms"
[ "$(echo "$M" | grep -c 'unknown/unknown')" -ge 2 ] && ok "SBOM and provenance attestations attached" || bad "attestations"

cosign verify "$I" \
  --certificate-identity-regexp 'https://github.com/mayanksekhar/distroless-java/' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com >/dev/null 2>&1 \
  && ok "cosign signature verifies" || bad "cosign"

trivy image -q --skip-version-check --severity HIGH,CRITICAL --ignore-unfixed --ignorefile "$(git rev-parse --show-toplevel)"/.trivyignore --exit-code 1 "$I" >/dev/null 2>&1 \
  && ok "trivy HIGH and CRITICAL gate" || bad "trivy gate"

OUT=$(docker run --rm -v "$(git rev-parse --show-toplevel)"/t:/t:Z,ro "$I" -cp /t Hello 2>&1)
echo "$OUT" | grep -q "user.name=nonroot" && echo "$OUT" | grep -q "sha256 ok=true" && echo "$OUT" | grep -q "https status=" \
  && ok "real Java program runs (nonroot, crypto, TLS)" || bad "real program"

python3 - <<'PYEOF' && ok "pinned SHA256s match Azul's published values" || bad "pinned checksums"
import json, os, sys, urllib.request as u
base = "https://api.azul.com/metadata/v1/zulu/packages/"
wf = open(os.path.expanduser(""$(git rev-parse --show-toplevel)"/.github/workflows/build.yml")).read()
rel = "zulu25.38.201-ca-jre25.0.5.1"
for arch in ("x64", "aarch64"):
    q = f"?java_version=25&os=linux&arch={arch}&archive_type=tar.gz&java_package_type=jre&javafx_bundled=false&latest=true&release_status=ga"
    for p in json.load(u.urlopen(base + q)):
        if p["name"] == f"{rel}-linux_{arch}.tar.gz":
            sha = json.load(u.urlopen(base + p["package_uuid"]))["sha256_hash"]
            if sha not in wf:
                sys.exit(1)
            break
    else:
        sys.exit(1)
PYEOF

echo "size: $(docker image inspect "$I" --format '{{.Size}}') bytes"
[ "$F" -eq 0 ] && echo "ALL CHECKS PASSED" || echo "SOME CHECKS FAILED"
