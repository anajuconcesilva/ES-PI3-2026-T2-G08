/**
 * Código feito por Lucas David de Sousa, RA: 25895152
 *
 * ================================
 * VALIDATORS (UTILITÁRIOS)
 * ================================
 *
 * Funções puras responsáveis por:
 * - validar dados de entrada
 * - formatar CPF e telefone
 * - normalizar strings
 *
 * Não dependem de banco de dados ou Firebase
 */

/*
 * Remove tudo que não for número
 */
export function onlyNumbers(value: string): string {
  return value.replace(/\D/g, "");
}

/*
 *CPF
 */

// Validação de CPF (algoritmo oficial)
export function validateCPF(cpf: string): boolean {
  cpf = onlyNumbers(cpf);

  if (cpf.length !== 11) return false;

  // elimina sequências inválidas
  if (/^(\d)\1+$/.test(cpf)) return false;

  let soma = 0;
  let resto;

  // primeiro dígito
  for (let i = 1; i <= 9; i++) {
    soma += parseInt(cpf.substring(i - 1, i), 10) * (11 - i);
  }

  resto = (soma * 10) % 11;
  if (resto === 10 || resto === 11) resto = 0;
  if (resto !== parseInt(cpf.substring(9, 10), 10)) return false;

  // segundo dígito
  soma = 0;
  for (let i = 1; i <= 10; i++) {
    soma += parseInt(cpf.substring(i - 1, i), 10) * (12 - i);
  }

  resto = (soma * 10) % 11;
  if (resto === 10 || resto === 11) resto = 0;

  return resto === parseInt(cpf.substring(10, 11), 10);
}

// Formata CPF: XXX.XXX.XXX-XX
export function formatCPF(cpf: string): string {
  const cleaned = onlyNumbers(cpf);

  if (cleaned.length !== 11) return cpf;

  return cleaned.replace(
    /(\d{3})(\d{3})(\d{3})(\d{2})/,
    "$1.$2.$3-$4"
  );
}

/*
 *Telefone
 */

// Lista real de DDDs válidos
const validDDDs = [
  "11","12","13","14","15","16","17","18","19",
  "21","22","24","27","28",
  "31","32","33","34","35","37","38",
  "41","42","43","44","45","46",
  "47","48","49",
  "51","53","54","55",
  "61","62","63","64","65","66","67","68","69",
  "71","73","74","75","77","79",
  "81","82","83","84","85","86","87","88","89",
  "91","92","93","94","95","96","97","98","99"
];

// Validação de celular brasileiro
export function validatePhone(phone: string): boolean {
  const cleaned = onlyNumbers(phone);

  if (cleaned.length !== 11) return false;

  const ddd = cleaned.substring(0, 2);
  const numero = cleaned.substring(2);

  if (!validDDDs.includes(ddd)) return false;

  // celular começa com 9
  if (!numero.startsWith("9")) return false;

  return true;
}

// Formata telefone: (11) 99999-9999
export function formatPhone(phone: string): string {
  const cleaned = onlyNumbers(phone);

  if (cleaned.length !== 11) return phone;

  return cleaned.replace(
    /^(\d{2})(\d{5})(\d{4})$/,
    "($1) $2-$3"
  );
}

/*
 *E-mail
 */

// Validação de e-mail
export function validateEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

/*
 * Senha
 */

// Validação básica (ajustável de acordo com a preferência do nosso grupo)
export function validatePassword(password: string): boolean {
  return password.length >= 6;
}

/*
 * Normalização
 */

export function normalizeCPF(cpf: string): string {
  return onlyNumbers(cpf);
}

export function normalizePhone(phone: string): string {
  return onlyNumbers(phone);
}

// Remove espaços e garante string válida
export function normalizeString(value: unknown): string {
  if (typeof value !== "string") return "";

  return value.trim();
}

/*
 * Validador de entrada completo para cadastro de usuário
 */

type RegisterInput = {
  nome: string;
  email: string;
  cpf: string;
  telefone: string;
  senha: string;
};

type ValidationResult =
  | { valid: false; message: string }
  | { valid: true; data: RegisterInput };

export function validateRegisterInput(data: any): ValidationResult {
  const nome = normalizeString(data.nome);
  const email = normalizeString(data.email).toLowerCase();
  const cpf = normalizeCPF(data.cpf);
  const telefone = normalizePhone(data.telefone);
  const senha = normalizeString(data.senha);

  if (!nome || !email || !cpf || !telefone || !senha) {
    return { valid: false, message: "Todos os campos são obrigatórios" };
  }

  if (!validateEmail(email)) {
    return { valid: false, message: "E-mail inválido" };
  }

  if (!validateCPF(cpf)) {
    return { valid: false, message: "CPF inválido" };
  }

  if (!validatePhone(telefone)) {
    return { valid: false, message: "Telefone inválido" };
  }

  if (!validatePassword(senha)) {
    return { valid: false, message: "Senha inválida" };
  }

  return {
    valid: true,
    data: { nome, email, cpf, telefone, senha }
  };
}

/*
 * Validador de entrada completo para atualizar perfil
 */

type UpdateProfileInput = {
  nome: string;
  email: string;
  cpf: string;
  telefone: string;
};

type UpdateValidationResult =
  | { valid: false; message: string }
  | { valid: true; data: UpdateProfileInput };

export function validateUpdateProfileInput(data: any): UpdateValidationResult {
  const nome = normalizeString(data.nome);
  const email = normalizeString(data.email).toLowerCase();
  const cpf = normalizeCPF(data.cpf);
  const telefone = normalizePhone(data.telefone);

if (!nome || !email || !cpf || !telefone) {
  return { valid: false, message: "Todos os campos são obrigatórios" };
}

if (!validateEmail(email)) {
  return { valid: false, message: "E-mail inválido" };
}

if (!validateCPF(cpf)) {
  return { valid: false, message: "CPF inválido" };
}

if (!validatePhone(telefone)) {
  return { valid: false, message: "Telefone inválido" };
}

return {
    valid: true,
    data: { nome, email, cpf, telefone }
  };
}