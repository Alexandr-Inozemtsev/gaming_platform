export interface CampaignRecord {
  id: string;
  name: string;
  description?: string;
}

export interface CampaignService {
  create(input: { name: string; description?: string }): CampaignRecord;
  start(input: { id: string; players: string[] }): { matchId: string; campaignId: string };
}
