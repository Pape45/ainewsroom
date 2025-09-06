# Git Strategy & Development Workflow

**Document Version:** 1.0  
**Date:** September 6, 2025  
**Project:** AI Newsroom (ainewsroom.news)  

## Branching Strategy

### Trunk-Based Development with Short-Lived Feature Branches

We follow a **trunk-based development** approach with the `main` branch as the single source of truth. All changes merge to main frequently through short-lived feature branches that exist for no more than 2-3 days.

```mermaid
gitgraph
    commit id: "Initial"
    branch feat/task-1-1
    checkout feat/task-1-1
    commit id: "Setup repo"
    commit id: "Add tooling"
    checkout main
    merge feat/task-1-1
    
    branch feat/task-1-2
    checkout feat/task-1-2
    commit id: "Next.js setup"
    commit id: "Add Tailwind"
    checkout main
    merge feat/task-1-2
    
    branch fix/auth-bug
    checkout fix/auth-bug
    commit id: "Fix login"
    checkout main
    merge fix/auth-bug
    
    commit id: "Production deploy"
    tag: "v1.0.0"
```

### Branch Naming Convention

All branches must follow this naming pattern:
```
<type>/<task-id>-<description>
```

**Branch Types:**
- `feat/` - New features and major functionality
- `fix/` - Bug fixes and patches
- `chore/` - Maintenance, refactoring, dependency updates
- `docs/` - Documentation updates
- `test/` - Test additions or improvements
- `perf/` - Performance improvements
- `security/` - Security fixes and improvements

**Examples:**
```
feat/task-1-1-repository-setup
feat/task-3-2-ai-content-generation
fix/auth-session-timeout
chore/dependency-updates-q4
docs/api-documentation-update
security/csp-header-enforcement
```

### Task-Linked Branches

Each branch name should reference the corresponding task from `020-roadmap-v1.md`:
- `feat/task-1-1-repository-setup` → Task 1.1: Repository Structure & Tooling
- `feat/task-2-3-content-models` → Task 2.3: Content Models & API Routes
- `feat/task-3-1-rss-ingestion` → Task 3.1: RSS/API Ingestion Service

This creates traceability between roadmap tasks and code changes.

## Commit Message Standards

### Conventional Commits Format

All commits must follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

**Commit Types:**
- `feat:` - New feature or functionality
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, missing semi-colons, etc.)
- `refactor:` - Code refactoring without feature changes
- `perf:` - Performance improvements
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks, dependency updates
- `ci:` - CI/CD pipeline changes
- `security:` - Security-related changes

**Scope Examples:**
- `auth` - Authentication/authorization
- `api` - API routes and handlers
- `ui` - User interface components
- `db` - Database/schema changes
- `content` - Content generation pipeline
- `seo` - SEO and metadata
- `admin` - Admin interface
- `deploy` - Deployment configuration

### Commit Message Examples

```bash
feat(content): implement AI article generation pipeline

- Add OpenRouter integration for multi-model support
- Create section-by-section generation workflow
- Implement citation tracking and source mapping
- Add quality scoring for generated content

Closes #task-3-2

fix(auth): resolve session timeout on admin pages

The NextAuth session was expiring due to misconfigured 
JWT settings, causing admin users to lose access.

- Increase session maxAge to 30 days
- Add automatic session refresh on activity
- Fix cookie settings for production domain

Fixes #123

chore(deps): update Next.js to 15.0.2

- Update to latest stable version
- Update related TypeScript types
- Fix breaking changes in App Router API
```

### Commit Hygiene Rules

1. **One Logical Change Per Commit:** Each commit should represent a single logical change
2. **Descriptive Messages:** Explain "what" and "why", not just "what"
3. **Present Tense:** Use present tense ("add feature" not "added feature")
4. **Imperative Mood:** Write as if giving a command ("fix bug" not "fixes bug")
5. **Reference Issues:** Link to roadmap tasks or GitHub issues when applicable
6. **No WIP Commits:** Avoid "work in progress" or "temp" commits on shared branches

## Signed Commits & Security

### GPG Signing Requirement

All commits to `main` and production branches must be GPG signed for security verification.

**Setup GPG Signing:**
```bash
# Generate GPG key
gpg --full-generate-key

# List keys and copy key ID
gpg --list-secret-keys --keyid-format LONG

# Configure Git
git config --global user.signingkey [KEY_ID]
git config --global commit.gpgsign true

# Add to GitHub
gpg --armor --export [KEY_ID]
```

**Verification:**
```bash
# Verify commits are signed
git log --show-signature

# Check branch signature status
git verify-commit HEAD
```

## Protected Branch Configuration

### Main Branch Protection Rules

The `main` branch is protected with the following rules:

1. **Required Pull Request Reviews**
   - At least 1 reviewer required
   - Dismiss stale reviews when new commits pushed
   - Require review from code owners for sensitive paths

2. **Required Status Checks**
   - All CI tests must pass
   - TypeScript compilation successful
   - ESLint checks pass without errors
   - Prettier formatting verified
   - Security scan completed
   - Docker build successful

3. **Enforce Linear History**
   - Require branches to be up to date before merging
   - Squash and merge preferred for feature branches
   - No force pushes allowed

4. **Signed Commits Required**
   - All commits must be GPG signed
   - Verified signatures required for merge

### Code Owners Configuration

**CODEOWNERS file:**
```
# Default owners for everything
* @pape45

# Critical infrastructure requires admin review
/infra/ @pape45
/docker/ @pape45
/.github/ @pape45
/prisma/ @pape45

# Security-sensitive areas
/lib/auth.ts @pape45
/middleware.ts @pape45
/app/api/ @pape45

# Documentation can be reviewed by any team member
/docs/ @pape45
/README.md @pape45

# Generated files should not be manually edited
/prisma/migrations/ @pape45
package-lock.json @pape45
```

## Pull Request Workflow

### PR Template

All pull requests must use this template:

```markdown
## Changes
Brief description of what this PR changes and why.

## Task Reference
- Closes #task-X-X (reference roadmap task)
- Related to #issue-number (if applicable)

## Type of Change
- [ ] 🚀 New feature (feat)
- [ ] 🐛 Bug fix (fix)
- [ ] 🧹 Chore/maintenance (chore)
- [ ] 📚 Documentation (docs)
- [ ] ⚡ Performance improvement (perf)
- [ ] 🔒 Security fix (security)

## Testing Checklist
- [ ] Unit tests pass locally
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] No new TypeScript errors
- [ ] ESLint passes without warnings

## Security Checklist
- [ ] No secrets committed
- [ ] Input validation added where needed
- [ ] Authentication/authorization checked
- [ ] No new security vulnerabilities introduced

## Performance Checklist
- [ ] No performance regressions
- [ ] Database queries optimized
- [ ] Bundle size impact acceptable
- [ ] Core Web Vitals not degraded

## SEO Checklist (if applicable)
- [ ] Meta tags properly configured
- [ ] Structured data validates
- [ ] Sitemap updates automatically
- [ ] URLs follow SEO best practices

## Deployment Notes
- [ ] No breaking changes
- [ ] Database migrations included
- [ ] Environment variables documented
- [ ] Deployment order considerations noted

## Screenshots/Videos
(If UI changes, include before/after screenshots)

## Additional Notes
Any additional context, concerns, or follow-up tasks.
```

### PR Review Process

1. **Author Responsibilities:**
   - Fill out PR template completely
   - Ensure all CI checks pass
   - Self-review code changes
   - Test functionality locally
   - Update documentation if needed

2. **Reviewer Responsibilities:**
   - Review code for correctness and style
   - Test functionality when possible
   - Check security implications
   - Verify performance impact
   - Ensure documentation updates

3. **Merge Requirements:**
   - All status checks green
   - At least one approved review
   - No requested changes outstanding
   - Branch up to date with main
   - Squash and merge preferred

## Release Management

### Semantic Versioning

Releases follow [Semantic Versioning](https://semver.org/) (MAJOR.MINOR.PATCH):

- **MAJOR** (1.0.0): Breaking changes, major new features
- **MINOR** (0.1.0): New features, backward compatible
- **PATCH** (0.0.1): Bug fixes, security patches

### Tagging Strategy

```bash
# Create annotated tag for release
git tag -a v1.0.0 -m "Release v1.0.0: Initial production launch"

# Push tag to trigger release workflow
git push origin v1.0.0
```

### Release Workflow

1. **Pre-Release Checks:**
   - All roadmap tasks completed
   - Security scan passed
   - Performance benchmarks met
   - Documentation updated

2. **Release Creation:**
   - Create release branch from main
   - Update version numbers
   - Generate changelog
   - Create release tag

3. **Post-Release:**
   - Deploy to production
   - Monitor for issues
   - Update project documentation
   - Communicate release notes

### Changelog Management

Maintain `CHANGELOG.md` with format:

```markdown
# Changelog

## [1.0.0] - 2025-09-06

### Added
- Initial AI newsroom platform
- RSS feed ingestion system
- AI content generation pipeline
- Human review workflow
- SEO optimization with Google News sitemaps

### Security
- GPG signed commits enforced
- Content Security Policy implemented
- Input validation on all API endpoints

## [0.1.0] - 2025-08-30

### Added
- Project repository setup
- Basic Next.js application
- Database schema and migrations
```

## Backport Strategy

### When to Backport

Backports to previous versions are only done for:
- Critical security vulnerabilities
- Data corruption bugs
- Performance regressions affecting user experience
- Legal compliance issues

### Backport Process

```bash
# Create backport branch from release tag
git checkout -b backport/v1.0.1-security-fix v1.0.0

# Cherry-pick fix commits
git cherry-pick <commit-hash>

# Create PR for backport
gh pr create --title "Backport: Security fix for v1.0.1"
```

## Generated Files & Commit Guidelines

### Never Commit These Files

Files that should **never** be committed:
```
# Environment variables
.env
.env.local
.env.production

# Build outputs
.next/
dist/
build/

# Dependencies
node_modules/
.pnpm-store/

# Database
*.db
*.sqlite

# Logs and temporary files
*.log
.DS_Store
Thumbs.db

# IDE files
.vscode/settings.json
.idea/
```

### Auto-Generated Files Policy

Some files are auto-generated but should be committed:
```
# These should be committed
package-lock.json          # Lock dependency versions
prisma/migrations/         # Database schema changes
apps/web/.next/types/      # Generated TypeScript types (if configured)

# These should NOT be committed
.next/                     # Next.js build output
coverage/                  # Test coverage reports
```

### Secrets & Security

**Absolute Rules:**
1. **No API keys, passwords, or tokens in repository**
2. **Use .env files for local development**
3. **Use GitHub Secrets for CI/CD**
4. **Mask secrets in logs and outputs**
5. **Rotate keys if accidentally committed**

**Secret Detection:**
```bash
# Pre-commit hook to detect secrets
git secrets --register-aws
git secrets --scan
```

## Emergency Procedures

### Hotfix Process

For critical production issues:

1. **Create hotfix branch from main:**
   ```bash
   git checkout -b hotfix/critical-security-fix main
   ```

2. **Make minimal fix and test:**
   ```bash
   # Make only necessary changes
   git commit -m "security: fix XSS vulnerability in article content"
   ```

3. **Fast-track review:**
   - Skip normal review process if critical
   - Get immediate deployment approval
   - Deploy with monitoring

4. **Follow up:**
   - Create post-mortem document
   - Update security procedures
   - Schedule comprehensive review

### Rollback Procedures

If deployment causes issues:

```bash
# Immediate rollback using previous commit
git revert HEAD --no-edit
git push origin main

# Or rollback to specific version
git reset --hard v1.0.0
git push --force-with-lease origin main
```

---

## Workflow Automation

### GitHub Actions Integration

**Automated Workflows:**
- **CI Pipeline:** Run on every PR
- **Deployment:** Trigger on merge to main
- **Security Scan:** Daily vulnerability checks
- **Dependency Updates:** Weekly automated PRs

**Example CI Workflow:**
```yaml
name: CI
on:
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '18'
      - run: npm ci
      - run: npm run type-check
      - run: npm run lint
      - run: npm run test
      - run: npm run build
```

### Git Hooks

**Pre-commit hooks:**
```bash
#!/bin/sh
# .husky/pre-commit

npm run lint-staged
npm run type-check
git secrets --scan
```

**Commit-msg hook:**
```bash
#!/bin/sh
# .husky/commit-msg

npx commitlint --edit $1
```

---

**Git Strategy Status:** Ready for implementation  
**Next Review:** After V1 launch for process optimization  
**Documentation Updated:** September 6, 2025
