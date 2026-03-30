import {
  WASI,
  File,
  OpenFile,
  ConsoleStdout,
} from "https://esm.sh/@bjorn3/browser_wasi_shim@0.4.2";

const requestEl = document.getElementById("request");
const outputEl = document.getElementById("output");
const runBtn = document.getElementById("runBtn");

requestEl.value = JSON.stringify(
  {
    year: 2024,
    month: 6,
    day: 15,
    hour: 10,
    minute: 0,
    timeZone: 8,
    useTrueSolarTime: true,
    longitude: 87.6,
    language: "zh-CN",
    includeRelationships: true,
    includePattern: true,
    includeThermalBalance: true,
    includeUsefulGod: false,
    includeLuck: true,
    includeYearlyLuck: true,
    gender: "male",
    luckCycleLimit: 3,
  },
  null,
  2,
);

const textEncoder = new TextEncoder();
const textDecoder = new TextDecoder();

let wasmExports;

async function instantiateWasm(url, imports) {
  if (WebAssembly.instantiateStreaming) {
    try {
      const response = await fetch(url);
      if (!response.ok) {
        throw new Error(`Failed to fetch wasm: ${response.status}`);
      }
      return await WebAssembly.instantiateStreaming(response, imports);
    } catch {
      // Fallback below when server does not set application/wasm MIME.
    }
  }

  const response = await fetch(url);
  if (!response.ok) {
    throw new Error("无法加载 ./dist/ganzhi.wasm，请先运行 ./scripts/build-wasm.sh");
  }
  const bytes = await response.arrayBuffer();
  return WebAssembly.instantiate(bytes, imports);
}

async function loadWasm() {
  if (wasmExports) {
    return wasmExports;
  }

  const fds = [
    new OpenFile(new File([])),
    ConsoleStdout.lineBuffered((msg) => console.log(`[wasi stdout] ${msg}`)),
    ConsoleStdout.lineBuffered((msg) => console.error(`[wasi stderr] ${msg}`)),
  ];
  const wasi = new WASI([], [], fds);

  const { instance } = await instantiateWasm("./dist/ganzhi.wasm", {
    wasi_snapshot_preview1: wasi.wasiImport,
  });

  wasi.start(instance);
  wasmExports = instance.exports;
  return wasmExports;
}

function callAnalyze(exports, requestText) {
  const {
    memory,
    ganzhi_alloc,
    ganzhi_dealloc,
    ganzhi_analyze,
    ganzhi_string_len,
    ganzhi_free_string,
  } = exports;

  if (!memory || !ganzhi_alloc || !ganzhi_analyze || !ganzhi_string_len || !ganzhi_free_string) {
    throw new Error("WASM 导出函数不完整，请确认构建脚本成功执行。");
  }

  const requestBytes = textEncoder.encode(requestText);
  const inPtr = Number(ganzhi_alloc(requestBytes.length));
  if (!inPtr) {
    throw new Error("输入内存分配失败");
  }

  new Uint8Array(memory.buffer, inPtr, requestBytes.length).set(requestBytes);
  const outPtr = Number(ganzhi_analyze(inPtr, requestBytes.length));

  if (ganzhi_dealloc) {
    ganzhi_dealloc(inPtr, requestBytes.length);
  }

  if (!outPtr) {
    throw new Error("ganzhi_analyze 返回空指针");
  }

  const outLen = Number(ganzhi_string_len(outPtr));
  const outBytes = new Uint8Array(memory.buffer, outPtr, outLen);
  const result = textDecoder.decode(outBytes);
  ganzhi_free_string(outPtr);
  return result;
}

runBtn.addEventListener("click", async () => {
  outputEl.textContent = "执行中...";

  try {
    const requestObj = JSON.parse(requestEl.value);
    const exports = await loadWasm();
    const result = callAnalyze(exports, JSON.stringify(requestObj));
    outputEl.textContent = result;
  } catch (error) {
    outputEl.textContent = `执行失败: ${error.message}`;
  }
});
