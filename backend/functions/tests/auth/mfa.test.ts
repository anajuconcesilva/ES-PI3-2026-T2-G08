/**
 * Importa as funções MFA que serão testadas.
 * Cada uma representa uma etapa do sistema de autenticação multifator.
 */
import { startMfa } from "../../src/auth/handlers/startMfa";
import { verifyMfa } from "../../src/auth/handlers/verifyMfa";
import { disableMfa } from "../../src/auth/handlers/disableMfa";

/**
 * Grupo de testes relacionado ao módulo MFA.
 */
describe("MFA Functions", () => {

  /**
   * Testa se a função startMfa bloqueia usuários não autenticados.
   * Segurança: somente usuários logados podem ativar MFA.
   */
  test("startMfa deve bloquear sem login", async () => {
    await expect(
      startMfa.run({
        auth: null,
        data: {},
      } as any)
    ).rejects.toThrow("Usuário não autenticado");
  });

  /**
   * Testa se verifyMfa exige autenticação.
   * Mesmo com código enviado, usuário precisa estar logado.
   */
  test("verifyMfa deve bloquear sem login", async () => {
    await expect(
      verifyMfa.run({
        auth: null,
        data: {
          code: "123456",
        },
      } as any)
    ).rejects.toThrow("Usuário não autenticado");
  });

  /**
   * Testa se disableMfa também exige login.
   * Apenas o dono da conta pode desativar MFA.
   */
  test("disableMfa deve bloquear sem login", async () => {
    await expect(
      disableMfa.run({
        auth: null,
        data: {},
      } as any)
    ).rejects.toThrow("Usuário não autenticado");
  });

});
