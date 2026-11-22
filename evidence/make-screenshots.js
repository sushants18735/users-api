import { readFileSync, writeFileSync } from 'node:fs';

const esc = (s) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

const page = (title, pre) => `<!doctype html>
<html lang="en"><head><meta charset="utf-8"><title>${title}</title>
<style>
  body { margin:0; background:#0b1220; color:#e6edf3; font:13px/1.5 ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; }
  .bar { background:#1c2536; padding:12px 18px; color:#9fb2c9; border-bottom:1px solid #2b3850; }
  .bar b { color:#7ee787; }
  pre { margin:0; padding:18px 22px; white-space:pre-wrap; overflow-wrap:anywhere; }
</style></head><body>
<div class="bar">● terminal — <b>users-api</b> — ${title}</div>
<pre>${pre}</pre>
</body></html>`;

const curls = readFileSync('evidence/curl-checks.txt', 'utf8');
const logs = readFileSync('evidence/server.log', 'utf8');
writeFileSync('evidence/curl-checks.html', page('Step 13 — 7 curl checks', esc(curls)));
writeFileSync('evidence/server-log.html', page('server log lines', esc(logs)));
console.log('wrote evidence/curl-checks.html and evidence/server-log.html');
