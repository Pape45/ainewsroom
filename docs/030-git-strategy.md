# 030 — Git Strategy & PR Process

Last updated: 2025-09-06

## Branching & Protection
- Trunk-based: protected `main`; short-lived feature branches
- Branch prefixes: `feat/…`, `fix/…`, `chore/…`, `docs/…`
- Required reviews on `main`; required status checks (lint, typecheck, tests, build images)
- Signed commits preferred; no secrets committed; masks in logs

## Conventional Commits
- feat: new user-facing functionality
- fix: bug fix
- chore: tooling, deps, CI, infra
- docs: documentation-only changes
- refactor/test/perf/build as needed

## PR Template (checks)
- Description: what/why, screenshots if UI
- Links: roadmap task ID(s) in /docs/020-roadmap-v1.md
- Acceptance Criteria: list and evidence
- Tests: unit/e2e added/updated; coverage unchanged or improved
- Perf/SEO: any impact on CWV, sitemaps, JSON-LD
- Security/Compliance: secrets, ToS/robots adherence
- Observability: logs/traces/metrics added as specified

## Reviews & Merging
- Squash merge to keep trunk linear; auto-delete branches
- CI must be green; if flaky, fix or quarantine with issue reference
- Re-request review after substantive changes

## Releases & Tags
- Tag releases: v0.x for V1 iterations; changelog entries in /docs/CHANGELOG.md
- Hotfixes: `fix/*` branches off `main` with targeted scope

## CI/CD Requirements
- Lint, typecheck, unit tests (Vitest), integration tests (Playwright), build images (ARM64 via buildx)
- Push to GHCR on merge to `main`; deploy to VPS via SSH

## Git Hygiene for Generated & Secrets
- Never commit secrets; provide `.env.example` only
- Generated files: commit only when necessary (lockfiles yes; build artifacts no)
- Large assets: store in object storage/CDN; keep repo lean

## Backports (if needed later)
- If a long-lived release branch exists, use `cherry-pick -x` and reference original PR/commit

## Risk Management
- Feature flags or env toggles for risky changes
- Rollback: previous image tag retained; Caddy reload is idempotent

## References
- Next.js App Router docs[^next-app]
- Google News sitemap & structured data for PR SEO checks[^news-sitemap][^article-sd]
- Robots rules (RFC 9309) for compliance[^rfc9309]

[^next-app]: https://nextjs.org/docs/app
[^news-sitemap]: https://developers.google.com/search/docs/crawling-indexing/sitemaps/news-sitemap
[^article-sd]: https://developers.google.com/search/docs/appearance/structured-data/article
[^rfc9309]: https://datatracker.ietf.org/doc/html/rfc9309

