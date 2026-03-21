#!/usr/bin/env bash
set -euo pipefail

API_BASE="${API_BASE:-http://localhost:3000}"

u1=$(curl -s -X POST "${API_BASE}/auth/register" -H 'content-type: application/json' -d '{"email":"p2_u1@test.dev","password":"secret01"}')
u2=$(curl -s -X POST "${API_BASE}/auth/register" -H 'content-type: application/json' -d '{"email":"p2_u2@test.dev","password":"secret02"}')

u1_id=$(echo "$u1" | node -e 'let d="";process.stdin.on("data",c=>d+=c).on("end",()=>console.log(JSON.parse(d).id));')
u2_id=$(echo "$u2" | node -e 'let d="";process.stdin.on("data",c=>d+=c).on("end",()=>console.log(JSON.parse(d).id));')

campaign=$(curl -s -X POST "${API_BASE}/campaigns" -H 'content-type: application/json' -d '{"name":"Save the Plumpkin","levels":[{"gameId":"tile_placement_demo"}]}' )
campaign_id=$(echo "$campaign" | node -e 'let d="";process.stdin.on("data",c=>d+=c).on("end",()=>console.log(JSON.parse(d).id));')

curl -s -X POST "${API_BASE}/campaigns/${campaign_id}/start" -H 'content-type: application/json' -d "{\"players\":[\"${u1_id}\",\"${u2_id}\"]}" >/dev/null
curl -s "${API_BASE}/leaderboard?period=all-time" >/dev/null

echo "P2 smoke finished"
