/**
 * Importa as funções relacionadas ao perfil do usuário.
 * Essas funções permitem consultar e atualizar dados cadastrais.
 */
import { getProfile } from "../src/users/handlers/getProfile";
import { updateProfile } from "../src/users/handlers/updateProfile";

/**
 * Grupo de testes do módulo de Perfil.
 */
describe("Profile Functions", () => {

  /**
   * Testa se a consulta de perfil exige autenticação.
   * Usuários não logados não podem acessar dados pessoais.
   */
  test("getProfile deve bloquear usuário não autenticado", async () => {
    await expect(
      getProfile.run({
        auth: null,
        data: {},
      } as any)
    ).rejects.toThrow("Usuário não autenticado");
  });

  /**
   * Testa se atualização de perfil exige login.
   * Apenas o próprio usuário autenticado pode alterar seus dados.
   */
  test("updateProfile deve bloquear usuário não autenticado", async () => {
    await expect(
      updateProfile.run({
        auth: null,
        data: {},
      } as any)
    ).rejects.toThrow("Usuário não autenticado");
  });

  /**
   * Testa validação de e-mail.
   * O sistema deve impedir formatos inválidos no cadastro/edição.
   */
  test("updateProfile deve rejeitar e-mail inválido", async () => {
    await expect(
      updateProfile.run({
        auth: {
          uid: "123",
          token: {},
        },
        data: {
          nome: "Laura",
          email: "email-invalido",
          cpf: "12345678909",
          telefone: "19999999999",
        },
      } as any)
    ).rejects.toThrow("E-mail inválido");
  });

});