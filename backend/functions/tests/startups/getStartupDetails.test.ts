import { getStartupDetails } from "../../src/startups/handlers/getStartupDetails";

import {
  getStartupById,
  listPublicQuestions,
  userIsInvestor,
} from "../../src/startups/repositories/startupRepository";

import { requireAuthenticatedUser } from "../../src/startups/shared/auth";

jest.mock("../../src/startups/repositories/startupRepository");
jest.mock("../../src/startups/shared/auth");

describe("getStartupDetails", () => {

  test("deve retornar erro se não autenticado", async () => {
    (requireAuthenticatedUser as jest.Mock).mockImplementation(() => {
      throw new Error("Usuário não autenticado");
    });

    await expect(
      getStartupDetails.run({} as any)
    ).rejects.toThrow("Usuário não autenticado");
  });

  test("deve retornar erro se startup não existir", async () => {

    (requireAuthenticatedUser as jest.Mock).mockReturnValue({ uid: "1" });

    (getStartupById as jest.Mock).mockResolvedValue(null);

    await expect(
      getStartupDetails.run({
        data: { id: "1" },
      } as any)
    ).rejects.toThrow("Startup não encontrada");
  });

});