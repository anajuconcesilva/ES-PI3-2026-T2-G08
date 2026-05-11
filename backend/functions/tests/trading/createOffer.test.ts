import * as admin from "firebase-admin";

admin.initializeApp();

import { createOffer }
from "../../src/trading/handlers/createOffer";

import {
  createOffer as createOfferRepository,
} from "../../src/trading/repositories/tradingRepository";

import {
  getWalletByUserId,
} from "../../src/wallet/repositories/walletRepository";

import { requireAuthenticatedUser }
from "../../src/wallet/shared/auth";

jest.mock("../../src/trading/repositories/tradingRepository");

jest.mock("../../src/wallet/repositories/walletRepository");

jest.mock("../../src/wallet/shared/auth");

describe("createOffer", () => {

  test("deve retornar erro se não autenticado", async () => {

    (requireAuthenticatedUser as jest.Mock)
      .mockImplementation(() => {
        throw new Error("Usuário não autenticado");
      });

    await expect(
      createOffer.run({} as any)
    ).rejects.toThrow("Usuário não autenticado");
  });

  test("deve criar oferta corretamente", async () => {

    (requireAuthenticatedUser as jest.Mock)
      .mockReturnValue({
        uid: "123",
      });

    (getWalletByUserId as jest.Mock)
      .mockResolvedValue({
        balance: 1000,
        investments: {},
      });

    (createOfferRepository as jest.Mock)
      .mockResolvedValue({
        id: "offer1",
      });

    const result = await createOffer.run({
      data: {
        startupId: "startup1",
        type: "BUY",
        quantity: 10,
        tokenPrice: 50,
      },
    } as any);

    expect(result.success).toBe(true);
  });
});