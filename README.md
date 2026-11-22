# users-api — Assignment 2.1

Layered Users REST API with Node.js 22+ and Express 5 (ES Modules, no DI container).

```bash
npm install
npm run dev      # node --env-file-if-exists=.env --watch src/server.js
npm start        # without --watch
```

Base URL: `http://127.0.0.1:3000` · Health: `GET /health`

| Method | Path | Notes |
| --- | --- | --- |
| GET | `/api/v1/users` | `?q=&role=&sort=-lastName&page=1&limit=20` |
| GET | `/api/v1/users/:id` | 404 Problem Details when missing |
| POST | `/api/v1/users` | validated body; 201 + `Location`; role forced to `customer` |
| PATCH | `/api/v1/users/:id` | partial update; password not allowed here |
| DELETE | `/api/v1/users/:id` | 204 |

Layers: `routes → controllers → services → repositories`, with cross-cutting
utils/validators/middleware. `src/app.js` builds the app; `src/server.js` listens.

## Verification

Run `bash evidence/run-checks.sh` while the server is running. Expected statuses:
`201, 200, 200, 200, 409, 400, 204, 404`.

- `evidence/curl-checks.txt` / `.png` — all 7 Step 13 requests and responses
- `evidence/server.log` / `.png` — server startup plus request log lines
- `evidence/run-checks.sh` — reproducible curl script
- `SHORT-ANSWERS.md` — the three written answers

Never commit `.env` or `node_modules/` (both are in `.gitignore`).
