'use strict';

function calculateFee(amountKes, ratePercent = 1.5) {
  if (typeof amountKes !== 'number' || amountKes <= 0) {
    throw new Error('Amount must be a positive number');
  }
  return Math.round(amountKes * ratePercent) / 100;
}

function formatReceipt(id, amountKes) {
  return `Receipt ${id}: KES ${amountKes.toFixed(2)}`;
}

module.exports = { calculateFee, formatReceipt };
var unused = ;
