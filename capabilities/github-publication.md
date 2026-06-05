# Evidence-first GitHub repo publication

Status: seeded

## Trigger

Use when publishing repos, forks, public artifacts, or GitHub organization pages where visibility matters.

## Procedure

1. Create the repo with GitHub CLI or API.
2. Push a minimal, truthful artifact.
3. Verify authenticated metadata.
4. Verify unauthenticated API visibility.
5. Verify unauthenticated web visibility.
6. Report both successful and failed checks.

## Commands

```bash
gh api repos/OWNER/REPO --jq '{full_name,private,visibility,html_url}'
curl -s -o /tmp/repo-public.json -w '%{http_code}\n' https://api.github.com/repos/OWNER/REPO
curl -s -L -o /tmp/repo-public.html -w '%{http_code} %{url_effective}\n' https://github.com/OWNER/REPO
```

## Verification

A repo is not publicly published until unauthenticated API and web checks return non-404 status.

## Failure modes

- Authenticated GitHub says public while logged-out users get 404.
- Token scopes allow repo creation but not workflow creation.
- Global git URL rewrites accidentally embed tokens in remotes.

## Falsifier

If a logged-out browser/API cannot fetch it, it is not public, no matter what the authenticated API says. This is obvious. That has not historically prevented it from being missed.
