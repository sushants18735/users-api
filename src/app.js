import express from 'express';
import { config } from './config/env.js';
import { errorHandler } from './middleware/error-handler.js';
import { notFoundHandler } from './middleware/not-found.js';
import { requestId } from './middleware/request-id.js';
import { requestLogger } from './middleware/request-logger.js';
import { requireJson } from './middleware/require-json.js';
import { responseTime } from './middleware/response-time.js';
import { createUsersRouter } from './routes/users.routes.js';

// Builds the Express app from the objects in the container. Does NOT call listen().
export function createApp({ usersController }) {
  const app = express();

  app.disable('x-powered-by'); // don't advertise the framework
  app.set('trust proxy', 'loopback'); // trust X-Forwarded-* only from a local proxy (Nginx)

  // ── 1. App-level middleware (runs top to bottom for EVERY request) ──
  app.use(requestId);
  app.use(responseTime); // bonus: X-Response-Time header on every response
  if (!config.isTest) app.use(requestLogger);
  app.use(requireJson); // 415 unless POST/PUT/PATCH bodies are JSON
  app.use(express.json({ limit: config.bodyLimit }));

  // ── 2. Routes ──
  app.get('/health', (req, res) => {
    res.json({ status: 'ok', uptimeSec: Math.round(process.uptime()) });
  });
  app.use('/api/v1/users', createUsersRouter(usersController));

  // ── 3. Fallbacks (order matters: these must be LAST) ──
  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}
