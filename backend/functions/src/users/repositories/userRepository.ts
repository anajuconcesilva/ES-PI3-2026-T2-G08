/**
 * Código feito por Lucas David de Sousa, RA: 25895152
 *
 * ================================
 * USER REPOSITORY
 * ================================
 *
 * Responsável por todas as operações no Firestore relacionadas a usuários.
 *
 * Funções:
 * - createUser: cria um novo documento de usuário
 * - findByCPF: busca usuário pelo CPF
 * - findByEmail: busca usuário pelo e-mail
 * - findByAuthUid: busca usuário pelo UID do Firebase Auth
 * - updateUser: atualiza dados do usuário
 *
 * Camada de abstração:
 * - Evita acesso direto ao Firestore dentro dos handlers
 */

import { db } from "../../auth/shared/firebase";
import { User, UserWithId } from "../types/user";

const COLLECTION = "users";

// Buscar por email
export async function getUserByEmail(email: string): Promise<UserWithId | null> {
  const snapshot = await db
    .collection(COLLECTION)
    .where("email", "==", email)
    .limit(1)
    .get();

  if (snapshot.empty) return null;

  const doc = snapshot.docs[0];

  return {
    id: doc.id,
    ...(doc.data() as User),
  };
}

// Buscar por CPF
export async function getUserByCPF(cpfRaw: string): Promise<UserWithId | null> {
  const snapshot = await db
    .collection(COLLECTION)
    .where("cpfRaw", "==", cpfRaw)
    .limit(1)
    .get();

  if (snapshot.empty) return null;

  const doc = snapshot.docs[0];

  return {
    id: doc.id,
    ...(doc.data() as User),
  };
}

// Buscar por UID do Firebase Auth
export async function getUserByAuthUid(
  authUid: string
): Promise<UserWithId | null> {
  const doc = await db.collection(COLLECTION).doc(authUid).get();

  if (!doc.exists) return null;

  return {
    id: doc.id,
    ...(doc.data() as User),
  };
}

// Criar usuário
export async function createUser(user: User): Promise<UserWithId> {
  const docRef = db.collection(COLLECTION).doc(user.authUid);

  await docRef.set(user);

  return {
    id: docRef.id,
    ...user,
  };
}

// Atualizar usuário
export async function updateUser(
  authUid: string,
  data: Partial<User>
): Promise<UserWithId> {
  const docRef = db.collection(COLLECTION).doc(authUid);

  await docRef.set(data, { merge: true });

  const updatedDoc = await docRef.get();

  return {
    id: updatedDoc.id,
    ...(updatedDoc.data() as User),
  };
}