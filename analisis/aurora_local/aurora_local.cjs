// Reproduce la custom metric "aurora" de HTTP Archive (react_version) en el Chrome local.
//
// Inyecta antes de cargar la página el mismo hook que HTTPArchive/custom-metrics/inject-dist/aurora.js
// (__REACT_DEVTOOLS_GLOBAL_HOOK__ con inject(renderer)): React se registra en ese hook al iniciar, con
// cualquier API de montaje (render, createRoot, hydrateRoot), y deja su versión. Además de la última
// versión registrada (lo que guarda aurora) devuelve todos los renderers.
//
// Para capturas de Wayback usar el modo "if_" (https://web.archive.org/web/<ts>if_/<url>): los scripts se
// sirven desde el archivo. Cada recurso se sirve con la captura más cercana en fecha, que puede ser de
// otro mes: la salida registra la fecha de cada script cargado y los que fallaron, para juzgar si la
// reproducción corresponde al mes pedido.
//
// Entrada: un archivo con una URL por línea. Salida: una línea JSON por URL en stdout.
// Uso: (cd analisis/aurora_local && npm install) ; node analisis/aurora_local/aurora_local.cjs urls.txt
const fs = require("fs");
const puppeteer = require("puppeteer-core");

const CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const UA_MOVIL = "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Mobile Safari/537.36";
const EN_PARALELO = 4;
const HOOK = `
  window.__REACT_DEVTOOLS_GLOBAL_HOOK__ = {
    supportsFiber: true,
    inject(renderer) {
      window.react_renderer_version = renderer.version;
      (window.__renderers_aurora_local = window.__renderers_aurora_local || []).push(
        { version: renderer.version, paquete: renderer.rendererPackageName || null });
      return 1;
    }
  };`;
const FECHA_WAYBACK = /web\.archive\.org\/web\/(\d{14})/;
const dias = (a, b) => Math.abs(Date.UTC(+a.slice(0, 4), +a.slice(4, 6) - 1, +a.slice(6, 8)) - Date.UTC(+b.slice(0, 4), +b.slice(4, 6) - 1, +b.slice(6, 8))) / 864e5;

async function medir(navegador, url) {
  const pagina = await navegador.newPage();
  await pagina.setUserAgent(UA_MOVIL);
  await pagina.setViewport({ width: 412, height: 915, isMobile: true });
  await pagina.evaluateOnNewDocument(HOOK);
  const fechasScripts = [];
  let scriptsFallidos = 0;
  pagina.on("response", r => {
    if (r.request().resourceType() !== "script") return;
    if (r.status() >= 400) scriptsFallidos++;
    const m = r.url().match(FECHA_WAYBACK);
    if (m) fechasScripts.push(m[1]);
  });
  pagina.on("requestfailed", r => { if (r.resourceType() === "script") scriptsFallidos++; });
  const r = { url };
  try {
    const resp = await pagina.goto(url, { waitUntil: "networkidle2", timeout: 90000 });
    r.http = resp ? resp.status() : null;
    await new Promise(res => setTimeout(res, 4000));
    Object.assign(r, await pagina.evaluate(() => ({
      react_version: window.react_renderer_version || null,
      renderers: window.__renderers_aurora_local || [],
    })));
  } catch (e) {
    r.error = String(e).slice(0, 200);
  }
  r.scripts_fallidos = scriptsFallidos;
  const pedida = url.match(FECHA_WAYBACK);
  if (pedida && fechasScripts.length) {
    const distancias = fechasScripts.map(f => dias(f, pedida[1]));
    r.wayback = { captura: pedida[1], scripts: fechasScripts.length, max_dias_de_distancia: Math.max(...distancias),
                  scripts_a_mas_de_15_dias: distancias.filter(d => d > 15).length };
  }
  await pagina.close();
  return r;
}

(async () => {
  const urls = fs.readFileSync(process.argv[2], "utf8").split("\n").map(s => s.trim()).filter(Boolean);
  const navegador = await puppeteer.launch({ executablePath: CHROME, headless: true, args: ["--no-first-run"] });
  let siguiente = 0;
  await Promise.all(Array.from({ length: EN_PARALELO }, async () => {
    while (siguiente < urls.length) {
      const url = urls[siguiente++];
      console.log(JSON.stringify(await medir(navegador, url)));
    }
  }));
  await navegador.close();
})();
