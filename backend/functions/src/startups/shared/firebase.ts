/**
 * Código feito por Lucas David de Sousa(disponibilizado pelo professor), RA: 25895152
 *
 */

import { getAuth } from "firebase-admin/auth";
import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";

if(getApps().length === 0) {
  initializeApp();
}

export const auth = getAuth();
export const db = getFirestore();