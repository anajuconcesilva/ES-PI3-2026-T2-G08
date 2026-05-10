import * as admin from "firebase-admin";

admin.initializeApp();
import * as admin from "firebase-admin";

admin.initializeApp();

import { addBalance } from "../../src/wallet/handlers/addBalance";

import {
  getWalletByUserId,
  updateWallet,
} from "../../src/wallet/repositories/walletRepository";

import { requireAuthenticatedUser }
from "../../src/wallet/shared/auth";

jest.mock("../../src/wallet/repositories/walletRepository");

jest.mock("../../src/wallet/shared/auth");

describe("addBalance", () => {

  test("deve retornar erro se não autenticado", async () => {

    (requireAuthenticatedUser as jest.Mock)
      .mockImplementation(() => {
        throw new Error("Usuário não autenticado");
      });

    await expect(
      addBalance.run({} as any)
    ).rejects.toThrow("Usuário não autenticado");
  });

  test("deve adicionar saldo corretamente", async () => {

    (requireAuthenticatedUser as jest.Mock)
      .mockReturnValue({ uid: "123" });

    (getWalletByUserId as jest.Mock)
      .mockResolvedValue({
        balance: 100,
        investments: {},
      });

    await addBalance.run({
      data: {
        value: 50,
      },
    } as any);

    expect(updateWallet).toHaveBeenCalled();
  });
});
import { addBalance } from "../../src/wallet/handlers/addBalance";

import {
  gevoutWalletByUserId,
  updateWallet,
} from "../../src/wallet/repositories/walletRepository";

import { requireAuthenticatedUser }
from "../../src/wallet/shared/auth";

jest.mock("../../src/wallet/repositories/walletRepository");

jest.mock("../../src/wallet/shared/auth");

describe("addBalance", () => {

  test("deve retornar erro se não autenticado", async () => {

    (requireAuthenticatedUser as jest.Mock)
      .mockImplementation(() => {
        throw new Error("Usuário não autenticado");
      });

    await expect(
      addBalance.run({} as any)
    ).rejects.toThrow("Usuário não autenticado");
  });

  test("deve adicionar saldo corretamente", async () => {

    (requireAuthenticatedUser as jest.Mock)
      .mockReturnValue({ uid: "123" });

    (getWalletByUserId as jest.Mock)
      .mockResolvedValue({
        balance: 100,
        investments: {},
      });

    await addBalance.run({
      data: {
        value: 50,
      },
    } as any);

    expect(updateWallet).toHaveBeenCalled();
  });
});