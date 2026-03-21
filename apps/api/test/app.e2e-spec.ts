import { type INestApplication } from '@nestjs/common';
import { Test, type TestingModule } from '@nestjs/testing';
import request, { type Response } from 'supertest';

import { AppModule } from './../src/app.module';

interface HealthResponse {
  readonly service: string;
  readonly status: string;
}

interface FramesResponse {
  readonly total: number;
  readonly items: ReadonlyArray<{
    readonly frameId: string;
  }>;
}

function isHealthResponse(value: unknown): value is HealthResponse {
  if (value === null || typeof value !== 'object' || Array.isArray(value)) {
    return false;
  }

  const candidate = value as Record<string, unknown>;

  return typeof candidate.status === 'string' && typeof candidate.service === 'string';
}

function isFramesResponse(value: unknown): value is FramesResponse {
  if (value === null || typeof value !== 'object' || Array.isArray(value)) {
    return false;
  }

  const candidate = value as Record<string, unknown>;

  if (typeof candidate.total !== 'number' || !Array.isArray(candidate.items)) {
    return false;
  }

  return candidate.items.every((item) => {
    if (item === null || typeof item !== 'object' || Array.isArray(item)) {
      return false;
    }

    const frame = item as Record<string, unknown>;

    return typeof frame.frameId === 'string';
  });
}

function getHttpServer(application: INestApplication): Parameters<typeof request>[0] {
  return application.getHttpServer() as Parameters<typeof request>[0];
}

describe('AppController (e2e)', () => {
  let app: INestApplication;

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('v1');
    await app.init();
  });

  afterEach(async () => {
    await app.close();
  });

  it('/v1/health (GET)', () => {
    return request(getHttpServer(app))
      .get('/v1/health')
      .expect(200)
      .expect((response: Response) => {
        if (!isHealthResponse(response.body)) {
          throw new Error('Unexpected health response shape.');
        }

        const body = response.body;

        expect(body.status).toBe('ok');
        expect(body.service).toBe('phos-api');
      });
  });

  it('/v1/frames (GET)', () => {
    return request(getHttpServer(app))
      .get('/v1/frames')
      .expect(200)
      .expect((response: Response) => {
        if (!isFramesResponse(response.body)) {
          throw new Error('Unexpected frames response shape.');
        }

        const body = response.body;

        expect(body.total).toBe(2);
        expect(body.items[0].frameId).toBe('frm_4cut_basic');
      });
  });
});
