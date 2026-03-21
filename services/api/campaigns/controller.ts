export interface CampaignCreateRequest {
  name: string;
  description?: string;
  levels?: Array<Record<string, unknown>>;
}

export interface CampaignStartRequest {
  id: string;
  players: string[];
  botLevel?: 'easy' | 'normal' | null;
}
