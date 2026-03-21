import {
  assertCreateSessionRequest,
  assertUpdateSessionRequest,
  validateSessionSummary,
} from '@phos/backend-contracts';
import { Body, Controller, Get, NotFoundException, Param, Patch, Post } from '@nestjs/common';

import { assertBody, assertResponse } from '../../common/http/typia-assert';
import { SessionsService } from './sessions.service';

@Controller('sessions')
export class SessionsController {
  public constructor(private readonly sessionsService: SessionsService) {}

  @Post()
  public async createSession(@Body() body: unknown) {
    const request = assertBody(body, assertCreateSessionRequest);
    const session = await this.sessionsService.createSession(request);

    return {
      session: assertResponse(validateSessionSummary(session)),
    };
  }

  @Get(':sessionId')
  public async getSession(@Param('sessionId') sessionId: string) {
    const session = await this.sessionsService.getSession(sessionId);

    if (!session) {
      throw new NotFoundException(`Session ${sessionId} was not found.`);
    }

    return {
      session: assertResponse(validateSessionSummary(session)),
    };
  }

  @Patch(':sessionId')
  public async updateSession(@Param('sessionId') sessionId: string, @Body() body: unknown) {
    const request = assertBody(body, assertUpdateSessionRequest);
    const session = await this.sessionsService.updateSession(sessionId, request);

    return {
      session: assertResponse(validateSessionSummary(session)),
    };
  }

  @Post(':sessionId/render')
  public async renderSession(@Param('sessionId') sessionId: string) {
    const session = await this.sessionsService.renderSession(sessionId);

    return {
      session: assertResponse(validateSessionSummary(session)),
    };
  }

  @Post(':sessionId/finalize')
  public async finalizeSession(@Param('sessionId') sessionId: string) {
    const session = await this.sessionsService.finalizeSession(sessionId);

    return {
      session: assertResponse(validateSessionSummary(session)),
    };
  }
}
