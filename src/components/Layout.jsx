import React, { useState } from 'react'
import { Outlet, NavLink, useNavigate } from 'react-router-dom'
import {
  LayoutDashboard,
  Server,
  Users,
  ShieldCheck,
  Bell,
  Settings,
  LogOut,
  Menu,
  X,
  Activity,
} from 'lucide-react'
import useAuthStore from '../store/authStore'

const navItems = [
  { to: '/', icon: LayoutDashboard, label: 'لوحة التحكم' },
  { to: '/devices', icon: Server, label: 'الأجهزة' },
  { to: '/monitoring', icon: Activity, label: 'المراقبة' },
  { to: '/users', icon: Users, label: 'المستخدمون' },
  { to: '/roles', icon: ShieldCheck, label: 'الأدوار والصلاحيات' },
  { to: '/alerts', icon: Bell, label: 'التنبيهات' },
  { to: '/settings', icon: Settings, label: 'الإعدادات' },
]

export default function Layout() {
  const [sidebarOpen, setSidebarOpen] = useState(true)
  const navigate = useNavigate()
  const { user, clearAuth } = useAuthStore()

  const handleLogout = () => {
    clearAuth()
    navigate('/login')
  }

  return (
    <div className="flex h-screen bg-slate-900 overflow-hidden" dir="rtl">
      <aside
        className={`${
          sidebarOpen ? 'w-64' : 'w-16'
        } bg-slate-800 border-l border-slate-700 flex flex-col transition-all duration-300 ease-in-out shrink-0`}
      >
        <div className="flex items-center gap-3 px-4 py-4 border-b border-slate-700">
          <div className="w-9 h-9 rounded-full overflow-hidden border border-green-500/40 shrink-0">
            <img src="/logo.jpeg" alt="249 Shadow" className="w-full h-full object-cover" />
          </div>
          {sidebarOpen && (
            <div className="overflow-hidden">
              <p className="text-white font-bold text-sm leading-tight truncate">249-NIP</p>
              <p className="text-slate-400 text-xs truncate">Network Intelligence</p>
            </div>
          )}
        </div>

        <nav className="flex-1 py-4 overflow-y-auto">
          {navItems.map(({ to, icon: Icon, label }) => (
            <NavLink
              key={to}
              to={to}
              end={to === '/'}
              className={({ isActive }) =>
                `flex items-center gap-3 px-4 py-2.5 mx-2 rounded-lg mb-0.5 transition-colors text-sm font-medium ${
                  isActive
                    ? 'bg-blue-600 text-white'
                    : 'text-slate-400 hover:text-white hover:bg-slate-700'
                }`
              }
            >
              <Icon className="w-4 h-4 shrink-0" />
              {sidebarOpen && <span className="truncate">{label}</span>}
            </NavLink>
          ))}
        </nav>

        <div className="border-t border-slate-700 p-3">
          {sidebarOpen && user && (
            <div className="px-2 mb-2">
              <p className="text-white text-sm font-medium truncate">{user.name || user.username}</p>
              <p className="text-slate-400 text-xs truncate">{user.role || 'Admin'}</p>
            </div>
          )}
          <button
            onClick={handleLogout}
            className="flex items-center gap-3 w-full px-2 py-2 rounded-lg text-slate-400 hover:text-red-400 hover:bg-slate-700 transition-colors text-sm"
          >
            <LogOut className="w-4 h-4 shrink-0" />
            {sidebarOpen && <span>تسجيل الخروج</span>}
          </button>
        </div>
      </aside>

      <div className="flex-1 flex flex-col overflow-hidden">
        <header className="bg-slate-800 border-b border-slate-700 px-6 py-3 flex items-center justify-between shrink-0">
          <button
            onClick={() => setSidebarOpen(!sidebarOpen)}
            className="text-slate-400 hover:text-white transition p-1 rounded"
          >
            {sidebarOpen ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
          </button>
          <div className="flex items-center gap-3">
            <button className="relative text-slate-400 hover:text-white transition p-1 rounded">
              <Bell className="w-5 h-5" />
              <span className="absolute top-0 right-0 w-2 h-2 bg-red-500 rounded-full" />
            </button>
          </div>
        </header>

        <main className="flex-1 overflow-auto p-6">
          <Outlet />
        </main>
      </div>
    </div>
  )
}
