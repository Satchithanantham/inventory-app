
import React, { useEffect, useState } from "react";
import {
  listBooks,
  createBook,
  updateBook,
  deleteBook,
  API_BASE_URL,  // optional: display which API is being used
} from "./services/api";

export default function App() {
  const emptyForm = { id: null, title: "", author: "", isbn: "", quantity: 0, price: 0 };
  const [items, setItems] = useState([]);
  const [form, setForm] = useState(emptyForm);
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");

  async function refresh() {
    setLoading(true);
    setError("");
    try {
      const data = await listBooks();
      setItems(Array.isArray(data) ? data : []);
    } catch (err) {
      setError(err?.message || "Failed to load books");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    refresh();
  }, []);

  async function onSave() {
    // Basic validation
    if (!form.title?.trim() || !form.author?.trim()) {
      alert("Title and Author are required");
      return;
    }

    setSaving(true);
    setError("");
    try {
      if (form.id != null) {
        await updateBook(form.id, {
          title: form.title,
          author: form.author,
          isbn: form.isbn,
          quantity: Number(form.quantity) || 0,
          price: Number(form.price) || 0,
        });
      } else {
        await createBook({
          title: form.title,
          author: form.author,
          isbn: form.isbn,
          quantity: Number(form.quantity) || 0,
          price: Number(form.price) || 0,
        });
      }
      setForm(emptyForm);
      await refresh();
    } catch (err) {
      setError(err?.message || "Save failed");
    } finally {
      setSaving(false);
    }
  }

  async function onDelete(id) {
    if (!window.confirm("Delete this book?")) return;
    setError("");
    try {
      await deleteBook(id);
      await refresh();
    } catch (err) {
      setError(err?.message || "Delete failed");
    }
  }

  function onEdit(row) {
    setForm({
      id: row.id,
      title: row.title ?? "",
      author: row.author ?? "",
      isbn: row.isbn ?? "",
      quantity: Number(row.quantity) || 0,
      price: Number(row.price) || 0,
    });
    // Scroll to form
    window.scrollTo({ top: 0, behavior: "smooth" });
  }

  function onCancelEdit() {
    setForm(emptyForm);
  }

  return (
    <div style={{ padding: 24, fontFamily: "system-ui, -apple-system, Segoe UI, Roboto, sans-serif" }}>
      <h2>Books Dashboard</h2>
      <div style={{ marginBottom: 8, color: "#555" }}>
        <small>API: {API_BASE_URL}</small>
      </div>

      {error && (
        <div style={{ marginBottom: 12, padding: 8, background: "#ffe6e6", border: "1px solid #ffb3b3", color: "#b30000" }}>
          {error}
        </div>
      )}

      <section style={{ marginBottom: 16 }}>
        <h3>{form.id != null ? "Edit Book" : "Add Book"}</h3>

        <div style={{ display: "grid", gridTemplateColumns: "repeat(2, 1fr)", gap: 8, maxWidth: 640 }}>
          <input
            placeholder="Title"
            value={form.title}
            onChange={e => setForm({ ...form, title: e.target.value })}
          />
          <input
            placeholder="Author"
            value={form.author}
            onChange={e => setForm({ ...form, author: e.target.value })}
          />
          <input
            placeholder="ISBN"
            value={form.isbn}
            onChange={e => setForm({ ...form, isbn: e.target.value })}
          />
          <input
            type="number"
            placeholder="Quantity"
            value={form.quantity}
            onChange={e => setForm({ ...form, quantity: Number(e.target.value) })}
          />
          <input
            type="number"
            placeholder="Price"
            step="0.01"
            value={form.price}
            onChange={e => setForm({ ...form, price: Number(e.target.value) })}
          />
        </div>

        <div style={{ marginTop: 8, display: "flex", gap: 8 }}>
          <button onClick={onSave} disabled={saving}>
            {saving ? "Saving..." : "Save"}
          </button>
          {form.id != null && (
            <button onClick={onCancelEdit} type="button">Cancel</button>
          )}
        </div>
      </section>

      <section>
        <div style={{ marginBottom: 8 }}>
          <strong>Books</strong> {loading && <span style={{ color: "#888" }}>(loading...)</span>}
        </div>
        <table border="1" cellPadding="8" style={{ borderCollapse: "collapse", width: "100%", maxWidth: 960 }}>
          <thead style={{ background: "#f6f6f6" }}>
            <tr>
              <th>ID</th>
              <th>Title</th>
              <th>Author</th>
              <th>ISBN</th>
              <th>Qty</th>
              <th>Price</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {(items || []).map(it => (
              <tr key={it.id}>
                <td>{it.id}</td>
                <td>{it.title}</td>
                <td>{it.author}</td>
                <td>{it.isbn}</td>
                <td>{it.quantity}</td>
                <td>{it.price}</td>
                <td style={{ display: "flex", gap: 8 }}>
                  <button onClick={() => onEdit(it)} title="Edit">Edit</button>
                  <button onClick={() => onDelete(it.id)} title="Delete">Delete</button>
                </td>
              </tr>
            ))}
            {(!items || items.length === 0) && !loading && (
              <tr><td colSpan={7} style={{ textAlign: "center", color: "#888" }}>No books found</td></tr>
            )}
          </tbody>
        </table>
      </section>
    </div>
  );
}
