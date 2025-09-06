# 010 — Product Brief & Personas

Last updated: 2025-09-06

## Vision & Positioning
AI Newsroom delivers fast, high-signal, citation-first AI news for builders and decision-makers. We combine rigorous source attribution with helpful developer context (links, usage notes) and a professional editing flow.

## Goals
- Coverage: timely aggregation from trusted AI sources and communities
- Quality: grounded, cited, and consistent articles with human review where needed
- SEO & Distribution: Google News-ready, structured data, fast pages
- Editorial UX: moderation queue, diffs, source map, prompt inspector
- DX & Reliability: containerized, observable, ARM64-compatible

Non-goals (V1): real-time push notifications, social syndication, multi-lingual generation, deep paywall integrations.

## Personas
- AI-curious reader: wants concise, trustworthy summaries; follows Top Stories
- Developer: wants links to repos, APIs, tutorials, quick how-tos
- Researcher: cares about original sources, arXiv links, claims-to-citations
- CTO/PM: wants impact context, vendor roadmaps, risks, enterprise signals
- Breaking-news visitor: skim headline/lede, quick context, source links

## Editorial Product & Types
- Breaking: short, cited, timely updates (lede answers what/why)
- Explainer: context/background, diagrams or visuals later
- Tutorial-flavored News: dev-first, includes install/use snippets and links
- Weekly Recap: curated highlights with clusters and crosslinks

Tone & Style
- People-first, clear headlines, avoid hype; include why-it-matters
- Quotes: max 2–3 sentences; link to originals; no wholesale copying

## Human-in-the-loop & Quality Bars
- Auto-publish: score ≥ 0.8 + ≥ 2 corroborating sources
- Always review: safety incidents, policy/regulation, ethics, employment, vulns
- Factuality: each non-trivial claim mapped to a source (source_map.json)
- Recency: prioritize last 48h for News sitemap inclusion[^news-sitemap]

## SEO Strategy
- Structured Data: JSON-LD NewsArticle or Article for all stories[^article-sd][^schema-news]
- Sitemaps: standard XML sitemap + Google News sitemap for last 2 days, ≤1,000 items per News sitemap[^news-sitemap][^sitemap-best]
- Robots: follow robots.txt (RFC 9309) and Google’s interpretation[^rfc9309][^robots-google]
- Technical SEO: canonical, OG/Twitter, fast CLS/LCP/INP, clean internal linking, author pages, E-E-A-T-like signals (org, logo, staff bios)

## Initial Sources (curated)
RSS/Atom (examples provided by operator; confirm availability periodically):
- Machine Learning Mastery — https://machinelearningmastery.com/blog/feed/
- MarkTechPost — https://marktechpost.com/feed
- BAIR Blog — https://bair.berkeley.edu/blog/feed.xml
- Google Research — https://blog.google/technology/ai/rss
- Analytics Vidhya — https://www.analyticsvidhya.com/feed/
- KDnuggets — https://kdnuggets.com/feed
- AWS ML Blog — https://aws.amazon.com/blogs/machine-learning/feed/
- CMU ML Blog — https://blog.ml.cmu.edu/feed
- O’Reilly Radar (AI/ML, Emerging Tech) — https://www.oreilly.com/radar/topics/ai-ml/feed/; https://www.oreilly.com/radar/topics/emerging-tech/feed/
- OpenAI — https://openai.com/news/rss.xml
- DeepMind — https://deepmind.google/blog/rss.xml
- Towards Data Science — https://towardsdatascience.com/feed
- TOPBOTS — https://www.topbots.com/feed/
- Datumbox — https://blog.datumbox.com/feed; BigML — https://blog.bigml.com/feed
- O’Reilly Generative AI podcast — https://www.oreilly.com/radar/topics/generative-ai-in-the-real-world-podcast/feed/

APIs & Streams
- Hacker News (official API)[^hn-api]
- arXiv API (cs.AI, cs.CL, cs.LG, etc.)[^arxiv-api]
- Reddit Data API (r/MachineLearning, r/artificial, r/ArtificialInteligence, r/LearnMachineLearning, r/MachineLearningPapers, r/deeplearning, r/LocalLLaMA, r/ChatGPT, r/OpenAI, r/bard, r/generativeAI, r/midjourney, r/StableDiffusion)[^reddit-terms]
- YouTube channels (embed-only; privacy-enhanced mode): Two Minute Papers, Matt Wolfe, AI Explained, Tech With Tim, The AI Advantage[^privacy-enhanced]

Compliance
- robots.txt honored; paywalled content blocked unless licensed; embed only for videos

## Admin Experience (V1)
- Moderation queue: status filters, score, sensitivity flags
- Draft detail: sources, citations, diff view, license checklist
- Prompt inspector: high-level prompt text (parameters redacted)
- Actions: request operator action (keys, paywalled copy), retry/fix pipeline steps

## KPIs
- Clicks from Top Stories/Discover; dwell time; return visitors; newsletter signups
- Editorial: % auto-published vs reviewed; time to publish; citation coverage
- Ops: queue latency; errors per 1000 jobs; LLM cost per article

## Consent & Region
- GDPR consent: two‑click embeds (YouTube privacy‑enhanced mode)
- Regions: global; default focus EU/US timezones

## Analytics
- PostHog enabled (project id provided)
- Server events for ingestion/generation/publish; client events for page engagement

## V2 Roadmap (hints)
- Social syndication and summary cards
- Notifications and digests
- Multi-lingual publishing
- Video summaries and voice-over

---

### Footnotes
[^news-sitemap]: Google Search Central — Create a News Sitemap — https://developers.google.com/search/docs/crawling-indexing/sitemaps/news-sitemap
[^sitemap-best]: Google Search Central — Best practices for XML sitemaps and RSS/Atom — https://developers.google.com/search/blog/2014/10/best-practices-for-xml-sitemaps-rssatom
[^article-sd]: Google Search Central — Article structured data (Article, NewsArticle, BlogPosting) — https://developers.google.com/search/docs/appearance/structured-data/article
[^schema-news]: schema.org — NewsArticle — https://schema.org/NewsArticle
[^rfc9309]: IETF RFC 9309 — Robots Exclusion Protocol — https://datatracker.ietf.org/doc/html/rfc9309
[^robots-google]: Google Search Central — robots.txt guide/interpretation — https://developers.google.com/search/docs/crawling-indexing/robots/robots_txt
[^hn-api]: Hacker News — Official API — https://github.com/HackerNews/API
[^arxiv-api]: arXiv — API Access — https://info.arxiv.org/help/api/index.html
[^reddit-terms]: Reddit — Data API Terms — https://redditinc.com/policies/data-api-terms
[^privacy-enhanced]: YouTube Help — Privacy‑enhanced mode (youtube‑nocookie.com) — https://support.google.com/youtube/answer/171780?hl=en

### Bibliography
- Google Search Central: News sitemap, Article structured data, robots.txt
- IETF RFC 9309: Robots Exclusion Protocol
- schema.org: NewsArticle
- Reddit Data API Terms
- Hacker News API; arXiv API
- YouTube Help: privacy‑enhanced mode

