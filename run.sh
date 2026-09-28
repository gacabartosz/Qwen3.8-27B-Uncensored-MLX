#!/usr/bin/env bash
# Uruchomienie modelu. Uzycie: ./run.sh [wariant] "prompt" [obraz]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
VARIANT="${1:-4-bit}"
PROMPT="${2:-Wyjasnij splatanie kwantowe w jednym zdaniu.}"
IMAGE="${3:-}"

if ! ls "$ROOT/$VARIANT"/model-*.safetensors >/dev/null 2>&1; then
  echo "Brak wag w ./$VARIANT. Najpierw: ./install-mac.sh $VARIANT"; exit 1
fi

# shellcheck disable=SC1091
source "$ROOT/.venv/bin/activate"

ARGS=(--model "$ROOT/$VARIANT" --prompt "$PROMPT" --max-tokens 512)
if [ -n "$IMAGE" ]; then ARGS+=(--image "$IMAGE"); fi

python -m mlx_vlm generate "${ARGS[@]}"
