#!/bin/bash

# 1. ניקוי וסגירת קונטיינרים ישנים
echo "Cleaning old files and containers..."
docker compose down --volumes --remove-orphans 2>/dev/null || true
rm -rf api web node_modules package.json package-lock.json app.js greets.js greets.test.js index.html styles.css Dockerfile nginx.conf setup.sh Jenkinsfile

# 2. יצירת תיקיות לשירותים
mkdir api web

# ==========================================
# ------------ API SERVICE SETUP -----------
# ==========================================
echo "Setting up API Service..."

cat << 'EOF' > api/package.json
{
  "name": "jenkins-api",
  "version": "1.0.0",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "test": "jest --coverage"
  },
  "dependencies": {
    "express": "^4.21.0"
  },
  "devDependencies": {
    "jest": "^29.7.0"
  },
  "jest": {
    "coverageThreshold": {
      "global": {
        "lines": 80
      }
    }
  }
}
EOF

cat << 'EOF' > api/app.js
const express = require("express");
const { randomGreets } = require("./greets");

const app = express();
const PORT = 3000;

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

app.listen(PORT, () => {
  console.log(`API is running on port ${PORT}`);
});
EOF

cat << 'EOF' > api/greets.js
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
EOF

cat << 'EOF' > api/greets.test.js
const { greets, randomGreets } = require("./greets");

test("There are at least 5 greetings", () => {
  expect(greets.length).toBeGreaterThanOrEqual(5);
});

test("randomGreets returns a valid string", () => {
  const result = randomGreets();
  expect(typeof result).toBe("string");
});
EOF

cat << 'EOF' > api/Dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD [ "npm", "start" ]
EOF

# ==========================================
# ------------ WEB SERVICE SETUP -----------
# ==========================================
echo "Setting up Web Service..."

cat << 'EOF' > web/package.json
{
  "name": "jenkins-web",
  "version": "1.0.0",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.21.0"
  }
}
EOF

cat << 'EOF' > web/app.js
const express = require("express");
const path = require("path");

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

// ה-WEB מושך נתונים מה-API דרך הרשת הפנימית של דוקר! (דרישת חובה במטלה)
app.get("/api/greets", async (req, res) => {
  try {
    // השם api מגיע מתוך ההגדרה ב-docker-compose
    const response = await fetch("http://api:3000/api/greets");
    const data = await response.json();
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: "API connection failed" });
  }
});

app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "index.html"));
});

app.listen(PORT, () => {
  console.log(`Web server is running on port ${PORT}`);
});
EOF

cat << 'EOF' > web/styles.css
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
EOF

cat << 'EOF' > web/index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Jenkins App - Web Service</title>
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
EOF

cat << 'EOF' > web/Dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 8000
CMD [ "npm", "start" ]
EOF

# ==========================================
# ------------ DOCKER COMPOSE --------------
# ==========================================
echo "Setting up Docker Compose..."

cat << 'EOF' > docker-compose.yml
services:
  api:
    build: ./api
    ports:
      - "3000:3000"
    restart: unless-stopped

  web:
    build: ./web
    ports:
      - "8000:8000"
    depends_on:
      - api
    restart: unless-stopped
EOF

echo "✅ Project split and configured successfully!"