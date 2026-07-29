#!/usr/bin/env bash
# Block `gh pr create` when --repo / -R is missing.
# On forks, bare `gh pr create` opens against the upstream parent.

set -euo pipefail

input=$(cat)
command=$(printf '%s' "$input" | jq -r '.command // empty')

# Matcher should already filter, but double-check in case of broad config.
if ! printf '%s' "$command" | grep -Eq '(^|[[:space:];|&])gh[[:space:]]+pr[[:space:]]+create([[:space:]]|$)'; then
	printf '%s\n' '{ "permission": "allow" }'
	exit 0
fi

# Accept --repo VALUE, --repo=VALUE, and the short form -R.
if printf '%s' "$command" | grep -Eq '(^|[[:space:]])(--repo(=|[[:space:]])|-R(=|[[:space:]]))'; then
	printf '%s\n' '{ "permission": "allow" }'
	exit 0
fi

jq -n \
	--arg user 'Blocked: `gh pr create` requires `--repo` so the PR opens on your fork, not upstream.' \
	--arg agent 'gh pr create without --repo targets the upstream parent on forks. Re-run with an explicit fork repo, e.g. `gh pr create --repo mpm-anysphere/vikunja --base main --head <branch>`.' \
	'{permission: "deny", user_message: $user, agent_message: $agent}'
exit 0
