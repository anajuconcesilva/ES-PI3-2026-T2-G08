export type OfferType = "BUY" | "SELL";

export type OfferStatus = "OPEN" | "EXECUTED";

export interface Offer {
  id?: string;
  userId: string;
  startupId: string;
  type: OfferType;
  quantity: number;
  tokenPrice: number;
  status: OfferStatus;
  createdAt: number;
}