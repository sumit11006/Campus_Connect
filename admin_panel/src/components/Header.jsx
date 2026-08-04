import React, { useState, useRef, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';

export default function Header({ user, themeLabel, onCycleTheme }) {
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const initials = user?.name?.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase() || 'A';
  const dropdownRef = useRef(null);
  const navigate = useNavigate();

  useEffect(() => {
    function handleClickOutside(event) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setDropdownOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const handleProfileClick = () => {
    setDropdownOpen(false);
    navigate('/settings');
  };

  return (
    <header className="header">
      <div className="header-left">
        <div>
          <div className="header-title">Admin Dashboard</div>
          <div className="header-subtitle">Welcome back, {user?.name || 'Admin'}</div>
        </div>
      </div>

      <div className="header-search">
        <svg fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24">
          <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
        </svg>
        <input type="text" placeholder="Search anything..." />
      </div>

      <div className="header-right">
        {/* Color theme toggle */}
        <button className="theme-toggle-btn" onClick={onCycleTheme} title="Cycle color theme">
          <span className="theme-swatch" />
          {themeLabel}
        </button>

        {/* Notification bell */}
        <div className="notif-btn">
          <svg width="18" height="18" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24">
            <path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/>
          </svg>
          <span className="notif-dot" />
        </div>

        {/* User avatar with dropdown */}
        <div style={{ position: 'relative' }} ref={dropdownRef}>
          <div className="user-avatar" onClick={() => setDropdownOpen(!dropdownOpen)} title={user?.email}>
            {initials}
          </div>

          {dropdownOpen && (
            <div style={{
              position: 'absolute',
              top: '48px',
              right: '0',
              background: 'var(--bg-card)',
              border: '1px solid var(--border-color)',
              borderRadius: '12px',
              boxShadow: 'var(--shadow-lg)',
              padding: '0.5rem',
              zIndex: 100,
              minWidth: '160px',
              display: 'flex',
              flexDirection: 'column',
              gap: '0.25rem'
            }}>
              <div style={{ padding: '0.5rem', borderBottom: '1px solid var(--border-color)', marginBottom: '0.25rem' }}>
                <div style={{ fontSize: '0.85rem', fontWeight: 600, color: 'var(--text-main)' }}>{user?.name}</div>
                <div style={{ fontSize: '0.72rem', color: 'var(--text-muted)' }}>{user?.email}</div>
              </div>
              <button 
                onClick={handleProfileClick}
                style={{
                  background: 'none',
                  border: 'none',
                  textAlign: 'left',
                  padding: '0.5rem',
                  fontSize: '0.85rem',
                  borderRadius: '6px',
                  cursor: 'pointer',
                  color: 'var(--text-main)',
                  width: '100%',
                }}
                className="nav-item-dropdown"
              >
                👤 Profile Settings
              </button>
            </div>
          )}
        </div>
      </div>
    </header>
  );
}
