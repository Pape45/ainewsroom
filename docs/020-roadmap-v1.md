# 020 — Roadmap V1 (Executable)

Last updated: 2025-09-06

This roadmap decomposes V1 into verifiable tasks with clear inputs/outputs, files to touch, acceptance criteria, telemetry, and Stop & Ask gates. Update this file after each completed task.

Legend — Branch prefixes: feat/, fix/, chore/. Link branches/PRs back to task IDs here. CI gates: lint, typecheck, test, build.

BLOCKERS (live log)
- None yet. Secrets will be requested at Stop & Ask gates.

## 0. Repo Bootstrap & Standards

Objective: Initialize monorepo structure, configs, docs, and templates.
Branch: feat/bootstrap
Files/Dirs:
- /apps/web (Next.js App Router, TS)
- /packages/ui, /packages/config (eslint, tsconfig, prettier)
- /services/ingest (Node worker)
- /services/meilisearch (optional)
- /infra/docker (Dockerfiles, compose.yml, .dockerignore), /infra/caddy/Caddyfile, /infra/github (workflows)
- /prisma (schema.prisma), /scripts (bootstrap, health checks)
- /docs (already created), .env.example, CODEOWNERS, SECURITY.md, CONTRIBUTING.md, LICENSE, README.md
Acceptance:
- Yarn/PNPM workspaces resolve; lint/typecheck pass locally
- CI workflow skeleton runs (no deploy)
Telemetry:
- N/A
Stop & Ask:
- Confirm package manager (pnpm default) and Node LTS version

## 1. Branding & Legal Pages (scaffold)

Objective: Implement initial theme, typography, colors, and SVG logo; scaffold legal pages.
Branch: feat/branding-legal
Files:
- apps/web/app/(marketing)/layout.tsx, globals.css, theme config
- apps/web/public/brand/logo.svg (generated placeholder)
- apps/web/app/(legal)/privacy/page.tsx; terms/page.tsx; about/page.tsx; contact/page.tsx
Acceptance:
- Dark/auto mode; Inter + Newsreader; brand colors applied
- Pages routable and included in sitemap
Telemetry:
- Page view events for legal pages
Stop & Ask:
- None

## 2. Database & Prisma Schema

Objective: Define schema tables (sources, items, articles, etc.), generate client, run migrations.
Branch: feat/db-prisma
Files:
- prisma/schema.prisma; prisma/migrations/*; scripts/dev-db-init.ts
Acceptance:
- Prisma migrate dev applies locally/in CI
- Seed creates initial admin user and base sources
Telemetry:
- DB connection healthcheck
Stop & Ask:
- Provide admin seed password OR enable SES magic link only (choose one)

## 3. Ingestion MVP: RSS + HN

Objective: Scheduled ingestion for curated RSS and Hacker News API; dedup and persist items.
Branch: feat/ingest-mvp
Files:
- services/ingest/src/index.ts (BullMQ workers)
- services/ingest/src/jobs/pull_rss.ts, pull_hn.ts, dedup.ts, score.ts
- apps/web/lib/db/* (shared db client)
- infra/docker/compose.yml (worker + schedules)
Acceptance:
- Items fetched, deduped (URL/title/text MinHash), stored; basic scoring
- Admin list in web UI (read-only)
Telemetry:
- Job durations, errors, items pulled per source
Stop & Ask:
- Rate limits confirmation; extend source list vs staged rollout

## 4. Admin Auth (V1 minimal)

Objective: Admin-only access with email+password seed OR SES magic link; RBAC (admin, editor, reviewer) enforced.
Branch: feat/admin-auth
Files:
- apps/web/app/(admin)/login/page.tsx; api/auth/* (Route Handlers)
- apps/web/lib/auth/* (NextAuth or custom minimal)
Acceptance:
- Admin can log in; other routes protected; session persisted; no public registration
Telemetry:
- Login success/fail events; session duration
Stop & Ask:
- Finalize auth mode: seed password now or SES magic link now

## 5. Admin Panel: Moderation Queue & Draft Detail

Objective: Approvals interface with status filters, diff view, source map, license checklist.
Branch: feat/admin-panel
Files:
- apps/web/app/(admin)/queue/page.tsx; draft/[id]/page.tsx
- apps/web/components/admin/* (source map viewer, diff component)
- apps/web/app/api/admin/*
Acceptance:
- Moderation queue shows drafts; draft detail displays sources/citations/diff; actions to approve/reject/ask
Telemetry:
- Approve/reject counts; time-in-state
Stop & Ask:
- None

## 6. Generation Pipeline (Outline → Sections → Consistency)

Objective: LLM-based drafting with grounding and source_map.json per article.
Branch: feat/generation-pipeline
Files:
- services/ingest/src/jobs/generate_outline.ts, generate_section.ts, consistency_pass.ts, factcheck.ts
- apps/web/lib/llm/openrouter.ts (rate limiting/budgets)
- apps/web/lib/articles/pipeline.ts
Acceptance:
- Manual “Generate Draft” for an item produces draft with sections + source_map.json
- Budget caps enforced ($5/day, $50/month); fallback models used when necessary
Telemetry:
- Cost per article; token usage; errors
Stop & Ask:
- Save OpenRouter API key via GitHub Secrets/env

## 7. Publish Pipeline & SEO

Objective: Approve → publish flow; generate JSON-LD; update sitemaps (XML + News); purge caches.
Branch: feat/publish-seo
Files:
- apps/web/app/article/[slug]/page.tsx; lib/seo/jsonld.ts
- apps/web/app/sitemap.xml/route.ts; app/news-sitemap.xml/route.ts
- services/ingest/src/jobs/publish.ts
Acceptance:
- Published article renders with JSON-LD NewsArticle; appears in sitemaps; news-sitemap limited to last 48h and 
≤1,000 items[^news-sitemap]
Telemetry:
- Publish latency; sitemap generation timings
Stop & Ask:
- None

## 8. Image Proxy & Media Policy

Objective: SSRF-safe image proxy with allowlist, caps, timeouts; CloudFront integration.
Branch: feat/image-proxy
Files:
- apps/web/app/api/image-proxy/route.ts
- apps/web/lib/images/*; infra/caddy/Caddyfile (headers)
Acceptance:
- Proxies external images via img.ainewsroom.news; enforces 5 MB cap, 5s timeout, EXIF strip; cache headers: browser 1d, CDN 7d, SWR 1d
Telemetry:
- Proxy hit rate; failures
Stop & Ask:
- Provide allowlist domains to start

## 9. Observability & Analytics

Objective: OpenTelemetry traces, structured logs; PostHog events wired.
Branch: feat/observability
Files:
- packages/config/opentelemetry.ts; apps/web/lib/telemetry/*; services/ingest/lib/telemetry/*
Acceptance:
- Traces for ingestion/generation/publish; PostHog client and server capture key events
Telemetry:
- Enabled by design
Stop & Ask:
- None

## 10. CI/CD, Containers, and Deployment

Objective: Compose stack (ARM64), healthchecks, Caddy HTTPS; GH Actions buildx multi-arch; push to GHCR; deploy via SSH.
Branch: feat/infra-cicd
Files:
- infra/docker/Dockerfile.*; infra/docker/compose.yml; infra/github/workflows/*; infra/caddy/Caddyfile
Acceptance:
- CI green (lint, typecheck, tests, build images); images in GHCR; one-click deploy to VPS; systemd unit optional
Telemetry:
- Workflow runs archived; deployment logs stored
Stop & Ask:
- Target domain mapping in Caddy; Cloudflare DNS records confirmation

## 11. Final V1 QA & Docs

Objective: Validate acceptance criteria and docs; cut release tag.
Branch: chore/v1-qa
Acceptance:
- /docs complete with citations; site runs behind HTTPS; admin login + moderation queue; ingestion of RSS works; generation produces cited draft; publish flow updates sitemaps; CI passes; .env.example exists; no secrets in git
Telemetry:
- Smoke tests green
Stop & Ask:
- Sign-off

---

### References
- News sitemap rules (48h, ≤1,000 items) — Google Search Central[^news-sitemap]
- Article/NewsArticle structured data — Google & schema.org[^article-sd][^schema-news]
- Robots rules — RFC 9309; Google interpretation[^rfc9309][^robots-google]
- Next.js App Router, Route Handlers, sitemap metadata[^next-app][^next-route][^next-sitemap]

[^news-sitemap]: https://developers.google.com/search/docs/crawling-indexing/sitemaps/news-sitemap
[^article-sd]: https://developers.google.com/search/docs/appearance/structured-data/article
[^schema-news]: https://schema.org/NewsArticle
[^rfc9309]: https://datatracker.ietf.org/doc/html/rfc9309
[^robots-google]: https://developers.google.com/search/docs/crawling-indexing/robots/robots_txt
[^next-app]: https://nextjs.org/docs/app
[^next-route]: https://nextjs.org/docs/app/api-reference/file-conventions/route
[^next-sitemap]: https://nextjs.org/docs/app/api-reference/file-conventions/metadata/sitemap

