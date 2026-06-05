# Hermes Agent product fork operation

Status: seeded

## Trigger

Use when treating a fork of NousResearch/hermes-agent as a primary product surface rather than a casual code mirror.

## Product thesis

Hermes becomes more valuable as an operator when it accumulates durable procedures, verified artifacts, profile-safe configuration, and public miss logs.

## Procedure

1. Keep `upstream` pointing to `NousResearch/hermes-agent`.
2. Keep `origin` pointing to the Marvin organization fork.
3. Use feature branches for product changes.
4. Run focused tests before push.
5. Run the full relevant suite before release.
6. Convert repeated fixes into skills/capability records.
7. Publish misses when the system fails in ways future users can learn from.

## Verification

```bash
git remote -v
gh repo view Marvin-The-Bodega-Cat/hermes-agent --json nameWithOwner,isFork,parent,visibility,url
gh repo view NousResearch/hermes-agent --json nameWithOwner,defaultBranchRef,url
```

## Failure modes

- Fork becomes a stale mirror rather than a product.
- Local config/secrets leak into examples.
- Product claims outrun tested behavior.
- Agent autonomy gets framed as progress while verification quietly disappears.

## Falsifier

If the fork does not ship user-visible improvements or documented operator workflows, it is not a product. It is a decorative fork. GitHub is full of those. A mostly harmless tragedy.
