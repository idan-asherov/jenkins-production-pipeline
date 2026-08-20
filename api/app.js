const express = require("express");
const { randomGreets } = require("./greets");
const app = express();

app.get("/health", (req, res) => {
  res.json({ 
    status: "ok",
    build: process.env.BUILD_NUMBER || "local",
    commit: process.env.COMMIT_HASH || "unknown"
  });
});

app.get("/api/greets", (req, res) => {
  res.json({ greets: randomGreets() });
});

app.listen(3000, () => {
  console.log("API is running on port 3000");
});
