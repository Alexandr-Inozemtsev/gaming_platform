export interface HealthStatus {
  service: 'api';
  status: 'ok';
}

export const getApiHealth = (): HealthStatus => ({
  service: 'api',
  status: 'ok'
});
