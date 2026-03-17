import { describe, expect, it } from 'vitest';
import { createPingEvent } from '../src/index';

describe('realtime event', () => {
  it('creates ping event', () => {
    expect(createPingEvent().channel).toBe('system.ping');
  });
});
