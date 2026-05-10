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