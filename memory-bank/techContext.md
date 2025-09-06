# Technical Context

**Created:** September 6, 2025  
**Project:** AI Newsroom (ainewsroom.news)  

## Technology Stack Overview

### Core Technologies Chosen

#### Frontend & Web Framework
- **Next.js 15 with App Router:** Modern React framework with server-side rendering
- **TypeScript:** Type safety and better developer experience
- **Tailwind CSS:** Utility-first CSS framework for rapid styling
- **shadcn/ui:** High-quality, accessible React components
- **MDX:** Markdown with JSX for rich article content

#### Backend & Database
- **PostgreSQL 16+:** Robust relational database for structured data
- **Prisma ORM:** Type-safe database client with excellent TypeScript integration
- **Redis:** In-memory store for caching and job queues
- **BullMQ:** Reliable job queue system for content processing

#### AI & Content Processing
- **OpenRouter:** Unified API access to multiple LLM providers
- **Model Strategy:** GPT-4o → Claude 3.5 → Llama 3.1 (fallback hierarchy)
- **Budget Controls:** $50/month cap with auto-cutoffs and monitoring

#### Infrastructure
- **Platform:** ARM64 Ubuntu 24.04 VPS (production environment)
- **Containerization:** Docker + Docker Compose for consistent deployment
- **Reverse Proxy:** Caddy 2.x with automatic HTTPS and HTTP/3
- **CDN:** AWS CloudFront with S3 origin for global distribution

#### External Services
- **Email:** Amazon SES with verified domain (ainewsroom.news)
- **Analytics:** PostHog for user behavior tracking
- **DNS:** Cloudflare for domain management and security
- **Storage:** Amazon S3 for file storage and image optimization

## Development Environment

### Local Setup Requirements
```bash
# Required software
- Node.js 18+ (currently using v22.19.0)
- Docker & Docker Compose v2.39.1+
- Git with GPG signing configured
- PostgreSQL 16+ (via Docker)
- Redis 7+ (via Docker)

# Environment verification
uname -m        # Should show: aarch64 (ARM64)
node -v         # Should show: v22.19.0+
docker -v       # Should show: Docker version 28.3.3+
```

### Configuration Management
- **Environment Variables:** Managed via .env files (never committed)
- **Secrets:** GitHub Secrets for CI/CD, AWS SSM for production
- **Configuration Files:** TypeScript configs shared across workspaces
- **Feature Flags:** Environment-based feature toggles

### Database Strategy
- **Development:** Local PostgreSQL via Docker Compose
- **Production:** Managed PostgreSQL with connection pooling
- **Migrations:** Prisma migrations with rollback support
- **Seeding:** Automated test data generation for development

## Architecture Decisions

### Why Next.js App Router?
- **Modern React:** Server Components and streaming for better performance
- **API Integration:** Route handlers and Server Actions for backend logic
- **SEO Optimization:** Built-in metadata API and static generation
- **TypeScript Support:** First-class TypeScript integration
- **Deployment:** Excellent Vercel/Docker deployment options

### Why PostgreSQL + Prisma?
- **Relational Data:** Articles, sources, users have clear relationships
- **ACID Compliance:** Data integrity critical for journalism platform
- **Full-Text Search:** Built-in search capabilities for content
- **JSON Support:** Flexible storage for metadata and analytics
- **Type Safety:** Prisma generates TypeScript types from schema

### Why OpenRouter for AI?
- **Model Diversity:** Access to multiple providers (OpenAI, Anthropic, Google)
- **Cost Control:** Transparent pricing and usage monitoring
- **Reliability:** Automatic failover between models
- **Budget Management:** Built-in spending controls and alerts

### Why ARM64 Architecture?
- **Performance:** Better performance-per-dollar for content processing
- **Efficiency:** Lower energy consumption for 24/7 operations
- **Future-Proof:** Industry trend toward ARM in server environments
- **Cost:** More affordable compute resources

## Technical Constraints

### Performance Requirements
- **Page Load:** <3 seconds on mobile, <2 seconds on desktop
- **API Response:** <200ms average response time
- **Search:** <500ms full-text search across all content
- **Generation:** <2 minutes average article generation time

### Security Requirements
- **Content Security Policy:** Strict CSP with nonce-based scripts
- **Rate Limiting:** 100 requests/minute per IP, sliding window
- **Input Validation:** Zod schemas for all API inputs
- **Authentication:** NextAuth.js with secure session management
- **HTTPS Only:** All traffic encrypted, HSTS headers enabled

### Scalability Constraints
- **Database Connections:** Pool size managed by environment
- **Queue Workers:** Horizontally scalable job processing
- **Cache Strategy:** Redis for session/API cache, CDN for static assets
- **Image Processing:** Lazy loading, WebP/AVIF conversion

### Legal & Compliance
- **GDPR:** Consent management for analytics and embeds
- **Copyright:** Fair use compliance with quote length limits
- **Attribution:** Complete source citation requirements
- **Privacy:** Minimal data collection, user data portability

## Dependencies & Integrations

### Critical External Dependencies
```json
{
  "runtime": {
    "next": "^15.0.0",
    "react": "^18.2.0", 
    "typescript": "^5.0.0",
    "prisma": "^5.0.0",
    "@prisma/client": "^5.0.0",
    "bullmq": "^4.0.0",
    "redis": "^4.0.0"
  },
  "ai": {
    "openai": "^4.0.0",
    "@openrouter/ai-sdk": "^1.0.0"
  },
  "ui": {
    "tailwindcss": "^3.4.0",
    "@radix-ui/react-*": "^1.0.0",
    "lucide-react": "^0.300.0"
  },
  "auth": {
    "next-auth": "^5.0.0",
    "@auth/prisma-adapter": "^1.0.0"
  }
}
```

### API Integrations
- **OpenRouter API:** Content generation with multiple model access
- **Reddit API (PRAW):** Subreddit monitoring for AI discussions
- **Hacker News API:** Technology news aggregation
- **arXiv API:** Academic paper monitoring (cs.AI, cs.CL, cs.LG)
- **YouTube Data API:** Channel monitoring for AI content creators
- **PostHog API:** User analytics and event tracking

### Development Tools
- **Code Quality:** ESLint, Prettier, Husky for git hooks
- **Testing:** Vitest for unit tests, Playwright for E2E
- **Monitoring:** OpenTelemetry for distributed tracing
- **Documentation:** TypeDoc for API docs, Markdown for guides

## Deployment Architecture

### Container Strategy
```dockerfile
# Multi-stage builds for optimization
FROM node:18-alpine AS base
# Dependencies stage
FROM base AS deps
# Build stage  
FROM base AS builder
# Runtime stage
FROM base AS runner
```

### Docker Compose Services
```yaml
services:
  web:          # Next.js application
  ingest:       # Content ingestion worker
  postgres:     # Database
  redis:        # Cache and queues
  caddy:        # Reverse proxy
  meilisearch:  # Search engine (optional)
```

### CI/CD Pipeline
- **GitHub Actions:** Automated testing and deployment
- **Multi-arch Builds:** ARM64 and AMD64 compatibility
- **Security Scanning:** Dependency vulnerability checks
- **Automated Deployment:** Merge to main triggers production deploy

### Monitoring & Observability
- **Health Checks:** Kubernetes-style liveness/readiness probes
- **Structured Logging:** JSON logs with correlation IDs
- **Metrics Collection:** OpenTelemetry with custom metrics
- **Error Tracking:** Centralized error collection and alerting

## Performance Optimization

### Frontend Optimizations
- **Server Components:** Minimize client-side JavaScript
- **Image Optimization:** Next.js Image component with WebP/AVIF
- **Bundle Splitting:** Automatic code splitting for routes
- **Prefetching:** Strategic prefetching of critical resources

### Backend Optimizations
- **Database Indexing:** Optimized indexes for common queries
- **Connection Pooling:** Efficient database connection management
- **Caching Strategy:** Multi-layer caching (Redis, CDN, browser)
- **Queue Optimization:** Batch processing and priority queues

### SEO Technical Implementation
- **Structured Data:** Complete JSON-LD implementation
- **Sitemap Generation:** Automated XML and News sitemaps
- **Meta Tags:** Dynamic Open Graph and Twitter Card generation
- **Core Web Vitals:** Performance monitoring and optimization

## Development Workflow

### Code Organization
```
/apps/web/           # Main Next.js application
  /app/              # App Router pages and API routes
  /components/       # Reusable React components
  /lib/              # Utility functions and configurations
  /types/            # TypeScript type definitions

/packages/           # Shared packages
  /ui/               # Shared UI components
  /config/           # Shared configurations

/services/           # Background services
  /ingest/           # Content ingestion worker

/infra/              # Infrastructure configuration
  /docker/           # Dockerfiles and compose files
  /caddy/            # Reverse proxy configuration
```

### Testing Strategy
- **Unit Tests:** Component and utility function testing
- **Integration Tests:** API endpoint and database testing
- **E2E Tests:** Critical user journey automation
- **Performance Tests:** Load testing for scalability validation

### Quality Gates
- **Type Checking:** Strict TypeScript compilation
- **Linting:** ESLint with custom rules for consistency
- **Formatting:** Prettier for code style enforcement
- **Security:** Dependency scanning and secret detection

This technical context ensures all implementation decisions align with our performance, security, and scalability requirements while maintaining developer productivity and code quality.
