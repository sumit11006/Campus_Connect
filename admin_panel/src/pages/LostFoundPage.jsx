import React, { useEffect, useState } from 'react';
import api from '../services/api';

export default function LostFoundPage() {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [toast, setToast] = useState(null);

  useEffect(() => { fetchItems(); }, []);

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const fetchItems = async () => {
    try {
      const res = await api.get('/lostfound');
      if (res.data.success) setItems(res.data.items);
    } catch (err) { console.error(err); }
    finally { setLoading(false); }
  };

  const handleDeleteItem = async (itemId) => {
    if (!window.confirm('Delete this item? This cannot be undone.')) return;
    try {
      const res = await api.delete(`/lostfound/${itemId}`);
      if (res.data.success) {
        setItems(items.filter(i => i._id !== itemId));
        showToast('Item deleted successfully');
      }
    } catch (err) { showToast(err.response?.data?.message || 'Failed to delete item', 'error'); }
  };

  const handleResolveItem = async (itemId) => {
    if (!window.confirm('Mark this item as resolved?')) return;
    try {
      const res = await api.put(`/lostfound/${itemId}/resolve`);
      if (res.data.success) {
        setItems(items.map(i => i._id === itemId ? { ...i, isResolved: true } : i));
        showToast('Item resolved successfully');
      }
    } catch (err) { showToast(err.response?.data?.message || 'Failed to resolve item', 'error'); }
  };

  const filtered = items.filter(i =>
    i.itemName.toLowerCase().includes(search.toLowerCase()) ||
    (i.description || '').toLowerCase().includes(search.toLowerCase())
  );

  if (loading) return (
    <div className="loading-container">
      <div className="spinner" />
      <p>Loading Lost & Found items...</p>
    </div>
  );

  return (
    <div>
      {toast && <div className={`toast toast-${toast.type}`}>{toast.type === 'success' ? '✅' : '❌'} {toast.msg}</div>}

      <div className="page-header">
        <div>
          <h1 className="page-title">Lost & Found Management</h1>
          <p className="page-subtitle">{items.length} items reported</p>
        </div>
        <div className="header-search" style={{ width: '220px' }}>
          <svg width="18" height="18" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><path d="M21 21l-4.35-4.35"/></svg>
          <input 
            type="text" 
            placeholder="Search items..." 
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
                <th>Item</th>
                <th>Type</th>
                <th>Status</th>
                <th>Reporter</th>
                <th>Date</th>
                <th style={{ textAlign: 'right' }}>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr>
                  <td colSpan="6" style={{ textAlign: 'center', padding: '3rem', color: 'var(--text-muted)' }}>
                    No items found.
                  </td>
                </tr>
              ) : (
                filtered.map(item => (
                  <tr key={item._id}>
                    <td>
                      <div style={{ fontWeight: 600 }}>{item.itemName}</div>
                      <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>{item.location}</div>
                    </td>
                    <td>
                      <span className={`badge ${item.type === 'lost' ? 'badge-red' : 'badge-green'}`}>
                        {item.type.toUpperCase()}
                      </span>
                    </td>
                    <td>
                      {item.isResolved ? (
                        <span className="badge badge-gray">Resolved</span>
                      ) : (
                        <span className="badge badge-purple">Active</span>
                      )}
                    </td>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                        {item.reporterId?.avatarUrl ? (
                          <img src={item.reporterId.avatarUrl.startsWith('http') ? item.reporterId.avatarUrl : `http://localhost:5000${item.reporterId.avatarUrl}`} alt="" style={{ width: 32, height: 32, borderRadius: '50%', objectFit: 'cover' }} />
                        ) : (
                          <div style={{ width: 32, height: 32, borderRadius: '50%', background: 'var(--bg-main-alt)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 600, color: 'var(--accent1)' }}>
                            {(item.reporterId?.name || 'U').charAt(0)}
                          </div>
                        )}
                        <div>
                          <div style={{ fontWeight: 500 }}>{item.reporterId?.name || 'Unknown'}</div>
                        </div>
                      </div>
                    </td>
                    <td>
                      <div style={{ fontSize: '0.875rem' }}>{new Date(item.createdAt).toLocaleDateString()}</div>
                    </td>
                    <td style={{ textAlign: 'right' }}>
                      <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end' }}>
                        {!item.isResolved && (
                          <button className="btn btn-outline" style={{ padding: '0.4rem 0.8rem', fontSize: '0.875rem' }} onClick={() => handleResolveItem(item._id)}>
                            Resolve
                          </button>
                        )}
                        <button className="btn btn-outline" style={{ borderColor: 'var(--danger)', color: 'var(--danger)', padding: '0.4rem 0.8rem', fontSize: '0.875rem' }} onClick={() => handleDeleteItem(item._id)}>
                          Delete
                        </button>
                      </div>
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
