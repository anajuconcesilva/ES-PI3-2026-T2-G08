/**
 * Código feito por Lucas David de Sousa(disponibilizado pelo professor), RA: 25895152
 *
 */

import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import { allowedVisibilities } from "../shared/constants";
import { requireAuthenticatedUser } from "../shared/auth";
import { normalizeString } from "../shared/validation";

import {
  createQuestion,
  getStartupById,
  userIsInvestor,
} from "../repositories/startupRepository";

import { QuestionVisibility, StartupQuestionDocument } from "../types";

/**
  * Cria uma pergunta para uma startup.
  *
  * Esta Firebase Function é callable e deve ser chamada pelo app com:
  *
  * - 'startupId': identificador da startup.
  * - 'text': texto da pergunta.
  * - 'visibility': visibilidade opcional ('pública' ou 'privada').
  *
  * Perguntas públicas podem ser enviadas por qualquer usuário autenticado.
  * Perguntas privadas exigem que o usuário tenha um documento em:
  * 'startups/{startupId}/investors/{uid}'.
  */
export const createStartupQuestion = onCall(async (request) => {
  const user = requireAuthenticatedUser(request);

  const startupId = normalizeString(request.data?.startupId);

  const text = normalizeString(request.data?.text);

  const visibility = normalizeString(request.data?.visibility) ?? "publica";

  if (!startupId || !text) {
    throw new HttpsError("invalid-argument", "Informe startupId e text.");
  }

  if (!allowedVisibilities.includes(visibility as QuestionVisibility)) {
    throw new HttpsError(
      "invalid-argument",
      "Visibility inválida. Use pública ou privada."
    );
  }

  const startup = await getStartupById(startupId);

  if (!startup) {
    throw new HttpsError("not-found", "Startup não encontrada.");
  }

  if (visibility === "privada") {
    const isInvestor = await userIsInvestor(startupId, user.uid);

    if (!isInvestor) {
      throw new HttpsError(
        "permission-denied",
        "Somente investidores desta startup podem enviar perguntas privadas."
      );
    }
  }

  const question: StartupQuestionDocument = {
    authorUid: user.uid,
    authorEmail: user.email,
    text,
    visibility: visibility as QuestionVisibility,
    status: "pendente",
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  };

  const questionId = await createQuestion(startupId, question);

  logger.info("Pergunta criada para startup.", {
    startupId,
    questionId,
    visibility,
  });

  return {
    data: {
      id: questionId,
      startupId,
      visibility,
    },
  };
});