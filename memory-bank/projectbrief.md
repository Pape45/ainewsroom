# AI Newsroom - Project Brief

**Project Name:** AI Newsroom  
**Domain:** ainewsroom.news  
**Created:** September 6, 2025  
**Owner:** Pape45  

## Mission Statement

Build a production-grade AI news website that autonomously aggregates, curates, and publishes high-quality AI/tech news with human oversight, strong SEO, and professional presentation.

## Core Requirements

### Technical Stack
- **Platform:** ARM64 Ubuntu 24.04 VPS
- **Frontend:** Next.js App Router + TypeScript + Tailwind + shadcn/ui
- **Database:** PostgreSQL + Prisma
- **Queue:** BullMQ + Redis
- **Search:** Meilisearch
- **Containers:** Docker + Docker Compose
- **Proxy:** Caddy (automatic HTTPS)
- **CI/CD:** GitHub Actions

### AI & Content
- **LLM Gateway:** OpenRouter (unified access)
- **Budget:** $50/month initially, free models preferred
- **Sources:** RSS feeds, Reddit, Hacker News, arXiv, YouTube
- **Content Types:** Breaking news, explainers, dev-focused tutorials
- **Quality:** Human review for sensitive topics, auto-publish for high-confidence

### Infrastructure 
- **Domain:** ainewsroom.news (apex)
- **DNS:** Cloudflare
- **Email:** Amazon SES
- **Storage:** Amazon S3 + CloudFront CDN
- **Analytics:** PostHog
- **Monitoring:** Built-in telemetry, Sentry for V2+

### Compliance & SEO
- **GDPR:** Consent management for embeds
- **Target:** Global (Europe/America focus)
- **SEO:** Google News sitemaps, structured data, Core Web Vitals
- **Ethics:** Citation requirements, quote limits, embed-only videos

## Non-Negotiables
1. Production reliability and security
2. Legal compliance with citations
3. Zero hardcoded secrets
4. Strong SEO optimization
5. ARM64 container compatibility
6. Human oversight for sensitive content
7. Professional presentation quality

## Success Criteria for V1
- Fully documented with web-cited sources
- Running behind HTTPS with Caddy
- Admin interface with moderation queue
- Automated RSS ingestion and storage
- AI-generated articles with citations
- Published articles with JSON-LD and sitemaps
- Passing CI/CD pipeline
- No secrets in repository
