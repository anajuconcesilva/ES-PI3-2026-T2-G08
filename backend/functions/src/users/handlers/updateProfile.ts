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

import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getAuth } from "firebase-admin/auth";

import {
  findByCPF,
  findByEmail,
  updateUser,
} from "../repositories/userRepository";

import {
    validateUpdateProfileInput,
    formatCPF,
    formatPhone
} from "../shared/validators";

export const updateProfile = onCall(async (request) => {

  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Usuário não autenticado");
  }

  const uid = request.auth.uid;

  /**
   * Normalização dos dados
   */
  const validation = validateUpdateProfileInput(request.data);

  if (!validation.valid) {
    throw new HttpsError("invalid-argument", validation.message);
  }

  const { nome, email, cpf, telefone } = validation.data;

  /**
   * Verifica duplicidade
   */
  const cpfExists = await findByCPF(cpf);

  if (cpfExists && cpfExists.authUid !== uid) {
    throw new HttpsError("already-exists", "CPF já cadastrado");
  }

  const emailExists = await findByEmail(email);

  if (emailExists && emailExists.authUid !== uid) {
    throw new HttpsError("already-exists", "E-mail já cadastrado");
  }

  /**
   * Atualiza Firebase Auth
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
   */
  const updatedUser = await updateUser(uid, {
    nome,
    email,
    cpf: formatCPF(cpf),
    cpfRaw: cpf,
    telefone: formatPhone(telefone),
    telefoneRaw: telefone,
  });

  return {
    data: {
      message: "Perfil atualizado com sucesso",
      user: {
        id: updatedUser.id,
        nome: updatedUser.nome,
        email: updatedUser.email,
        cpf: updatedUser.cpf,
        telefone: updatedUser.telefone,
      },
    },
  };
});