export const createSentry = ({ dsn = process.env.SENTRY_DSN ?? '' } = {}) => ({
  enabled: Boolean(dsn),
  captureException: (error, context = {}) => {
    if (!dsn) return { ok: false, reason: 'SENTRY_DISABLED' };
    return {
      ok: true,
      eventId: `sentry_${Date.now()}`,
      error: String(error?.message ?? error),
      context
    };
  }
});
