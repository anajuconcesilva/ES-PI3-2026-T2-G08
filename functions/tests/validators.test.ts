/**
 * Testes unitários para validators.ts
 */

import {
  validateCPF,
  validateEmail,
  validatePhone,
  validatePassword,
  normalizeString,
  onlyNumbers,
} from "../src/users/shared/validators";

describe("Validators", () => {

  // ========================
  // CPF
  // ========================
  describe("validateCPF", () => {

    it("deve aceitar CPF válido", () => {
      expect(validateCPF("12345678909")).toBe(true);
    });

    it("deve rejeitar CPF com tamanho inválido", () => {
      expect(validateCPF("123")).toBe(false);
    });

    it("deve rejeitar CPF com números repetidos", () => {
      expect(validateCPF("11111111111")).toBe(false);
    });

    it("deve rejeitar CPF inválido", () => {
      expect(validateCPF("12345678900")).toBe(false);
    });

  });

  // ========================
  // EMAIL
  // ========================
  describe("validateEmail", () => {

    it("deve aceitar email válido", () => {
      expect(validateEmail("teste@email.com")).toBe(true);
    });

    it("deve rejeitar email inválido", () => {
      expect(validateEmail("email-invalido")).toBe(false);
    });

    it("deve rejeitar email vazio", () => {
      expect(validateEmail("")).toBe(false);
    });

  });

  // ========================
  // TELEFONE
  // ========================
  describe("validatePhone", () => {

    it("deve aceitar telefone válido", () => {
      expect(validatePhone("11999999999")).toBe(true);
    });

    it("deve rejeitar telefone com DDD inválido", () => {
      expect(validatePhone("00999999999")).toBe(false);
    });

    it("deve rejeitar telefone sem 9 inicial", () => {
      expect(validatePhone("11888888888")).toBe(false);
    });

    it("deve rejeitar telefone curto", () => {
      expect(validatePhone("11999")).toBe(false);
    });

  });

  // ========================
  // SENHA
  // ========================
  describe("validatePassword", () => {

    it("deve aceitar senha válida", () => {
      expect(validatePassword("123456")).toBe(true);
    });

    it("deve rejeitar senha curta", () => {
      expect(validatePassword("123")).toBe(false);
    });

  });

  // ========================
  // NORMALIZAÇÃO
  // ========================
  describe("normalizeString", () => {

    it("deve remover espaços", () => {
      expect(normalizeString("  Lucas  ")).toBe("Lucas");
    });

    it("deve retornar string vazia para valor inválido", () => {
      expect(normalizeString(null as any)).toBe("");
    });

  });

  // ========================
  // onlyNumbers
  // ========================
  describe("onlyNumbers", () => {

    it("deve remover caracteres não numéricos", () => {
      expect(onlyNumbers("123.456-789")).toBe("123456789");
    });

  });

});