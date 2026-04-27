-- CreateEnum
CREATE TYPE "FrameLayout" AS ENUM ('4_cut', '6_cut');

-- CreateEnum
CREATE TYPE "SessionMode" AS ENUM ('LIVE_BOOTH');

-- CreateEnum
CREATE TYPE "SessionStatus" AS ENUM ('active', 'rendered', 'finalized', 'deleted');

-- CreateEnum
CREATE TYPE "DeletionStatus" AS ENUM ('active', 'export_requested', 'delete_requested', 'deleted');

-- CreateEnum
CREATE TYPE "AssetType" AS ENUM ('photo', 'video');

-- CreateEnum
CREATE TYPE "AssetRole" AS ENUM ('raw_shot', 'final_photo', 'making_video');

-- CreateEnum
CREATE TYPE "AssetStatus" AS ENUM ('available', 'expired', 'deleted');

-- CreateEnum
CREATE TYPE "ShareLinkStatus" AS ENUM ('active', 'expired', 'revoked');

-- CreateEnum
CREATE TYPE "RequestStatus" AS ENUM ('requested', 'completed', 'failed');

-- CreateTable
CREATE TABLE "Frame" (
    "frameId" TEXT NOT NULL,
    "layoutType" "FrameLayout" NOT NULL,
    "title" TEXT NOT NULL,
    "slotCount" INTEGER NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "Frame_pkey" PRIMARY KEY ("frameId")
);

-- CreateTable
CREATE TABLE "Session" (
    "sessionId" TEXT NOT NULL,
    "mode" "SessionMode" NOT NULL,
    "status" "SessionStatus" NOT NULL DEFAULT 'active',
    "selectedFrameId" TEXT NOT NULL,
    "selectedShotAssetIds" TEXT[],
    "editState" JSONB NOT NULL,
    "mediaPreset" TEXT NOT NULL DEFAULT 'default',
    "finalPhotoAssetId" TEXT,
    "makingVideoAssetId" TEXT,
    "retentionExpiresAt" TIMESTAMP(3) NOT NULL,
    "trainingUsed" BOOLEAN NOT NULL DEFAULT false,
    "consentVersion" TEXT,
    "deletionStatus" "DeletionStatus" NOT NULL DEFAULT 'active',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Session_pkey" PRIMARY KEY ("sessionId")
);

-- CreateTable
CREATE TABLE "Asset" (
    "assetId" TEXT NOT NULL,
    "sessionId" TEXT NOT NULL,
    "assetType" "AssetType" NOT NULL,
    "assetRole" "AssetRole" NOT NULL,
    "mimeType" TEXT NOT NULL,
    "status" "AssetStatus" NOT NULL DEFAULT 'available',
    "durationMs" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Asset_pkey" PRIMARY KEY ("assetId")
);

-- CreateTable
CREATE TABLE "SessionShotSelection" (
    "sessionId" TEXT NOT NULL,
    "assetId" TEXT NOT NULL,
    "position" INTEGER NOT NULL,

    CONSTRAINT "SessionShotSelection_pkey" PRIMARY KEY ("sessionId","assetId")
);

-- CreateTable
CREATE TABLE "Consent" (
    "consentId" TEXT NOT NULL,
    "sessionId" TEXT NOT NULL,
    "serviceConsentAccepted" BOOLEAN NOT NULL,
    "trainingOptIn" BOOLEAN NOT NULL DEFAULT false,
    "consentVersion" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Consent_pkey" PRIMARY KEY ("consentId")
);

-- CreateTable
CREATE TABLE "DeletionRequest" (
    "requestId" TEXT NOT NULL,
    "sessionId" TEXT NOT NULL,
    "status" "RequestStatus" NOT NULL DEFAULT 'requested',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completedAt" TIMESTAMP(3),

    CONSTRAINT "DeletionRequest_pkey" PRIMARY KEY ("requestId")
);

-- CreateTable
CREATE TABLE "ShareLink" (
    "shareLinkId" TEXT NOT NULL,
    "sessionId" TEXT NOT NULL,
    "status" "ShareLinkStatus" NOT NULL DEFAULT 'active',
    "url" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ShareLink_pkey" PRIMARY KEY ("shareLinkId")
);

-- CreateTable
CREATE TABLE "ExportRequest" (
    "exportRequestId" TEXT NOT NULL,
    "sessionId" TEXT NOT NULL,
    "status" "RequestStatus" NOT NULL DEFAULT 'requested',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completedAt" TIMESTAMP(3),

    CONSTRAINT "ExportRequest_pkey" PRIMARY KEY ("exportRequestId")
);

-- CreateIndex
CREATE UNIQUE INDEX "Session_finalPhotoAssetId_key" ON "Session"("finalPhotoAssetId");

-- CreateIndex
CREATE UNIQUE INDEX "Session_makingVideoAssetId_key" ON "Session"("makingVideoAssetId");

-- CreateIndex
CREATE INDEX "Session_selectedFrameId_idx" ON "Session"("selectedFrameId");

-- CreateIndex
CREATE INDEX "Session_status_idx" ON "Session"("status");

-- CreateIndex
CREATE INDEX "Session_deletionStatus_idx" ON "Session"("deletionStatus");

-- CreateIndex
CREATE INDEX "Session_retentionExpiresAt_idx" ON "Session"("retentionExpiresAt");

-- CreateIndex
CREATE INDEX "Asset_sessionId_idx" ON "Asset"("sessionId");

-- CreateIndex
CREATE INDEX "Asset_sessionId_assetRole_idx" ON "Asset"("sessionId", "assetRole");

-- CreateIndex
CREATE INDEX "Asset_sessionId_assetType_idx" ON "Asset"("sessionId", "assetType");

-- CreateIndex
CREATE INDEX "Asset_status_idx" ON "Asset"("status");

-- CreateIndex
CREATE INDEX "SessionShotSelection_assetId_idx" ON "SessionShotSelection"("assetId");

-- CreateIndex
CREATE UNIQUE INDEX "SessionShotSelection_sessionId_position_key" ON "SessionShotSelection"("sessionId", "position");

-- CreateIndex
CREATE INDEX "Consent_sessionId_idx" ON "Consent"("sessionId");

-- CreateIndex
CREATE INDEX "Consent_sessionId_consentVersion_idx" ON "Consent"("sessionId", "consentVersion");

-- CreateIndex
CREATE INDEX "DeletionRequest_sessionId_idx" ON "DeletionRequest"("sessionId");

-- CreateIndex
CREATE INDEX "DeletionRequest_status_idx" ON "DeletionRequest"("status");

-- CreateIndex
CREATE UNIQUE INDEX "ShareLink_url_key" ON "ShareLink"("url");

-- CreateIndex
CREATE INDEX "ShareLink_sessionId_idx" ON "ShareLink"("sessionId");

-- CreateIndex
CREATE INDEX "ShareLink_status_idx" ON "ShareLink"("status");

-- CreateIndex
CREATE INDEX "ShareLink_expiresAt_idx" ON "ShareLink"("expiresAt");

-- CreateIndex
CREATE INDEX "ExportRequest_sessionId_idx" ON "ExportRequest"("sessionId");

-- CreateIndex
CREATE INDEX "ExportRequest_status_idx" ON "ExportRequest"("status");

-- AddForeignKey
ALTER TABLE "Session" ADD CONSTRAINT "Session_selectedFrameId_fkey" FOREIGN KEY ("selectedFrameId") REFERENCES "Frame"("frameId") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Session" ADD CONSTRAINT "Session_finalPhotoAssetId_fkey" FOREIGN KEY ("finalPhotoAssetId") REFERENCES "Asset"("assetId") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Session" ADD CONSTRAINT "Session_makingVideoAssetId_fkey" FOREIGN KEY ("makingVideoAssetId") REFERENCES "Asset"("assetId") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Asset" ADD CONSTRAINT "Asset_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "Session"("sessionId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SessionShotSelection" ADD CONSTRAINT "SessionShotSelection_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "Session"("sessionId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SessionShotSelection" ADD CONSTRAINT "SessionShotSelection_assetId_fkey" FOREIGN KEY ("assetId") REFERENCES "Asset"("assetId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Consent" ADD CONSTRAINT "Consent_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "Session"("sessionId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DeletionRequest" ADD CONSTRAINT "DeletionRequest_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "Session"("sessionId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ShareLink" ADD CONSTRAINT "ShareLink_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "Session"("sessionId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ExportRequest" ADD CONSTRAINT "ExportRequest_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "Session"("sessionId") ON DELETE CASCADE ON UPDATE CASCADE;
