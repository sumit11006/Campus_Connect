import React from 'react';

export default function StatsCard({ title, value, icon: Icon, color }) {
  return (
    <div className="stats-card">
      <div>
        <div className="stats-label">{title}</div>
        <div className="stats-value">{value}</div>
      </div>
      <div className="stats-icon" style={color ? { color, backgroundColor: `${color}20` } : {}}>
        <Icon size={24} />
      </div>
    </div>
  );
}
