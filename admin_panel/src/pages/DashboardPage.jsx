import React, { useEffect, useState } from 'react';
import api from '../services/api';

const GRAD_COLORS = ['stats-card-1', 'stats-card-2', 'stats-card-3', 'stats-card-4', 'stats-card-5'];

const StatCard = ({ title, value, change, icon, gradClass }) => (
  <div className={`stats-card ${gradClass}`}>
    <div className="stats-icon-wrap">{icon}</div>
    <div className="stats-label">{title}</div>
    <div className="stats-value">{value}</div>
    {change && <div className="stats-change">{change}</div>}
  </div>
);

const BarChart = ({ data }) => {
  const max = Math.max(...data.map(d => d.value), 1);
  const accents = ['', 'accent2', 'accent3', '', 'accent2', 'accent3'];
  return (
    <div className="bar-chart">
      {data.map((d, i) => (
        <div className="bar-item" key={d.label}>
          <div
            className={`bar-fill ${accents[i % accents.length]}`}
            style={{ height: `${Math.max((d.value / max) * 80, 4)}px` }}
            title={`${d.label}: ${d.value}`}
          />
          <div className="bar-label">{d.label}</div>
        </div>
      ))}
    </div>
  );
};

export default function DashboardPage() {
  const [stats, setStats] = useState(null);
  const [activities, setActivities] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showAllModal, setShowAllModal] = useState(false);

  useEffect(() => {
    fetchStats();
    fetchActivity();
  }, []);

  const fetchStats = async () => {
    try {
      const res = await api.get('/admin/stats');
      if (res.data.success) setStats(res.data.stats);
    } catch (err) { console.error(err); }
  };

  const fetchActivity = async () => {
    try {
      // Fetch up to 30 items for activity logs
      const res = await api.get('/admin/activity?limit=30');
      if (res.data.success) {
        setActivities(res.data.activities);
      }
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleRefresh = async () => {
    setLoading(true);
    await Promise.all([fetchStats(), fetchActivity()]);
    setLoading(false);
  };

  const formatFullDate = (isoString) => {
    const d = new Date(isoString);
    return d.toLocaleDateString('en-IN', {
      day: '2-digit',
      month: 'short',
      year: 'numeric'
    }) + ', ' + d.toLocaleTimeString('en-IN', {
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  if (loading) return (
    <div className="loading-container">
      <div className="spinner" />
      <p>Loading dashboard...</p>
    </div>
  );

  const s = stats || {};
  const barData = [
    { label: 'Users',    value: s.totalUsers    || 0 },
    { label: 'Clubs',    value: s.totalClubs    || 0 },
    { label: 'Events',   value: s.totalEvents   || 0 },
    { label: 'Posts',    value: s.totalPosts    || 0 },
    { label: 'Messages', value: s.totalMessages || 0 },
  ];

  // Limit display to first 5 items on the dashboard view
  const dashboardActivities = activities.slice(0, 5);

  return (
    <div>
      <div className="page-header">
        <div>
          <h1 className="page-title">Dashboard Overview</h1>
          <p className="page-subtitle">Your campus platform at a glance</p>
        </div>
        <button className="btn btn-primary" onClick={handleRefresh}>
          <svg width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24"><polyline points="23,4 23,10 17,10"/><polyline points="1,20 1,14 7,14"/><path d="M3.51 9a9 9 0 0114.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0020.49 15"/></svg>
          Refresh
        </button>
      </div>

      {/* Stats Cards */}
      <div className="stats-grid">
        <StatCard title="Total Users"      value={s.totalUsers    || 0} change="↑ Platform members"   gradClass="stats-card-1" icon={<svg width="22" height="22" fill="none" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87M16 3.13a4 4 0 010 7.75"/></svg>} />
        <StatCard title="Active Clubs"     value={s.totalClubs    || 0} change="↑ Campus communities"  gradClass="stats-card-2" icon={<svg width="22" height="22" fill="none" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>} />
        <StatCard title="Campus Events"    value={s.totalEvents   || 0} change="↑ Scheduled events"    gradClass="stats-card-3" icon={<svg width="22" height="22" fill="none" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>} />
        <StatCard title="Discussion Posts" value={s.totalPosts    || 0} change="↑ Feed activity"        gradClass="stats-card-4" icon={<svg width="22" height="22" fill="none" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14,2 14,8 20,8"/></svg>} />
        <StatCard title="Chat Messages"    value={s.totalMessages || 0} change="↑ Real-time chats"      gradClass="stats-card-5" icon={<svg width="22" height="22" fill="none" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>} />
      </div>

      {/* Row 2: Chart + Role dist */}
      <div className="two-col" style={{ marginBottom: '1.25rem' }}>
        {/* Bar Chart */}
        <div className="glass-card chart-card">
          <div className="chart-header">
            <div className="chart-title">Platform Activity</div>
            <span className="chart-badge">Live</span>
          </div>
          <BarChart data={barData} />
        </div>

        {/* Role Distribution */}
        <div className="glass-card chart-card">
          <div className="chart-header">
            <div className="chart-title">User Roles</div>
          </div>
          <div className="role-grid">
            <div className="role-item">
              <div className="role-item-label">Students</div>
              <div className="role-item-value">{s.roles?.students || 0}</div>
              <div className="progress-bar-wrap"><div className="progress-bar-fill" style={{ width: `${s.totalUsers ? (s.roles?.students / s.totalUsers) * 100 : 0}%` }} /></div>
            </div>
            <div className="role-item">
              <div className="role-item-label">Faculty</div>
              <div className="role-item-value">{s.roles?.faculty || 0}</div>
              <div className="progress-bar-wrap"><div className="progress-bar-fill" style={{ width: `${s.totalUsers ? (s.roles?.faculty / s.totalUsers) * 100 : 0}%`, background: 'var(--grad-card2)' }} /></div>
            </div>
            <div className="role-item">
              <div className="role-item-label">Club Admins</div>
              <div className="role-item-value">{s.roles?.clubAdmins || 0}</div>
              <div className="progress-bar-wrap"><div className="progress-bar-fill" style={{ width: `${s.totalUsers ? (s.roles?.clubAdmins / s.totalUsers) * 100 : 0}%`, background: 'var(--grad-card3)' }} /></div>
            </div>
            <div className="role-item">
              <div className="role-item-label">Super Admins</div>
              <div className="role-item-value">{s.roles?.admins || 0}</div>
              <div className="progress-bar-wrap"><div className="progress-bar-fill" style={{ width: `${s.totalUsers ? (s.roles?.admins / s.totalUsers) * 100 : 0}%`, background: 'var(--grad-card4)' }} /></div>
            </div>
          </div>
        </div>
      </div>

      {/* Row 3: Quick Actions + Recent Activity */}
      <div className="two-col" style={{ marginBottom: '1.25rem' }}>
        {/* Quick Actions */}
        <div>
          <div className="section-header">
            <div className="section-title">Quick Actions</div>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.75rem' }}>
            {[
              { icon: '👥', title: 'Manage Users',  desc: 'Ban, promote, or update roles', color: 'rgba(124,58,237,0.12)', link: '/users' },
              { icon: '🏆', title: 'Manage Clubs',  desc: 'View and delete clubs', color: 'rgba(236,72,153,0.12)', link: '/clubs' },
              { icon: '📅', title: 'Manage Events', desc: 'Review and delete events', color: 'rgba(6,182,212,0.12)', link: '/events' },
              { icon: '📝', title: 'Manage Posts',  desc: 'Moderate discussion feed', color: 'rgba(16,185,129,0.12)', link: '/posts' },
              { icon: '⚙️', title: 'Settings',      desc: 'Platform configuration', color: 'rgba(245,158,11,0.12)', link: '/settings' },
              { icon: '📊', title: 'Analytics',     desc: 'Real-time stats overview', color: 'rgba(59,130,246,0.12)', link: '/dashboard' },
            ].map(a => (
              <a key={a.title} href={a.link} style={{ textDecoration: 'none' }}>
                <div className="action-card">
                  <div className="action-card-icon" style={{ background: a.color }}>
                    <span style={{ fontSize: '1.3rem' }}>{a.icon}</span>
                  </div>
                  <div>
                    <div className="action-card-title">{a.title}</div>
                    <div className="action-card-desc">{a.desc}</div>
                  </div>
                </div>
              </a>
            ))}
          </div>
        </div>

        {/* Recent Activity */}
        <div>
          <div className="section-header">
            <div className="section-title">Recent Activity</div>
            <button className="btn btn-ghost btn-sm" onClick={() => setShowAllModal(true)}>View All</button>
          </div>
          <div className="glass-card" style={{ overflow: 'hidden' }}>
            <div className="activity-list">
              {dashboardActivities.length === 0 ? (
                <div className="empty-state" style={{ padding: '2rem' }}>
                  <p>No recent activity detected</p>
                </div>
              ) : (
                dashboardActivities.map((a, i) => (
                  <div key={i} className="activity-item">
                    <div className="activity-avatar" style={{ background: a.color }}>
                      {a.name.slice(0, 2).toUpperCase()}
                    </div>
                    <div className="activity-info">
                      <div className="activity-name">{a.name}</div>
                      <div className="activity-desc">{a.desc}</div>
                    </div>
                    <div className="activity-time" style={{ fontSize: '0.75rem', textAlign: 'right' }}>
                      {formatFullDate(a.time)}
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
      </div>

      {/* View All Activities Modal Overlay */}
      {showAllModal && (
        <div style={{
          position: 'fixed',
          top: 0, left: 0, right: 0, bottom: 0,
          background: 'rgba(0,0,0,0.6)',
          backdropFilter: 'blur(8px)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          zIndex: 9999,
          padding: '1.5rem'
        }}>
          <div className="glass-card" style={{
            background: 'var(--bg-card)',
            width: '100%',
            maxWidth: '650px',
            maxHeight: '80vh',
            borderRadius: '24px',
            display: 'flex',
            flexDirection: 'column',
            overflow: 'hidden',
            border: '1px solid var(--border-color)',
            boxShadow: 'var(--shadow-lg)'
          }}>
            <div style={{
              padding: '1.5rem',
              borderBottom: '1px solid var(--border-color)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'between',
              justifyContent: 'space-between'
            }}>
              <h3 className="section-title">All Recent Activities</h3>
              <button 
                onClick={() => setShowAllModal(false)}
                style={{
                  background: 'none', border: 'none', color: 'var(--text-main)',
                  fontSize: '1.25rem', cursor: 'pointer', padding: '0.25rem'
                }}
              >✕</button>
            </div>
            
            <div style={{ overflowY: 'auto', padding: '1rem', flex: 1 }}>
              <div className="activity-list">
                {activities.map((a, i) => (
                  <div key={i} className="activity-item" style={{ padding: '1rem 0.5rem' }}>
                    <div className="activity-avatar" style={{ background: a.color }}>
                      {a.name.slice(0, 2).toUpperCase()}
                    </div>
                    <div className="activity-info">
                      <div className="activity-name">{a.name}</div>
                      <div className="activity-desc">{a.desc}</div>
                    </div>
                    <div className="activity-time" style={{ fontSize: '0.78rem' }}>
                      {formatFullDate(a.time)}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
