const assert = require('node:assert/strict');
const { spawn } = require('node:child_process');
const fs = require('node:fs');
const net = require('node:net');
const os = require('node:os');
const path = require('node:path');
const { after, before, test } = require('node:test');

const root = path.join(__dirname, '..');
let baseUrl;
let tempDir;
let server;
let studentToken;
let tutorToken;
let studentId;
let tutorId;
let serverError = '';

const delay = ms => new Promise(resolve => setTimeout(resolve, ms));

async function request(route, { method = 'GET', token, body } = {}) {
  const response = await fetch(`${baseUrl}/api${route}`, {
    method,
    headers: {
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...(body === undefined ? {} : { 'Content-Type': 'application/json' }),
    },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  return { status: response.status, data: await response.json() };
}

async function login(email) {
  const result = await request('/auth/login', {
    method: 'POST',
    body: { email, password: 'demo123' },
  });
  assert.equal(result.status, 200);
  return result.data;
}

async function createBooking(overrides = {}) {
  return request('/bookings', {
    method: 'POST',
    token: studentToken,
    body: { tutor_id: tutorId, slot: 'Lun 17h', mode: 'En ligne', subject: 'Maths', ...overrides },
  });
}

before(async () => {
  tempDir = fs.mkdtempSync(path.join(os.tmpdir(), 'maak-api-test-'));
  const portServer = net.createServer();
  await new Promise((resolve, reject) => {
    portServer.once('error', reject);
    portServer.listen(0, '127.0.0.1', resolve);
  });
  const { port } = portServer.address();
  await new Promise((resolve, reject) => portServer.close(error => error ? reject(error) : resolve()));
  baseUrl = `http://127.0.0.1:${port}`;

  server = spawn(process.execPath, [path.join(root, 'server', 'index.js')], {
    cwd: root,
    env: {
      ...process.env,
      DB_FILE: path.join(tempDir, 'maak.db'),
      JWT_SECRET: 'test-only-secret',
      NODE_ENV: 'test',
      PORT: String(port),
    },
    stdio: ['ignore', 'ignore', 'pipe'],
  });
  server.stderr.setEncoding('utf8');
  server.stderr.on('data', chunk => { serverError += chunk; });

  for (let attempt = 0; attempt < 40; attempt++) {
    if (server.exitCode !== null) break;
    try {
      const response = await fetch(`${baseUrl}/api/tutors`);
      if (response.ok) break;
    } catch {}
    await delay(250);
  }
  if (server.exitCode !== null) throw new Error(`API server exited: ${serverError}`);

  const student = await login('eleve@maak.tn');
  const tutor = await login('tuteur@maak.tn');
  studentToken = student.token;
  tutorToken = tutor.token;
  studentId = student.user.id;
  tutorId = tutor.user.id;
});

after(async () => {
  if (server && server.exitCode === null) {
    const exited = new Promise(resolve => server.once('exit', resolve));
    server.kill();
    await Promise.race([exited, delay(3000)]);
  }
  if (tempDir && fs.existsSync(tempDir)) fs.rmSync(tempDir, { recursive: true, force: true });
});

test('requires authentication and validates registration input', async () => {
  const unauthorized = await request('/bookings', { method: 'POST', body: {} });
  assert.equal(unauthorized.status, 401);

  const invalidRegistration = await request('/auth/register', {
    method: 'POST',
    body: { name: 'Student', email: 'not-an-email', password: 'demo123', role: 'student' },
  });
  assert.equal(invalidRegistration.status, 400);

  const registered = await request('/auth/register', {
    method: 'POST',
    body: { name: ' New Student ', email: 'NEW.STUDENT@MAAK.TN', password: 'demo123', role: 'student' },
  });
  assert.equal(registered.status, 201);
  assert.equal(registered.data.user.name, 'New Student');

  const normalizedLogin = await request('/auth/login', {
    method: 'POST',
    body: { email: 'new.student@maak.tn', password: 'demo123' },
  });
  assert.equal(normalizedLogin.status, 200);
});

test('accepts only a tutor offered slot, mode and subject', async () => {
  for (const body of [
    { slot: 'Not offered' },
    { mode: 'Not offered' },
    { subject: 'Not taught' },
  ]) {
    const result = await createBooking(body);
    assert.equal(result.status, 400);
  }

  const result = await createBooking();
  assert.equal(result.status, 201);
  assert.equal(result.data.status, 'pending');
});

test('enforces booking transitions and permits one review after completion', async () => {
  const booking = await createBooking();
  assert.equal(booking.status, 201);

  const confirmed = await request(`/bookings/${booking.data.id}`, {
    method: 'PATCH',
    token: tutorToken,
    body: { status: 'confirmed' },
  });
  assert.equal(confirmed.status, 200);

  const invalidTransition = await request(`/bookings/${booking.data.id}`, {
    method: 'PATCH',
    token: tutorToken,
    body: { status: 'declined' },
  });
  assert.equal(invalidTransition.status, 409);

  const completed = await request(`/bookings/${booking.data.id}`, {
    method: 'PATCH',
    token: tutorToken,
    body: { status: 'done' },
  });
  assert.equal(completed.status, 200);

  const review = await request('/reviews', {
    method: 'POST',
    token: studentToken,
    body: { booking_id: booking.data.id, rating: 5, comment: 'Great session' },
  });
  assert.equal(review.status, 201);

  const duplicateReview = await request('/reviews', {
    method: 'POST',
    token: studentToken,
    body: { booking_id: booking.data.id, rating: 4 },
  });
  assert.equal(duplicateReview.status, 409);

  const cancellable = await createBooking();
  const cancelled = await request(`/bookings/${cancellable.data.id}`, {
    method: 'PATCH',
    token: studentToken,
    body: { status: 'cancelled' },
  });
  assert.equal(cancelled.status, 200);

  const invalidCompletion = await request(`/bookings/${cancellable.data.id}`, {
    method: 'PATCH',
    token: tutorToken,
    body: { status: 'done' },
  });
  assert.equal(invalidCompletion.status, 409);
});

test('validates tutor profile updates and saves valid changes', async () => {
  const invalid = await request('/tutor/profile', {
    method: 'PUT',
    token: tutorToken,
    body: { hourly_rate: 0, subjects: ['Unknown subject'] },
  });
  assert.equal(invalid.status, 400);

  const unknownSubject = await request('/tutor/profile', {
    method: 'PUT',
    token: tutorToken,
    body: { hourly_rate: 22, subjects: ['Unknown subject'] },
  });
  assert.equal(unknownSubject.status, 400);

  const unchanged = await request('/me', { token: tutorToken });
  assert.equal(unchanged.data.profile.p, 15);

  const valid = await request('/tutor/profile', {
    method: 'PUT',
    token: tutorToken,
    body: {
      hourly_rate: 20,
      bio: 'Available for lessons',
      is_available: true,
      subjects: ['Maths'],
      slots: ['Lun 18h'],
    },
  });
  assert.equal(valid.status, 200);

  const profile = await request('/me', { token: tutorToken });
  assert.equal(profile.data.profile.p, 20);
  assert.deepEqual(profile.data.profile.slots, ['Lun 18h']);
});

test('rejects invalid messages and delivers valid messages to both users', async () => {
  for (const body of ['', '   ', 'x'.repeat(1001)]) {
    const result = await request('/messages', {
      method: 'POST',
      token: studentToken,
      body: { to: tutorId, body },
    });
    assert.equal(result.status, 400);
  }

  const sent = await request('/messages', {
    method: 'POST',
    token: studentToken,
    body: { to: tutorId, body: 'Hello tutor' },
  });
  assert.equal(sent.status, 201);

  const received = await request('/messages', { token: tutorToken });
  assert.ok(received.data.some(message => message.id === sent.data.id && message.sender_id === studentId));
});
