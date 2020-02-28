# syntax = docker/dockerfile:experimental
FROM ubuntu:18.04

ARG TEKTON_VERSION
ENV TEKTON_VERSION=${TEKTON_VERSION:-0.8.0}

RUN apt-get update && \
    apt-get install -y \
        curl \
        gnupg2

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" |tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

RUN --mount=type=cache,target=/var/cache/apt/archives \
    apt-get update && \
    apt-get install -y \
        google-cloud-sdk \
        google-cloud-sdk-app-engine-python \
        google-cloud-sdk-app-engine-python-extras

RUN groupadd -g 1000 tekton && \
    useradd -u 1000 -g tekton -d /home/tekton -m -k /etc/skel -s /bin/bash tekton

RUN curl -L https://github.com/tektoncd/cli/releases/download/v${TEKTON_VERSION}/tkn_${TEKTON_VERSION}_Linux_x86_64.tar.gz | tar xvz -C /usr/local/bin

RUN echo "source $(tkn completion bash) > /home/tekton/.bashrc"

USER tekton
ENTRYPOINT ["tkn"]
