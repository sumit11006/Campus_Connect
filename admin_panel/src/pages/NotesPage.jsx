import React, { useEffect, useState } from 'react';
import api from '../services/api';

export default function NotesPage() {
  const [notes, setNotes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [toast, setToast] = useState(null);

  useEffect(() => { fetchNotes(); }, []);

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const fetchNotes = async () => {
    try {
      const res = await api.get('/notes');
      if (res.data.success) setNotes(res.data.notes);
    } catch (err) { console.error(err); }
    finally { setLoading(false); }
  };

  const handleDeleteNote = async (noteId) => {
    if (!window.confirm('Delete this note? This cannot be undone.')) return;
    try {
      const res = await api.delete(`/notes/${noteId}`);
      if (res.data.success) {
        setNotes(notes.filter(n => n._id !== noteId));
        showToast('Note deleted successfully');
      }
    } catch (err) { showToast(err.response?.data?.message || 'Failed to delete note', 'error'); }
  };

  const filtered = notes.filter(n =>
    n.title.toLowerCase().includes(search.toLowerCase()) ||
    (n.subject || '').toLowerCase().includes(search.toLowerCase())
  );

  if (loading) return (
    <div className="loading-container">
      <div className="spinner" />
      <p>Loading notes...</p>
    </div>
  );

  return (
    <div>
      {toast && <div className={`toast toast-${toast.type}`}>{toast.type === 'success' ? '✅' : '❌'} {toast.msg}</div>}

      <div className="page-header">
        <div>
          <h1 className="page-title">Notes Management</h1>
          <p className="page-subtitle">{notes.length} notes uploaded</p>
        </div>
        <div className="header-search" style={{ width: '220px' }}>
          <svg width="18" height="18" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><path d="M21 21l-4.35-4.35"/></svg>
          <input 
            type="text" 
            placeholder="Search notes..." 
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
      </div>

      <div className="card">
        <div style={{ overflowX: 'auto' }}>
          <table className="table">
            <thead>
              <tr>
                <th>Title</th>
                <th>Subject</th>
                <th>Uploader</th>
                <th>Date</th>
                <th style={{ textAlign: 'right' }}>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr>
                  <td colSpan="5" style={{ textAlign: 'center', padding: '3rem', color: 'var(--text-muted)' }}>
                    No notes found.
                  </td>
                </tr>
              ) : (
                filtered.map(note => (
                  <tr key={note._id}>
                    <td>
                      <div style={{ fontWeight: 600 }}>{note.title}</div>
                    </td>
                    <td>
                      <span className="badge badge-gray">{note.subject || 'General'}</span>
                    </td>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                        {note.uploaderId?.avatarUrl ? (
                          <img src={note.uploaderId.avatarUrl.startsWith('http') ? note.uploaderId.avatarUrl : `http://localhost:5000${note.uploaderId.avatarUrl}`} alt="" style={{ width: 32, height: 32, borderRadius: '50%', objectFit: 'cover' }} />
                        ) : (
                          <div style={{ width: 32, height: 32, borderRadius: '50%', background: 'var(--bg-main-alt)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 600, color: 'var(--accent1)' }}>
                            {(note.uploaderId?.name || 'U').charAt(0)}
                          </div>
                        )}
                        <div>
                          <div style={{ fontWeight: 500 }}>{note.uploaderId?.name || 'Unknown'}</div>
                          <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>{note.uploaderId?.email}</div>
                        </div>
                      </div>
                    </td>
                    <td>
                      <div style={{ fontSize: '0.875rem' }}>{new Date(note.createdAt).toLocaleDateString()}</div>
                    </td>
                    <td style={{ textAlign: 'right' }}>
                      <button className="btn btn-outline" style={{ borderColor: 'var(--danger)', color: 'var(--danger)', padding: '0.4rem 0.8rem', fontSize: '0.875rem' }} onClick={() => handleDeleteNote(note._id)}>
                        Delete
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
