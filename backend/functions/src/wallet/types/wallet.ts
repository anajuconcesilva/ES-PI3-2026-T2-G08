// Código feito por Laura Cristine Soares
// RA: 24802431

export interface StartupInvestment {
  quantity: number;
  investedValue: number;
}

export interface Wallet {
  balance: number;

  investments: {
    [startupId: string]: StartupInvestment;
  };
}