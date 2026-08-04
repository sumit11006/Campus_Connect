import React, { useState, useEffect } from 'react';

const THEMES = [
  { id: 'purple', name: 'Purple Custom', desc: 'Default vibrant purple & pink' },
  { id: 'blue',   name: 'Ocean Blue',   desc: 'Professional blue & cyan' },
  { id: 'teal',   name: 'Forest Teal',   desc: 'Fresh teal & blue' },
  { id: 'dark',   name: 'Midnight Dark',   desc: 'Dark mode with purple accents' },
];

const Toggle = ({ checked, onChange }) => (
  <label className="toggle-switch">
    <input type="checkbox" checked={checked} onChange={e => onChange(e.target.checked)} />
    <span className="toggle-slider" />
  </label>
);

export default function SettingsPage() {
  const [activeTheme, setActiveTheme] = useState(() => localStorage.getItem('admin_theme') || 'purple');
  const [settings, setSettings] = useState(() => {
    const saved = localStorage.getItem('admin_system_settings');
    return saved ? JSON.parse(saved) : {
      notifications: true,
      emailAlerts: false,
      maintenanceMode: false,
      registrationOpen: true,
      autoModeration: false,
      showOnlineStatus: true,
    };
  });
  const [toast, setToast] = useState(null);

  useEffect(() => {
    localStorage.setItem('admin_system_settings', JSON.stringify(settings));
  }, [settings]);

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const applyTheme = (id) => {
    setActiveTheme(id);
    const root = document.documentElement;
    if (id === 'purple') root.removeAttribute('data-theme');
    else root.setAttribute('data-theme', id);
    localStorage.setItem('admin_theme', id);
    showToast(`Applied ${id.toUpperCase()} theme successfully!`);
    window.dispatchEvent(new CustomEvent('themeChange', { detail: id }));
  };

  const toggle = (key) => {
    setSettings(prev => {
      const nextVal = !prev[key];
      showToast(`${key.replace(/([A-Z])/g, ' $1').replace(/^./, str => str.toUpperCase())} ${nextVal ? 'enabled' : 'disabled'}`);
      return { ...prev, [key]: nextVal };
    });
  };

  const handleClearCache = () => {
    showToast("Clearing server-side cache... Completed!");
  };

  const handleExportData = () => {
    const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify({ settings, exportTime: new Date() }));
    const downloadAnchor = document.createElement('a');
    downloadAnchor.setAttribute("href", dataStr);
    downloadAnchor.setAttribute("download", `campusconnect_settings_export_${Date.now()}.json`);
    document.body.appendChild(downloadAnchor);
    downloadAnchor.click();
    downloadAnchor.remove();
    showToast("Configuration exported successfully!");
  };

  return (
    <div>
      {toast && <div className={`toast toast-${toast.type}`}>✅ {toast.msg}</div>}

      <div className="page-header">
        <div>
          <h1 className="page-title">Settings</h1>
          <p className="page-subtitle">Configure platform appearance and behaviour</p>
        </div>
      </div>

      <div className="two-col" style={{ marginBottom: '1.5rem' }}>
        {/* Theme Picker */}
        <div>
          <div className="section-header" style={{ marginBottom: '1rem' }}>
            <div className="section-title">🎨 Color Theme</div>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
            {THEMES.map(t => (
              <div
                key={t.id}
                className="action-card"
                style={{
                  border: activeTheme === t.id ? '2px solid var(--accent1)' : '1px solid var(--border-color)',
                  boxShadow: activeTheme === t.id ? 'var(--shadow)' : 'none',
                  cursor: 'pointer',
                }}
                onClick={() => applyTheme(t.id)}
              >
                <div className="action-card-icon" style={{ background: 'var(--grad-hero)', width: 42, height: 42 }}>
                  <span style={{ fontSize: '1.2rem' }}>🎨</span>
                </div>
                <div style={{ flex: 1 }}>
                  <div className="action-card-title">{t.name}</div>
                  <div className="action-card-desc">{t.desc}</div>
                </div>
                {activeTheme === t.id && (
                  <div style={{ width: 20, height: 20, borderRadius: '50%', background: 'var(--grad-hero)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <svg width="12" height="12" fill="white" viewBox="0 0 24 24"><polyline points="20,6 9,17 4,12" stroke="white" strokeWidth="3" fill="none" strokeLinecap="round"/></svg>
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>

        {/* Platform Settings */}
        <div>
          <div className="section-header" style={{ marginBottom: '1rem' }}>
            <div className="section-title">⚙️ Platform Settings</div>
          </div>
          <div className="glass-card" style={{ overflow: 'hidden' }}>
            {[
              { key: 'notifications',    label: 'Push Notifications',   desc: 'Enable browser push notifications' },
              { key: 'emailAlerts',      label: 'Email Alerts',          desc: 'Send admin alerts via email' },
              { key: 'maintenanceMode',  label: 'Maintenance Mode',      desc: 'Show maintenance page to users' },
              { key: 'registrationOpen', label: 'Open Registration',     desc: 'Allow new user signups' },
              { key: 'autoModeration',   label: 'Auto-Moderation',       desc: 'AI-powered content filtering' },
              { key: 'showOnlineStatus', label: 'Show Online Status',    desc: 'Display online indicators in chat' },
            ].map(s => (
              <div key={s.key} className="settings-row">
                <div>
                  <div className="settings-label">{s.label}</div>
                  <div className="settings-desc">{s.desc}</div>
                </div>
                <Toggle checked={settings[s.key]} onChange={() => toggle(s.key)} />
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Platform Info */}
      <div className="section-header" style={{ marginBottom: '1rem' }}>
        <div className="section-title">ℹ️ Platform Information</div>
      </div>
      <div className="glass-card" style={{ overflow: 'hidden', marginBottom: '1.5rem' }}>
        {[
          { label: 'Platform Name',    value: 'CampusConnect' },
          { label: 'Admin Panel Version', value: '2.0.0' },
          { label: 'Backend API',      value: 'http://localhost:5000/api' },
          { label: 'Database',         value: 'MongoDB (campusconnect)' },
          { label: 'Real-time',        value: 'Socket.IO' },
          { label: 'Authentication',   value: 'JWT (7d expiry)' },
        ].map(row => (
          <div key={row.label} className="settings-row">
            <div className="settings-label">{row.label}</div>
            <div style={{ fontSize: '0.875rem', color: 'var(--accent1)', fontWeight: 600, fontFamily: 'monospace' }}>{row.value}</div>
          </div>
        ))}
      </div>

      {/* Danger Zone */}
      <div className="section-header" style={{ marginBottom: '1rem' }}>
        <div className="section-title" style={{ color: 'var(--danger)' }}>⚠️ Danger Zone</div>
      </div>
      <div className="glass-card" style={{ border: '1px solid rgba(239,68,68,0.25)', overflow: 'hidden' }}>
        {[
          { label: 'Clear All Cache',        desc: 'Flush server-side cache and CDN', btn: 'Clear Cache',        color: 'btn-danger', onClick: handleClearCache },
          { label: 'Export All Data',        desc: 'Download configuration backup as JSON',   btn: 'Export JSON',       color: 'btn-ghost', onClick: handleExportData },
        ].map(row => (
          <div key={row.label} className="settings-row">
            <div>
              <div className="settings-label">{row.label}</div>
              <div className="settings-desc">{row.desc}</div>
            </div>
            <button className={`btn btn-sm ${row.color}`} onClick={row.onClick}>{row.btn}</button>
          </div>
        ))}
      </div>
    </div>
  );
}
