/**
 * Código feito por Lucas David de Sousa(disponibilizado pelo professor), RA: 25895152
 *
 */

import { FieldValue, Timestamp } from "firebase-admin/firestore";

export type StartupStage = "nova" | "em_operacao" | "em_expansao";

export type QuestionVisibility = "publica" | "privada";

export type QuestionStatus = "pendente" | "respondida";

export type AuthenticatedUser = {
  uid: string;
  email?: string;
};

export type Founder = {
  name: string;
  role: string;
  equityPercent: number;
  bio?: string;
};

export type ExternalMember = {
  name: string;
  role: string;
  organization?: string;
};

export type StartupDocument = {
  name: string;
  stage: StartupStage;
  shortDescription: string;
  description: string;
  executiveSummary: string;
  capitalRaisedCents: number;
  totalTokensIssued: number;
  currentTokenPriceCents: number;
  founders: Founder[];
  externalMembers: ExternalMember[];
  demoVideos: string[];
  pitchDeckUrl?: string;
  coverImageUrl?: string;
  tags: string[];
  ownerUid?: string;
  createdByUid?: string;
  createdAt?: Timestamp;
  updatedAt?: Timestamp;
};

export type StartupQuestionDocument = {
  authorUid: string;
  authorEmail?: string;
  text: string;
  visibility: QuestionVisibility;
  status?: QuestionStatus;
  answer?: string;
  answeredByUid?: string;
  answeredAt?: Timestamp;
  createdAt: FieldValue;
  updatedAt?: FieldValue;
};

export type StartupQuestionListItem = {
  id: string;
  startupId: string;
  authorUid: string;
  text: string;
  visibility: QuestionVisibility;
  status: QuestionStatus;
  answer: string | null;
  answeredAt: string | null;
  createdAt: string | null;
  updatedAt: string | null;
  askedByCurrentUser?: boolean;
};

export type StartupListItem = {
  id: string;
  name: string;
  stage: StartupStage;
  shortDescription: string;
  capitalRaisedCents: number;
  totalTokensIssued: number;
  currentTokenPriceCents: number;
  coverImageUrl?: string;
  tags: string[];
};
