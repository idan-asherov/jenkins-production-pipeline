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
