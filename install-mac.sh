#!/usr/bin/env bash
# Instalacja Qwen3.8-27B-Uncensored-MLX na Macu z Apple Silicon.
# Uzycie: ./install-mac.sh [2-bit|4-bit|6-bit|8-bit]   (domyslnie 4-bit)
set -euo pipefail

VARIANT="${1:-4-bit}"
HF_REPO="orcarouter/Qwen3.8-27B-Uncensored-MLX"
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

case "$VARIANT" in
  2-bit|4-bit|6-bit|8-bit) ;;
  *) echo "Nieznany wariant: $VARIANT (dozwolone: 2-bit, 4-bit, 6-bit, 8-bit)"; exit 1 ;;
esac

if [ "$(uname -s)" != "Darwin" ] || [ "$(uname -m)" != "arm64" ]; then
  echo "Wymagany Mac z Apple Silicon (M1/M2/M3/M4/M5)."; exit 1
fi

RAM_GB=$(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 ))
case "$VARIANT" in
  2-bit) NEED=16 ;; 4-bit) NEED=24 ;; 6-bit) NEED=24 ;; 8-bit) NEED=32 ;;
esac
echo "RAM: ${RAM_GB} GB, wariant ${VARIANT} potrzebuje min. ${NEED} GB."
if [ "$RAM_GB" -lt "$NEED" ]; then
  echo "Za malo RAM dla ${VARIANT}. Wybierz mniejszy wariant."; exit 1
fi

# Srodowisko Pythona: uv (szybciej) albo zwykly venv. MLX ma wheele dla 3.10 do 3.13.
if [ ! -d .venv ]; then
  if command -v uv >/dev/null 2>&1; then
    uv venv --python 3.12 .venv
  else
    PY=""
    for c in python3.13 python3.12 python3.11 python3.10; do
      if command -v "$c" >/dev/null 2>&1; then PY="$c"; break; fi
    done
    if [ -z "$PY" ]; then
      echo "Brak Pythona 3.10 do 3.13. Zainstaluj: brew install python@3.12 (albo brew install uv)"; exit 1
    fi
    "$PY" -m venv .venv
  fi
fi

# shellcheck disable=SC1091
source .venv/bin/activate
if command -v uv >/dev/null 2>&1; then
  uv pip install -U "mlx-vlm>=0.6.13" "huggingface_hub[cli]"
else
  python -m pip install -U pip
  python -m pip install -U "mlx-vlm>=0.6.13" "huggingface_hub[cli]"
fi

echo "Pobieram ${VARIANT} z Hugging Face (${HF_REPO}) do ./${VARIANT} ..."
hf download "$HF_REPO" --include "${VARIANT}/*" --local-dir "$ROOT"

echo
echo "Gotowe. Test:"
echo "  ./run.sh ${VARIANT} \"Napisz jedno zdanie o Krakowie.\""
