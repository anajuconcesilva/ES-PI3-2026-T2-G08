// Código feito por Laura Cristine Soares
// RA: 24802431

import { Timestamp, FieldValue } from "firebase-admin/firestore";

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

  createdAt: Timestamp | FieldValue;
  executedAt?: Timestamp | FieldValue;
  executedBy?: string;
}