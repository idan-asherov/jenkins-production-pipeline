#!/bin/bash
echo "Cleaning old files..."
docker compose down --volumes --remove-orphans 2>/dev/null || true
rm -rf api web node_modules

echo "Creating package.json..."
cat << 'PKG' > package.json
{
  "name": "jenkins-pipeline-project",
  "version": "1.0.0",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "test": "node --test"
  },
  "dependencies": {
    "express": "^4.21.0"
  }
}
PKG

echo "Creating greets.js..."
cat << 'GREET' > greets.js
const greets = [
  "Today is your best day.",
  "You're closer to your goals than yesterday.",
  "Great things start with small actions.",
  "This is a good day to make progress.",
  "You've got everything you need to succeed.",
  "Every step you take moves you forward."
];
function randomGreets() {
  const index = Math.floor(Math.random() * greets.length);
  return greets[index];
}
module.exports = { randomGreets, greets };
GREET

echo "Creating greets.test.js..."
cat << 'TEST' > greets.test.js
const { test } = require("node:test");
const assert = require("node:assert");
const { greets, randomGreets } = require("./greets");
test("There are at least 5 greetings", () => {
  assert.ok(greets.length >= 5, "Need at least 5 greetings");
});
test("randomGreets returns a valid string", () => {
  const result = randomGreets();
  assert.strictEqual(typeof result, "string");
});
TEST

echo "Creating app.js..."
cat << 'APP' > app.js
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
APP

echo "Creating styles.css..."
cat << 'CSS' > styles.css
* { box-sizing: border-box; margin: 0; padding: 0; }
body {
  font-family: Arial, sans-serif;
  background-color: #0f172a;
  color: #f8fafc;
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
}
.card {
  background-color: #1e293b;
  padding: 2rem;
  border-radius: 12px;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.3);
  text-align: center;
  max-width: 400px;
  width: 90%;
}
h1 { font-size: 1.5rem; margin-bottom: 1.5rem; color: #38bdf8; }
p { font-size: 1.1rem; margin-bottom: 1.5rem; min-height: 50px; }
button {
  background-color: #0284c7;
  color: white;
  border: none;
  padding: 0.75rem 1.5rem;
  font-size: 1rem;
  border-radius: 6px;
  cursor: pointer;
}
button:hover { background-color: #0369a1; }
CSS

echo "Creating index.html..."
cat << 'HTML' > index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Jenkins Pipeline App</title>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <div class="card">
    <h1>Random Greeting Generator</h1>
    <p id="greeting">Loading...</p>
    <button onclick="fetchGreeting()">Get New Greeting</button>
  </div>
  <script>
    async function fetchGreeting() {
      try {
        const response = await fetch('/api/greets');
        const data = await response.json();
        document.getElementById('greeting').innerText = data.greets;
      } catch (error) {
        document.getElementById('greeting').innerText = 'Error fetching greeting!';
      }
    }
    fetchGreeting();
  </script>
</body>
</html>
HTML

echo "Creating Dockerfile..."
cat << 'DOC' > Dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 8000
CMD [ "npm", "start" ]
DOC

echo "Creating docker-compose.yml..."
cat << 'COMPOSE' > docker-compose.yml
services:
  app:
    build: .
    ports:
      - "8000:8000"
COMPOSE

echo "Setup script completed!"
