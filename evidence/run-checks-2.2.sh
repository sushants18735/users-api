#!/usr/bin/env bash
# Assignment 2.2 checkpoint: the two new middleware + the bonus header.
# Run the server first (npm run dev), then: bash evidence/run-checks-2.2.sh
BASE=http://127.0.0.1:3000

show() { printf '\n$ %s\n' "$1"; }

show "curl -s -X POST localhost:3000/api/v1/users -d 'firstName=Sita'"
curl -sS -w '\nHTTP %{http_code}\n' -X POST "$BASE/api/v1/users" -d 'firstName=Sita'

show "curl -s localhost:3000/api/v1/users/123"
curl -sS -w '\nHTTP %{http_code}\n' "$BASE/api/v1/users/123"

show "curl -s localhost:3000/api/v1/users/15cfde80-9253-4e58-a113-a87a9e67498a"
curl -sS -w '\nHTTP %{http_code}\n' "$BASE/api/v1/users/15cfde80-9253-4e58-a113-a87a9e67498a"

show "curl -sI localhost:3000/health   # bonus: X-Response-Time"
curl -sSI "$BASE/health"
