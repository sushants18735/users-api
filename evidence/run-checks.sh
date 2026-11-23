#!/usr/bin/env bash
# Step 13 verification: run all 7 curl checks against a running server.
BASE=http://127.0.0.1:3000

show() { printf '\n$ %s\n' "$1"; }

show "curl -i -X POST localhost:3000/api/v1/users -H 'Content-Type: application/json' -d '{...Sita...}'"
POST1=$(curl -sS -i -X POST "$BASE/api/v1/users" \
  -H 'Content-Type: application/json' \
  -d '{"firstName":"Sita","lastName":"Gurung","email":"Sita@Example.com","password":"Secret123",
       "phone":"+977-9800000002","dateOfBirth":"2002-11-03",
       "address":{"street":"Lakeside Road 5","city":"Pokhara","postalCode":"33700","country":"Nepal"}}')
printf '%s\n' "$POST1"
ID=$(printf '%s\n' "$POST1" | tail -n 1 | python3 -c 'import json,sys; print(json.load(sys.stdin)["data"]["id"])')
printf 'USER_ID=%s\n' "$ID"

show "curl -s -w 'HTTP %{http_code}' localhost:3000/api/v1/users"
curl -sS -w '\nHTTP %{http_code}\n' "$BASE/api/v1/users"

show "curl -s -w 'HTTP %{http_code}' localhost:3000/api/v1/users/<id>"
curl -sS -w '\nHTTP %{http_code}\n' "$BASE/api/v1/users/$ID"

show "curl -s -w 'HTTP %{http_code}' -X PATCH localhost:3000/api/v1/users/<id> -d '{\"phone\":\"+977-9811111111\"}'"
curl -sS -w '\nHTTP %{http_code}\n' -X PATCH "$BASE/api/v1/users/$ID" \
  -H 'Content-Type: application/json' -d '{"phone":"+977-9811111111"}'

show "curl -s -w 'HTTP %{http_code}' -X POST localhost:3000/api/v1/users -d '{...SITA@example.com...}'"
curl -sS -w '\nHTTP %{http_code}\n' -X POST "$BASE/api/v1/users" -H 'Content-Type: application/json' \
  -d '{"firstName":"X","lastName":"Y","email":"SITA@example.com","password":"Secret123"}'

show "curl -s -w 'HTTP %{http_code}' -X POST localhost:3000/api/v1/users -d '{...role:admin...}'"
curl -sS -w '\nHTTP %{http_code}\n' -X POST "$BASE/api/v1/users" -H 'Content-Type: application/json' \
  -d '{"firstName":"Eve","lastName":"H","email":"eve@x.com","password":"Secret123","role":"admin"}'

show "curl -s -o /dev/null -w '%{http_code}' -X DELETE localhost:3000/api/v1/users/<id>"
curl -sS -o /dev/null -w '%{http_code}\n' -X DELETE "$BASE/api/v1/users/$ID"

show "curl -s -o /dev/null -w '%{http_code}' localhost:3000/api/v1/users/<id>"
curl -sS -o /dev/null -w '%{http_code}\n' "$BASE/api/v1/users/$ID"
