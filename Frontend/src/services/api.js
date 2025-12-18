
// Base URL: prefer REACT_APP_API_URL; fallback to same-origin /api for local dev
const BASE =
  process.env.REACT_APP_API_URL?.trim() ||
  `${window.location.origin}/api`;

// Default fetch with timeout and JSON handling
async function request(path, { method = "GET", body, headers } = {}) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 20000); // 20s timeout

  const opts = {
    method,
    signal: controller.signal,
    headers: {
      "Accept": "application/json",
      ...(body ? { "Content-Type": "application/json" } : {}),
      ...(headers || {}),
    },
    ...(body ? { body: JSON.stringify(body) } : {}),
    // If you need cookies/session, uncomment:
    // credentials: "include",
  };

  let res;
  try {
    res = await fetch(`${BASE}${path}`, opts);
  } finally {
    clearTimeout(timeout);
  }

  // Throw for non-2xx to be handled at call site
  if (!res.ok) {
    const text = await safeText(res);
    const err = new Error(
      `HTTP ${res.status} ${res.statusText} for ${path}: ${text || "<no body>"}`
    );
    err.status = res.status;
    err.body = text;
    throw err;
  }

  // Try JSON; fallback to text for empty responses
  return await safeJson(res);
}

async function safeJson(res) {
  const text = await res.text();
  if (!text) return null;
  try {
    return JSON.parse(text);
  } catch {
    // If server returned non-JSON, return raw text
    return text;
  }
}

async function safeText(res) {
  try {
    return await res.text();
  } catch {
    return "";
  }
}

/** -------- Books CRUD -------- **/

export async function listBooks() {
  return await request(`/books`, { method: "GET" });
}

export async function createBook(book) {
  return await request(`/books`, {
    method: "POST",
    body: book,
  });
}

export async function updateBook(id, book) {
  return await request(`/books/${encodeURIComponent(id)}`, {
    method: "PUT",
    body: book,
  });
}

export async function deleteBook(id) {
  // Some APIs return 204 No Content; we handle both JSON and empty
  return await request(`/books/${encodeURIComponent(id)}`, {
    method: "DELETE",
  });
}

/** Optional: ping backend health (useful in diagnostics) */
export async function health() {
  // Note: backend TG health path is /health, but ALB routes /api/* to backend.
  // If ALB listener rule is /api/*, we need to include /api in BASE (which we did).
  return await request(`/health`, { method: "GET" });
}

export { BASE as API_BASE_URL };
``
