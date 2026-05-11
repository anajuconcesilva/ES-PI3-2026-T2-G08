import { listStartupQuestions } from "../../src/startups/handlers/listStartupQuestions";

import {
  getStartupById,
  listQuestionsByStartup,
  userCanManageStartup,
  userIsInvestor,
} from "../../src/startups/repositories/startupRepository";

import { requireAuthenticatedUser } from "../../src/startups/shared/auth";

jest.mock("../../src/startups/repositories/startupRepository");
jest.mock("../../src/startups/shared/auth");

describe("listStartupQuestions", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("deve bloquear usuário não autenticado", async () => {
    (requireAuthenticatedUser as jest.Mock).mockImplementation(() => {
      throw new Error("Usuário não autenticado");
    });

    await expect(
      listStartupQuestions.run({} as any)
    ).rejects.toThrow("Usuário não autenticado");
  });

  test("deve retornar erro se startup não existir", async () => {
    (requireAuthenticatedUser as jest.Mock).mockReturnValue({uid: "user1"});
    (getStartupById as jest.Mock).mockResolvedValue(null);

    await expect(
      listStartupQuestions.run({
        data: {startupId: "startup1"},
        auth: {token: {}},
      } as any)
    ).rejects.toThrow("Startup não encontrada");
  });

  test("deve listar apenas o que o usuário comum pode acessar", async () => {
    (requireAuthenticatedUser as jest.Mock).mockReturnValue({uid: "user1"});
    (getStartupById as jest.Mock).mockResolvedValue({id: "startup1"});
    (userIsInvestor as jest.Mock).mockResolvedValue(false);
    (userCanManageStartup as jest.Mock).mockResolvedValue(false);
    (listQuestionsByStartup as jest.Mock).mockResolvedValue([]);

    await listStartupQuestions.run({
      data: {startupId: "startup1"},
      auth: {token: {}},
    } as any);

    expect(listQuestionsByStartup).toHaveBeenCalledWith("startup1", {
      requesterUid: "user1",
      includePrivate: false,
      visibility: undefined,
      status: undefined,
    });
  });

  test("deve liberar perguntas privadas para investidor", async () => {
    (requireAuthenticatedUser as jest.Mock).mockReturnValue({uid: "user1"});
    (getStartupById as jest.Mock).mockResolvedValue({id: "startup1"});
    (userIsInvestor as jest.Mock).mockResolvedValue(true);
    (userCanManageStartup as jest.Mock).mockResolvedValue(false);
    (listQuestionsByStartup as jest.Mock).mockResolvedValue([
      {id: "q1", visibility: "privada"},
    ]);

    const response = await listStartupQuestions.run({
      data: {
        startupId: "startup1",
        visibility: "privada",
        status: "pendente",
      },
      auth: {token: {}},
    } as any);

    expect(response.data.access.canReadPrivateQuestions).toBe(true);
    expect(listQuestionsByStartup).toHaveBeenCalledWith("startup1", {
      requesterUid: "user1",
      includePrivate: true,
      visibility: "privada",
      status: "pendente",
    });
  });
});
