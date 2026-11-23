# users-api — Assignments 2.1 & 2.2

Layered Users REST API with Node.js 22+ and Express 5 (ES Modules).

```bash
npm install
npm run dev      # node --env-file-if-exists=.env --watch src/server.js
npm start        # without --watch
npm test         # vitest run (unit + integration)
```

Base URL: `http://127.0.0.1:3000` · Health: `GET /health`

| Method | Path | Notes |
| --- | --- | --- |
| GET | `/api/v1/users` | `?q=&role=&sort=-lastName&page=1&limit=20` |
| GET | `/api/v1/users/:id` | 400 if `:id` is not a UUID, 404 if unknown |
| POST | `/api/v1/users` | JSON only (415 otherwise); 201 + `Location`; role forced to `customer` |
| PATCH | `/api/v1/users/:id` | partial update; password not allowed here |
| DELETE | `/api/v1/users/:id` | 204 |

Layers: `routes → controllers → services → repositories`, with cross-cutting
utils/validators/middleware. `src/app.js` builds the app; `src/server.js` listens.

## Assignment 2.2 — middleware & dependency injection

| Piece | Where |
| --- | --- |
| `requireJson` (415 for non-JSON POST/PUT/PATCH) | `src/middleware/require-json.js`, registered in `src/app.js` **before** `express.json()` |
| `validateIdParam` (400 for a non-UUID `:id`) | `src/middleware/validate-id.js`, registered with `router.param('id', …)` |
| `responseTime` (bonus, `X-Response-Time` header) | `src/middleware/response-time.js` |
| Composition root + `overrides` for tests | `src/container.js` |
| Controller receives its service | `src/controllers/users.controller.js` |
| Router factory | `src/routes/users.routes.js` |
| `createApp(container)` | `src/app.js` |

```js
const container = createContainer();          // production
const app = createApp(container);

// tests
createContainer({ hashPassword: fakeHasher });
createContainer({ usersService: fakeService });
```

## Verification

Run `bash evidence/run-checks.sh` while the server is running. Expected statuses:
`201, 200, 200, 200, 409, 400, 204, 404`.

Run `bash evidence/run-checks-2.2.sh` for the new middleware: `415`, `400`,
`404` for a valid-but-unknown UUID, and the `X-Response-Time` header.

- `evidence/curl-checks.txt` / `.png` — all 7 Step 13 requests and responses
- `evidence/server.log` / `.png` — server startup plus request log lines
- `evidence/curl-checks-2.2.txt` / `2.2-middleware.png` — 415 / 400 / 404 + header
- `evidence/test-output.txt` / `2.2-tests.png` — `npm test` (3 files, 23 tests)
- `evidence/run-checks.sh`, `evidence/run-checks-2.2.sh` — reproducible scripts
- `SHORT-ANSWERS.md` — Assignment 2.1 answers
- `SHORT-ANSWERS-2.2.md` — Assignment 2.2 answers

Never commit `.env` or `node_modules/` (both are in `.gitignore`).
