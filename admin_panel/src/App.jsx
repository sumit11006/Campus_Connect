import React, { useState, useEffect } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import Sidebar from './components/Sidebar';
import Header from './components/Header';
import LoginPage from './pages/LoginPage';
import DashboardPage from './pages/DashboardPage';
import UsersPage from './pages/UsersPage';
import ClubsPage from './pages/ClubsPage';
import EventsPage from './pages/EventsPage';
import PostsPage from './pages/PostsPage';
import SettingsPage from './pages/SettingsPage';
import './App.css';

const THEMES = ['purple', 'blue', 'teal', 'dark'];

export default function App() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [theme, setTheme] = useState(() => localStorage.getItem('admin_theme') || 'purple');

  useEffect(() => {
    const handleThemeChange = (e) => {
      setTheme(e.detail);
    };
    window.addEventListener('themeChange', handleThemeChange);
    
    const storedUser = localStorage.getItem('admin_user');
    const token = localStorage.getItem('admin_token');
    if (storedUser && token) {
      try { setUser(JSON.parse(storedUser)); }
      catch { localStorage.removeItem('admin_user'); localStorage.removeItem('admin_token'); }
    }
    setLoading(false);

    return () => window.removeEventListener('themeChange', handleThemeChange);
  }, []);

  // Apply theme to <html>
  useEffect(() => {
    const root = document.documentElement;
    if (theme === 'purple') root.removeAttribute('data-theme');
    else root.setAttribute('data-theme', theme);
    localStorage.setItem('admin_theme', theme);
  }, [theme]);

  const cycleTheme = () => {
    setTheme(prev => {
      const idx = THEMES.indexOf(prev);
      return THEMES[(idx + 1) % THEMES.length];
    });
  };

  const themeLabels = { purple: '🟣 Purple', blue: '🔵 Blue', teal: '🟢 Teal', dark: '⚫ Dark' };

  const handleLoginSuccess = (userData) => setUser(userData);
  const handleLogout = () => {
    localStorage.removeItem('admin_token');
    localStorage.removeItem('admin_user');
    setUser(null);
  };

  if (loading) return null;

  if (!user) {
    return (
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<LoginPage onLoginSuccess={handleLoginSuccess} />} />
          <Route path="*" element={<Navigate to="/login" replace />} />
        </Routes>
      </BrowserRouter>
    );
  }

  return (
    <BrowserRouter>
      <div className="app-container">
        <Sidebar onLogout={handleLogout} />
        <div className="main-content">
          <Header user={user} theme={theme} themeLabel={themeLabels[theme]} onCycleTheme={cycleTheme} />
          <main className="page-body">
            <Routes>
              <Route path="/dashboard" element={<DashboardPage />} />
              <Route path="/users"     element={<UsersPage />} />
              <Route path="/clubs"     element={<ClubsPage />} />
              <Route path="/events"    element={<EventsPage />} />
              <Route path="/posts"     element={<PostsPage />} />
              <Route path="/settings"  element={<SettingsPage />} />
              <Route path="*"          element={<Navigate to="/dashboard" replace />} />
            </Routes>
          </main>
        </div>
      </div>
    </BrowserRouter>
  );
}
