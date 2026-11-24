# users-api — Assignments 2.1 → 2.3

Layered Users REST API with Node.js 22+, Express 5, ES Modules, JWT auth,
refresh-token rotation, RBAC/ABAC and GitHub OAuth 2.0 + PKCE.

```bash
npm install
cp .env.example .env     # then set JWT_SECRET, admin and GitHub credentials
npm run dev              # node --env-file-if-exists=.env --watch src/server.js
npm start                # without --watch
npm test                 # vitest run — 79 tests
```

`config/env.js` refuses to start without a 32+ character `JWT_SECRET`; generate one with:

```bash
node -e "console.log(require('node:crypto').randomBytes(48).toString('base64url'))"
```

## Auth endpoints (`/api/v1/auth`)

| Method | Path | Auth | Notes |
| --- | --- | --- | --- |
| POST | `/register` | public | customer only, 201 + Bearer token + httpOnly refresh cookie |
| POST | `/login` | public | generic 401 for both bad email and bad password |
| POST | `/refresh` | refresh cookie | rotation + reuse detection, 200 + new cookie |
| POST | `/logout` | refresh cookie | revokes the token family, 204 |
| GET | `/me` | Bearer | own profile |
| PATCH | `/password` | Bearer | changes password and logs out every device |
| GET | `/github` | public | 302 to GitHub with `state` + PKCE challenge |
| GET | `/github/callback` | `state` cookie | exchanges code, links by verified email, issues session |

## Users endpoints (`/api/v1/users`)

| Method | Path | Rule | Notes |
| --- | --- | --- | --- |
| GET | `/` | RBAC `admin` | `?q=&role=&sort=&page=&limit=` |
| POST | `/` | RBAC `admin` | 201 + `Location` |
| GET | `/:id` | ABAC `users:read` | owner or admin; 400 for a non-UUID id |
| PATCH | `/:id` | ABAC `users:update` | owner or admin; partial update |
| PATCH | `/:id/role` | RBAC `admin` | change a user's role |
| DELETE | `/:id` | ABAC `users:delete` | admin, never themselves; 204 |

Anonymous requests get **401** with `WWW-Authenticate: Bearer`; an authenticated but
disallowed request gets **403**. `router.use(authenticate)` runs before
`router.param('id')`, so an anonymous `/users/123` is 401, not 400.

## Structure

- `src/auth/` — ABAC policies and PKCE helpers
- `src/middleware/` — `authenticate`, `requireRole`, `requirePermission`, plus 2.2 middleware
- `src/services/` — `UsersService`, `TokenService`, `AuthService`, `GithubOAuthClient`
- `src/repositories/` — in-memory users and hashed refresh tokens
- `src/container.js` — composition root; `overrides` inject fake hashers, fetchers or services
- `src/data/bootstrap-admin.js` — creates the first admin from `.env` at startup

## Verification

With the server running, `bash evidence/run-checks-2.3.sh` performs Part E end to end:
`401 → 201 → 200 → 403 → 200 → 200 → 403 → 200 → 204 → 401`.

`npm test` runs 7 files / **79 tests** (JWT forgery, rotation and reuse detection,
RBAC/ABAC policies, auth API, users API, and GitHub OAuth with an injected fake `fetch`).

Evidence: `evidence/curl-checks-2.3.txt`, `evidence/*.png`, `evidence/test-output-2.3.txt`,
`SHORT-ANSWERS-2.3.md`. Never commit `.env`, `node_modules/` or cookie jar files.
