/**
 * Código feito por Lucas David de Sousa(disponibilizado pelo professor), RA: 25895152
 *
 */

import { QuestionStatus, QuestionVisibility, StartupStage } from "../types";

export const allowedStages: StartupStage[] = [
  "nova",
  "em_operacao",
  "em_expansao",
];

export const allowedVisibilities: QuestionVisibility[] = [
  "publica",
  "privada",
];

export const allowedQuestionStatuses: QuestionStatus[] = [
  "pendente",
  "respondida",
];
