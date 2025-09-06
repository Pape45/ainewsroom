# System Patterns

**Created:** September 6, 2025  
**Project:** AI Newsroom (ainewsroom.news)  

## Architectural Patterns

### Content Pipeline Pattern
The core system follows a **pipeline architecture** for content processing:

```
Source Detection → Ingestion → Scoring → Generation → Review → Publication → Analytics
```

Each stage is **loosely coupled** through message queues, allowing for:
- Independent scaling of each component
- Failure isolation and recovery
- Easy addition of new processing stages
- Monitoring and observability at each step

### Event-Driven Architecture
The system uses **event-driven patterns** for coordination:

```typescript
// Event types flowing through the system
type ContentEvent = 
  | { type: 'source.detected'; payload: SourceData }
  | { type: 'content.scored'; payload: ScoredContent }
  | { type: 'article.generated'; payload: GeneratedArticle }
  | { type: 'review.completed'; payload: ReviewResult }
  | { type: 'article.published'; payload: PublishedArticle }
```

**Benefits:**
- Loose coupling between services
- Easy to add new event consumers
- Built-in audit trail of all content operations
- Supports both sync and async processing

### Repository + Service Pattern
Data access follows **Repository pattern** with **Service layer**:

```typescript
// Repository handles data access
interface ArticleRepository {
  create(data: CreateArticleData): Promise<Article>
  findBySlug(slug: string): Promise<Article | null>
  update(id: string, data: UpdateArticleData): Promise<Article>
}

// Service handles business logic
class ArticleService {
  constructor(
    private articleRepo: ArticleRepository,
    private seoService: SEOService,
    private analyticsService: AnalyticsService
  ) {}

  async publishArticle(articleId: string): Promise<PublishedArticle> {
    // Business logic orchestration
  }
}
```

**Benefits:**
- Clear separation of concerns
- Testable business logic
- Consistent data access patterns
- Easy to mock for testing

## Content Processing Patterns

### Multi-Stage Generation Pipeline
AI content generation uses **pipeline pattern** with **checkpoints**:

```typescript
class GenerationPipeline {
  async generateArticle(sourceContent: SourceContent): Promise<Article> {
    // Stage 1: Outline generation
    const outline = await this.generateOutline(sourceContent)
    await this.saveCheckpoint('outline', outline)
    
    // Stage 2: Section generation
    const sections = await this.generateSections(outline)
    await this.saveCheckpoint('sections', sections)
    
    // Stage 3: Citation integration
    const withCitations = await this.addCitations(sections)
    await this.saveCheckpoint('citations', withCitations)
    
    // Stage 4: Quality pass
    const finalArticle = await this.qualityReview(withCitations)
    await this.saveCheckpoint('final', finalArticle)
    
    return finalArticle
  }
}
```

**Benefits:**
- Resume generation from any stage on failure
- Debug and inspect intermediate results
- A/B test different approaches per stage
- Monitor quality at each step

### Citation Tracking Pattern
Every claim in generated content maintains **provenance chain**:

```typescript
interface CitedClaim {
  id: string
  text: string
  confidence: number
  sources: SourceReference[]
  generatedAt: Date
  verifiedAt?: Date
  verificationStatus: 'pending' | 'verified' | 'disputed'
}

interface SourceReference {
  url: string
  title: string
  excerpt: string
  accessedAt: Date
  reliability: number
}
```

**Benefits:**
- Full transparency of information sources
- Easy fact-checking and verification
- Legal compliance for attribution
- Quality metrics based on source reliability

### Human-AI Collaboration Pattern
Content review follows **collaborative editing pattern**:

```typescript
interface ReviewWorkflow {
  // AI generates content with metadata
  generateContent(): Promise<GeneratedContent>
  
  // Human reviews with context
  requestHumanReview(content: GeneratedContent): Promise<ReviewTask>
  
  // Collaborative editing cycle
  incorporateFeedback(review: ReviewFeedback): Promise<RevisedContent>
  
  // Final approval gate
  approveForPublication(content: RevisedContent): Promise<ApprovedContent>
}
```

**Benefits:**
- Leverages AI speed with human judgment
- Maintains editorial quality standards
- Creates learning feedback for AI improvement
- Scales human oversight efficiently

## Data Management Patterns

### Event Sourcing for Content Lifecycle
Article state changes are stored as **immutable events**:

```typescript
type ArticleEvent =
  | { type: 'article.created'; data: CreateData; timestamp: Date }
  | { type: 'article.reviewed'; data: ReviewData; timestamp: Date }
  | { type: 'article.published'; data: PublishData; timestamp: Date }
  | { type: 'article.updated'; data: UpdateData; timestamp: Date }

class ArticleAggregate {
  static fromEvents(events: ArticleEvent[]): Article {
    return events.reduce((article, event) => {
      return this.applyEvent(article, event)
    }, new Article())
  }
}
```

**Benefits:**
- Complete audit trail of all changes
- Easy to replay state at any point in time
- Natural fit for analytics and reporting
- Supports undo/redo functionality

### CQRS for Read/Write Separation
Separate models for **commands** (writes) and **queries** (reads):

```typescript
// Command side - optimized for writes
interface ArticleCommands {
  createArticle(data: CreateArticleCommand): Promise<void>
  updateArticle(data: UpdateArticleCommand): Promise<void>
  publishArticle(data: PublishArticleCommand): Promise<void>
}

// Query side - optimized for reads
interface ArticleQueries {
  getPublishedArticles(filters: ArticleFilters): Promise<ArticleList>
  getArticleBySlug(slug: string): Promise<ArticleView>
  searchArticles(query: SearchQuery): Promise<SearchResults>
}
```

**Benefits:**
- Optimize reads and writes independently
- Scale read and write operations separately
- Support complex queries without affecting write performance
- Enable polyglot persistence strategies

### Content Versioning Pattern
All content changes tracked with **semantic versioning**:

```typescript
interface ContentVersion {
  id: string
  version: string  // semver: major.minor.patch
  content: string
  changes: ContentChange[]
  createdAt: Date
  createdBy: string
  publishStatus: 'draft' | 'review' | 'published' | 'archived'
}

interface ContentChange {
  type: 'addition' | 'deletion' | 'modification'
  section: string
  oldValue?: string
  newValue?: string
  reason: string
}
```

**Benefits:**
- Track all editorial changes
- Support rollback to previous versions
- Compare versions with diff visualization
- Maintain publication history

## User Interface Patterns

### Progressive Enhancement Pattern
Web interface built with **progressive enhancement**:

```typescript
// Base functionality works without JavaScript
export default function ArticlePage({ article }: { article: Article }) {
  return (
    <article>
      <h1>{article.title}</h1>
      <div dangerouslySetInnerHTML={{ __html: article.content }} />
      
      {/* Enhanced features with JavaScript */}
      <ClientOnlyFeatures>
        <ShareButtons article={article} />
        <RelatedArticles articleId={article.id} />
        <CommentSection articleId={article.id} />
      </ClientOnlyFeatures>
    </article>
  )
}
```

**Benefits:**
- Core functionality always works
- Better SEO and accessibility
- Faster initial page loads
- Graceful degradation for slow connections

### Admin Interface Patterns
Admin interface follows **dashboard pattern** with **role-based views**:

```typescript
interface DashboardConfig {
  role: UserRole
  widgets: DashboardWidget[]
  permissions: Permission[]
}

const AdminDashboard: React.FC<{ user: User }> = ({ user }) => {
  const config = getDashboardConfig(user.role)
  
  return (
    <Dashboard>
      {config.widgets.map(widget => (
        <DashboardWidget key={widget.id} {...widget} />
      ))}
    </Dashboard>
  )
}
```

**Benefits:**
- Customized interface per user role
- Modular widget system
- Easy to add new admin features
- Consistent user experience

## Integration Patterns

### API Gateway Pattern
External service access through **unified gateway**:

```typescript
interface ServiceGateway {
  // Unified interface for all external services
  fetchRSSFeed(url: string): Promise<FeedData>
  generateContent(prompt: ContentPrompt): Promise<GeneratedContent>
  sendEmail(email: EmailData): Promise<EmailResult>
  trackEvent(event: AnalyticsEvent): Promise<void>
}

class OpenRouterGateway implements LLMService {
  async generateContent(prompt: ContentPrompt): Promise<GeneratedContent> {
    // Handle model selection, retries, rate limiting
    // Abstract away provider-specific details
  }
}
```

**Benefits:**
- Single point of configuration
- Easy to switch providers
- Consistent error handling
- Built-in monitoring and metrics

### Circuit Breaker Pattern
External service failures handled with **circuit breaker**:

```typescript
class CircuitBreaker {
  private state: 'closed' | 'open' | 'half-open' = 'closed'
  private failures = 0
  private lastFailTime?: Date

  async execute<T>(operation: () => Promise<T>): Promise<T> {
    if (this.state === 'open') {
      if (this.shouldAttemptReset()) {
        this.state = 'half-open'
      } else {
        throw new Error('Circuit breaker is open')
      }
    }

    try {
      const result = await operation()
      this.onSuccess()
      return result
    } catch (error) {
      this.onFailure()
      throw error
    }
  }
}
```

**Benefits:**
- Prevent cascading failures
- Fast failure for downstream services
- Automatic recovery attempts
- System stability under load

## Security Patterns

### Defense in Depth
Security implemented at **multiple layers**:

```typescript
// 1. Input validation
const schema = z.object({
  title: z.string().max(200),
  content: z.string().max(50000),
})

// 2. Authorization middleware
const requireRole = (role: UserRole) => (req: Request) => {
  if (!req.user || !req.user.roles.includes(role)) {
    throw new UnauthorizedError()
  }
}

// 3. Rate limiting
const rateLimiter = new RateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
})

// 4. Content Security Policy
const cspHeader = {
  'Content-Security-Policy': 
    "default-src 'self'; script-src 'self' 'nonce-{random}'"
}
```

**Benefits:**
- Multiple security checkpoints
- Failure in one layer doesn't compromise system
- Comprehensive protection strategy
- Audit trail of security events

These patterns ensure the system is maintainable, scalable, and secure while providing clear guidelines for future development and feature additions.
