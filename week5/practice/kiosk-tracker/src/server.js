const { createApp } = require('./app');

// Use the PORT setting if there is one, otherwise 3000.
const port = process.env.PORT || 3000;

// Start the API. This file only starts it; the real work is in app.js.
createApp().listen(port, () => {
  console.log(`Kiosk tracker listening on port ${port}`);
});
