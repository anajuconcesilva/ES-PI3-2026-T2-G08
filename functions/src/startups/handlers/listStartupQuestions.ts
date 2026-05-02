/**
 * Código feito por Lucas David de Sousa(disponibilizado pelo professor), RA: 25895152
 *
 */

import { HttpsError, onCall } from "firebase-functions/https";
import {
  allowedQuestionStatuses,
  allowedVisibilities,
} from "../shared/constants";
import { requireAuthenticatedUser } from "../shared/auth";
import { normalizeString } from "../shared/validation";

import {
  getStartupById,
  listQuestionsByStartup,
  userCanManageStartup,
  userIsInvestor,
} from "../repositories/startupRepository";

import { QuestionStatus, QuestionVisibility } from "../types";

/**
  * Lista perguntas de uma startup respeitando visibilidade e perfil do usuário.
  *
  * Esta Firebase Function é callable e deve ser chamada pelo app com:
  *
  * - 'startupId': identificador da startup.
  * - 'visibility': filtro opcional ('publica' ou 'privada').
  * - 'status': filtro opcional ('pendente' ou 'respondida').
  *
  * Perguntas públicas aparecem para qualquer usuário autenticado. Perguntas
  * privadas aparecem para investidores, gestores da startup ou para o próprio
  * autor da pergunta.
  */
export const listStartupQuestions = onCall(async (request) => {
  const user = requireAuthenticatedUser(request);

  const startupId = normalizeString(request.data?.startupId);
  const visibility = normalizeString(request.data?.visibility);
  const status = normalizeString(request.data?.status);

  if (!startupId) {
    throw new HttpsError("invalid-argument", "Informe startupId.");
  }

  if (
    visibility &&
    !allowedVisibilities.includes(visibility as QuestionVisibility)
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Visibility inválida. Use pública ou privada."
    );
  }

  if (status && !allowedQuestionStatuses.includes(status as QuestionStatus)) {
    throw new HttpsError(
      "invalid-argument",
      "Status inválido. Use pendente ou respondida."
    );
  }

  const startup = await getStartupById(startupId);

  if (!startup) {
    throw new HttpsError("not-found", "Startup não encontrada.");
  }

  const isInvestor = await userIsInvestor(startupId, user.uid);
  const canManageStartup =
    request.auth?.token.admin === true ||
    await userCanManageStartup(startupId, user.uid);

  const includePrivate = isInvestor || canManageStartup;

  const questions = await listQuestionsByStartup(startupId, {
    requesterUid: user.uid,
    includePrivate,
    visibility: visibility as QuestionVisibility | undefined,
    status: status as QuestionStatus | undefined,
  });

  return {
    data: {
      startupId,
      access: {
        isInvestor,
        canManageStartup,
        canReadPrivateQuestions: includePrivate,
      },
      questions,
    },
  };
});
