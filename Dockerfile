ARG UBUNTU_VERSION=24.04

FROM ubuntu:${UBUNTU_VERSION}

COPY config.yaml /tmp/devcontainer/config.yaml
ENV CONFIG_FILE=/tmp/devcontainer/config.yaml

ARG USERNAME=yolowingpixie

LABEL description="Generic development container for my personal projects"

ENV DEBIAN_FRONTEND=noninteractive

# Install yq to parse config, then all apt_packages from config
RUN apt-get update && apt-get install -y yq \
    && apt-get install -y $(yq -r '.apt_packages[]' $CONFIG_FILE) \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Python
RUN PYTHON_VERSION=$(yq -r '.versions.python' $CONFIG_FILE) && \
    PYTHON_MAJOR_VERSION=${PYTHON_VERSION%%.*} && \
    apt-get update && apt-get install -y \
    python${PYTHON_MAJOR_VERSION} \
    python${PYTHON_MAJOR_VERSION}-pip \
    python${PYTHON_MAJOR_VERSION}-venv \
    && ln -s /usr/bin/python${PYTHON_MAJOR_VERSION} /usr/bin/python \
    && rm -rf /var/lib/apt/lists/*

# Install kubectl
RUN KUBECTL_VERSION=$(yq -r '.versions.kubectl' $CONFIG_FILE) && \
    if [ "$KUBECTL_VERSION" = "stable" ]; then \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"; \
    else \
    curl -LO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl"; \
    fi && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install helm
RUN curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list && \
    sudo apt-get update
RUN HELM_VERSION=$(yq -r '.versions.helm' $CONFIG_FILE) && \
    if [ "$HELM_VERSION" = "latest" ]; then \
    apt update && apt-get install -y helm; \
    else \
    apt update && apt-get install -y helm=$HELM_VERSION; \
    fi \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install terraform
RUN wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list

RUN TERRAFORM_VERSION=$(yq -r '.versions.terraform' $CONFIG_FILE) && \
    if [ "$TERRAFORM_VERSION" = "latest" ]; then \
    apt update && apt-get install -y terraform; \
    else \
    apt update && apt-get install -y terraform=$TERRAFORM_VERSION; \
    fi \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create user
RUN USER_UID=$(yq -r '.user.uid' $CONFIG_FILE) && \
    USER_GID=$(yq -r '.user.gid' $CONFIG_FILE) && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set user
USER $USERNAME
WORKDIR /home/$USERNAME

# Profile setup

# install uv
ENV PATH="/home/${USERNAME}/.local/bin:${PATH}"
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
RUN for pkg in $(yq -r '.global_python_packages[]' $CONFIG_FILE); do uv tool install $pkg; done

RUN touch ~/.bashrc
COPY --chown=$USERNAME:$USERNAME --chmod=755 scripts/alias.sh alias.sh
RUN echo 'source $HOME/alias.sh' >>~/.bashrc

RUN terraform -install-autocomplete
RUN echo 'source <(kubectl completion bash)' >>~/.bashrc
RUN echo 'alias k=kubectl' >>~/.bashrc && \
    echo 'complete -o default -F __start_kubectl k' >>~/.bashrc

CMD ["/bin/bash"]