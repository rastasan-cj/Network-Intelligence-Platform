import React from 'react'
import {
  Server,
  Activity,
  AlertTriangle,
  CheckCircle,
  TrendingUp,
  Wifi,
  Clock,
  Cpu,
} from 'lucide-react'
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from 'recharts'

const stats = [
  { label: 'إجمالي الأجهزة', value: '0', icon: Server, color: 'blue', change: '' },
  { label: 'أجهزة نشطة', value: '0', icon: CheckCircle, color: 'green', change: '' },
  { label: 'تنبيهات نشطة', value: '0', icon: AlertTriangle, color: 'yellow', change: '' },
  { label: 'متوسط زمن الاستجابة', value: '—', icon: Activity, color: 'purple', change: '' },
]

const colorMap = {
  blue: 'bg-blue-500/10 text-blue-400 border-blue-500/20',
  green: 'bg-green-500/10 text-green-400 border-green-500/20',
  yellow: 'bg-yellow-500/10 text-yellow-400 border-yellow-500/20',
  purple: 'bg-purple-500/10 text-purple-400 border-purple-500/20',
}

const placeholderData = Array.from({ length: 12 }, (_, i) => ({
  time: `${String(i * 2).padStart(2, '0')}:00`,
  latency: 0,
  uptime: 0,
}))

export default function Dashboard() {
  return (
    <div className="space-y-6" dir="rtl">
      <div>
        <h1 className="text-2xl font-bold text-white">لوحة التحكم</h1>
        <p className="text-slate-400 text-sm mt-1">نظرة عامة على حالة الشبكة</p>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        {stats.map(({ label, value, icon: Icon, color }) => (
          <div
            key={label}
            className="bg-slate-800 border border-slate-700 rounded-xl p-5 flex items-center gap-4"
          >
            <div className={`w-12 h-12 rounded-xl border flex items-center justify-center shrink-0 ${colorMap[color]}`}>
              <Icon className="w-6 h-6" />
            </div>
            <div>
              <p className="text-slate-400 text-xs font-medium">{label}</p>
              <p className="text-white text-2xl font-bold mt-0.5">{value}</p>
            </div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-3 gap-4">
        <div className="xl:col-span-2 bg-slate-800 border border-slate-700 rounded-xl p-5">
          <div className="flex items-center justify-between mb-5">
            <div>
              <h2 className="text-white font-semibold">زمن الاستجابة (ms)</h2>
              <p className="text-slate-400 text-xs mt-0.5">آخر 24 ساعة</p>
            </div>
            <div className="flex items-center gap-1.5 text-slate-400 text-xs">
              <Clock className="w-3.5 h-3.5" />
              <span>تحديث تلقائي</span>
            </div>
          </div>
          <ResponsiveContainer width="100%" height={200}>
            <LineChart data={placeholderData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#334155" />
              <XAxis dataKey="time" stroke="#64748b" tick={{ fontSize: 11 }} />
              <YAxis stroke="#64748b" tick={{ fontSize: 11 }} />
              <Tooltip
                contentStyle={{ backgroundColor: '#1e293b', border: '1px solid #334155', borderRadius: 8 }}
                labelStyle={{ color: '#94a3b8' }}
                itemStyle={{ color: '#60a5fa' }}
              />
              <Line type="monotone" dataKey="latency" stroke="#3b82f6" strokeWidth={2} dot={false} />
            </LineChart>
          </ResponsiveContainer>
        </div>

        <div className="bg-slate-800 border border-slate-700 rounded-xl p-5">
          <h2 className="text-white font-semibold mb-4">حالة الخدمات</h2>
          <div className="space-y-3">
            {[
              { name: 'SNMP Polling', status: 'inactive', icon: Cpu },
              { name: 'Ping Monitor', status: 'inactive', icon: Wifi },
              { name: 'SSH Agent', status: 'inactive', icon: Server },
              { name: 'Alert Engine', status: 'inactive', icon: AlertTriangle },
              { name: 'AI Analyzer', status: 'inactive', icon: TrendingUp },
            ].map(({ name, status, icon: Icon }) => (
              <div key={name} className="flex items-center justify-between py-2 border-b border-slate-700 last:border-0">
                <div className="flex items-center gap-2.5 text-slate-300 text-sm">
                  <Icon className="w-4 h-4 text-slate-400" />
                  {name}
                </div>
                <span className="text-xs px-2 py-0.5 rounded-full bg-slate-700 text-slate-400">
                  غير مفعّل
                </span>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="bg-slate-800 border border-slate-700 rounded-xl p-5">
        <h2 className="text-white font-semibold mb-1">آخر الأحداث</h2>
        <p className="text-slate-400 text-xs mb-4">سجل أحداث النظام</p>
        <div className="flex flex-col items-center justify-center py-12 text-slate-500">
          <Activity className="w-10 h-10 mb-3 opacity-30" />
          <p className="text-sm">لا توجد أحداث حتى الآن</p>
          <p className="text-xs mt-1 opacity-60">ستظهر الأحداث هنا بعد إضافة الأجهزة</p>
        </div>
      </div>
    </div>
  )
}
