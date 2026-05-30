// Código feito por Lucas David de Sousa
// RA: 25895152

import {
  Timestamp,
  FieldValue
} from "firebase-admin/firestore";

export type TransactionType =
  | "deposit"
  | "buy"
  | "sell";

export interface Transaction {
  userId: string;
  type: TransactionType;
  startupId?: string;
  startupName?: string;
  quantity?: number;
  amount: number;
  createdAt: Timestamp | FieldValue;
}