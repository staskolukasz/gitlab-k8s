FROM alpine:3.9

ARG CLOUD_SDK_VERSION=235.0.0
ARG KUBECTL_VERSION=1.13.3
ARG HELM_VERSION=2.12.3

# Google Cloud
ENV CLOUD_SDK_VERSION=$CLOUD_SDK_VERSION

ENV PATH /google-cloud-sdk/bin:$PATH
RUN apk --no-cache add \
        curl \
        python \
        py-crcmod \
        bash \
        libc6-compat \
        openssh-client \
        git \
        gnupg \
    && curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    tar xzf google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    rm google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    ln -s /lib /lib64 && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image && \
    gcloud --version

VOLUME ["/root/.config"]

# Kubectl
ADD https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl /usr/local/bin/kubectl

RUN set -x && \
    apk add --no-cache curl ca-certificates && \
    chmod +x /usr/local/bin/kubectl && \
    adduser kubectl -Du 2342 -h /config && \
    kubectl version --client

USER kubectl

# Helm
USER root
RUN cd /home && \
	curl https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz -o helm.tar.gz && \
	tar -xvf helm.tar.gz && \
	rm helm.tar.gz && \
	mv linux-amd64/helm /usr/local/bin/helm && \
	chmod +x /usr/local/bin/helm && \
	helm --help && \
	cd

ENTRYPOINT /bin/sh

