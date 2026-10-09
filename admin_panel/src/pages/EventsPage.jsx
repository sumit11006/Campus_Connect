import React, { useEffect, useState } from 'react';
import api from '../services/api';

export default function EventsPage() {
  const [events, setEvents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [toast, setToast] = useState(null);

  useEffect(() => { fetchEvents(); }, []);

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const fetchEvents = async () => {
    try {
      const res = await api.get('/events');
      if (res.data.success) setEvents(res.data.events);
    } catch (err) { console.error(err); }
    finally { setLoading(false); }
  };

  const handleDeleteEvent = async (eventId) => {
    if (!window.confirm('Delete this event? This cannot be undone.')) return;
    try {
      const res = await api.delete(`/admin/events/${eventId}`);
      if (res.data.success) {
        setEvents(events.filter(e => e._id !== eventId));
        showToast('Event deleted successfully');
      }
    } catch (err) { showToast(err.response?.data?.message || 'Failed to delete event', 'error'); }
  };

  const handleTogglePinEvent = async (event) => {
    try {
      const res = await api.put(`/events/${event._id}`, { isPinned: !event.isPinned });
      if (res.data.success) {
        setEvents(events.map(e => e._id === event._id ? { ...e, isPinned: !event.isPinned } : e));
        showToast(event.isPinned ? 'Event unpinned' : 'Event pinned');
      }
    } catch (err) { showToast(err.response?.data?.message || 'Failed to toggle pin', 'error'); }
  };

  const filtered = events.filter(e =>
    e.title.toLowerCase().includes(search.toLowerCase()) ||
    (e.location || '').toLowerCase().includes(search.toLowerCase())
  );

  const upcoming = events.filter(e => new Date(e.date) > new Date()).length;
  const past = events.length - upcoming;

  if (loading) return (
    <div className="loading-container">
      <div className="spinner" />
      <p>Loading events...</p>
    </div>
  );

  return (
    <div>
      {toast && <div className={`toast toast-${toast.type}`}>{toast.type === 'success' ? '✅' : '❌'} {toast.msg}</div>}

      <div className="page-header">
        <div>
          <h1 className="page-title">Events Management</h1>
          <p className="page-subtitle">{events.length} campus events registered</p>
        </div>
        <div className="header-search" style={{ width: '220px' }}>
          <svg fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24">
            <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
          </svg>
          <input type="text" placeholder="Search events..." value={search} onChange={e => setSearch(e.target.value)} />
        </div>
      </div>

      {/* Summary cards */}
      <div className="stats-grid" style={{ marginBottom: '1.5rem' }}>
        <div className="stats-card stats-card-3">
          <div className="stats-icon-wrap"><svg width="22" height="22" fill="none" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg></div>
          <div className="stats-label">Total Events</div>
          <div className="stats-value">{events.length}</div>
        </div>
        <div className="stats-card stats-card-4">
          <div className="stats-icon-wrap"><svg width="22" height="22" fill="none" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12,6 12,12 16,14"/></svg></div>
          <div className="stats-label">Upcoming</div>
          <div className="stats-value">{upcoming}</div>
        </div>
        <div className="stats-card stats-card-2">
          <div className="stats-icon-wrap"><svg width="22" height="22" fill="none" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/></svg></div>
          <div className="stats-label">Past Events</div>
          <div className="stats-value">{past}</div>
        </div>
      </div>

      <div className="table-container">
        <div className="table-header">
          <div className="table-title">All Events</div>
          <span className="badge badge-student">{filtered.length} results</span>
        </div>
        <table className="data-table">
          <thead>
            <tr>
              <th>Event Title</th>
              <th>Date & Time</th>
              <th>Location</th>
              <th>Host Club</th>
              <th>Registrations</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {filtered.length === 0 ? (
              <tr><td colSpan={7}><div className="empty-state"><p>No events found</p></div></td></tr>
            ) : filtered.map(event => {
              const isUpcoming = new Date(event.date) > new Date();
              return (
                <tr key={event._id}>
                  <td style={{ fontWeight: 700 }}>
                    {event.isPinned && <span title="Pinned" style={{ marginRight: 6 }}>📌</span>}
                    {event.title}
                  </td>
                  <td style={{ fontSize: '0.82rem', color: 'var(--text-muted)' }}>
                    {new Date(event.date).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' })}
                    <br/>
                    {new Date(event.date).toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit' })}
                  </td>
                  <td>{event.location || '—'}</td>
                  <td>{event.clubId?.name || 'Campus Wide'}</td>
                  <td style={{ fontWeight: 700, color: 'var(--accent1)' }}>{event.registrationCount || 0}</td>
                  <td>
                    <span className={`badge ${isUpcoming ? 'badge-active' : 'badge-banned'}`}>
                      {isUpcoming ? '● Upcoming' : '● Past'}
                    </span>
                  </td>
                  <td>
                    <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
                      <button className="btn btn-sm btn-outline" onClick={() => handleTogglePinEvent(event)}>
                        {event.isPinned ? 'Unpin' : '📌 Pin'}
                      </button>
                      <button className="btn btn-sm btn-danger" onClick={() => handleDeleteEvent(event._id)}>
                        🗑 Delete
                      </button>
                    </div>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}
