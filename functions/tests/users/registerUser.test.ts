import { registerUser } from "../../src/users/handlers/registerUser";
import { getUserByCPF, createUser } from "../../src/users/repositories/userRepository";
import { validateRegisterInput } from "../../src/users/shared/validators";
import { getAuth } from "firebase-admin/auth";

jest.mock("../../src/users/repositories/userRepository");
jest.mock("../../src/users/shared/validators");
jest.mock("firebase-admin/auth");

describe("registerUser", () => {

  beforeEach(() => {
    jest.clearAllMocks();
  });

  // =========================
  //  DADOS INVÁLIDOS
  // =========================
  test("deve rejeitar dados inválidos", async () => {

    (validateRegisterInput as jest.Mock).mockReturnValue({
      valid: false,
      message: "Dados inválidos",
    });

    await expect(
      registerUser.run({
        data: {},
      } as any)
    ).rejects.toThrow("Dados inválidos");
  });

  // =========================
  //  CPF JÁ EXISTE
  // =========================
  test("deve rejeitar CPF duplicado", async () => {

    (validateRegisterInput as jest.Mock).mockReturnValue({
      valid: true,
      data: {
        nome: "Teste",
        email: "teste@email.com",
        cpf: "12345678909",
        telefone: "11999999999",
        senha: "123456",
      },
    });

    (getUserByCPF as jest.Mock).mockResolvedValue({
      id: "user1",
    });

    await expect(
      registerUser.run({
        data: {},
      } as any)
    ).rejects.toThrow("CPF já cadastrado");
  });

  // =========================
  //  E-MAIL JÁ EXISTE NO AUTH
  // =========================
  test("deve rejeitar e-mail duplicado no Auth", async () => {

    (validateRegisterInput as jest.Mock).mockReturnValue({
      valid: true,
      data: {
        nome: "Teste",
        email: "teste@email.com",
        cpf: "12345678909",
        telefone: "11999999999",
        senha: "123456",
      },
    });

    (getUserByCPF as jest.Mock).mockResolvedValue(null);

    (getAuth as jest.Mock).mockReturnValue({
      createUser: jest.fn().mockRejectedValue({
        code: "auth/email-already-exists",
      }),
    });

    await expect(
      registerUser.run({
        data: {},
      } as any)
    ).rejects.toThrow("E-mail já cadastrado");
  });

  // =========================
  //  SUCESSO
  // =========================
  test("deve cadastrar usuário com sucesso", async () => {

    (validateRegisterInput as jest.Mock).mockReturnValue({
      valid: true,
      data: {
        nome: "Teste",
        email: "teste@email.com",
        cpf: "12345678909",
        telefone: "11999999999",
        senha: "123456",
      },
    });

    (getUserByCPF as jest.Mock).mockResolvedValue(null);

    (getAuth as jest.Mock).mockReturnValue({
      createUser: jest.fn().mockResolvedValue({
        uid: "uid123",
      }),
    });

    (createUser as jest.Mock).mockResolvedValue({
      id: "uid123",
      nome: "Teste",
      email: "teste@email.com",
      saldo: 0,
    });

    const response = await registerUser.run({
      data: {},
    } as any);

    expect(response.data.message).toBe("Usuário cadastrado com sucesso");
    expect(response.data.user.id).toBe("uid123");
  });
});