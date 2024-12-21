import test from 'ava'; // AVA's test runner
import request from 'supertest'; // HTTP assertions
import app from '../app.js'; // Import the app

test('GET / - should return "Hello, World!"', async (t) => {
    const res = await request(app).get('/');
    t.is(res.status, 200); // Assert HTTP status
    t.is(res.text, 'Hello, World!'); // Assert response text
});

test('GET /unknown - error 404', async (t) => {
    const res = await request(app).get('/unknown');
    t.is(res.status, 404);
});
