export interface AdminFeatureFlag {
  name: string;
  enabled: boolean;
}

export const defaultFlags = (): AdminFeatureFlag[] => [
  { name: 'admin_dashboard', enabled: true }
];
