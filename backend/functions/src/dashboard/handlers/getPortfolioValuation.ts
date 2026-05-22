//Código feito por Lucas David de Sousa
//RA: 25895152

import {
  onCall,
} from "firebase-functions/v2/https";

import {
  requireAuthenticatedUser,
} from "../../wallet/shared/auth";

import {
  getWalletByUserId,
} from "../../wallet/repositories/walletRepository";

import {
  getStartupById,
} from "../repositories/dashboardRepository";

import {
  calculateProfit,
  calculateVariationPercent,
} from "../shared/dashboardUtils";

import { db } from "../../startups/shared/firebase";

export const getPortfolioValuation =
onCall(async (request) => {

  const user =
    requireAuthenticatedUser(request);

  const wallet =
    await getWalletByUserId(user.uid);

  if (!wallet) {

    return {
      data: {
        totalInvested: 0,
        totalCurrentValue: 0,
        totalProfit: 0,
        totalVariationPercent: 0,
        investments: [],
      },
    };
  }

  const investments = [];

  let totalInvested = 0;

  let totalCurrentValue = 0;

  for (
    const startupId
    of Object.keys(wallet.investments)
  ) {

    const investment =
      wallet.investments[startupId];

    const startup =
      await getStartupById(startupId);

    if (!startup) {
      continue;
    }

    const quantity =
      investment.quantity;

    const investedValue =
      investment.investedValue;

    const currentValue =
      quantity *
      startup.currentTokenPriceCents;

    const profit =
      calculateProfit(
        investedValue,
        currentValue
      );

    const variationPercent =
      calculateVariationPercent(
        investedValue,
        currentValue
      );

    const startupDoc = await db
      .collection("startups")
      .doc(startupId)
      .get();

    const startupData = startupDoc.data();

    investments.push({

      startupId: startupId,
      startupName: startupData?.name || startupId,
      quantity,
      investedValue,
      currentValue,
      profit,
      variationPercent,
    });

    totalInvested += investedValue;

    totalCurrentValue += currentValue;
  }

  const totalProfit =
    calculateProfit(
      totalInvested,
      totalCurrentValue
    );

  const totalVariationPercent =
    calculateVariationPercent(
      totalInvested,
      totalCurrentValue
    );

  return {
    data: {
      totalInvested,
      totalCurrentValue,
      totalProfit,
      totalVariationPercent,
      investments,
    },
  };
});