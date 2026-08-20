const express = require("express");
const path = require("path");
const { randomGreets } = require("./greets");
const app = express();
const PORT = 8000;
app.use(express.static(__dirname));
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
app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "index.html"));
});
app.listen(PORT, () => {
  console.log(`App is running on port ${PORT}`);
});
