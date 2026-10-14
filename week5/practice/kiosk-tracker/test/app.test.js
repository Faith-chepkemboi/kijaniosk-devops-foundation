const request = require('supertest');
const { createApp } = require('../src/app');

describe('kiosk tracker API', () => {
  let app;

  // A fresh app before every test, so one test cannot affect another.
  beforeEach(() => {
    app = createApp();
  });

  test('health check says ok', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ status: 'ok' });
  });

  test('lists the starting items', async () => {
    const res = await request(app).get('/items');
    expect(res.status).toBe(200);
    expect(res.body).toHaveLength(3);
  });

  test('adds a new item', async () => {
    const res = await request(app)
      .post('/items')
      .send({ name: 'Rice 1kg', price: 200, quantity: 10 });
    expect(res.status).toBe(201);
    expect(res.body.name).toBe('Rice 1kg');
  });

  test('rejects an item with no name', async () => {
    const res = await request(app)
      .post('/items')
      .send({ price: 200, quantity: 10 });
    expect(res.status).toBe(400);
  });

  test('a sale lowers the stock and returns the amount', async () => {
    const sale = await request(app).post('/sales').send({ itemId: 2, quantity: 2 });
    expect(sale.status).toBe(201);
    expect(sale.body.amount).toBe(340);

    const items = await request(app).get('/items');
    const sugar = items.body.find((i) => i.id === 2);
    expect(sugar.quantity).toBe(2);
  });

  test('refuses to sell more than is in stock', async () => {
    const res = await request(app).post('/sales').send({ itemId: 2, quantity: 50 });
    expect(res.status).toBe(400);
    expect(res.body.error).toBe('not enough stock');
  });

  test('returns 404 for an item that does not exist', async () => {
    const res = await request(app).post('/sales').send({ itemId: 99, quantity: 1 });
    expect(res.status).toBe(404);
  });

  test('the report adds up all sales', async () => {
    await request(app).post('/sales').send({ itemId: 1, quantity: 2 });
    await request(app).post('/sales').send({ itemId: 3, quantity: 3 });

    const res = await request(app).get('/report');
    expect(res.body.totalSales).toBe(520);
    expect(res.body.itemsSold).toBe(5);
    expect(res.body.numberOfSales).toBe(2);
  });
});
