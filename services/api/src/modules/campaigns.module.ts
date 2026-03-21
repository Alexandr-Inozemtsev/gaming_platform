export interface ModuleDescriptor {
  name: string;
  responsibility: string;
}

export const MODULE_DESCRIPTOR: ModuleDescriptor = {
  name: 'CampaignsModule',
  responsibility: 'campaign creation and progression APIs'
};
