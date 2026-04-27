import {
  type CreateSessionRequest,
  type SessionSummary,
  type UpdateSessionRequest,
} from './session';
import typia from 'typia';

export const assertCreateSessionRequest = typia.createAssert<CreateSessionRequest>();
export const assertUpdateSessionRequest = typia.createAssert<UpdateSessionRequest>();
export const validateSessionSummary = typia.createValidate<SessionSummary>();
