import { describe, expect, it } from '@jest/globals';
import {
  invalidSessionSummaryFixture,
  validSessionSummaryFixture,
} from '../../__fixtures__/sessionSummary';
import { validateSessionSummary } from './session';

describe('validateSessionSummary', () => {
  it('accepts the valid session fixture', () => {
    const result = validateSessionSummary(validSessionSummaryFixture);

    expect(result.success).toBe(true);
  });

  it('rejects the invalid session fixture and preserves failure details', () => {
    const result = validateSessionSummary(invalidSessionSummaryFixture);

    expect(result.success).toBe(false);

    if (result.success) {
      throw new Error('Expected invalid fixture to fail validation');
    }

    const issueSummary = JSON.stringify(result.issues);

    expect(issueSummary).toContain('status');
    expect(issueSummary).toContain('cropToFrame');
    expect(issueSummary).toContain('selectedShotAssetIds');
  });
});
