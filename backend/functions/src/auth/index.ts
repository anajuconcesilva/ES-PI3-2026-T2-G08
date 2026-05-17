/**
 * Código feito por Laura Cristine Soares, RA: 24802431
 *
 * ================================
 * AUTH MODULE EXPORTS
 * ================================
 *
 * Responsável por exportar as Firebase Functions relacionadas
 * ao módulo de autenticação.
 */

export { me } from "./handlers/me";
export { startMfa } from "./handlers/startMfa";
export { verifyMfa } from "./handlers/verifyMfa";
export { disableMfa } from "./handlers/disableMfa";