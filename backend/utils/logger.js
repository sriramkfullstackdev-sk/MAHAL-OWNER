const morgan = require("morgan");

// Log incoming HTTP requests in development format (colored status codes, response time)
const logger = morgan("dev");

module.exports = logger;
