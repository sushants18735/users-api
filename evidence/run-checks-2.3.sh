#!/usr/bin/env bash
# Assignment 2.3 Part E: end-to-end auth/authorization checks against a running server.
# Start the server first: npm run dev
API=http://127.0.0.1:3000/api/v1
COOKIES="${TMPDIR:-/tmp}/users-api-2.3-cookies"
mkdir -p "$COOKIES"

show() { printf '\n$ %s\n' "$1"; }

show "curl -s $API/users   # anonymous → 401"
curl -sS -w '\nHTTP %{http_code}\n' "$API/users"

show "curl -s -X POST $API/auth/register -d '{...Sita...}'   # → 201 + Bearer token"
REG=$(curl -sS -c "$COOKIES/sita.txt" -X POST "$API/auth/register" -H 'Content-Type: application/json' \
  -d '{"firstName":"Sita","lastName":"Gurung","email":"sita@example.com","password":"Secret123"}')
printf '%s\n' "$REG"
SITA=$(printf '%s' "$REG" | python3 -c 'import json,sys; print(json.load(sys.stdin)["data"]["accessToken"])')
SITA_ID=$(printf '%s' "$REG" | python3 -c 'import json,sys; print(json.load(sys.stdin)["data"]["user"]["id"])')

show "node -e '...decode base64url payload...'   # JWT payload is encoded, NOT encrypted"
node -e "console.log(Buffer.from(process.argv[1].split('.')[1],'base64url').toString())" "$SITA"

show "curl -s $API/auth/me -H 'Authorization: Bearer <SITA>'   # → 200"
curl -sS -w '\nHTTP %{http_code}\n' "$API/auth/me" -H "Authorization: Bearer $SITA"

show "curl -s $API/users -H 'Authorization: Bearer <SITA>'   # RBAC: customer → 403"
curl -sS -w '\nHTTP %{http_code}\n' "$API/users" -H "Authorization: Bearer $SITA"

show "curl -s -X POST $API/auth/login -d 'admin@users-api.test'   # → 200"
ADM=$(curl -sS -c "$COOKIES/admin.txt" -X POST "$API/auth/login" -H 'Content-Type: application/json' \
  -d '{"email":"admin@users-api.test","password":"ChangeMe12345"}')
printf '%s\n' "$ADM"
ADMIN=$(printf '%s' "$ADM" | python3 -c 'import json,sys; print(json.load(sys.stdin)["data"]["accessToken"])')
ADMIN_ID=$(printf '%s' "$ADM" | python3 -c 'import json,sys; print(json.load(sys.stdin)["data"]["user"]["id"])')

show "curl -s $API/users -H 'Authorization: Bearer <ADMIN>'   # RBAC: admin → 200"
curl -sS -w '\nHTTP %{http_code}\n' "$API/users" -H "Authorization: Bearer $ADMIN"

show "curl -s $API/users/$SITA_ID -H 'Authorization: Bearer <SITA>'   # ABAC: own profile → 200"
curl -sS -w '\nHTTP %{http_code}\n' "$API/users/$SITA_ID" -H "Authorization: Bearer $SITA"

show "curl -s $API/users/$ADMIN_ID -H 'Authorization: Bearer <SITA>'   # ABAC: someone else → 403"
curl -sS -w '\nHTTP %{http_code}\n' "$API/users/$ADMIN_ID" -H "Authorization: Bearer $SITA"

show "curl -s -b sita.txt -c sita.txt -X POST $API/auth/refresh   # rotation → 200 + new cookie"
curl -sS -w '\nHTTP %{http_code}\n' -b "$COOKIES/sita.txt" -c "$COOKIES/sita.txt" -X POST "$API/auth/refresh"

show "curl -s -o /dev/null -w '%{http_code}' -b sita.txt -X POST $API/auth/logout   # → 204"
curl -sS -o /dev/null -w '%{http_code}\n' -b "$COOKIES/sita.txt" -X POST "$API/auth/logout"

show "curl -s -b sita.txt -X POST $API/auth/refresh   # after logout → 401"
curl -sS -w '\nHTTP %{http_code}\n' -b "$COOKIES/sita.txt" -X POST "$API/auth/refresh"
