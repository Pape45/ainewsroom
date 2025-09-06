-- CreateEnum
CREATE TYPE "public"."Role" AS ENUM ('ADMIN', 'EDITOR', 'REVIEWER');

-- CreateTable
CREATE TABLE "public"."User" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "role" "public"."Role" NOT NULL DEFAULT 'ADMIN',
    "status" TEXT NOT NULL DEFAULT 'active',
    "lastLoginAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Source" (
    "id" TEXT NOT NULL,
    "kind" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "trustScore" INTEGER NOT NULL DEFAULT 5,
    "lastPullAt" TIMESTAMP(3),
    "active" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Source_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Item" (
    "id" TEXT NOT NULL,
    "sourceId" TEXT NOT NULL,
    "extId" TEXT,
    "title" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "publishedAt" TIMESTAMP(3),
    "author" TEXT,
    "raw" TEXT,
    "cleaned" TEXT,
    "hashTitle" TEXT,
    "hashBody" TEXT,
    "dedupKey" TEXT NOT NULL,
    "scoreFeatures" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Item_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Article" (
    "id" TEXT NOT NULL,
    "itemId" TEXT,
    "slug" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'draft',
    "score" DOUBLE PRECISION DEFAULT 0,
    "sectionCount" INTEGER NOT NULL DEFAULT 0,
    "heroImage" TEXT,
    "seoTitle" TEXT,
    "seoDescription" TEXT,
    "publishedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Article_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."ArticleSection" (
    "id" TEXT NOT NULL,
    "articleId" TEXT NOT NULL,
    "idx" INTEGER NOT NULL,
    "heading" TEXT,
    "bodyMd" TEXT NOT NULL,

    CONSTRAINT "ArticleSection_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."ArticleSource" (
    "id" TEXT NOT NULL,
    "articleId" TEXT NOT NULL,
    "claimRef" TEXT,
    "sourceUrl" TEXT NOT NULL,
    "confidence" DOUBLE PRECISION,

    CONSTRAINT "ArticleSource_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Job" (
    "id" TEXT NOT NULL,
    "kind" TEXT NOT NULL,
    "key" TEXT,
    "state" TEXT NOT NULL DEFAULT 'queued',
    "attempts" INTEGER NOT NULL DEFAULT 0,
    "error" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Job_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Budget" (
    "id" TEXT NOT NULL,
    "provider" TEXT NOT NULL,
    "dailyLimit" DOUBLE PRECISION NOT NULL DEFAULT 5,
    "monthlyLimit" DOUBLE PRECISION NOT NULL DEFAULT 50,
    "spentToday" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "spentMonth" DOUBLE PRECISION NOT NULL DEFAULT 0,

    CONSTRAINT "Budget_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Event" (
    "id" TEXT NOT NULL,
    "entity" TEXT NOT NULL,
    "entityId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "payload" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Event_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "public"."User"("email");

-- CreateIndex
CREATE INDEX "Source_kind_idx" ON "public"."Source"("kind");

-- CreateIndex
CREATE INDEX "Source_url_idx" ON "public"."Source"("url");

-- CreateIndex
CREATE UNIQUE INDEX "Item_dedupKey_key" ON "public"."Item"("dedupKey");

-- CreateIndex
CREATE INDEX "Item_sourceId_idx" ON "public"."Item"("sourceId");

-- CreateIndex
CREATE INDEX "Item_publishedAt_idx" ON "public"."Item"("publishedAt");

-- CreateIndex
CREATE UNIQUE INDEX "Article_slug_key" ON "public"."Article"("slug");

-- CreateIndex
CREATE INDEX "ArticleSection_articleId_idx" ON "public"."ArticleSection"("articleId");

-- CreateIndex
CREATE INDEX "ArticleSource_articleId_idx" ON "public"."ArticleSource"("articleId");

-- CreateIndex
CREATE INDEX "Job_kind_idx" ON "public"."Job"("kind");

-- CreateIndex
CREATE INDEX "Job_state_idx" ON "public"."Job"("state");

-- CreateIndex
CREATE INDEX "Event_entity_entityId_idx" ON "public"."Event"("entity", "entityId");

-- AddForeignKey
ALTER TABLE "public"."Item" ADD CONSTRAINT "Item_sourceId_fkey" FOREIGN KEY ("sourceId") REFERENCES "public"."Source"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Article" ADD CONSTRAINT "Article_itemId_fkey" FOREIGN KEY ("itemId") REFERENCES "public"."Item"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."ArticleSection" ADD CONSTRAINT "ArticleSection_articleId_fkey" FOREIGN KEY ("articleId") REFERENCES "public"."Article"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."ArticleSource" ADD CONSTRAINT "ArticleSource_articleId_fkey" FOREIGN KEY ("articleId") REFERENCES "public"."Article"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
