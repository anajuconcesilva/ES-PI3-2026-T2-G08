import { answerStartupQuestion } from "../../src/startups/handlers/answerStartupQuestion";

import {
  answerQuestion,
  getQuestionById,
  getStartupById,
  userCanManageStartup,
} from "../../src/startups/repositories/startupRepository";

import { requireAuthenticatedUser } from "../../src/startups/shared/auth";

jest.mock("../../src/startups/repositories/startupRepository");
jest.mock("../../src/startups/shared/auth");

describe("answerStartupQuestion", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("deve bloquear usuário não autenticado", async () => {
    (requireAuthenticatedUser as jest.Mock).mockImplementation(() => {
      throw new Error("Usuário não autenticado");
    });

    await expect(
      answerStartupQuestion.run({} as any)
    ).rejects.toThrow("Usuário não autenticado");
  });

  test("deve bloquear usuário sem permissão de gestão", async () => {
    (requireAuthenticatedUser as jest.Mock).mockReturnValue({uid: "user1"});
    (getStartupById as jest.Mock).mockResolvedValue({id: "startup1"});
    (userCanManageStartup as jest.Mock).mockResolvedValue(false);

    await expect(
      answerStartupQuestion.run({
        data: {
          startupId: "startup1",
          questionId: "q1",
          answer: "Resposta",
        },
        auth: {token: {}},
      } as any)
    ).rejects.toThrow("Somente gestores");
  });

  test("deve retornar erro se pergunta não existir", async () => {
    (requireAuthenticatedUser as jest.Mock).mockReturnValue({uid: "user1"});
    (getStartupById as jest.Mock).mockResolvedValue({id: "startup1"});
    (userCanManageStartup as jest.Mock).mockResolvedValue(true);
    (getQuestionById as jest.Mock).mockResolvedValue(null);

    await expect(
      answerStartupQuestion.run({
        data: {
          startupId: "startup1",
          questionId: "q1",
          answer: "Resposta",
        },
        auth: {token: {}},
      } as any)
    ).rejects.toThrow("Pergunta não encontrada");
  });

  test("deve responder pergunta com sucesso", async () => {
    (requireAuthenticatedUser as jest.Mock).mockReturnValue({uid: "gestor1"});
    (getStartupById as jest.Mock).mockResolvedValue({id: "startup1"});
    (userCanManageStartup as jest.Mock).mockResolvedValue(true);
    (getQuestionById as jest.Mock).mockResolvedValue({id: "q1"});
    (answerQuestion as jest.Mock).mockResolvedValue(undefined);

    const response = await answerStartupQuestion.run({
      data: {
        startupId: "startup1",
        questionId: "q1",
        answer: "Resposta publicada",
      },
      auth: {token: {}},
    } as any);

    expect(answerQuestion).toHaveBeenCalledWith(
      "startup1",
      "q1",
      "Resposta publicada",
      "gestor1"
    );
    expect(response.data.status).toBe("respondida");
  });
});
