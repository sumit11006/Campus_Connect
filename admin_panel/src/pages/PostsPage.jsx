import React, { useEffect, useState } from 'react';
import api from '../services/api';

export default function PostsPage() {
  const [posts, setPosts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [toast, setToast] = useState(null);

  useEffect(() => { fetchPosts(); }, []);

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const fetchPosts = async () => {
    try {
      const res = await api.get('/posts?limit=100');
      if (res.data.success) setPosts(res.data.posts);
    } catch (err) { console.error(err); }
    finally { setLoading(false); }
  };

  const handleDeletePost = async (postId) => {
    if (!window.confirm('Delete this post permanently?')) return;
    try {
      const res = await api.delete(`/admin/posts/${postId}`);
      if (res.data.success) {
        setPosts(posts.filter(p => p._id !== postId));
        showToast('Post deleted successfully');
      }
    } catch (err) { showToast(err.response?.data?.message || 'Failed to delete post', 'error'); }
  };

  // Posts use authorId (populated) not author
  const getAuthor = (post) => post.authorId || post.author || null;

  const filtered = posts.filter(p => {
    const author = getAuthor(p);
    return (
      (p.content || '').toLowerCase().includes(search.toLowerCase()) ||
      (author?.name || '').toLowerCase().includes(search.toLowerCase()) ||
      (author?.email || '').toLowerCase().includes(search.toLowerCase())
    );
  });

  if (loading) return (
    <div className="loading-container">
      <div className="spinner" />
      <p>Loading posts...</p>
    </div>
  );

  const totalLikes = posts.reduce((s, p) => s + (p.likesCount || 0), 0);
  const totalComments = posts.reduce((s, p) => s + (p.commentsCount || 0), 0);
  const withImages = posts.filter(p => p.imageUrl).length;

  return (
    <div>
      {toast && <div className={`toast toast-${toast.type}`}>{toast.type === 'success' ? '✅' : '❌'} {toast.msg}</div>}

      <div className="page-header">
        <div>
          <h1 className="page-title">Posts Moderation</h1>
          <p className="page-subtitle">{posts.length} discussion posts on the feed</p>
        </div>
        <div style={{ display: 'flex', gap: '0.75rem', alignItems: 'center' }}>
          <button className="btn btn-ghost btn-sm" onClick={fetchPosts}>
            <svg width="14" height="14" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24"><polyline points="23,4 23,10 17,10"/><polyline points="1,20 1,14 7,14"/><path d="M3.51 9a9 9 0 0114.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0020.49 15"/></svg>
            Refresh
          </button>
          <div className="header-search" style={{ width: '260px' }}>
            <svg fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24">
              <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
            </svg>
            <input type="text" placeholder="Search by content or author..." value={search} onChange={e => setSearch(e.target.value)} />
            {search && (
              <button onClick={() => setSearch('')} style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--text-muted)', padding: 0 }}>✕</button>
            )}
          </div>
        </div>
      </div>

      {/* Summary */}
      <div className="stats-grid" style={{ marginBottom: '1.5rem' }}>
        <div className="stats-card stats-card-4">
          <div className="stats-icon-wrap"><svg width="22" height="22" fill="none" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14,2 14,8 20,8"/></svg></div>
          <div className="stats-label">Total Posts</div>
          <div className="stats-value">{posts.length}</div>
          <div className="stats-change">All discussion posts</div>
        </div>
        <div className="stats-card stats-card-5">
          <div className="stats-icon-wrap"><svg width="22" height="22" fill="none" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 000-7.78z"/></svg></div>
          <div className="stats-label">Total Likes</div>
          <div className="stats-value">{totalLikes}</div>
          <div className="stats-change">Across all posts</div>
        </div>
        <div className="stats-card stats-card-1">
          <div className="stats-icon-wrap"><svg width="22" height="22" fill="none" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg></div>
          <div className="stats-label">Total Comments</div>
          <div className="stats-value">{totalComments}</div>
          <div className="stats-change">Engagement metric</div>
        </div>
        <div className="stats-card stats-card-3">
          <div className="stats-icon-wrap"><svg width="22" height="22" fill="none" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21,15 16,10 5,21"/></svg></div>
          <div className="stats-label">Posts with Images</div>
          <div className="stats-value">{withImages}</div>
          <div className="stats-change">Media content</div>
        </div>
      </div>

      <div className="table-container">
        <div className="table-header">
          <div className="table-title">All Posts</div>
          <span className="badge badge-student">{filtered.length} results</span>
        </div>
        <table className="data-table">
          <thead>
            <tr>
              <th>Author</th>
              <th>Content</th>
              <th>Engagement</th>
              <th>Image</th>
              <th>Posted</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {filtered.length === 0 ? (
              <tr><td colSpan={6}><div className="empty-state">
                <svg width="40" height="40" fill="none" stroke="currentColor" strokeWidth="1.5" viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/></svg>
                <p>{search ? `No posts matching "${search}"` : 'No posts found'}</p>
              </div></td></tr>
            ) : filtered.map(post => {
              const author = getAuthor(post);
              const initials = (author?.name || 'U').split(' ').map(n => n[0]).join('').slice(0,2).toUpperCase();
              return (
                <tr key={post._id}>
                  <td>
                    <div className="user-cell">
                      <div className="user-cell-avatar">{initials}</div>
                      <div>
                        <div className="user-cell-name">{author?.name || 'Unknown User'}</div>
                        <div className="user-cell-email">{author?.role || '—'}</div>
                      </div>
                    </div>
                  </td>
                  <td style={{ maxWidth: '280px' }}>
                    <div style={{ fontSize: '0.85rem', color: 'var(--text-main)', overflow: 'hidden', display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical' }}>
                      {post.content || '(no content)'}
                    </div>
                  </td>
                  <td>
                    <div style={{ display: 'flex', gap: '0.75rem', alignItems: 'center' }}>
                      <span style={{ color: 'var(--accent2)', fontWeight: 700, fontSize: '0.82rem' }}>❤️ {post.likesCount || 0}</span>
                      <span style={{ color: 'var(--accent1)', fontWeight: 700, fontSize: '0.82rem' }}>💬 {post.commentsCount || 0}</span>
                    </div>
                  </td>
                  <td>
                    <span className={`badge ${post.imageUrl ? 'badge-active' : 'badge-muted'}`}>
                      {post.imageUrl ? '🖼 Yes' : '—'}
                    </span>
                  </td>
                  <td style={{ fontSize: '0.78rem', color: 'var(--text-muted)', whiteSpace: 'nowrap' }}>
                    {new Date(post.createdAt).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' })}
                  </td>
                  <td>
                    <button className="btn btn-sm btn-danger" onClick={() => handleDeletePost(post._id)}>
                      🗑 Delete
                    </button>
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
