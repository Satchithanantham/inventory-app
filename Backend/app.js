import express from "express";
import cors from "cors";
import { getPool } from "./db.js";

const app = express();
app.use(cors());
app.use(express.json());

/**
 * Health check
 */
app.get("/health", (req, res) => res.json({ ok: true }));

/**
 * Ensure schema for books table
 * Adds retry logic to wait for MySQL readiness
 */
async function ensureSchema(retries = 5) {
  while (retries > 0) {
    try {
      const pool = getPool();
      await (await pool).query(`
        CREATE TABLE IF NOT EXISTS books (
          id INT AUTO_INCREMENT PRIMARY KEY,
          title VARCHAR(255) NOT NULL,
          author VARCHAR(255) NOT NULL,
          isbn VARCHAR(64) UNIQUE NOT NULL,
          quantity INT DEFAULT 0,
          price DECIMAL(10,2) DEFAULT 0.00
        )
      `);
      console.log("✅ Database schema ensured");
      return;
    } catch (err) {
      console.log(`⏳ Waiting for DB... (${retries} retries left)`);
      retries--;
      await new Promise(resolve => setTimeout(resolve, 5000));
    }
  }
  throw new Error("❌ Database not reachable");
}

// Initialize DB schema safely
ensureSchema().catch(err => {
  console.error(err.message);
  process.exit(1);
});

/**
 * Routes
 * GET    /api/books
 * POST   /api/books
 * PUT    /api/books/:id
 * DELETE /api/books/:id
 */

app.get("/api/books", async (req, res) => {
  const pool = getPool();
  const [rows] = await (await pool).query(
    "SELECT * FROM books ORDER BY id DESC"
  );
  res.json(rows);
});

app.post("/api/books", async (req, res) => {
  const { title, author, isbn, quantity, price } = req.body;
  if (!title || !author || !isbn) {
    return res
      .status(400)
      .json({ error: "title, author, isbn required" });
  }

  try {
    const pool = getPool();
    const [result] = await (await pool).query(
      "INSERT INTO books(title, author, isbn, quantity, price) VALUES (?, ?, ?, ?, ?)",
      [title, author, isbn, quantity ?? 0, price ?? 0.0]
    );
    res.status(201).json({ id: result.insertId });
  } catch (err) {
    if (err.code === "ER_DUP_ENTRY") {
      return res.status(409).json({ error: "ISBN already exists" });
    }
    console.error(err);
    res.status(500).json({ error: "Internal server error" });
  }
});

app.put("/api/books/:id", async (req, res) => {
  const { id } = req.params;
  const { title, author, isbn, quantity, price } = req.body;

  const pool = getPool();
  await (await pool).query(
    "UPDATE books SET title=?, author=?, isbn=?, quantity=?, price=? WHERE id=?",
    [title, author, isbn, quantity ?? 0, price ?? 0.0, id]
  );

  res.json({ ok: true });
});

app.delete("/api/books/:id", async (req, res) => {
  const { id } = req.params;
  const pool = getPool();
  await (await pool).query(
    "DELETE FROM books WHERE id=?",
    [id]
  );
  res.json({ ok: true });
});

/**
 * Start server
 */
const port = process.env.PORT || 5000;
app.listen(port, "0.0.0.0", () => {
  console.log(`🚀 Backend running on port ${port}`);
});
