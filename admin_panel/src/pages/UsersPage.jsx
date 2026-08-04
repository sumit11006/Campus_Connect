import React, { useEffect, useState } from 'react';
import api from '../services/api';

export default function UsersPage() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [filterRole, setFilterRole] = useState('all');
  const [toast, setToast] = useState(null);

  useEffect(() => { fetchUsers(); }, []);

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const fetchUsers = async () => {
    try {
      const res = await api.get('/admin/users');
      if (res.data.success) setUsers(res.data.users);
    } catch (err) { console.error(err); }
    finally { setLoading(false); }
  };

  const handleRoleChange = async (userId, newRole) => {
    try {
      const res = await api.put(`/admin/users/${userId}/role`, { role: newRole });
      if (res.data.success) {
        setUsers(users.map(u => u._id === userId ? { ...u, role: newRole } : u));
        showToast(`Role updated to ${newRole}`);
      }
    } catch (err) { showToast(err.response?.data?.message || 'Failed to update role', 'error'); }
  };

  const handleToggleStatus = async (userId) => {
    try {
      const res = await api.put(`/admin/users/${userId}/toggle-active`);
      if (res.data.success) {
        setUsers(users.map(u => u._id === userId ? { ...u, isActive: res.data.user.isActive } : u));
        showToast(res.data.message);
      }
    } catch (err) { showToast(err.response?.data?.message || 'Failed to toggle status', 'error'); }
  };

  const filtered = users.filter(u => {
    const matchSearch = u.name.toLowerCase().includes(search.toLowerCase()) || u.email.toLowerCase().includes(search.toLowerCase());
    const matchRole = filterRole === 'all' || u.role === filterRole;
    return matchSearch && matchRole;
  });

  if (loading) return (
    <div className="loading-container">
      <div className="spinner" />
      <p>Loading users...</p>
    </div>
  );

  return (
    <div>
      {toast && <div className={`toast toast-${toast.type}`}>
        {toast.type === 'success' ? '✅' : '❌'} {toast.msg}
      </div>}

      <div className="page-header">
        <div>
          <h1 className="page-title">User Management</h1>
          <p className="page-subtitle">{users.length} registered users on platform</p>
        </div>
        <div style={{ display: 'flex', gap: '0.75rem', alignItems: 'center' }}>
          <select
            className="select-styled"
            value={filterRole}
            onChange={e => setFilterRole(e.target.value)}
          >
            <option value="all">All Roles</option>
            <option value="student">Students</option>
            <option value="faculty">Faculty</option>
            <option value="clubAdmin">Club Admins</option>
            <option value="admin">Admins</option>
          </select>
          <div className="header-search" style={{ width: '220px' }}>
            <svg fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24">
              <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
            </svg>
            <input type="text" placeholder="Search by name or email..." value={search} onChange={e => setSearch(e.target.value)} />
          </div>
        </div>
      </div>

      <div className="table-container">
        <div className="table-header">
          <div className="table-title">All Users</div>
          <span className="badge badge-student">{filtered.length} results</span>
        </div>
        <table className="data-table">
          <thead>
            <tr>
              <th>User</th>
              <th>Branch / Year</th>
              <th>Role</th>
              <th>Status</th>
              <th>Joined</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {filtered.length === 0 ? (
              <tr><td colSpan={6}>
                <div className="empty-state">
                  <svg width="40" height="40" fill="none" stroke="currentColor" strokeWidth="1.5" viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
                  <p>No users found</p>
                </div>
              </td></tr>
            ) : filtered.map(user => (
              <tr key={user._id}>
                <td>
                  <div className="user-cell">
                    <div className="user-cell-avatar">{user.name.slice(0,2).toUpperCase()}</div>
                    <div>
                      <div className="user-cell-name">{user.name}</div>
                      <div className="user-cell-email">{user.email}</div>
                    </div>
                  </div>
                </td>
                <td>{user.branch || '—'} {user.year ? `· Yr ${user.year}` : ''}</td>
                <td>
                  <select
                    className="select-styled"
                    value={user.role}
                    onChange={e => handleRoleChange(user._id, e.target.value)}
                  >
                    <option value="student">Student</option>
                    <option value="faculty">Faculty</option>
                    <option value="clubAdmin">Club Admin</option>
                    <option value="admin">Admin</option>
                  </select>
                </td>
                <td>
                  <span className={`badge ${user.isActive ? 'badge-active' : 'badge-banned'}`}>
                    {user.isActive ? '● Active' : '● Banned'}
                  </span>
                </td>
                <td style={{ color: 'var(--text-muted)', fontSize: '0.8rem' }}>
                  {new Date(user.createdAt).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' })}
                </td>
                <td>
                  <button
                    className={`btn btn-sm ${user.isActive ? 'btn-danger' : 'btn-success'}`}
                    onClick={() => handleToggleStatus(user._id)}
                  >
                    {user.isActive ? '🚫 Ban' : '✅ Activate'}
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
