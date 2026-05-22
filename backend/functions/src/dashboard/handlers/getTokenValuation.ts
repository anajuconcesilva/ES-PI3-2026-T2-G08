//Código feito por Lucas David de Sousa
//RA: 25895152

import {
  onCall,
  HttpsError,
} from "firebase-functions/v2/https";

import { requireAuthenticatedUser }
from "../../wallet/shared/auth";

import {
  getStartupTransactions,
} from "../repositories/dashboardRepository";

import {
  calculateVariationPercent,
  getStartDateByPeriod,
} from "../shared/dashboardUtils";

import {
  DashboardPeriod,
} from "../types/dashboard";

export const getTokenValuation =
onCall(async (request) => {

  requireAuthenticatedUser(request);

  const {
    startupId,
    period,
  } = request.data;

  if (!startupId) {
    throw new HttpsError(
      "invalid-argument",
      "Startup inválida"
    );
  }

  const selectedPeriod =
    (period || "monthly") as DashboardPeriod;

  const startDate =
    getStartDateByPeriod(selectedPeriod);

  const transactions =
    await getStartupTransactions(
      startupId,
      startDate
    );

  if (transactions.length === 0) {

    return {
      data: {
        startupId,
        currentPrice: 0,
        variationPercent: 0,
        points: [],
      },
    };
  }

  const points = transactions.map(
    (transaction: any) => {

      const price =
        transaction.amount /
        transaction.quantity;

      const date =
        transaction.createdAt.toDate();

      return {

        label:
          `${date.getDate()}/${date.getMonth() + 1}`,

        price,

        timestamp: date,
      };
    }
  );

  const firstPrice =
    points[0].price;

  const currentPrice =
    points[points.length - 1].price;

  const variationPercent =
    calculateVariationPercent(
      firstPrice,
      currentPrice
    );

  return {
    data: {
      startupId,
      currentPrice,
      variationPercent,
      points,
    },
  };
});