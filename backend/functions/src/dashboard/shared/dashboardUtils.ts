//Código feito por Lucas David de Sousa
//RA: 25895152

import { DashboardPeriod } from "../types/dashboard";

export function getStartDateByPeriod(
  period: DashboardPeriod
): Date {

  const now = new Date();

  switch (period) {

    case "daily":
      now.setDate(now.getDate() - 1);
      return now;

    case "weekly":
      now.setDate(now.getDate() - 7);
      return now;

    case "monthly":
      now.setMonth(now.getMonth() - 1);
      return now;

    case "6months":
      now.setMonth(now.getMonth() - 6);
      return now;

    case "ytd":
      return new Date(
        now.getFullYear(),
        0,
        1
      );

    default:
      return new Date(0);
  }
}

export function calculateVariationPercent(
  firstPrice: number,
  currentPrice: number
): number {

  if (firstPrice === 0) {
    return 0;
  }

  return Number(
    (
      ((currentPrice - firstPrice) / firstPrice) * 100
    ).toFixed(2)
  );
}

export function calculateProfit(
  investedValue: number,
  currentValue: number
): number {

  return currentValue - investedValue;
}