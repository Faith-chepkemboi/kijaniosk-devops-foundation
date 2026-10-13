const { calculateFee, formatReceipt } = require('../src/index');

test('calculates a 1.5% fee', () => {
  expect(calculateFee(1000)).toBe(15);
});

test('rejects a negative amount', () => {
  expect(() => calculateFee(-5)).toThrow('positive number');
});

test('formats a receipt', () => {
  expect(formatReceipt('A1', 250)).toBe('Receipt A1: KES 250.00');
});

test('deliberate failure', () => {
  expect(true).toBe(false);
});
