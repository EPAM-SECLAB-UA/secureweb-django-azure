FROM python:3.11-slim

# Встановлення системних залежностей
RUN apt-get update && apt-get install -y \
    postgresql-client \
    build-essential \
    curl \
    git \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Створення користувача vscode
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Встановлення Python залежностей
COPY requirements/development.txt /tmp/
RUN pip install --no-cache-dir -r /tmp/development.txt

USER $USERNAME
