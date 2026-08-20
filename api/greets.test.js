const { greets, randomGreets } = require("./greets");

test("There are at least 5 greetings", () => {
  expect(greets.length).toBeGreaterThanOrEqual(5);
});

test("randomGreets returns a valid string", () => {
  const result = randomGreets();
  expect(typeof result).toBe("string");
});
