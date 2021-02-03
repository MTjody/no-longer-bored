const http = require("http");

/**
 * Proxy GET method for the Bored Api (https://www.boredapi.com/documentation)
 *
 * The bored API is served over HTTP which stops browsers from calling it from a HTTPS site.
 *
 */
exports.boredProxy = (req, res) => {
  // Set CORS headers for preflight requests
  // Allows GETs from any origin with the Content-Type header
  // and caches preflight response for 3600s

  res.set("Access-Control-Allow-Origin", "https://mtjody.github.io/");
  switch (req.method) {
    case "OPTIONS": {
      // Send response to OPTIONS requests
      res.set("Access-Control-Allow-Methods", "GET");
      res.set("Access-Control-Allow-Headers", "Content-Type");
      res.set("Access-Control-Max-Age", "3600");
      res.status(204).send("");
      return;
    }
    case "GET": {
      http
        .get("http://www.boredapi.com/api/activity/", (response) => {
          let chunks = "";

          // called when a data chunk is received.
          response.on("data", (chunk) => {
            chunks += chunk;
          });

          // called when the complete response is received.
          response.on("end", () => {
            res.json(JSON.parse(chunks));
          });
        })
        .on("error", (error) => {
          res.status(500).send("Error", error);
          console.error("Error: " + error.message);
        });

      break;
    }
    default:
      res.status(403).send("Forbidden!");
      break;
  }
};
