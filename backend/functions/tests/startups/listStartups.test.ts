import { listStartups } from "../../src/startups/handlers/listStartups";

import { listStartupItems } from "../../src/startups/repositories/startupRepository";
import { requireAuthenticatedUser } from "../../src/startups/shared/auth";

jest.mock("../../src/startups/repositories/startupRepository");
jest.mock("../../src/startups/shared/auth");

describe("listStartups", () => {

  test("deve bloquear usuário não autenticado", async () => {
    (requireAuthenticatedUser as jest.Mock).mockImplementation(() => {
      throw new Error("Usuário não autenticado");
    });

    await expect(
      listStartups.run({} as any)
    ).rejects.toThrow("Usuário não autenticado");
  });

  test("deve retornar lista de startups", async () => {

    (requireAuthenticatedUser as jest.Mock).mockReturnValue({ uid: "1" });

    (listStartupItems as jest.Mock).mockResolvedValue([
      {
        name: "Startup A",
        stage: "nova",
        shortDescription: "desc",
        tags: [],
      },
    ]);

    const response = await listStartups.run({
      data: {},
    } as any);

    expect(response.count).toBe(1);
  });

});