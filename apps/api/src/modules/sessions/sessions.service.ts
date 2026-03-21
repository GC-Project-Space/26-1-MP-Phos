import {
  DEFAULT_EDIT_STATE,
  type CreateSessionRequest,
  type SessionEditState,
  type SessionSummary,
  type UpdateSessionRequest,
} from '@phos/shared';
import { Injectable, InternalServerErrorException, NotFoundException } from '@nestjs/common';
import type { Prisma, Session as SessionRecord, SessionStatus } from '@phos/db';
import { randomUUID } from 'crypto';

import { FramesService } from '../frames/frames.service';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class SessionsService {
  public constructor(
    private readonly framesService: FramesService,
    private readonly prisma: PrismaService,
  ) {}

  public async createSession(request: CreateSessionRequest): Promise<SessionSummary> {
    const now = new Date();
    const record = await this.prisma.session.create({
      data: {
        sessionId: `ses_${randomUUID()}`,
        mode: request.mode,
        status: 'active',
        selectedFrameId: this.framesService.getDefaultFrameId(),
        selectedShotAssetIds: [],
        editState: this.toPrismaEditState(DEFAULT_EDIT_STATE),
        mediaPreset: 'default',
        retentionExpiresAt: new Date(now.getTime() + 48 * 60 * 60 * 1000),
        trainingUsed: false,
        consentVersion: null,
        deletionStatus: 'active',
      },
    });

    return this.toSessionSummary(record);
  }

  public async getSession(sessionId: string): Promise<SessionSummary | undefined> {
    const record = await this.prisma.session.findUnique({
      where: {
        sessionId,
      },
    });

    return record ? this.toSessionSummary(record) : undefined;
  }

  public async updateSession(
    sessionId: string,
    request: UpdateSessionRequest,
  ): Promise<SessionSummary> {
    await this.ensureSessionExists(sessionId);

    const record = await this.prisma.session.update({
      where: {
        sessionId,
      },
      data: {
        selectedFrameId: request.selectedFrameId,
        selectedShotAssetIds: request.selectedShotAssetIds,
        mediaPreset: request.mediaPreset,
        editState: request.editState ? this.toPrismaEditState(request.editState) : undefined,
      },
    });

    return this.toSessionSummary(record);
  }

  public async renderSession(sessionId: string): Promise<SessionSummary> {
    return this.updateStatus(sessionId, 'rendered');
  }

  public async finalizeSession(sessionId: string): Promise<SessionSummary> {
    return this.updateStatus(sessionId, 'finalized');
  }

  private async ensureSessionExists(sessionId: string) {
    const record = await this.prisma.session.findUnique({
      where: {
        sessionId,
      },
      select: {
        sessionId: true,
      },
    });

    if (!record) {
      throw new NotFoundException(`Session ${sessionId} was not found.`);
    }
  }

  private async updateStatus(sessionId: string, status: SessionStatus): Promise<SessionSummary> {
    await this.ensureSessionExists(sessionId);

    const record = await this.prisma.session.update({
      where: {
        sessionId,
      },
      data: {
        status,
      },
    });

    return this.toSessionSummary(record);
  }

  private toSessionSummary(record: SessionRecord): SessionSummary {
    return {
      sessionId: record.sessionId,
      mode: record.mode,
      status: record.status,
      selectedFrameId: record.selectedFrameId,
      selectedShotAssetIds: record.selectedShotAssetIds,
      editState: this.parseEditState(record.editState),
      mediaPreset: record.mediaPreset,
      retentionExpiresAt: record.retentionExpiresAt.toISOString(),
      trainingUsed: record.trainingUsed,
      consentVersion: record.consentVersion,
      deletionStatus: record.deletionStatus,
      createdAt: record.createdAt.toISOString(),
      updatedAt: record.updatedAt.toISOString(),
    };
  }

  private parseEditState(value: Prisma.JsonValue): SessionEditState {
    if (this.isSessionEditState(value)) {
      return value;
    }

    throw new InternalServerErrorException('Stored editState is invalid.');
  }

  private isSessionEditState(
    value: Prisma.JsonValue,
  ): value is Prisma.JsonObject & SessionEditState {
    if (value === null || typeof value !== 'object' || Array.isArray(value)) {
      return false;
    }

    const candidate = value as Record<string, unknown>;

    return (
      (candidate.filterPreset === null || typeof candidate.filterPreset === 'string') &&
      (candidate.textOverlay === null || typeof candidate.textOverlay === 'string') &&
      typeof candidate.cropToFrame === 'boolean'
    );
  }

  private toPrismaEditState(editState: SessionEditState): Prisma.InputJsonObject {
    return {
      filterPreset: editState.filterPreset,
      textOverlay: editState.textOverlay,
      cropToFrame: editState.cropToFrame,
    };
  }
}
