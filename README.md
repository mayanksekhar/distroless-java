# distroless-java

Signed, multi arch distroless Java runtime images, built from vendor binaries
that are verified against published checksums. The first image is the Zulu JRE
25, created in response to AzulSystems/azul-zulu-images issue 1.

These images are unofficial and not affiliated with or endorsed by Azul. Zulu
is a trademark of Azul Systems. The files in this repository are BSD 3 Clause.
The images contain the vendor JRE, which is licensed by its upstream authors
(GPLv2 with the Classpath Exception).

## Images

| Image | Tags | Platforms |
| --- | --- | --- |
| ghcr.io/mayanksekhar/distroless-java/zulu | 25, 25.0.5.1 | linux/amd64, linux/arm64 |

Base is gcr.io/distroless/cc-debian13:nonroot. There is no shell and no package
manager, and the process runs as uid 65532. Every build runs a smoke test and a
Trivy gate, produces an SBOM and provenance attestation, and is signed with
keyless Cosign. A scheduled rebuild runs weekly.

## Use

    docker run --rm ghcr.io/mayanksekhar/distroless-java/zulu:25 -version

    FROM ghcr.io/mayanksekhar/distroless-java/zulu:25
    COPY app.jar /app/app.jar
    CMD ["-jar", "/app/app.jar"]

## Verify

    cosign verify ghcr.io/mayanksekhar/distroless-java/zulu:25 \
      --certificate-identity-regexp 'https://github.com/mayanksekhar/distroless-java/' \
      --certificate-oidc-issuer https://token.actions.githubusercontent.com

## Request an image

Open an issue with the vendor, the Java major version and the variant you need.
New images are added to the build matrix in .github/workflows/build.yml.

## Licensing and source

The JRE is Azul's Community Availability build of Zulu, based on OpenJDK and
licensed under GPLv2 with the Classpath Exception. The license notices ship in
/opt/java/legal inside the image. OpenJDK source is at
https://github.com/openjdk/jdk and Azul's terms are at
https://www.azul.com/products/core/openjdk-terms-of-use/. This is not legal
advice, so check the terms for your own use.
