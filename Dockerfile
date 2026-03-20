ARG BASE_IMAGE=devcontainer-base

FROM ${BASE_IMAGE}

ARG USERNAME=yolowingpixie
USER $USERNAME
WORKDIR /home/$USERNAME

ENV PATH="/home/${USERNAME}/.local/bin:${PATH}"

COPY --chmod=755 scripts/install/user/ /tmp/install/user/
RUN run-parts --regex '.*\.sh$' /tmp/install/user/

COPY --chown=$USERNAME:$USERNAME scripts/alias.sh alias.sh
COPY --chown=$USERNAME:$USERNAME scripts/alias/ alias/
RUN touch ~/.bashrc && \
    echo 'source $HOME/alias.sh' >> ~/.bashrc && \
    echo '[[ $- == *i* ]] && exec zsh' >> ~/.bashrc

COPY --chown=$USERNAME:$USERNAME scripts/zsh/.zshrc /home/$USERNAME/.zshrc
COPY --chown=$USERNAME:$USERNAME scripts/zsh/.p10k.zsh /home/$USERNAME/.p10k.zsh

COPY --chmod=755 scripts/entrypoint.sh /entrypoint.sh

CMD ["/bin/bash"]
