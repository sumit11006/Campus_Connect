import React, { useState } from 'react';
import api from '../services/api';

export default function LoginPage({ onLoginSuccess }) {
  const [isSignUp, setIsSignUp] = useState(false);
  const [form, setForm] = useState({ name: '', email: '', password: '' });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
    setError('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!form.email || !form.password || (isSignUp && !form.name)) {
      setError('Please fill in all required fields.');
      return;
    }
    setLoading(true);
    try {
      if (isSignUp) {
        // Attempt signup
        const res = await api.post('/auth/register', { ...form, role: 'admin' });
        if (res.data.success) {
          setIsSignUp(false);
          setError('Sign up successful! Please log in.');
        }
      } else {
        const res = await api.post('/auth/login', { email: form.email, password: form.password });
        if (res.data.success) {
          const { user, token } = res.data;
          if (user.role !== 'admin') {
            setError('Access denied. Only admins can log in here.');
            return;
          }
          localStorage.setItem('admin_token', token);
          localStorage.setItem('admin_user', JSON.stringify(user));
          onLoginSuccess(user);
        }
      }
    } catch (err) {
      setError(err.response?.data?.message || (isSignUp ? 'Sign up failed.' : 'Login failed. Check your credentials.'));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="app-container" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', minHeight: '100vh', width: '100vw' }}>
      <div className="glass-card" style={{ maxWidth: '450px', width: '100%', padding: '2.5rem', borderRadius: '24px' }}>
        <div style={{ textAlign: 'center', marginBottom: '2rem' }}>
          <div style={{ 
            width: '60px', height: '60px', background: 'var(--grad-hero)', 
            borderRadius: '16px', display: 'flex', alignItems: 'center', justifyContent: 'center', 
            margin: '0 auto 1rem', boxShadow: 'var(--shadow-glow)'
          }}>
            <svg width="32" height="32" fill="none" stroke="white" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24">
              <path d="M22 10v6M2 10l10-5 10 5-10 5z" />
              <path d="M6 12v5c3 3 9 3 12 0v-5" />
            </svg>
          </div>
          <h1 className="page-title" style={{ fontSize: '1.8rem', marginBottom: '0.5rem' }}>CampusConnect</h1>
          <p className="page-subtitle">{isSignUp ? 'Create an admin account' : 'Admin Control Center'}</p>
        </div>

        <div style={{ display: 'flex', gap: '1rem', marginBottom: '2rem' }}>
          <button 
            type="button"
            className={`btn ${!isSignUp ? 'btn-primary' : 'btn-secondary'}`} 
            style={{ flex: 1, justifyContent: 'center' }}
            onClick={() => { setIsSignUp(false); setError(''); }}
          >
            Login
          </button>
          <button 
            type="button"
            className={`btn ${isSignUp ? 'btn-primary' : 'btn-secondary'}`} 
            style={{ flex: 1, justifyContent: 'center' }}
            onClick={() => { setIsSignUp(true); setError(''); }}
          >
            Sign Up
          </button>
        </div>

        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
          {isSignUp && (
            <div>
              <label style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--text-muted)', fontSize: '0.85rem' }}>Full Name</label>
              <input
                type="text"
                name="name"
                placeholder="Admin Name"
                value={form.name}
                onChange={handleChange}
                style={{ width: '100%', padding: '0.85rem 1rem', borderRadius: '12px', background: 'rgba(255,255,255,0.05)', border: '1px solid var(--border-color)', color: 'var(--text-main)', fontSize: '1rem', outline: 'none' }}
                onFocus={(e) => e.target.style.borderColor = 'var(--text-main)'}
                onBlur={(e) => e.target.style.borderColor = 'var(--border-color)'}
              />
            </div>
          )}
          
          <div>
            <label style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--text-muted)', fontSize: '0.85rem' }}>Admin Email</label>
            <input
              type="email"
              name="email"
              placeholder="admin@campusconnect.edu"
              value={form.email}
              onChange={handleChange}
              style={{ width: '100%', padding: '0.85rem 1rem', borderRadius: '12px', background: 'rgba(255,255,255,0.05)', border: '1px solid var(--border-color)', color: 'var(--text-main)', fontSize: '1rem', outline: 'none' }}
              onFocus={(e) => e.target.style.borderColor = 'var(--text-main)'}
              onBlur={(e) => e.target.style.borderColor = 'var(--border-color)'}
            />
          </div>
          
          <div>
            <label style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--text-muted)', fontSize: '0.85rem' }}>Passkey Code</label>
            <input
              type="password"
              name="password"
              placeholder="Enter your passkey"
              value={form.password}
              onChange={handleChange}
              style={{ width: '100%', padding: '0.85rem 1rem', borderRadius: '12px', background: 'rgba(255,255,255,0.05)', border: '1px solid var(--border-color)', color: 'var(--text-main)', fontSize: '1rem', outline: 'none' }}
              onFocus={(e) => e.target.style.borderColor = 'var(--text-main)'}
              onBlur={(e) => e.target.style.borderColor = 'var(--border-color)'}
            />
          </div>

          {error && (
            <div style={{ padding: '0.75rem', background: 'rgba(239, 68, 68, 0.1)', color: '#ef4444', borderRadius: '8px', fontSize: '0.9rem', border: '1px solid rgba(239, 68, 68, 0.2)' }}>
              {error}
            </div>
          )}

          <button type="submit" className="btn btn-primary" style={{ width: '100%', padding: '0.9rem', fontSize: '1rem', marginTop: '0.5rem', justifyContent: 'center' }} disabled={loading}>
            {loading ? (
              <div className="spinner" style={{ width: '20px', height: '20px', borderTopColor: 'transparent', borderRadius: '50%', border: '2px solid white' }} />
            ) : (isSignUp ? 'Create Admin Account' : 'Authenticate Session')}
          </button>
        </form>
      </div>
    </div>
  );
}
