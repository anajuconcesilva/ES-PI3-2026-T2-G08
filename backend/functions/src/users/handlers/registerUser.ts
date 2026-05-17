/**
 * Código feito por Lucas David de Sousa, RA: 25895152
 *
 * =================================
 * REGISTER USER - FIREBASE FUNCTION
 * =================================
 *
 * Responsável por cadastrar um novo usuário no sistema.
 *
 * Fluxo:
 * 1. Recebe dados do frontend (nome, email, cpf, telefone, senha)
 * 2. Valida dados de entrada
 * 3. Normaliza CPF e telefone
 * 4. Verifica duplicidade de CPF no Firestore
 * 5. Verifica duplicidade de email no Firebase Auth
 * 6. Cria usuário no Firebase Authentication
 * 7. Salva dados adicionais no Firestore (sem senha)
 * 8. Retorna resposta ao cliente
 *
 * Segurança:
 * - Senha é armazenada SOMENTE no Firebase Auth (não vai para Firestore)
 * - CPF e telefone são armazenados em formato bruto e formatado
 */

import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getAuth } from "firebase-admin/auth";
import { Timestamp } from "firebase-admin/firestore";

import { createUser, getUserByCPF } from "../repositories/userRepository";
import {
    validateRegisterInput,
    formatCPF,
    formatPhone,
} from "../shared/validators";

/**
 * API de cadastro de usuário (Callable)
 */
export const registerUser = onCall(async (request) => {

  const validation = validateRegisterInput(request.data);

  if (!validation.valid) {
    throw new HttpsError("invalid-argument", validation.message);
  }

  const { nome, email, cpf, telefone, senha } = validation.data;

  const cpfExists = await getUserByCPF(cpf);

  if (cpfExists) {
    throw new HttpsError("already-exists", "CPF já cadastrado");
  }

  let userRecord;

  try {
    userRecord = await getAuth().createUser({
      email,
      password: senha,
      displayName: nome,
    });
  } catch (error: any) {
    if (error.code === "auth/email-already-exists") {
      throw new HttpsError("already-exists", "E-mail já cadastrado");
    }

    throw new HttpsError("internal", "Erro ao criar usuário");
  }

  const user = await createUser({
    authUid: userRecord.uid,
    nome,
    email,
    cpf: formatCPF(cpf),
    cpfRaw: cpf,
    telefone: formatPhone(telefone),
    telefoneRaw: telefone,
    wallet: {
        balance: 0,
        investments: {},
    },
    createdAt: Timestamp.now(),
  });

  return {
    data: {
      message: "Usuário cadastrado com sucesso",
      user: {
        id: user.id,
        nome: user.nome,
        email: user.email,
        wallet: user.wallet,
      },
    },
  };
});