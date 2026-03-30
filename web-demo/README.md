# Web Demo

## 1) Build wasm

From repository root:

```bash
./scripts/build-wasm.sh
```

If your host Swift version does not match the wasm SDK version, run with an explicit Swift toolchain:

```bash
SWIFT_CMD="swift" ./scripts/build-wasm.sh
```

Example with `swiftly`:

```bash
SWIFT_CMD="swiftly run swift +6.2.0" ./scripts/build-wasm.sh
```

If you don't have Swift 6.2.0 installed yet:

```bash
swiftly install 6.2.0
```

Expected output:

- `web-demo/dist/ganzhi.wasm`

## 2) Start a local static server

From repository root:

```bash
python3 -m http.server 8080
```

Then open:

- `http://localhost:8080/web-demo/`

## Notes

- This demo expects wasm exports from `GanZhiWasmRuntime`.
- If browser `instantiateStreaming` fails due MIME type, keep using `python3 -m http.server` or switch to another static server.
- Request JSON supports luck fields: `includeLuck`, `includeYearlyLuck`, `gender`, `luckCycleLimit`.
