export interface PublishEventRequest {
  topic: string;
  payload: Record<string, unknown>;
}

export interface QueryEventRequest {
  topic?: string;
  limit?: number;
}
