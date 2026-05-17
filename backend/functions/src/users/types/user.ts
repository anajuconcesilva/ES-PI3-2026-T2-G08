/**
 * Código feito por Lucas David de Sousa, RA: 25895152
 *
 * ================================
 * USER TYPE
 * ================================
 *
 * Define o formato padrão de usuário salvo no Firestore.
 *
 * IMPORTANTE:
 * - NÃO contém senha (gerenciada pelo Firebase Auth)
 * - contém apenas dados públicos e administrativos
 */

import { Timestamp } from "firebase-admin/firestore";

export interface User {
    authUid: string;
    nome: string;
    email: string;
    cpf: string;
    cpfRaw: string;
    telefone: string;
    telefoneRaw: string;

    wallet: {
        balance: number;
        investments: Record<string, number>;
    };
    createdAt: Timestamp;

    mfaEnabled?: boolean;
    mfaVerified?: boolean;
    mfaCode?: string | null;
    mfaExpiresAt?: number | null;
    mfaVerifiedAt?: number | null;
}

/**
 * Tipo usado quando o documento já vem do Firestore
 */
export interface UserWithId extends User {
    id: string;
}