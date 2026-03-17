import { describe, expect, it } from 'vitest';
import { defaultFlags } from '../src/index';

describe('admin defaults', () => {
  it('enables dashboard feature', () => {
    expect(defaultFlags()[0]).toEqual({ name: 'admin_dashboard', enabled: true });
  });
});
