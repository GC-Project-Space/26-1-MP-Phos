import { Injectable } from '@nestjs/common';

@Injectable()
export class HealthService {
  public getHealth() {
    return {
      service: 'phos-api',
      status: 'ok',
      timestamp: new Date().toISOString(),
    };
  }
}
