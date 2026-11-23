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

const middleware = readFileSync('evidence/curl-checks-2.2.txt', 'utf8');
const tests = readFileSync('evidence/test-output.txt', 'utf8');
writeFileSync('evidence/2.2-middleware.html', page('Assignment 2.2 — 415 / 400 / 404 + X-Response-Time', esc(middleware)));
writeFileSync('evidence/2.2-tests.html', page('Assignment 2.2 — npm test', esc(tests)));
console.log('wrote evidence/2.2-middleware.html and evidence/2.2-tests.html');
