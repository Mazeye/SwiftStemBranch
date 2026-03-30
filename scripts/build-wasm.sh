#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="$ROOT_DIR/web-demo/dist"
SDK=""
SWIFT_CMD="${SWIFT_CMD:-swift}"

mkdir -p "$OUT_DIR"

SDK_LIST="$($SWIFT_CMD sdk list 2>/dev/null || true)"

while IFS= read -r line; do
  case "$line" in
    *wasm32-unknown-wasip1-embedded*)
      ;;
    *wasm32-unknown-wasip1*)
      SDK="$line"
      break
      ;;
  esac
done <<< "$SDK_LIST"

if [[ -z "$SDK" ]]; then
  while IFS= read -r line; do
    case "$line" in
      *wasm32-unknown-wasi*)
        SDK="$line"
        break
        ;;
    esac
  done <<< "$SDK_LIST"
fi

if [[ -z "$SDK" ]]; then
  echo "Swift SDK 'wasm32-unknown-wasip1' or 'wasm32-unknown-wasi' is not installed."
  echo "Run '$SWIFT_CMD sdk list' to verify, then install a wasm SDK and retry."
  exit 1
fi

echo "[1/3] Building GanZhiWasmRuntime for $SDK..."
$SWIFT_CMD build \
  --package-path "$ROOT_DIR" \
  --swift-sdk "$SDK" \
  -c release \
  -Xswiftc -Osize \
  --product GanZhiWasmRuntime \
  -Xlinker --export=ganzhi_alloc \
  -Xlinker --export=ganzhi_dealloc \
  -Xlinker --export=ganzhi_analyze \
  -Xlinker --export=ganzhi_string_len \
  -Xlinker --export=ganzhi_free_string \
  -Xlinker --strip-all

WASM_PATH=""

for candidate in \
  "$ROOT_DIR/.build/wasm32-unknown-wasip1/release/GanZhiWasmRuntime.wasm" \
  "$ROOT_DIR/.build/wasm32-unknown-wasi/release/GanZhiWasmRuntime.wasm" \
  "$ROOT_DIR/.build/$SDK/release/GanZhiWasmRuntime.wasm"; do
  if [ -f "$candidate" ]; then
    WASM_PATH="$candidate"
    break
  fi
done

if [ -z "$WASM_PATH" ]; then
  shopt -s nullglob
  for candidate in "$ROOT_DIR"/.build/*/release/GanZhiWasmRuntime.wasm; do
    WASM_PATH="$candidate"
    break
  done
  shopt -u nullglob
fi

if [ -z "$WASM_PATH" ]; then
  echo "Expected wasm output not found under $ROOT_DIR/.build"
  echo "Tip: install Swift WASI SDK first, then rerun this script."
  exit 1
fi

echo "[2/3] Copying wasm artifact..."
cp "$WASM_PATH" "$OUT_DIR/ganzhi.wasm"

if command -v gzip >/dev/null 2>&1; then
  gzip -c -9 "$OUT_DIR/ganzhi.wasm" > "$OUT_DIR/ganzhi.wasm.gz"
fi

if command -v brotli >/dev/null 2>&1; then
  brotli -f -q 11 "$OUT_DIR/ganzhi.wasm" -o "$OUT_DIR/ganzhi.wasm.br"
fi

echo "[3/3] Done"
echo "WASM generated at: $OUT_DIR/ganzhi.wasm"
if [ -f "$OUT_DIR/ganzhi.wasm.gz" ]; then
  echo "Gzip generated at: $OUT_DIR/ganzhi.wasm.gz"
fi
if [ -f "$OUT_DIR/ganzhi.wasm.br" ]; then
  echo "Brotli generated at: $OUT_DIR/ganzhi.wasm.br"
fi
