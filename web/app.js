const express = require("express");
const path = require("path");
const app = express();

app.get("/health", (req, res) => {
  res.json({ 
    status: "ok",
    build: process.env.BUILD_NUMBER || "local",
    commit: process.env.COMMIT_HASH || "unknown"
  });
});

app.get("/api/greets", async (req, res) => {
  try {
    const response = await fetch("http://api:3000/api/greets");
    const data = await response.json();
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: "API connection failed" });
  }
});

app.use(express.static(__dirname));

app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "index.html"));
});

app.listen(8000, () => {
  console.log("Web server is running on port 8000");
});
