ARG VERSION

FROM debian:bookworm-slim AS builder
RUN sed -i 's|deb.debian.org|mirrors.aliyun.com|g' /etc/apt/sources.list.d/debian.sources && \
  DEBIAN_FRONTEND=noninteractive apt-get update && \
  apt-get install -y curl build-essential git && \
  rm -rf /var/lib/apt/lists/* && \
  apt-get clean

# Install the Pulumi SDK, including the CLI and language runtimes.
RUN curl -fsSL https://get.pulumi.com/ | bash -s -- --version "$VERSION"

# The runtime container
FROM node:18.20.5-bookworm-slim
LABEL org.opencontainers.image.description="Pulumi CLI container for nodejs"
WORKDIR /pulumi/projects

# Install needed tools, like git
RUN sed -i 's|deb.debian.org|mirrors.aliyun.com|g' /etc/apt/sources.list.d/debian.sources && \
  DEBIAN_FRONTEND=noninteractive apt-get update && \
  apt-get install -y curl git ca-certificates && \
  apt-get clean

# Uses the workdir, copies from pulumi interim container
COPY --from=builder /root/.pulumi/bin/pulumi /usr/local/bin
COPY --from=builder /root/.pulumi/bin/*-nodejs* /usr/local/bin
COPY --from=builder /root/.pulumi/bin/pulumi-analyzer-policy /usr/local/bin

CMD ["pulumi"]