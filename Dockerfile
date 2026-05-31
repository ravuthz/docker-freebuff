FROM node:24-bookworm

RUN apt-get update && apt-get install -y \
    git curl bash ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g freebuff

RUN useradd -ms /bin/bash freebuff

WORKDIR /workspace

COPY workspace/ /workspace/

RUN mkdir -p /home/freebuff/.config/manicode \
    && chown -R freebuff:freebuff /home/freebuff /workspace

ENV HOME=/home/freebuff

USER freebuff

CMD ["bash"]