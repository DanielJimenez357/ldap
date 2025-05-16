#!/bin/bash

sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg git -y

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable docker
sudo systemctl start docker

APP_DIR="/opt/app"
sudo mkdir -p "${APP_DIR}"
sudo chown -R admin:admin "${APP_DIR}" || sudo chown -R debian:debian "${APP_DIR}"

GIT_REPO_URL="https://github.com/DanielJimenez357/dockerfiles.git"
sudo -u admin git clone "${GIT_REPO_URL}" "${APP_DIR}"

cd "${APP_DIR}"
docker compose pull
docker compose up -d
