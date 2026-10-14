const express = require('express');
const path = require('path');

// This function builds the whole API. Keeping it in a function means each
// test can get a fresh app with fresh data, and nothing leaks between tests.
function createApp() {
  const app = express();

  // Lets the API read JSON sent in a request body.
  app.use(express.json());

  // Serve the screens (HTML, CSS, JS) from the public folder.
  app.use(express.static(path.join(__dirname, '..', 'public')));

  // Starting stock. For now it lives in memory, so it resets when the app restarts.
  const items = [
    { id: 1, name: 'Maize flour 2kg', price: 170, quantity: 38 },
    { id: 2, name: 'Sugar 1kg', price: 170, quantity: 4 },
    { id: 3, name: 'Milk 500ml', price: 60, quantity: 24 },
  ];
  const sales = [];
  let nextItemId = 4;

  // A quick check that the app is alive. Useful later for the pipeline.
  app.get('/health', (req, res) => {
    res.json({ status: 'ok' });
  });

  // Stock list screen: return every item.
  app.get('/items', (req, res) => {
    res.json(items);
  });

  // "Add an item" form: create a new stock item.
  app.post('/items', (req, res) => {
    const { name, price, quantity } = req.body;

    // Reject anything missing or invalid, with a clear message.
    if (!name || typeof price !== 'number' || price < 0 || !Number.isInteger(quantity) || quantity < 0) {
      return res.status(400).json({ error: 'name, price and quantity are required' });
    }

    const item = { id: nextItemId, name, price, quantity };
    nextItemId += 1;
    items.push(item);
    return res.status(201).json(item);
  });

  // "Record a sale" screen: sell some of an item and lower its stock.
  app.post('/sales', (req, res) => {
    const { itemId, quantity } = req.body;
    const item = items.find((i) => i.id === itemId);

    // The item must exist.
    if (!item) {
      return res.status(404).json({ error: 'item not found' });
    }
    // The quantity must be a whole number of at least 1.
    if (!Number.isInteger(quantity) || quantity < 1) {
      return res.status(400).json({ error: 'quantity must be a whole number of at least 1' });
    }
    // We cannot sell more than we have on the shelf.
    if (quantity > item.quantity) {
      return res.status(400).json({ error: 'not enough stock' });
    }

    // All checks passed: take the items off the shelf and save the sale.
    item.quantity -= quantity;
    const sale = {
      id: sales.length + 1,
      itemId,
      name: item.name,
      quantity,
      amount: item.price * quantity,
      time: new Date().toISOString(),
    };
    sales.push(sale);
    return res.status(201).json(sale);
  });

  // Daily report screen: totals plus the list of sales.
  app.get('/report', (req, res) => {
    res.json({
      totalSales: sales.reduce((sum, s) => sum + s.amount, 0),
      itemsSold: sales.reduce((sum, s) => sum + s.quantity, 0),
      numberOfSales: sales.length,
      sales,
    });
  });

  return app;
}

module.exports = { createApp };
