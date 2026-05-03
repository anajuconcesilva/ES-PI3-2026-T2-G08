import { seedStartupCatalog } from "../../src/startups/handlers/seedStartupCatalog";
import { seedDemoStartups } from "../../src/startups/repositories/startupRepository";

jest.mock("../../src/startups/repositories/startupRepository");

describe("seedStartupCatalog", () => {

  beforeEach(() => {
    jest.clearAllMocks();
    delete process.env.FUNCTIONS_EMULATOR;
    delete process.env.SEED_STARTUP_CATALOG_KEY;
  });

  // =========================
  //  FORA DO EMULATOR SEM CHAVE
  // =========================
  test("deve bloquear fora do emulator sem seedKey", async () => {

    await expect(
      seedStartupCatalog.run({
        data: {},
      } as any)
    ).rejects.toThrow("Seed bloqueado");
  });

  // =========================
  //  CHAVE INVÁLIDA
  // =========================
  test("deve bloquear com seedKey inválida", async () => {

    process.env.SEED_STARTUP_CATALOG_KEY = "chave_correta";

    await expect(
      seedStartupCatalog.run({
        data: { seedKey: "errada" },
      } as any)
    ).rejects.toThrow("Seed bloqueado");
  });

  // =========================
  //  CHAVE VÁLIDA
  // =========================
  test("deve permitir com seedKey válida", async () => {

    process.env.SEED_STARTUP_CATALOG_KEY = "chave_correta";

    (seedDemoStartups as jest.Mock).mockResolvedValue(["id1", "id2"]);

    const response = await seedStartupCatalog.run({
      data: { seedKey: "chave_correta" },
    } as any);

    expect(response.data.count).toBe(2);
    expect(response.data.ids).toEqual(["id1", "id2"]);
  });

  // =========================
  //  EMULATOR
  // =========================
  test("deve permitir no emulator sem seedKey", async () => {

    process.env.FUNCTIONS_EMULATOR = "true";

    (seedDemoStartups as jest.Mock).mockResolvedValue(["id1"]);

    const response = await seedStartupCatalog.run({
      data: {},
    } as any);

    expect(response.data.count).toBe(1);
  });

});