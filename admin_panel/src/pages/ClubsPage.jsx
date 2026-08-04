import React, { useEffect, useState } from 'react';
import api from '../services/api';

const CATEGORY_COLORS = {
  technical: 'badge-student',
  cultural:  'badge-faculty',
  sports:    'badge-clubAdmin',
  academic:  'badge-active',
  social:    'badge-admin',
};

export default function ClubsPage() {
  const [clubs, setClubs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [toast, setToast] = useState(null);

  useEffect(() => { fetchClubs(); }, []);

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const fetchClubs = async () => {
    try {
      const res = await api.get('/clubs');
      if (res.data.success) setClubs(res.data.clubs);
    } catch (err) { console.error(err); }
    finally { setLoading(false); }
  };

  const handleDeleteClub = async (clubId) => {
    if (!window.confirm('Are you sure you want to delete this club? This cannot be undone.')) return;
    try {
      const res = await api.delete(`/admin/clubs/${clubId}`);
      if (res.data.success) {
        setClubs(clubs.filter(c => c._id !== clubId));
        showToast('Club deleted successfully');
      }
    } catch (err) { showToast(err.response?.data?.message || 'Failed to delete club', 'error'); }
  };

  const filtered = clubs.filter(c =>
    c.name.toLowerCase().includes(search.toLowerCase()) ||
    (c.category || '').toLowerCase().includes(search.toLowerCase())
  );

  if (loading) return (
    <div className="loading-container">
      <div className="spinner" />
      <p>Loading clubs...</p>
    </div>
  );

  return (
    <div>
      {toast && <div className={`toast toast-${toast.type}`}>{toast.type === 'success' ? '✅' : '❌'} {toast.msg}</div>}

      <div className="page-header">
        <div>
          <h1 className="page-title">Clubs Management</h1>
          <p className="page-subtitle">{clubs.length} campus clubs registered</p>
        </div>
        <div className="header-search" style={{ width: '220px' }}>
          <svg fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24">
            <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
          </svg>
          <input type="text" placeholder="Search clubs..." value={search} onChange={e => setSearch(e.target.value)} />
        </div>
      </div>

      {/* Summary cards */}
      <div className="stats-grid" style={{ marginBottom: '1.5rem' }}>
        <div className="stats-card stats-card-1">
          <div className="stats-icon-wrap">
            <svg width="22" height="22" fill="none" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
          </div>
          <div className="stats-label">Total Clubs</div>
          <div className="stats-value">{clubs.length}</div>
        </div>
        <div className="stats-card stats-card-2">
          <div className="stats-icon-wrap">
            <svg width="22" height="22" fill="none" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
          </div>
          <div className="stats-label">Total Members</div>
          <div className="stats-value">{clubs.reduce((s, c) => s + (c.memberCount || 0), 0)}</div>
        </div>
        <div className="stats-card stats-card-3">
          <div className="stats-icon-wrap">
            <svg width="22" height="22" fill="none" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24"><polyline points="22,12 18,12 15,21 9,3 6,12 2,12"/></svg>
          </div>
          <div className="stats-label">Avg Members/Club</div>
          <div className="stats-value">{clubs.length ? Math.round(clubs.reduce((s, c) => s + (c.memberCount || 0), 0) / clubs.length) : 0}</div>
        </div>
      </div>

      <div className="table-container">
        <div className="table-header">
          <div className="table-title">All Clubs</div>
          <span className="badge badge-student">{filtered.length} results</span>
        </div>
        <table className="data-table">
          <thead>
            <tr>
              <th>Club Name</th>
              <th>Category</th>
              <th>Coordinator</th>
              <th>Members</th>
              <th>Created</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {filtered.length === 0 ? (
              <tr><td colSpan={6}><div className="empty-state"><p>No clubs found</p></div></td></tr>
            ) : filtered.map(club => (
              <tr key={club._id}>
                <td>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
                    <div className="user-cell-avatar" style={{ borderRadius: '10px', fontSize: '0.85rem' }}>
                      {club.name.slice(0,2).toUpperCase()}
                    </div>
                    <div>
                      <div style={{ fontWeight: 700 }}>{club.name}</div>
                      <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>{club.description?.slice(0,40) || 'No description'}...</div>
                    </div>
                  </div>
                </td>
                <td>
                  <span className={`badge ${CATEGORY_COLORS[club.category] || 'badge-student'}`}>
                    {club.category || 'General'}
                  </span>
                </td>
                <td>
                  <div style={{ fontSize: '0.875rem' }}>{club.coordinatorId?.name || 'Unknown'}</div>
                  <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>{club.coordinatorId?.email || '—'}</div>
                </td>
                <td>
                  <div style={{ fontWeight: 700, color: 'var(--accent1)' }}>{club.memberCount || 0}</div>
                </td>
                <td style={{ color: 'var(--text-muted)', fontSize: '0.8rem' }}>
                  {club.createdAt ? new Date(club.createdAt).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' }) : '—'}
                </td>
                <td>
                  <button className="btn btn-sm btn-danger" onClick={() => handleDeleteClub(club._id)}>
                    🗑 Delete
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
