# syntax = docker/dockerfile:experimental
FROM ubuntu:18.04

ARG TEKTON_VERSION
ENV TEKTON_VERSION=${TEKTON_VERSION:-0.8.0}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3009,SC2215
RUN --mount=type=cache,target=/var/cache/apt/archives apt-get update && \
    apt-get install -y --no-install-recommends \
        curl=7.58.0-2ubuntu3.8 \
        gnupg2=2.2.4-1ubuntu1.2 \
        ca-certificates=20180409

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" |tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

# hadolint ignore=SC2215
RUN --mount=type=cache,target=/var/cache/apt/archives apt-get update && \
    apt-get install -y --no-install-recommends \
        google-cloud-sdk=282.0.0-0 \
        google-cloud-sdk-app-engine-python=282.0.0-0 \
        google-cloud-sdk-app-engine-python-extras=282.0.0-0

RUN groupadd -g 1000 tekton && \
    useradd -u 1000 -g tekton -d /home/tekton -m -k /etc/skel -s /bin/bash tekton

RUN curl -L https://github.com/tektoncd/cli/releases/download/v${TEKTON_VERSION}/tkn_${TEKTON_VERSION}_Linux_x86_64.tar.gz | tar xvz -C /usr/local/bin

RUN echo "source $(tkn completion bash) > /home/tekton/.bashrc"

USER tekton
ENTRYPOINT ["tkn"]
