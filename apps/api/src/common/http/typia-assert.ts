import { BadRequestException, InternalServerErrorException } from '@nestjs/common';
import type { IValidation } from 'typia';

export function assertBody<T>(input: unknown, assertFn: (value: unknown) => T): T {
  try {
    return assertFn(input);
  } catch (error) {
    if (error instanceof Error) {
      throw new BadRequestException(error.message);
    }

    throw new BadRequestException('Invalid request body.');
  }
}

export function assertResponse<T>(validation: IValidation<T>): T {
  if (validation.success) {
    return validation.data;
  }

  throw new InternalServerErrorException('Response contract mismatch.');
}
