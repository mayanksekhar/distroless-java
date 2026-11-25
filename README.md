# zulu-distroless

Unofficial distroless image for the Zulu OpenJDK 25 JRE, built in response to
AzulSystems/azul-zulu-images issue 1.

This project is not affiliated with or endorsed by Azul. Zulu is a trademark of
Azul Systems. The Dockerfile in this repository is BSD 3 Clause. The image
contains the Zulu JRE, which is licensed by its upstream authors (GPLv2 with
the Classpath Exception).

## What it is

- Zulu JRE 25 from cdn.azul.com, pinned to one release and verified against
  the SHA256 that Azul publishes through its metadata API
- Base: gcr.io/distroless/cc-debian13:nonroot (no shell, no package manager)
- Runs as uid 65532
- Platforms: linux/amd64 and linux/arm64
- Every build runs a Trivy gate, produces an SBOM and provenance attestation,
  and is signed with keyless Cosign

## Use

    docker run --rm ghcr.io/mayanksekhar/zulu-distroless:25 -version

    FROM ghcr.io/mayanksekhar/zulu-distroless:25
    COPY app.jar /app/app.jar
    CMD ["-jar", "/app/app.jar"]

## Verify

    cosign verify ghcr.io/mayanksekhar/zulu-distroless:25 \
      --certificate-identity-regexp 'https://github.com/mayanksekhar/zulu-distroless/' \
      --certificate-oidc-issuer https://token.actions.githubusercontent.com
