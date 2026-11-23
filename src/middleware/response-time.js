// Bonus middleware: add X-Response-Time to every response.
// Headers must be set before they are flushed, so hook writeHead rather than
// listening for 'finish' (by then it is too late to add a header).
export function responseTime(req, res, next) {
  const start = process.hrtime.bigint();
  const originalWriteHead = res.writeHead;

  res.writeHead = function writeHeadWithTiming(...args) {
    if (!res.headersSent) {
      const ms = Number(process.hrtime.bigint() - start) / 1e6;
      res.setHeader('X-Response-Time', `${ms.toFixed(2)}ms`);
    }
    return originalWriteHead.apply(this, args);
  };

  next();
}
