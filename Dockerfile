# Build args: default to config.yaml values; override via task build or docker build --build-arg
ARG UBUNTU_VERSION=24.04
FROM ubuntu:${UBUNTU_VERSION}
COPY config.yaml /tmp/devcontainer/config.yaml

ARG UBUNTU_VERSION=24.04
ARG USERNAME=yolowingpixie
ARG USER_UID=1001
ARG USER_GID=1000

LABEL description="Generic development container for my personal projects"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    sudo

RUN sudo apt-get update && apt-get install -y \
    build-essential \
    curl \
    wget \
    git \
    vim \
    nano \
    neovim \
    unzip \
    jq \
    yq \
    ca-certificates \
    gnupg \
    gpg \
    sudo \
    apt-transport-https \
    lsb-release \
    software-properties-common \
    bash-completion \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Python
ARG PYTHON_VERSION=3.12
ARG PYTHON_MAJOR_VERSION=${PYTHON_VERSION%%.*}

RUN apt-get update && apt-get install -y \
    python${PYTHON_MAJOR_VERSION} \
    python${PYTHON_MAJOR_VERSION}-pip \
    python${PYTHON_MAJOR_VERSION}-venv \
    && ln -s /usr/bin/python${PYTHON_MAJOR_VERSION} /usr/bin/python \
    && rm -rf /var/lib/apt/lists/*

# Install kubectl
ARG KUBECTL_VERSION=stable

RUN if [ "$KUBECTL_VERSION" = "stable" ]; then \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"; \
    else \
    curl -LO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl"; \
    fi && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install helm
ARG HELM_VERSION=latest
RUN curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list && \
    sudo apt-get update
RUN if [ "$HELM_VERSION" = "latest" ]; then \
    apt update && apt-get install helm; \
    else \
    apt update && apt-get install helm=$HELM_VERSION; \
    fi

# Install terraform
ARG TERRAFORM_VERSION=latest

RUN wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list

RUN if [ "$TERRAFORM_VERSION" = "latest" ]; then \ 
    apt update && apt-get install terraform; \
    else \
    apt update && apt-get install terraform=$TERRAFORM_VERSION; \
    fi

# Create user
RUN useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set user
USER $USERNAME
WORKDIR /home/$USERNAME

# Profile setup

# install uv
ENV PATH="/home/${USERNAME}/.local/bin:${PATH}"
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
RUN for pkg in $(yq -r '.global_python_packages[]' /tmp/devcontainer/config.yaml); do uv tool install $pkg; done

RUN touch ~/.bashrc
COPY --chown=$USERNAME:$USERNAME --chmod=755 scripts/alias.sh alias.sh
RUN echo 'source $HOME/alias.sh' >>~/.bashrc

RUN terraform -install-autocomplete
RUN echo 'source <(kubectl completion bash)' >>~/.bashrc
RUN echo 'alias k=kubectl' >>~/.bashrc && \
    echo 'complete -o default -F __start_kubectl k' >>~/.bashrc

CMD ["/bin/bash"]