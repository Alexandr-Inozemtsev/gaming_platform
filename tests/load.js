/* k6 script with node fallback metadata */
export const options = {
  scenarios: {
    api_load: {
      executor: 'constant-arrival-rate',
      rate: 100,
      timeUnit: '1s',
      duration: '60s',
      preAllocatedVUs: 50,
      maxVUs: 1000
    }
  },
  thresholds: {
    http_req_failed: ['rate<0.01'],
    http_req_duration: ['p(95)<500']
  }
};

const target = globalThis.__ENV?.TARGET_API ?? process.env.TARGET_API ?? 'http://localhost:3000';

export default function () {
  if (typeof http !== 'undefined') {
    http.get(`${target}/games`);
    return;
  }
  console.log('k6 runtime not detected; this file is intended for k6 run tests/load.js');
}
