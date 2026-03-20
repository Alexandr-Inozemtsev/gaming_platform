import { describe, expect, it } from 'vitest';
import { getApiHealth } from '../src/index';

describe('api health', () => {
  it('returns ok status', () => {
    expect(getApiHealth()).toEqual({ service: 'api', status: 'ok' });
  });
});
