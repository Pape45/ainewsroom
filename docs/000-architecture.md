# 000 — System Architecture for AI Newsroom

Last updated: 2025-09-06

Status: Phase 0 (documentation). Operator-approved inputs captured; defaults chosen where requested.

## 1) System Overview & Context

Pipeline: ingest → normalize → deduplicate → score → select → generate (outline → sections → consistency) → fact/citation map → human review (when required) → publish → distribute (sitemaps/social) → analytics/observability.

- Ingestion: curated RSS/Atom feeds, Hacker News API, Reddit API, arXiv API/RSS, YouTube channels. Respect robots.txt and each API ToS; no paywall bypass.
- Ranking/Selection: feature-driven scoring (recency, authority, uniqueness, velocity proxies), thresholds configured per source type.
- Generation: LLM via OpenRouter with budget guardrails; grounding via source snippets; produce source_map.json mapping claims to URLs.
- Human-in-the-loop: auto-publish only when score ≥ 0.8 and ≥2 corroborating sources; sensitive categories require review (safety, policy, ethics, employment, vulns).
- Publish: render article pages with JSON-LD NewsArticle; update XML sitemap + Google News sitemap (last 48h, ≤1,000 items per News sitemap); purge caches.
- Distribution: web, RSS; V2 social syndication.
- Telemetry: request logs, queue metrics, publish timings; PostHog client and server analytics (project id provided).

## 2) Tech Stack (defaults unless the operator overrides)

- Web app: Next.js App Router (TypeScript), Tailwind CSS, shadcn/ui, MDX where helpful; Server Components for perf.
- Backend: Next.js Route Handlers + Server Actions for internal APIs.
- DB: PostgreSQL via Prisma (strict types). Tables: sources, items, articles, article_sections, article_sources, users, roles, jobs, budgets, events.
- Queue/cron: BullMQ + Redis; scheduled pulls per source class; per-article idempotency keys.
- Search: Meilisearch (swap to OpenSearch later if needed).
- LLM access: OpenRouter gateway with model routing, per-day/per-month spend caps, fallbacks.
- Ingestion: RSS parser; HN (official API); Reddit (Data API, OAuth); arXiv (API/RSS); YouTube (embed-only; no Data API for V1).
- Observability: OpenTelemetry traces, structured logs, Sentry/Equiv; health checks.
- Security: NextAuth (admin-only in V1) or minimal password/magic-link hybrid; RBAC; rate limiting; CSP; SSRF-safe image proxy; secret management via env.
- Deploy: Docker Compose (linux/arm64), Caddy reverse proxy/HTTPS, GitHub Actions CI/CD, images to GHCR, .env via GitHub Secrets.
- Infra: Postgres, Redis, optional Meilisearch, app, ingest worker, Caddy in compose with healthchecks.

References: Next.js App Router, Route Handlers, sitemap metadata APIs.[^next-app][^next-route][^next-sitemap]

## 3) Branding & Domain

- Brand: AI Newsroom (tagline: “The fastest, cited updates in AI for builders and decision‑makers”). Logo: generate simple SVG logomark + wordmark (dark/auto mode). Colors: neutral dark with electric blue accent; typography: Inter for UI, Newsreader/Georgia style for long‑form.
- Domain: ainewsroom.news (apex). DNS: Cloudflare. Redirect: www → apex (301). Subdomains: api.ainewsroom.news (app/API), cdn.ainewsroom.news (CloudFront), img.ainewsroom.news (image proxy), s.ainewsroom.news (meilisearch optional).

## 4) Data Model (ERD, textual)

- sources(id, kind[rss|hn|reddit|arxiv|youtube], url, name, trust_score, last_pull_at, active)
- items(id, source_id→sources, ext_id, title, url, published_at, author, raw, cleaned, hash_title, hash_body, dedup_key, score_features JSONB)
- articles(id, item_id→items nullable, slug, status[draft|pending_review|approved|published|rejected], score, section_count, hero_image, seo_title, seo_description, published_at)
- article_sections(id, article_id→articles, idx, heading, body_md)
- article_sources(id, article_id→articles, claim_ref, source_url, confidence)
- users(id, email, role[admin|editor|reviewer], status, last_login_at)
- jobs(id, kind[pull|score|generate|publish], key, state, attempts, error, created_at, updated_at)
- budgets(id, provider, daily_limit, monthly_limit, spent_today, spent_month)
- events(id, entity, entity_id, type, payload JSONB, created_at)

Indexes: unique(items.dedup_key), unique(items.ext_id, source_id), GIN(items.score_features), full-text on items.cleaned and articles.body_md (or Meilisearch primary index).

## 5) Queues & Topics

- pull:rss, pull:hn, pull:reddit, pull:arxiv
- dedup:index
- score:item
- draft:generate_outline, draft:generate_section, draft:consistency_pass
- draft:factcheck
- publish:render, publish:sitemaps, publish:purge

Idempotency key: article:<item_id> or article:<ext_id>.

## 6) State Machine — Article Lifecycle

- new_item → deduped → scored → selected → drafting → factchecked → pending_review | auto_publish → published → distributed
- Guards:
  - Auto-publish only if score ≥ 0.8 and ≥2 corroborating sources; else pending_review.
  - Sensitive categories force pending_review.

## 7) Ingestion Rules & Compliance

- Google News sitemap: include only articles from last 2 days; ≤1,000 items per news sitemap. Split if needed.[^news-sitemap]
- Standard XML sitemap and RSS/Atom best-practices for freshness.[^sitemap-best]
- Robots: follow robots.txt per RFC 9309 and Google interpretation.[^rfc9309][^robots-google]
- Reddit: follow Data API Terms (OAuth, rate limits, no training data usage unless permitted).[^
reddit-terms]
- YouTube: embed via official iframe; use privacy-enhanced “youtube‑nocookie.com”.[^
privacy-enhanced] Respect YouTube ToS and API/dev policies when applicable.[^yt-tos][^yt-api]

## 8) SEO & Structured Data

- Use JSON‑LD NewsArticle (or Article) with headline, dates, author, publisher (Org + logo), image, section, canonical, and optional mainEntityOfPage. Google’s Article structured data guide applies to NewsArticle.[^article-sd][^schema-news]
- Technical SEO: canonical URLs, hreflang (later), lazy images, OG/Twitter meta, Core Web Vitals budget, split News sitemaps by recency.

## 9) Security & Privacy

- Auth: Admin-only in V1; email login (SES) or password for the admin seed user; expand to SSO (Google/GitHub) later.
- Rate limiting on admin/API. CSP, XSS/CSRF hardening. SSRF‑safe image proxy with allowlist, 5 MB cap, 5s timeout, EXIF strip.
- Consent: GDPR two‑click embeds for YouTube; default region focus EU/US.
- Secrets: no hard-coded secrets; all via env/secret store; rotate keys.

## 10) Observability

- PostHog analytics (client + server) with given project key.
- OpenTelemetry traces through ingestion/generation/publish with article/job IDs; structured logs; error capture to Sentry.

## 11) Scaling & Cost

- Horizontal scale: separate ingest worker from web; Redis/DB sizing; Meilisearch optional.
- Costs: cap OpenRouter at $50/month, $5/day; degrade to cheaper models when exceeded; hard-fail only when no acceptable fallback.

## 12) Legal & Compliance

- Attribution: every non-trivial claim mapped to a source; short quotes (≤2–3 sentences); link prominently to originals.
- Videos: embed-only from official sources; honor embedding restrictions; no rehosting.
- Paywalls: never bypass; request licensed content from admin.

## 13) Source Catalog (initial)

- RSS/Atom (selected): Machine Learning Mastery, MarkTechPost, BAIR Blog, Google Research Blog, Analytics Vidhya, KDnuggets, AWS ML Blog, CMU ML Blog, O’Reilly Radar (AI/ML, Emerging Tech), OpenAI Blog, DeepMind Blog, Towards Data Science, TOPBOTS, Datumbox, BigML, O’Reilly “Generative AI in the Real World”. (See 010 brief for URLs.)
- APIs: Hacker News (official API); arXiv API; Reddit Data API (OAuth, subreddits curated); YouTube embeds.

## 14) Deployment (ARM64 VPS)

- Docker Compose with linux/arm64 images; buildx for multi-arch if needed.
- Caddy reverse proxy with HTTPS for ainewsroom.news and subdomains; Cloudflare DNS.
- GH Actions: lint, typecheck, test, build images (arm64), push to GHCR, deploy via SSH. Systemd unit optional.

---

### Footnotes

[^news-sitemap]: Google Search Central — Create a News Sitemap (only last 2 days; 1,000 items per News sitemap) — https://developers.google.com/search/docs/crawling-indexing/sitemaps/news-sitemap
[^sitemap-best]: Google Search Central — Best practices for XML sitemaps and RSS/Atom — https://developers.google.com/search/blog/2014/10/best-practices-for-xml-sitemaps-rssatom
[^rfc9309]: IETF RFC 9309 — Robots Exclusion Protocol — https://datatracker.ietf.org/doc/html/rfc9309
[^robots-google]: Google Search Central — robots.txt guide/interpretation — https://developers.google.com/search/docs/crawling-indexing/robots/robots_txt
[^article-sd]: Google Search Central — Article (Article, NewsArticle, BlogPosting) structured data — https://developers.google.com/search/docs/appearance/structured-data/article
[^schema-news]: schema.org — NewsArticle — https://schema.org/NewsArticle
[^next-app]: Next.js Docs — App Router — https://nextjs.org/docs/app
[^next-route]: Next.js Docs — Route Handlers — https://nextjs.org/docs/app/api-reference/file-conventions/route
[^next-sitemap]: Next.js Docs — Metadata Files: sitemap.xml — https://nextjs.org/docs/app/api-reference/file-conventions/metadata/sitemap
[^reddit-terms]: Reddit — Data API Terms — https://redditinc.com/policies/data-api-terms
[^privacy-enhanced]: YouTube Help — Privacy‑enhanced mode (youtube‑nocookie.com) — https://support.google.com/youtube/answer/171780?hl=en
[^yt-tos]: YouTube — Terms of Service — https://www.youtube.com/static?template=terms
[^yt-api]: Google Developers — YouTube Embedded Players and Player Parameters — https://developers.google.com/youtube/player_parameters

### Bibliography

- Google Search Central: News sitemap, Article structured data, robots.txt
- IETF RFC 9309: Robots Exclusion Protocol
- schema.org: NewsArticle
- Reddit Data API Terms
- YouTube Help/Developers: Privacy‑enhanced mode; Player parameters
- Next.js docs: App Router, Route Handlers, Metadata sitemap

