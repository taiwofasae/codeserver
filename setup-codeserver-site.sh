#!/usr/bin/env bash
set -euo pipefail

TEMPLATE_FILE="${1:-docker-compose.template.yml}"
OUTPUT_FILE="docker-compose.yml"
WEBSITES_ROOT="/srv/websites"

require_input() {
  local prompt="$1"
  local value=""

  while [[ -z "$value" ]]; do
    read -rp "$prompt: " value
  done

  echo "$value"
}

default_input() {
  local prompt="$1"
  local default="$2"
  local value=""

  read -rp "$prompt [$default]: " value
  echo "${value:-$default}"
}

if [[ ! -f "$TEMPLATE_FILE" ]]; then
  echo "Template file not found: $TEMPLATE_FILE"
  exit 1
fi

GIT_REPO_URL="$(require_input "Git repo URL")"
SITE_FOLDER="$(require_input "Site folder name")"

CODESERVER_PORT="$(default_input "Code-server machine port" "8701")"
PELICAN_PORT="$(default_input "Pelican machine port" "8702")"
LIVERELOAD_PORT="$(default_input "Livereload machine port" "8703")"

read -rsp "CODE_PASSWORD [empty]: " CODE_PASSWORD
echo ""

SITE_PATH="${WEBSITES_ROOT}/${SITE_FOLDER}"

echo "Creating site directory: $SITE_PATH"
sudo mkdir -p "$WEBSITES_ROOT"

if [[ -d "$SITE_PATH/.git" ]]; then
  echo "Repo already exists at $SITE_PATH; pulling latest..."
  git -C "$SITE_PATH" pull
else
  echo "Cloning repo into $SITE_PATH..."
  sudo git clone "$GIT_REPO_URL" "$SITE_PATH"
fi

echo "Fixing ownership..."
sudo chown -R 1000:1000 "$SITE_PATH"

echo "Writing .env..."
cat > "${SITE_PATH}/.env" <<EOF
CODE_PASSWORD=${CODE_PASSWORD}
EOF

echo "Generating $OUTPUT_FILE from $TEMPLATE_FILE..."
sed \
  -e "s|\[website-folder\]|${SITE_FOLDER}|g" \
  -e "s|\[codeserver_port\]|${CODESERVER_PORT}|g" \
  -e "s|\[pelican_port\]|${PELICAN_PORT}|g" \
  -e "s|\[livereload_port\]|${LIVERELOAD_PORT}|g" \
  "$TEMPLATE_FILE" > "$OUTPUT_FILE"

echo "Done."
echo "Site cloned to: $SITE_PATH"
echo "Compose file created: $OUTPUT_FILE"
echo "Env file created: ${SITE_PATH}/.env"