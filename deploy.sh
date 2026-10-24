#!/bin/bash
set -euo pipefail

APP_NAME="landing14"
PORT="8000"
APP_URL="http://127.0.0.1:${PORT}"

APP_USER="webadmin"
APP_GROUP="webgroup"
OWNER="${APP_USER}:${APP_GROUP}"
REPO_URL="https://gitlab.com/dos-26/cmdb/frontend.git"

APP_DIR="/opt/srv/${APP_NAME}"
VENV_DIR="${APP_DIR}/venv"
UNIT_FILE="/home/artsiom/home_works/lesson_14/lesson14/web_server.service"

SERVICE_NAME="web_server.service"
SERVICE_PATH="/etc/systemd/system/${SERVICE_NAME}"

CHECK_SCRIPT="$(dirname "$0")/check.sh"

export SERVICE_NAME CHECK_URL="http://127.0.0.1:${PORT}/"

git_clone() {
  if [ -d "${APP_DIR}/.git" ]; then
    echo "Updating project from remote repo"
    git -C "${APP_DIR}" fetch origin
    git -C "${APP_DIR}" reset --hard origin/main
  else
    echo "GIT CLONE ${REPO_URL}"
    git clone "${REPO_URL}" "${APP_DIR}"
  fi
}

create_venv() {
  if [ ! -x "${VENV_DIR}/bin/python3" ]; then
    echo "Creating venv in ${VENV_DIR}"
    sudo python3 -m venv "${VENV_DIR}"
  else
    echo "venv already exists: ${VENV_DIR}"
  fi
}

set_permission() {
  chown -R "${OWNER}" "${APP_DIR}"
  find "${APP_DIR}/public" -type d -exec chmod 755 {} \;
  find "${APP_DIR}/public" -type f -exec chmod 644 {} \;
}

copy_systemd() {
  if [ -f "${SERVICE_PATH}" ]; then
    if cmp -s "${UNIT_FILE}" "${SERVICE_PATH}"; then
      echo "systemd unit already up-to-date: ${SERVICE_PATH}"
    else
      echo "systemd unit exists but differs. backing up and updating"
      cp "${SERVICE_PATH}" "${SERVICE_PATH}.bak.$(date +%Y%m%d%H%M%S)"
      cp "${UNIT_FILE}" "${SERVICE_PATH}"
      chmod 644 "${SERVICE_PATH}"
    fi
  else
    echo "Installing systemd unit ${SERVICE_PATH}"
    cp "${UNIT_FILE}" "${SERVICE_PATH}"
    chmod 644 "${SERVICE_PATH}"
  fi

  systemctl daemon-reload
  systemctl enable "${SERVICE_NAME}"
  systemctl restart "${SERVICE_NAME}"
}

main() {
  git_clone
  create_venv
  set_permission
  copy_systemd

  chmod +x "${CHECK_SCRIPT}" 2>/dev/null || true
  sleep 2

  if ! "${CHECK_SCRIPT}"; then
    echo "Post-install checks failed" >&2
    exit 1
  fi

  echo "Done. Service URL: ${APP_URL}"
}

main "$@"
