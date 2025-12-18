
import mysql from "mysql2/promise";

let pool;

function requireEnv(name) {
  const v = process.env[name];
  if (!v || !String(v).trim()) {
    throw new Error(`Missing required env: ${name}`);
  }
  return v;
}

export function getPool() {
  if (!pool) {
    const host = requireEnv("DB_HOST");
    const user = requireEnv("DB_USER");
    const password = requireEnv("DB_PASSWORD");
    const database = requireEnv("DB_NAME");
    const port = Number(process.env.DB_PORT || 3306);

    pool = mysql.createPool({
      host, port, user, password, database,
           waitForConnections: true,
      connectionLimit: 10,
      queueLimit: 0,
    });
  }
  return pool;
}