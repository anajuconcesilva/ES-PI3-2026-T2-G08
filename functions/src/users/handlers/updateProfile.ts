/**
 * Código feito por Laura Cristine Soares, RA: 24802431
 *
 * ==================================
 * UPDATE PROFILE - FIREBASE FUNCTION
 * ==================================
 *
 * Responsável por atualizar os dados cadastrais do usuário autenticado.
 *
 * Objetivo:
 * Permitir que o próprio usuário altere suas informações pessoais
 * dentro do sistema de forma segura.
 *
 * Dados atualizados:
 * - nome
 * - e-mail
 * - CPF
 * - telefone
 *
 * Segurança:
 * - somente usuário logado pode atualizar
 * - impede duplicidade de CPF
 * - impede duplicidade de e-mail
 * - sincroniza Firebase Auth + Firestore
 */

import { onCall, HttpsError } from "firebase-functions/https";
import { getAuth } from "firebase-admin/auth";
import {
  findByCPF,
  findByEmail,
  updateUser,
} from "../repositories/userRepository";

/**
 * Remove qualquer caractere não numérico.
 *
 * Exemplo:
 * "(19) 99999-9999" -> "19999999999"
 * "123.456.789-09" -> "12345678909"
 */
function onlyNumbers(value: string): string {
  return value.replace(/\D/g, "");
}

/**
 * Validação simples de e-mail.
 *
 * Retorna true se estiver no formato correto:
 * nome@email.com
 */
function isValidEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

/**
 * Validação oficial de CPF.
 *
 * Etapas:
 * 1. Remove pontos e traços
 * 2. Verifica se possui 11 dígitos
 * 3. Bloqueia números repetidos
 * 4. Calcula os 2 dígitos verificadores
 */
function isValidCPF(cpf: string): boolean {
  const cleanCPF = onlyNumbers(cpf);

  // CPF precisa ter 11 números
  if (cleanCPF.length !== 11) return false;

  // Bloqueia 11111111111 / 22222222222 etc
  if (/^(\d)\1+$/.test(cleanCPF)) return false;

  let sum = 0;

  /**
   * Primeiro dígito verificador
   */
  for (let i = 0; i < 9; i++) {
    sum += Number(cleanCPF[i]) * (10 - i);
  }

  let firstDigit = (sum * 10) % 11;
  if (firstDigit === 10) firstDigit = 0;

  if (firstDigit !== Number(cleanCPF[9])) return false;

  sum = 0;

  /**
   * Segundo dígito verificador
   */
  for (let i = 0; i < 10; i++) {
    sum += Number(cleanCPF[i]) * (11 - i);
  }

  let secondDigit = (sum * 10) % 11;
  if (secondDigit === 10) secondDigit = 0;

  return secondDigit === Number(cleanCPF[10]);
}

/**
 * Formata CPF para exibição amigável.
 *
 * Exemplo:
 * 12345678909 -> 123.456.789-09
 */
function formatCPF(cpf: string): string {
  const cleanCPF = onlyNumbers(cpf);

  return cleanCPF.replace(
    /(\d{3})(\d{3})(\d{3})(\d{2})/,
    "$1.$2.$3-$4"
  );
}

/**
 * Callable Function:
 * updateProfile()
 *
 * Fluxo completo:
 *
 * 1. Verifica autenticação
 * 2. Recebe dados enviados pelo frontend
 * 3. Valida campos obrigatórios
 * 4. Valida e-mail
 * 5. Valida CPF
 * 6. Valida telefone
 * 7. Verifica duplicidade no banco
 * 8. Atualiza Firebase Auth
 * 9. Atualiza Firestore
 * 10. Retorna sucesso
 */
export const updateProfile = onCall(async (request) => {

  /**
   * Somente usuário logado pode editar perfil
   */
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Usuário não autenticado");
  }

  const uid = request.auth.uid;

  /**
   * Dados recebidos do frontend
   */
  const { nome, email, cpf, telefone } = request.data;

  /**
   * Todos os campos são obrigatórios
   */
  if (!nome || !email || !cpf || !telefone) {
    throw new HttpsError(
      "invalid-argument",
      "Informe nome, email, CPF e telefone"
    );
  }

  /**
   * Validação de e-mail
   */
  if (!isValidEmail(email)) {
    throw new HttpsError("invalid-argument", "E-mail inválido");
  }

  /**
   * Validação de CPF
   */
  if (!isValidCPF(cpf)) {
    throw new HttpsError("invalid-argument", "CPF inválido");
  }

  /**
   * Remove máscara do telefone
   */
  const telefoneRaw = onlyNumbers(telefone);

  /**
   * Telefone brasileiro:
   * 10 dígitos = fixo
   * 11 dígitos = celular
   */
  if (telefoneRaw.length < 10 || telefoneRaw.length > 11) {
    throw new HttpsError("invalid-argument", "Telefone inválido");
  }

  /**
   * Remove máscara do CPF
   */
  const cpfRaw = onlyNumbers(cpf);

  /**
   * Verifica se CPF já pertence a outro usuário
   */
  const cpfExists = await findByCPF(cpfRaw);

  if (cpfExists && cpfExists.authUid !== uid) {
    throw new HttpsError("already-exists", "CPF já cadastrado");
  }

  /**
   * Verifica se e-mail já pertence a outro usuário
   */
  const emailExists = await findByEmail(email);

  if (emailExists && emailExists.authUid !== uid) {
    throw new HttpsError("already-exists", "E-mail já cadastrado");
  }

  /**
   * Atualiza Firebase Authentication
   *
   * Mantém login sincronizado com perfil.
   */
  try {
    await getAuth().updateUser(uid, {
      email,
      displayName: nome,
    });
  } catch (error: any) {

    if (error.code === "auth/email-already-exists") {
      throw new HttpsError("already-exists", "E-mail já cadastrado");
    }

    throw new HttpsError("internal", "Erro ao atualizar autenticação");
  }

  /**
   * Atualiza Firestore
   *
   * Guarda dados públicos e administrativos.
   */
  const updatedUser = await updateUser(uid, {
    nome,
    email,
    cpf: formatCPF(cpf),
    cpfRaw,
    telefone,
    telefoneRaw,
  });

  /**
   * Retorno para frontend
   */
  return {
    data: {
      message: "Perfil atualizado com sucesso",
      user: {
        id: updatedUser.id,
        nome: updatedUser.nome,
        email: updatedUser.email,
        cpf: updatedUser.cpf,
        telefone: updatedUser.telefone,
        saldo: updatedUser.saldo,
      },
    },
  };
});