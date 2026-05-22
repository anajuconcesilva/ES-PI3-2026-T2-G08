//Código feito por Lucas David de Sousa
//RA: 25895152

export type DashboardPeriod =
  | "daily"
  | "weekly"
  | "monthly"
  | "6months"
  | "ytd";

export interface ValuationPoint {
  label: string;
  price: number;
  timestamp: Date;
}

export interface TokenValuationResponse {
  startupId: string;
  currentPrice: number;
  variationPercent: number;
  points: ValuationPoint[];
}

export interface PortfolioInvestment {
  startupId: string;
  quantity: number;
  investedValue: number;
  currentValue: number;
  profit: number;
  variationPercent: number;
}

export interface PortfolioValuationResponse {
  totalInvested: number;
  totalCurrentValue: number;
  totalProfit: number;
  totalVariationPercent: number;
  investments: PortfolioInvestment[];
}