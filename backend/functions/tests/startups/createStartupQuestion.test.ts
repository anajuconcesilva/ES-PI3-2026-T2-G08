import { createStartupQuestion } from "../../src/startups/handlers/createStartupQuestion";

import {
  getStartupById,
  createQuestion,
  userIsInvestor,
} from "../../src/startups/repositories/startupRepository";

import { requireAuthenticatedUser } from "../../src/startups/shared/auth";

jest.mock("../../src/startups/repositories/startupRepository");
jest.mock("../../src/startups/shared/auth");

describe("createStartupQuestion", () => {

  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("deve bloquear usuário não autenticado", async () => {
    (requireAuthenticatedUser as jest.Mock).mockImplementation(() => {
      throw new Error("Usuário não autenticado");
    });

    await expect(
      createStartupQuestion.run({} as any)
    ).rejects.toThrow("Usuário não autenticado");
  });

  test("deve retornar erro se startup não existir", async () => {

    (requireAuthenticatedUser as jest.Mock).mockReturnValue({
      uid: "user1",
      email: "email@test.com",
    });

    (getStartupById as jest.Mock).mockResolvedValue(null);

    await expect(
      createStartupQuestion.run({
        data: { startupId: "1", text: "teste" },
      } as any)
    ).rejects.toThrow("Startup não encontrada");
  });

  test("deve bloquear pergunta privada para não investidor", async () => {

    (requireAuthenticatedUser as jest.Mock).mockReturnValue({
      uid: "user1",
      email: "email@test.com",
    });

    (getStartupById as jest.Mock).mockResolvedValue({ id: "1" });
    (userIsInvestor as jest.Mock).mockResolvedValue(false);

    await expect(
      createStartupQuestion.run({
        data: {
          startupId: "1",
          text: "teste",
          visibility: "privada",
        },
      } as any)
    ).rejects.toThrow("Somente investidores");
  });

  test("deve criar pergunta com sucesso", async () => {

    (requireAuthenticatedUser as jest.Mock).mockReturnValue({
      uid: "user1",
      email: "email@test.com",
    });

    (getStartupById as jest.Mock).mockResolvedValue({ id: "1" });
    (createQuestion as jest.Mock).mockResolvedValue("q1");

    const response = await createStartupQuestion.run({
      data: {
        startupId: "1",
        text: "teste",
        visibility: "publica",
      },
    } as any);

    expect(response.data.id).toBe("q1");
  });

});