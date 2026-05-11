/**
 * Código feito por Lucas David de Sousa(disponibilizado pelo professor), RA: 25895152
 *
 */

import { HttpsError, onCall } from "firebase-functions/https";
import { requireAuthenticatedUser } from "../shared/auth";
import { normalizeString } from "../shared/validation";

import {
  answerQuestion,
  getQuestionById,
  getStartupById,
  userCanManageStartup,
} from "../repositories/startupRepository";

/**
  * Registra ou atualiza a resposta de uma pergunta feita para a startup.
  *
  * Esta Firebase Function é callable e deve ser chamada pelo app com:
  *
  * - 'startupId': identificador da startup.
  * - 'questionId': identificador da pergunta.
  * - 'answer': texto da resposta.
  *
  * Apenas gestores da startup ou usuários com claim admin podem responder.
  */
export const answerStartupQuestion = onCall(async (request) => {
  const user = requireAuthenticatedUser(request);

  const startupId = normalizeString(request.data?.startupId);
  const questionId = normalizeString(request.data?.questionId);
  const answer = normalizeString(request.data?.answer);

  if (!startupId || !questionId || !answer) {
    throw new HttpsError(
      "invalid-argument",
      "Informe startupId, questionId e answer."
    );
  }

  const startup = await getStartupById(startupId);

  if (!startup) {
    throw new HttpsError("not-found", "Startup não encontrada.");
  }

  const canManageStartup =
    request.auth?.token.admin === true ||
    await userCanManageStartup(startupId, user.uid);

  if (!canManageStartup) {
    throw new HttpsError(
      "permission-denied",
      "Somente gestores da startup podem responder perguntas."
    );
  }

  const question = await getQuestionById(startupId, questionId);

  if (!question) {
    throw new HttpsError("not-found", "Pergunta não encontrada.");
  }

  await answerQuestion(startupId, questionId, answer, user.uid);

  return {
    data: {
      id: questionId,
      startupId,
      status: "respondida",
    },
  };
});
