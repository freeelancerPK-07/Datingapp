import React, { useState, useEffect, useMemo } from 'react';
import {
  LayoutDashboard,
  Users,
  Sparkles,
  Coins,
  CreditCard,
  Video,
  Settings,
  ShieldAlert,
  Search,
  RefreshCw,
  Bell,
  CheckCircle2,
  XCircle,
  Eye,
  Plus,
  Trash2,
  Check,
  X,
  ExternalLink,
  Lock,
  Unlock,
  AlertTriangle,
  TrendingUp,
  UserCheck,
  UserX,
  Radio,
  Clock,
  ArrowUpRight,
  ArrowDownRight,
  Filter,
  DollarSign,
  ChevronRight,
  Calendar,
  Phone,
  Mail,
  Award,
  CircleDollarSign,
  Share2,
} from 'lucide-react';

const API_BASE = '/api/v1';

// Types
interface OverviewStats {
  totalUsers: number;
  activeToday: number;
  totalCreators: number;
  activeCreators: number;
  inactiveCreators: number;
  liveCreators: number;
  totalDiamondsSold: number;
  totalRevenue: number;
  totalCalls: number;
  completedCalls: number;
  pendingApprovals: number;
}

interface RecentTxn {
  id: string;
  userName: string;
  userEmail: string;
  coins: number;
  amountInr: number;
  type: string;
  status: string;
  createdAt: string;
  description: string;
}

interface RecentCall {
  id: string;
  callerName: string;
  creatorName: string;
  callType: string;
  durationSecs: number;
  durationFormatted: string;
  coins: number;
  status: string;
  createdAt: string;
}

interface UserRecord {
  id: string;
  name: string;
  email: string;
  phone: string;
  avatarUrl: string;
  role: string;
  isActive: boolean;
  isVerified: boolean;
  walletBalance: number;
  createdAt: string;
  city: string;
  isCreator: boolean;
}

interface CreatorApplication {
  id: string;
  userId: string;
  legalName: string;
  age: number;
  profession: string;
  bio: string;
  photoUrl: string;
  govtIdType: string;
  govtIdFrontUrl: string | null;
  govtIdBackUrl: string | null;
  selfieUrl: string | null;
  socialHandle: string | null;
  payoutUpiId: string;
  videoCallPrice: number;
  voiceCallPrice: number;
  languages: string[];
  tags: string[];
  subscriptionPlan: string;
  subscriptionPaid: boolean;
  createdAt: string;
  user: {
    email: string | null;
    phone: string | null;
    profile: {
      avatarUrl: string;
      name: string;
    } | null;
  };
}

interface Creator {
  id: string;
  userId: string;
  name: string;
  age: number;
  profession: string;
  photoUrl: string;
  videoCallPrice: number;
  voiceCallPrice: number;
  rating: number;
  reviewCount: number;
  isActive: boolean;
  isApproved: boolean;
  isFeatured: boolean;
  isOnline: boolean;
  languages: string[];
  tags: string[];
  email: string;
  phone: string;
}

interface AdminSettings {
  isFreezeBalance: boolean;
  isVideoConnectionEnabled: boolean;
  paymentUpiId: string;
}

export default function App() {
  // Navigation State
  const [activeMenu, setActiveMenu] = useState<
    'dashboard' | 'users' | 'creators' | 'wallet' | 'calls' | 'settings'
  >('dashboard');

  // Time Period State for Charts
  const [chartPeriod, setChartPeriod] = useState<'12h' | '24h' | 'Week' | 'Month'>('Week');
  const [dashboardTab, setDashboardTab] = useState<'creators' | 'users' | 'approvals'>('creators');

  // Loading & Connection State
  const [apiConnected, setApiConnected] = useState(false);
  const [loading, setLoading] = useState(false);
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  // Data States
  const [stats, setStats] = useState<OverviewStats>({
    totalUsers: 0,
    activeToday: 0,
    totalCreators: 0,
    activeCreators: 0,
    inactiveCreators: 0,
    liveCreators: 0,
    totalDiamondsSold: 0,
    totalRevenue: 0,
    totalCalls: 0,
    completedCalls: 0,
    pendingApprovals: 0,
  });
  const [recentTxns, setRecentTxns] = useState<RecentTxn[]>([]);
  const [recentCalls, setRecentCalls] = useState<RecentCall[]>([]);
  const [usersList, setUsersList] = useState<UserRecord[]>([]);
  const [pendingApps, setPendingApps] = useState<CreatorApplication[]>([]);
  const [creatorsList, setCreatorsList] = useState<Creator[]>([]);
  const [allTxns, setAllTxns] = useState<any[]>([]);
  const [allCalls, setAllCalls] = useState<any[]>([]);

  // Settings State
  const [settings, setSettings] = useState<AdminSettings>({
    isFreezeBalance: false,
    isVideoConnectionEnabled: true,
    paymentUpiId: 'XYX12438383@ybl',
  });
  const [upiInput, setUpiInput] = useState('XYX12438383@ybl');

  // Creator Sub-Tabs & Modals
  const [creatorSubTab, setCreatorSubTab] = useState<'pending' | 'directory' | 'add'>('pending');
  const [selectedKycApp, setSelectedKycApp] = useState<CreatorApplication | null>(null);
  const [rejectionReason, setRejectionReason] = useState('');
  const [rejectingAppId, setRejectingAppId] = useState<string | null>(null);

  // Users Filter & Search
  const [userSearchQuery, setUserSearchQuery] = useState('');
  const [userRoleFilter, setUserRoleFilter] = useState('ALL');
  const [deletingUser, setDeletingUser] = useState<{ id: string; name: string } | null>(null);
  const [isDeleting, setIsDeleting] = useState(false);

  // Direct Onboard Form
  const [newCreatorForm, setNewCreatorForm] = useState({
    name: '',
    age: 23,
    profession: 'Lifestyle Influencer',
    photoUrl: '',
    videoCallPrice: 500,
    voiceCallPrice: 300,
    bio: 'Official LinkUp Creator ready to connect live.',
    email: '',
    phone: '',
    isActive: true,
    isFeatured: true,
  });

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 4000);
  };

  // Real dynamic weekly activity calculation (from actual calls & transactions)
  const weeklyChartData = useMemo(() => {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const counts = [0, 0, 0, 0, 0, 0, 0];

    recentCalls.forEach((c) => {
      if (c.createdAt) {
        const d = new Date(c.createdAt);
        const dayIdx = (d.getDay() + 6) % 7;
        counts[dayIdx] += 1;
      }
    });

    recentTxns.forEach((t) => {
      if (t.createdAt) {
        const d = new Date(t.createdAt);
        const dayIdx = (d.getDay() + 6) % 7;
        counts[dayIdx] += 1;
      }
    });

    const maxCount = Math.max(...counts, 1);
    const todayIdx = (new Date().getDay() + 6) % 7;

    return days.map((day, idx) => {
      const val = counts[idx];
      const percent = val === 0 ? 8 : Math.max(15, Math.round((val / maxCount) * 100));
      return {
        day,
        height: `${percent}%`,
        val: val > 0 ? `${val}` : '0',
        active: idx === todayIdx,
      };
    });
  }, [recentCalls, recentTxns]);

  // ---------------------------------------------------------------------------
  // Data Fetching
  // ---------------------------------------------------------------------------
  const loadDashboardData = async () => {
    setLoading(true);
    try {
      // 1. Overview Stats & Recent Activity
      const ovRes = await fetch(`${API_BASE}/admin/overview`);
      if (ovRes.ok) {
        const d = await ovRes.json();
        if (d.data) {
          setStats(d.data.stats || stats);
          setRecentTxns(d.data.recentTransactions || []);
          setRecentCalls(d.data.recentCalls || []);
          setApiConnected(true);
        }
      }

      // 2. Settings
      const setRes = await fetch(`${API_BASE}/admin/settings`);
      if (setRes.ok) {
        const s = await setRes.json();
        if (s.settings) {
          setSettings(s.settings);
          setUpiInput(s.settings.paymentUpiId || 'XYX12438383@ybl');
        }
      }

      // 3. Pending Creator Applications
      const pendRes = await fetch(`${API_BASE}/admin/creators/pending`);
      if (pendRes.ok) {
        const p = await pendRes.json();
        setPendingApps(p.data || []);
      }

      // 4. All Creators
      const crRes = await fetch(`${API_BASE}/admin/creators`);
      if (crRes.ok) {
        const c = await crRes.json();
        setCreatorsList(c.data || []);
      }

      // 5. Users List
      const uRes = await fetch(`${API_BASE}/admin/users`);
      if (uRes.ok) {
        const u = await uRes.json();
        setUsersList(u.data || []);
      }

      // 6. Transactions
      const txRes = await fetch(`${API_BASE}/admin/transactions`);
      if (txRes.ok) {
        const t = await txRes.json();
        setAllTxns(t.data || []);
      }

      // 7. Calls
      const clRes = await fetch(`${API_BASE}/admin/calls`);
      if (clRes.ok) {
        const cl = await clRes.json();
        setAllCalls(cl.data || []);
      }
    } catch (e) {
      console.error('Error fetching admin data:', e);
      setApiConnected(false);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadDashboardData();
    const interval = setInterval(loadDashboardData, 8000); // 8s live poll
    return () => clearInterval(interval);
  }, []);

  // ---------------------------------------------------------------------------
  // Action Handlers
  // ---------------------------------------------------------------------------
  const handleUpdateSettings = async (updates: Partial<AdminSettings>) => {
    try {
      const res = await fetch(`${API_BASE}/admin/settings`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(updates),
      });
      const data = await res.json();
      if (data.success) {
        setSettings(data.settings);
        showToast('System settings updated successfully');
      }
    } catch (e) {
      showToast('Failed to update system settings');
    }
  };

  const handleApproveCreator = async (appId: string) => {
    try {
      const res = await fetch(`${API_BASE}/admin/creators/${appId}/approve`, {
        method: 'POST',
      });
      const data = await res.json();
      if (data.success) {
        showToast('Creator Approved! Profile is now LIVE on mobile app Home Feed.');
        setSelectedKycApp(null);
        loadDashboardData();
      } else {
        showToast(data.error || 'Failed to approve creator');
      }
    } catch (e) {
      showToast('Error approving creator application');
    }
  };

  const handleRejectCreator = async () => {
    if (!rejectingAppId) return;
    try {
      const res = await fetch(`${API_BASE}/admin/creators/${rejectingAppId}/reject`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ reason: rejectionReason || 'KYC documentation could not be verified.' }),
      });
      const data = await res.json();
      if (data.success) {
        showToast('Application rejected with feedback');
        setRejectingAppId(null);
        setRejectionReason('');
        loadDashboardData();
      }
    } catch (e) {
      showToast('Error rejecting application');
    }
  };

  const handleToggleUserBlock = async (userId: string) => {
    try {
      const res = await fetch(`${API_BASE}/admin/users/${userId}/toggle-status`, { method: 'PUT' });
      const data = await res.json();
      if (data.success) {
        showToast(data.message || 'User status updated');
        loadDashboardData();
      }
    } catch (e) {
      showToast('Failed to update user status');
    }
  };

  const handleConfirmDelete = async () => {
    if (!deletingUser) return;
    setIsDeleting(true);
    try {
      const res = await fetch(`${API_BASE}/admin/users/${deletingUser.id}`, {
        method: 'DELETE',
      });
      const data = await res.json();
      if (data.success) {
        showToast(`Account "${deletingUser.name}" permanently deleted from DB & platform.`);
        setDeletingUser(null);
        loadDashboardData();
      } else {
        showToast(data.error || 'Failed to delete user');
      }
    } catch (e) {
      showToast('Error deleting user account');
    } finally {
      setIsDeleting(false);
    }
  };

  const handleToggleCreatorActive = async (creatorId: string, current: boolean) => {
    try {
      const res = await fetch(`${API_BASE}/admin/creators/${creatorId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ isActive: !current }),
      });
      if (res.ok) {
        showToast(`Creator ${!current ? 'Activated' : 'Deactivated'}`);
        loadDashboardData();
      }
    } catch (e) {
      showToast('Failed to toggle creator status');
    }
  };

  const handleToggleFeatured = async (creatorId: string, current: boolean) => {
    try {
      const res = await fetch(`${API_BASE}/admin/creators/${creatorId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ isFeatured: !current }),
      });
      if (res.ok) {
        showToast(`Creator ${!current ? 'Pinned to Featured' : 'Removed from Featured'}`);
        loadDashboardData();
      }
    } catch (e) {
      showToast('Failed to update featured status');
    }
  };

  const handleDirectCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newCreatorForm.name || !newCreatorForm.profession) {
      showToast('Name and profession are required');
      return;
    }
    try {
      const res = await fetch(`${API_BASE}/admin/creators/create-direct`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newCreatorForm),
      });
      const data = await res.json();
      if (data.success) {
        showToast('Creator created & published LIVE to Mobile App!');
        setCreatorSubTab('directory');
        loadDashboardData();
      } else {
        showToast(data.error || 'Failed to create creator');
      }
    } catch (e) {
      showToast('Error creating creator');
    }
  };

  // Filtered users for Users Management table
  const filteredUsers = usersList.filter((u) => {
    const matchesSearch =
      u.name.toLowerCase().includes(userSearchQuery.toLowerCase()) ||
      u.phone.includes(userSearchQuery) ||
      u.email.toLowerCase().includes(userSearchQuery.toLowerCase());
    if (userRoleFilter === 'CREATORS') return matchesSearch && u.isCreator;
    if (userRoleFilter === 'USERS') return matchesSearch && !u.isCreator;
    return matchesSearch;
  });

  return (
    <div className="flex h-screen bg-[#F8FAFC] text-slate-800 font-sans antialiased overflow-hidden">
      {/* Toast Notification */}
      {toastMessage && (
        <div className="fixed bottom-6 right-6 z-50 bg-black text-white px-5 py-3.5 rounded-2xl shadow-2xl flex items-center gap-3 border border-slate-700 animate-slide-up">
          <CheckCircle2 className="w-5 h-5 text-emerald-400" />
          <span className="text-sm font-bold">{toastMessage}</span>
        </div>
      )}

      {/* -------------------------------------------------------------------- */}
      {/* SIDEBAR: Purely SaaS Light Theme with Rounded Black Active Pill       */}
      {/* -------------------------------------------------------------------- */}
      <aside className="w-64 bg-white border-r border-slate-200/80 flex flex-col justify-between p-5 select-none z-20">
        <div>
          {/* Logo Header */}
          <div className="flex items-center gap-3 px-3 py-2 mb-8">
            <div className="w-10 h-10 rounded-2xl bg-gradient-to-tr from-[#635BFF] via-[#84CC16] to-[#10B981] flex items-center justify-center shadow-md shadow-indigo-500/20">
              <Sparkles className="w-5 h-5 text-white" />
            </div>
            <div>
              <h1 className="text-xl font-black tracking-tight text-slate-900 flex items-center gap-1.5">
                PURELY
                <span className="text-[10px] font-black uppercase tracking-wider bg-slate-100 text-slate-600 px-2 py-0.5 rounded-md">
                  Admin
                </span>
              </h1>
              <p className="text-[11px] font-semibold text-slate-400">LinkUp SaaS Platform</p>
            </div>
          </div>

          {/* Menu Section Header */}
          <div className="px-3 mb-3">
            <span className="text-[11px] font-black uppercase tracking-wider text-slate-400">
              Menu
            </span>
          </div>

          {/* Navigation Items with Purely Pill Style */}
          <nav className="space-y-1.5">
            <SidebarPill
              icon={<LayoutDashboard className="w-4 h-4" />}
              label="Dashboard"
              active={activeMenu === 'dashboard'}
              onClick={() => setActiveMenu('dashboard')}
            />
            <SidebarPill
              icon={<Users className="w-4 h-4" />}
              label="Customers"
              sublabel="Users"
              active={activeMenu === 'users'}
              badge={stats.totalUsers > 0 ? stats.totalUsers : undefined}
              onClick={() => setActiveMenu('users')}
            />
            <SidebarPill
              icon={<Sparkles className="w-4 h-4" />}
              label="Creators"
              active={activeMenu === 'creators'}
              badge={pendingApps.length > 0 ? pendingApps.length : undefined}
              badgeColor="bg-emerald-500"
              onClick={() => setActiveMenu('creators')}
            />
            <SidebarPill
              icon={<Coins className="w-4 h-4" />}
              label="Store & Wallet"
              active={activeMenu === 'wallet'}
              onClick={() => setActiveMenu('wallet')}
            />
            <SidebarPill
              icon={<Video className="w-4 h-4" />}
              label="Live Calls"
              active={activeMenu === 'calls'}
              badge={stats.liveCreators > 0 ? `${stats.liveCreators} Live` : undefined}
              badgeColor="bg-rose-500"
              onClick={() => setActiveMenu('calls')}
            />
            <SidebarPill
              icon={<Settings className="w-4 h-4" />}
              label="Settings"
              active={activeMenu === 'settings'}
              onClick={() => setActiveMenu('settings')}
            />
          </nav>
        </div>

        {/* Footer / System Health Pill */}
        <div className="pt-4 border-t border-slate-100">
          <div className="bg-slate-50 border border-slate-200/70 rounded-2xl p-3.5 flex items-center justify-between">
            <div className="flex items-center gap-2.5">
              <span className={`w-2.5 h-2.5 rounded-full ${apiConnected ? 'bg-emerald-500 animate-pulse' : 'bg-rose-500'}`} />
              <div>
                <p className="text-xs font-bold text-slate-800">
                  {apiConnected ? 'Database Online' : 'Connecting DB'}
                </p>
                <p className="text-[10px] text-slate-500">PostgreSQL (Local:5432)</p>
              </div>
            </div>
            <button
              onClick={loadDashboardData}
              title="Refresh Live Data"
              className="p-1.5 hover:bg-white rounded-lg border border-transparent hover:border-slate-200 transition-all text-slate-500 hover:text-slate-800"
            >
              <RefreshCw className={`w-3.5 h-3.5 ${loading ? 'animate-spin text-indigo-600' : ''}`} />
            </button>
          </div>
        </div>
      </aside>

      {/* -------------------------------------------------------------------- */}
      {/* MAIN CONTENT AREA                                                    */}
      {/* -------------------------------------------------------------------- */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Top Navbar */}
        <header className="h-20 bg-white border-b border-slate-200/80 px-8 flex items-center justify-between z-10">
          {/* Welcome greeting */}
          <div>
            <h2 className="text-lg font-black text-slate-900 tracking-tight flex items-center gap-2">
              Hey Admin, Welcome Back! 👋
            </h2>
            <p className="text-xs font-semibold text-slate-400">
              Live LinkUp Overview & Verification Portal
            </p>
          </div>

          {/* Search Pill */}
          <div className="flex items-center gap-3">
            <div className="relative w-80">
              <Search className="w-4 h-4 text-slate-400 absolute left-4 top-1/2 -translate-y-1/2" />
              <input
                type="text"
                placeholder="Search Creators, Users..."
                value={userSearchQuery}
                onChange={(e) => setUserSearchQuery(e.target.value)}
                className="w-full pl-11 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-full text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-black focus:border-transparent transition-all placeholder:text-slate-400"
              />
            </div>

            {/* Live Date Pill */}
            <div className="hidden sm:flex items-center gap-2 bg-slate-50 border border-slate-200 px-3.5 py-2 rounded-full text-xs font-bold text-slate-600">
              <Calendar className="w-3.5 h-3.5 text-slate-400" />
              <span>{new Date().toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}</span>
            </div>

            {/* Notification Bell with Badge */}
            <button
              onClick={() => {
                setActiveMenu('creators');
                setCreatorSubTab('pending');
              }}
              className="relative p-2.5 bg-slate-50 hover:bg-slate-100 rounded-full border border-slate-200 text-slate-600 transition-all"
            >
              <Bell className="w-4 h-4" />
              {pendingApps.length > 0 && (
                <span className="absolute -top-1 -right-1 w-5 h-5 bg-rose-500 text-white rounded-full text-[10px] font-black flex items-center justify-center ring-2 ring-white">
                  {pendingApps.length}
                </span>
              )}
            </button>

            {/* Admin Avatar */}
            <div className="flex items-center gap-2.5 pl-2 border-l border-slate-200">
              <div className="w-9 h-9 rounded-full bg-slate-900 text-white font-extrabold text-xs flex items-center justify-center ring-2 ring-slate-100 shadow-sm">
                AD
              </div>
            </div>
          </div>
        </header>

        {/* Scrollable View Area */}
        <main className="flex-1 overflow-y-auto p-8">
          {/* VIEW 1: DASHBOARD (Sales Overview + Overall Insights + Approval Requests) */}
          {activeMenu === 'dashboard' && (
            <div className="space-y-8 max-w-7xl mx-auto">
              {/* Row 1: Section Title & Filter */}
              <div className="flex items-center justify-between">
                <div>
                  <h3 className="text-2xl font-black text-slate-900 tracking-tight">Sales Overview</h3>
                  <p className="text-xs font-semibold text-slate-400 mt-0.5">Real-time revenue, transactions, and user growth</p>
                </div>
                <div className="flex items-center gap-2">
                  <span className="text-xs font-bold text-slate-500">View:</span>
                  <div className="flex bg-white p-1 rounded-xl border border-slate-200 text-xs font-extrabold shadow-sm">
                    {(['12h', '24h', 'Week', 'Month'] as const).map((p) => (
                      <button
                        key={p}
                        onClick={() => setChartPeriod(p)}
                        className={`px-3 py-1 rounded-lg transition-all ${
                          chartPeriod === p
                            ? 'bg-black text-white shadow-sm'
                            : 'text-slate-500 hover:text-black'
                        }`}
                      >
                        {p}
                      </button>
                    ))}
                  </div>
                </div>
              </div>

              {/* Row 2: Purely Style Top Hero Cards Grid */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                {/* 1. Dark Hero Card: Total Revenue */}
                <div className="bg-[#0B0F19] text-white rounded-3xl p-6 relative overflow-hidden shadow-xl shadow-black/10 flex flex-col justify-between min-h-[170px]">
                  <div className="flex items-center justify-between z-10">
                    <span className="text-xs font-bold text-slate-400 tracking-wide uppercase">
                      Total Revenue
                    </span>
                    <span className="bg-[#84CC16]/20 border border-[#84CC16]/30 text-[#84CC16] text-[11px] font-black px-2.5 py-0.5 rounded-full flex items-center gap-1">
                      <ArrowUpRight className="w-3 h-3" /> Live
                    </span>
                  </div>
                  <div className="z-10 my-2">
                    <p className="text-3xl font-black tracking-tight">
                      ₹{stats.totalRevenue.toLocaleString()}
                    </p>
                    <p className="text-[11px] font-semibold text-slate-400 mt-1">
                      From wallet recharges & VIP subscriptions
                    </p>
                  </div>
                  <div className="flex items-center justify-between text-[11px] text-slate-400 pt-2 border-t border-slate-800 z-10">
                    <span>From database</span>
                    <span className="font-bold text-white">Live Sync</span>
                  </div>
                  {/* Decorative glowing gradient sphere */}
                  <div className="absolute -bottom-10 -right-10 w-36 h-36 bg-[#84CC16]/10 rounded-full blur-2xl pointer-events-none" />
                </div>

                {/* 2. Total Transactions Card */}
                <div className="bg-white rounded-3xl p-6 border border-slate-200/80 shadow-sm flex flex-col justify-between min-h-[170px]">
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-bold text-slate-500 uppercase tracking-wide">
                      Total Transactions
                    </span>
                    <span className="bg-emerald-50 border border-emerald-200 text-emerald-700 text-[11px] font-black px-2.5 py-0.5 rounded-full flex items-center gap-1">
                      <ArrowUpRight className="w-3 h-3" /> Real-time
                    </span>
                  </div>
                  <div className="my-2">
                    <p className="text-3xl font-black text-slate-900 tracking-tight">
                      {stats.totalDiamondsSold.toLocaleString()}
                    </p>
                    <p className="text-[11px] font-semibold text-slate-500 mt-1">
                      Diamonds sold to active users
                    </p>
                  </div>
                  <div className="flex items-center justify-between text-[11px] text-slate-400 pt-2 border-t border-slate-100">
                    <span>From database</span>
                    <span className="font-bold text-indigo-600">Wallet Ledger</span>
                  </div>
                </div>

                {/* 3. User Growth Card with Sparkline */}
                <div className="bg-white rounded-3xl p-6 border border-slate-200/80 shadow-sm flex flex-col justify-between min-h-[170px]">
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-bold text-slate-500 uppercase tracking-wide">
                      User Growth
                    </span>
                    <span className="bg-emerald-50 border border-emerald-200 text-emerald-700 text-[11px] font-black px-2.5 py-0.5 rounded-full flex items-center gap-1">
                      <ArrowUpRight className="w-3 h-3" /> DB Verified
                    </span>
                  </div>
                  <div className="my-2 flex items-end justify-between">
                    <div>
                      <p className="text-3xl font-black text-slate-900 tracking-tight">
                        {stats.totalUsers.toLocaleString()}
                        <span className="text-sm font-bold text-slate-400 ml-1.5">Users</span>
                      </p>
                      <p className="text-[11px] font-semibold text-slate-500 mt-1">
                        Active registered LinkUp accounts
                      </p>
                    </div>

                    {/* SVG Sparkline Curve */}
                    <div className="w-28 h-10">
                      <svg viewBox="0 0 100 35" className="w-full h-full overflow-visible">
                        <defs>
                          <linearGradient id="sparkGradient" x1="0" y1="0" x2="0" y2="1">
                            <stop offset="0%" stopColor="#84CC16" stopOpacity="0.4" />
                            <stop offset="100%" stopColor="#84CC16" stopOpacity="0.0" />
                          </linearGradient>
                        </defs>
                        <path
                          d="M0,25 Q20,28 35,20 T70,12 T100,5 L100,35 L0,35 Z"
                          fill="url(#sparkGradient)"
                        />
                        <path
                          d="M0,25 Q20,28 35,20 T70,12 T100,5"
                          fill="none"
                          stroke="#84CC16"
                          strokeWidth="2.5"
                          strokeLinecap="round"
                        />
                      </svg>
                    </div>
                  </div>
                  <div className="flex items-center justify-between text-[11px] text-slate-400 pt-2 border-t border-slate-100">
                    <span>From database</span>
                    <span className="font-bold text-emerald-600">Verified DB</span>
                  </div>
                </div>
              </div>

              {/* Row 3: Overall Insights 4-Card Grid (Matching User's Image 2) */}
              <div>
                <div className="flex items-center justify-between mb-4">
                  <h4 className="text-lg font-black text-slate-900 tracking-tight">Overall Insights</h4>
                  <div className="flex items-center gap-2">
                    <span className="text-xs font-bold text-slate-400">Database Sync</span>
                    <button
                      onClick={() => setActiveMenu('creators')}
                      className="text-xs font-black bg-slate-900 hover:bg-black text-white px-3.5 py-1.5 rounded-full transition-all"
                    >
                      View all
                    </button>
                  </div>
                </div>

                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                  {/* Insight 1: Active Creators */}
                  <div className="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm flex items-center gap-4">
                    <div className="w-12 h-12 rounded-2xl bg-emerald-50 border border-emerald-100 flex items-center justify-center shrink-0">
                      <Users className="w-6 h-6 text-emerald-600" />
                    </div>
                    <div>
                      <div className="flex items-center gap-2">
                        <span className="text-2xl font-black text-slate-900">
                          {stats.activeCreators.toLocaleString()}
                        </span>
                        <span className="text-[10px] font-black text-emerald-600 bg-emerald-50 px-1.5 py-0.5 rounded">
                          Live
                        </span>
                      </div>
                      <p className="text-xs font-bold text-slate-400 mt-0.5">Total Active Creators</p>
                    </div>
                  </div>

                  {/* Insight 2: Total Video Calls */}
                  <div className="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm flex items-center gap-4">
                    <div className="w-12 h-12 rounded-2xl bg-purple-50 border border-purple-100 flex items-center justify-center shrink-0">
                      <Video className="w-6 h-6 text-purple-600" />
                    </div>
                    <div>
                      <div className="flex items-center gap-2">
                        <span className="text-2xl font-black text-slate-900">
                          {stats.totalCalls.toLocaleString()}
                        </span>
                        <span className="text-[10px] font-black text-purple-600 bg-purple-50 px-1.5 py-0.5 rounded">
                          Sessions
                        </span>
                      </div>
                      <p className="text-xs font-bold text-slate-400 mt-0.5">Total Video Calls</p>
                    </div>
                  </div>

                  {/* Insight 3: People Reach */}
                  <div className="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm flex items-center gap-4">
                    <div className="w-12 h-12 rounded-2xl bg-amber-50 border border-amber-100 flex items-center justify-center shrink-0">
                      <CircleDollarSign className="w-6 h-6 text-amber-600" />
                    </div>
                    <div>
                      <div className="flex items-center gap-2">
                        <span className="text-2xl font-black text-slate-900">
                          {stats.totalDiamondsSold.toLocaleString()}
                        </span>
                        <span className="text-[10px] font-black text-amber-600 bg-amber-50 px-1.5 py-0.5 rounded">
                          Coins
                        </span>
                      </div>
                      <p className="text-xs font-bold text-slate-400 mt-0.5">Total Diamonds Reach</p>
                    </div>
                  </div>

                  {/* Insight 4: Engagement */}
                  <div className="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm flex items-center gap-4">
                    <div className="w-12 h-12 rounded-2xl bg-blue-50 border border-blue-100 flex items-center justify-center shrink-0">
                      <Sparkles className="w-6 h-6 text-blue-600" />
                    </div>
                    <div>
                      <div className="flex items-center gap-2">
                        <span className="text-2xl font-black text-slate-900">
                          {stats.completedCalls.toLocaleString()}
                        </span>
                        <span className="text-[10px] font-black text-blue-600 bg-blue-50 px-1.5 py-0.5 rounded">
                          Completed
                        </span>
                      </div>
                      <p className="text-xs font-bold text-slate-400 mt-0.5">Completed Calls</p>
                    </div>
                  </div>
                </div>
              </div>

              {/* Row 4: 2-Column Split: Performance Bar Chart & Active Creators (Left) + Total Earning & Approval Requests (Right) */}
              <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                {/* Left Column (Span 2) */}
                <div className="lg:col-span-2 space-y-6">
                  {/* Sales & Activity Bar Chart (Purely Style with Lime Green Bars) */}
                  <div className="bg-white rounded-3xl p-6 border border-slate-200/80 shadow-sm">
                    <div className="flex items-center justify-between mb-6">
                      <div>
                        <h4 className="text-base font-black text-slate-900">Total Sales & Activity</h4>
                        <p className="text-xs font-semibold text-slate-400">Weekly platform activity across LinkUp creators</p>
                      </div>
                      <div className="flex items-center gap-3">
                        <div className="flex items-center gap-1.5 text-xs font-bold text-slate-600">
                          <span className="w-3 h-3 rounded-full bg-[#84CC16]" />
                          <span>Calls & Diamonds</span>
                        </div>
                      </div>
                    </div>

                    {/* Bar Chart Bars with Lime Accent & Tooltip */}
                    <div className="h-48 flex items-end justify-between gap-3 pt-6 px-2">
                      {weeklyChartData.map((bar) => (
                        <div key={bar.day} className="flex-1 flex flex-col items-center gap-2 group relative">
                          {/* Active Bar Tooltip */}
                          {bar.active && (
                            <div className="absolute -top-10 bg-black text-white text-[10px] font-black px-2.5 py-1 rounded-lg shadow-lg flex flex-col items-center">
                              <span>{bar.val}</span>
                              <div className="w-2 h-2 bg-black rotate-45 -mb-1" />
                            </div>
                          )}
                          <div className="w-full bg-slate-100 rounded-xl h-36 flex items-end p-1 overflow-hidden">
                            <div
                              style={{ height: bar.height }}
                              className={`w-full rounded-lg transition-all duration-500 ${
                                bar.active
                                  ? 'bg-[#84CC16] shadow-md shadow-[#84CC16]/30'
                                  : 'bg-[#84CC16]/40 hover:bg-[#84CC16]/70'
                              }`}
                            />
                          </div>
                          <span className="text-[11px] font-bold text-slate-400">{bar.day}</span>
                        </div>
                      ))}
                    </div>
                  </div>

                  {/* Active Creators & Users List Table (Matching Image 2 & 5) */}
                  <div className="bg-white rounded-3xl p-6 border border-slate-200/80 shadow-sm">
                    {/* Header & Tabs */}
                    <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 mb-6">
                      <div>
                        <h4 className="text-base font-black text-slate-900">Registered Accounts & Creators</h4>
                        <p className="text-xs font-semibold text-slate-400">All real accounts registered directly from the app</p>
                      </div>

                      <div className="flex bg-slate-100 p-1 rounded-xl text-xs font-bold text-slate-600">
                        <button
                          onClick={() => setDashboardTab('creators')}
                          className={`px-3 py-1.5 rounded-lg transition-all ${
                            dashboardTab === 'creators' ? 'bg-white text-black font-black shadow-sm' : 'hover:text-black'
                          }`}
                        >
                          Creators ({creatorsList.length})
                        </button>
                        <button
                          onClick={() => setDashboardTab('users')}
                          className={`px-3 py-1.5 rounded-lg transition-all ${
                            dashboardTab === 'users' ? 'bg-white text-black font-black shadow-sm' : 'hover:text-black'
                          }`}
                        >
                          All Users ({usersList.length})
                        </button>
                      </div>
                    </div>

                    {/* Table View */}
                    <div className="overflow-x-auto">
                      <table className="w-full text-left text-xs">
                        <thead>
                          <tr className="border-b border-slate-100 text-slate-400 font-extrabold uppercase tracking-wider text-[10px]">
                            <th className="pb-3 px-3">Influencer / User</th>
                            <th className="pb-3 px-3">Role</th>
                            <th className="pb-3 px-3">Balance</th>
                            <th className="pb-3 px-3">Status</th>
                            <th className="pb-3 px-3 text-right">Action</th>
                          </tr>
                        </thead>
                        <tbody className="divide-y divide-slate-100">
                          {dashboardTab === 'creators' ? (
                            creatorsList.length > 0 ? (
                              creatorsList.slice(0, 5).map((c) => (
                                <tr key={c.id} className="hover:bg-slate-50/70 transition-all">
                                  <td className="py-3.5 px-3">
                                    <div className="flex items-center gap-3">
                                      <AvatarImage
                                        src={c.photoUrl}
                                        alt={c.name}
                                        className="w-10 h-10 rounded-full object-cover ring-2 ring-slate-100 shadow-sm"
                                      />
                                      <div>
                                        <p className="font-black text-slate-900 text-sm">{c.name}</p>
                                        <p className="text-[11px] text-slate-400">{c.profession}</p>
                                      </div>
                                    </div>
                                  </td>
                                  <td className="py-3.5 px-3">
                                    <span className="bg-amber-50 text-amber-800 border border-amber-200/70 text-[10px] font-black px-2 py-0.5 rounded-md">
                                      CREATOR
                                    </span>
                                  </td>
                                  <td className="py-3.5 px-3 font-extrabold text-slate-800">
                                    {c.videoCallPrice} Coins/min
                                  </td>
                                  <td className="py-3.5 px-3">
                                    <span
                                      className={`text-[10px] font-black px-2 py-0.5 rounded-full ${
                                        c.isActive ? 'bg-emerald-100 text-emerald-800' : 'bg-slate-100 text-slate-600'
                                      }`}
                                    >
                                      {c.isActive ? 'Active' : 'Inactive'}
                                    </span>
                                  </td>
                                  <td className="py-3.5 px-3 text-right">
                                    <button
                                      onClick={() => handleToggleCreatorActive(c.id, c.isActive)}
                                      className="text-xs font-bold text-slate-600 hover:text-black underline"
                                    >
                                      {c.isActive ? 'Deactivate' : 'Activate'}
                                    </button>
                                  </td>
                                </tr>
                              ))
                            ) : (
                              <tr>
                                <td colSpan={5} className="py-8 text-center text-slate-400 font-semibold">
                                  No approved creators yet. Check the "Approval Requests" panel on the right to approve applications!
                                </td>
                              </tr>
                            )
                          ) : (
                            usersList.length > 0 ? (
                              usersList.slice(0, 6).map((u) => (
                                <tr key={u.id} className="hover:bg-slate-50/70 transition-all">
                                  <td className="py-3.5 px-3">
                                    <div className="flex items-center gap-3">
                                      <AvatarImage
                                        src={u.avatarUrl}
                                        alt={u.name}
                                        className="w-10 h-10 rounded-full object-cover ring-2 ring-slate-100 shadow-sm"
                                      />
                                      <div>
                                        <p className="font-black text-slate-900 text-sm">{u.name}</p>
                                        <p className="text-[11px] text-slate-400">{u.phone || u.email || `ID: ${u.id.substring(0, 8)}...`}</p>
                                      </div>
                                    </div>
                                  </td>
                                  <td className="py-3.5 px-3">
                                    <span
                                      className={`text-[10px] font-black px-2 py-0.5 rounded-md ${
                                        u.isCreator
                                          ? 'bg-amber-50 text-amber-800 border border-amber-200'
                                          : 'bg-slate-100 text-slate-700'
                                      }`}
                                    >
                                      {u.isCreator ? 'CREATOR' : 'USER'}
                                    </span>
                                  </td>
                                  <td className="py-3.5 px-3 font-extrabold text-slate-900">
                                    {u.walletBalance} Diamonds
                                  </td>
                                  <td className="py-3.5 px-3">
                                    <span
                                      className={`text-[10px] font-black px-2 py-0.5 rounded-full ${
                                        u.isActive ? 'bg-emerald-100 text-emerald-800' : 'bg-rose-100 text-rose-800'
                                      }`}
                                    >
                                      {u.isActive ? 'Active' : 'Blocked'}
                                    </span>
                                  </td>
                                  <td className="py-3.5 px-3 text-right">
                                    <div className="flex items-center justify-end gap-1.5">
                                      <button
                                        onClick={() => handleToggleUserBlock(u.id)}
                                        className={`px-2.5 py-1 rounded-lg text-xs font-bold transition-all ${
                                          u.isActive
                                            ? 'bg-rose-50 text-rose-600 hover:bg-rose-100'
                                            : 'bg-emerald-50 text-emerald-600 hover:bg-emerald-100'
                                        }`}
                                      >
                                        {u.isActive ? 'Block' : 'Unblock'}
                                      </button>
                                      <button
                                        onClick={() => setDeletingUser({ id: u.id, name: u.name })}
                                        title="Permanently Delete Account from DB"
                                        className="p-1 rounded-lg text-slate-400 hover:text-rose-600 hover:bg-rose-50 transition-all"
                                      >
                                        <Trash2 className="w-3.5 h-3.5" />
                                      </button>
                                    </div>
                                  </td>
                                </tr>
                              ))
                            ) : (
                              <tr>
                                <td colSpan={5} className="py-8 text-center text-slate-400 font-semibold">
                                  Zero dummy users in database. As users register on the mobile app, they will appear here in real-time!
                                </td>
                              </tr>
                            )
                          )}
                        </tbody>
                      </table>
                    </div>
                  </div>
                </div>

                {/* Right Column (Span 1: Total Earning Card & Approval Requests Panel) */}
                <div className="space-y-6">
                  {/* Total Earning Quick Card (From Image 2) */}
                  <div className="bg-gradient-to-br from-blue-500 to-indigo-600 text-white rounded-3xl p-6 shadow-xl shadow-blue-500/20 relative overflow-hidden flex items-center justify-between">
                    <div>
                      <span className="text-xs font-bold text-blue-100 uppercase tracking-wide">
                        Total Earning
                      </span>
                      <p className="text-3xl font-black tracking-tight mt-1">
                        ₹{stats.totalRevenue.toLocaleString()}
                      </p>
                      <p className="text-[11px] font-semibold text-blue-100 mt-1">Platform Wallet Balance</p>
                    </div>
                    <div className="w-14 h-14 rounded-full bg-amber-400/90 text-amber-900 flex items-center justify-center font-black text-2xl shadow-lg ring-4 ring-white/20">
                      ₹
                    </div>
                  </div>

                  {/* Approval Requests Panel (Matching User's Image 2) */}
                  <div className="bg-white rounded-3xl p-6 border border-slate-200/80 shadow-sm">
                    <div className="flex items-center justify-between mb-4">
                      <div>
                        <h4 className="text-base font-black text-slate-900">Approval Requests</h4>
                        <p className="text-xs font-semibold text-slate-400">KYC creator verification queue</p>
                      </div>
                      <span className="bg-rose-50 text-rose-600 border border-rose-200 text-xs font-black px-2.5 py-0.5 rounded-full">
                        {pendingApps.length} Pending
                      </span>
                    </div>

                    {/* Pending Requests List */}
                    <div className="space-y-4">
                      {pendingApps.length > 0 ? (
                        pendingApps.map((app) => (
                          <div
                            key={app.id}
                            className="p-4 bg-slate-50 border border-slate-200/70 rounded-2xl space-y-3"
                          >
                            <div className="flex items-start gap-3">
                              <AvatarImage
                                src={app.photoUrl}
                                alt={app.legalName}
                                className="w-11 h-11 rounded-full object-cover ring-2 ring-white shadow-sm shrink-0"
                              />
                              <div className="flex-1 min-w-0">
                                <div className="flex items-center justify-between">
                                  <p className="font-black text-slate-900 text-sm truncate">{app.legalName}</p>
                                  <span className="text-[10px] font-bold text-slate-400">Just now</span>
                                </div>
                                <p className="text-xs text-slate-500 truncate">{app.profession}</p>
                                <p className="text-[11px] text-slate-400 mt-0.5">
                                  Plan: <span className="font-bold text-slate-700">{app.subscriptionPlan}</span> • Age: {app.age}
                                </p>
                              </div>
                            </div>

                            {/* Confirm & Delete Action Buttons (from Image 2) */}
                            <div className="flex items-center gap-2 pt-2 border-t border-slate-200/60">
                              <button
                                onClick={() => handleApproveCreator(app.id)}
                                className="flex-1 bg-blue-600 hover:bg-blue-700 text-white font-black text-xs py-2 px-3 rounded-xl transition-all shadow-sm flex items-center justify-center gap-1.5"
                              >
                                <Check className="w-3.5 h-3.5" />
                                Confirm & Make Live
                              </button>
                              <button
                                onClick={() => {
                                  setRejectingAppId(app.id);
                                  setSelectedKycApp(app);
                                }}
                                className="bg-slate-200 hover:bg-rose-100 hover:text-rose-700 text-slate-700 font-bold text-xs py-2 px-3 rounded-xl transition-all"
                              >
                                Delete
                              </button>
                            </div>
                          </div>
                        ))
                      ) : (
                        <div className="p-8 text-center bg-slate-50 rounded-2xl border border-dashed border-slate-200">
                          <CheckCircle2 className="w-10 h-10 text-emerald-500 mx-auto mb-2" />
                          <p className="text-xs font-black text-slate-800">All Caught Up!</p>
                          <p className="text-[11px] text-slate-400 mt-1">
                            No pending creator approvals. When users apply from the mobile app, their requests appear here for one-click approval!
                          </p>
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* VIEW 2: USERS MANAGEMENT (Full User Directory matching Image 5) */}
          {activeMenu === 'users' && (
            <div className="space-y-6 max-w-7xl mx-auto">
              {/* Header */}
              <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
                <div>
                  <h3 className="text-2xl font-black text-slate-900">User Management</h3>
                  <p className="text-xs font-semibold text-slate-400">Manage real registered accounts, wallet balances, and access</p>
                </div>
                <div className="flex items-center gap-3">
                  <select
                    value={userRoleFilter}
                    onChange={(e) => setUserRoleFilter(e.target.value)}
                    className="bg-white border border-slate-200 text-xs font-bold text-slate-700 rounded-xl px-3 py-2 focus:outline-none"
                  >
                    <option value="ALL">All Roles ({usersList.length})</option>
                    <option value="CREATORS">Creators Only</option>
                    <option value="USERS">Standard Users</option>
                  </select>
                </div>
              </div>

              {/* Users Table */}
              <div className="bg-white rounded-3xl p-6 border border-slate-200/80 shadow-sm overflow-hidden">
                <div className="overflow-x-auto">
                  <table className="w-full text-left text-xs">
                    <thead>
                      <tr className="border-b border-slate-100 text-slate-400 font-extrabold uppercase tracking-wider text-[10px]">
                        <th className="pb-3 px-4">User Details</th>
                        <th className="pb-3 px-4">Role</th>
                        <th className="pb-3 px-4">Wallet Balance</th>
                        <th className="pb-3 px-4">Status</th>
                        <th className="pb-3 px-4 text-right">Actions</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-100">
                      {filteredUsers.length > 0 ? (
                        filteredUsers.map((u) => (
                          <tr key={u.id} className="hover:bg-slate-50/70 transition-all">
                            <td className="py-4 px-4">
                              <div className="flex items-center gap-3.5">
                                <AvatarImage
                                  src={u.avatarUrl}
                                  alt={u.name}
                                  className="w-11 h-11 rounded-full object-cover ring-2 ring-slate-100 shadow-sm"
                                />
                                <div>
                                  <p className="font-black text-slate-900 text-sm">{u.name}</p>
                                  <p className="text-[11px] text-slate-400 font-mono">ID: {u.id.substring(0, 8)}...</p>
                                  <p className="text-[11px] text-slate-500">{u.phone || u.email || 'No contact provided'}</p>
                                </div>
                              </div>
                            </td>
                            <td className="py-4 px-4">
                              <span
                                className={`text-[11px] font-black px-2.5 py-0.5 rounded-md ${
                                  u.isCreator
                                    ? 'bg-amber-50 text-amber-800 border border-amber-200'
                                    : 'bg-slate-100 text-slate-700'
                                }`}
                              >
                                {u.isCreator ? 'CREATOR' : 'USER'}
                              </span>
                            </td>
                            <td className="py-4 px-4 font-black text-slate-900 text-sm">
                              {u.walletBalance} Diamonds
                            </td>
                            <td className="py-4 px-4">
                              <span
                                className={`text-[11px] font-bold px-2.5 py-0.5 rounded-full ${
                                  u.isActive ? 'bg-emerald-100 text-emerald-800' : 'bg-rose-100 text-rose-800'
                                }`}
                              >
                                {u.isActive ? 'Active' : 'Blocked'}
                              </span>
                            </td>
                            <td className="py-4 px-4 text-right">
                              <div className="flex items-center justify-end gap-2">
                                <button
                                  onClick={() => handleToggleUserBlock(u.id)}
                                  className={`px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all ${
                                    u.isActive
                                      ? 'bg-rose-50 text-rose-600 hover:bg-rose-100'
                                      : 'bg-emerald-50 text-emerald-600 hover:bg-emerald-100'
                                  }`}
                                >
                                  {u.isActive ? 'Block User' : 'Unblock User'}
                                </button>
                                <button
                                  onClick={() => setDeletingUser({ id: u.id, name: u.name })}
                                  title="Permanently Delete Account from DB"
                                  className="p-1.5 rounded-xl text-slate-400 hover:text-rose-600 hover:bg-rose-50 border border-transparent hover:border-rose-100 transition-all"
                                >
                                  <Trash2 className="w-4 h-4" />
                                </button>
                              </div>
                            </td>
                          </tr>
                        ))
                      ) : (
                        <tr>
                          <td colSpan={5} className="py-12 text-center text-slate-400 font-semibold">
                            No users found matching your search.
                          </td>
                        </tr>
                      )}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          )}

          {/* VIEW 3: CREATORS MANAGEMENT (KYC Queue, Directory, Direct Onboard) */}
          {activeMenu === 'creators' && (
            <div className="space-y-6 max-w-7xl mx-auto">
              <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
                <div>
                  <h3 className="text-2xl font-black text-slate-900">Creator Management</h3>
                  <p className="text-xs font-semibold text-slate-400">Review incoming KYC applications and manage live creators</p>
                </div>

                <div className="flex bg-white p-1 rounded-2xl border border-slate-200 text-xs font-extrabold shadow-sm">
                  <button
                    onClick={() => setCreatorSubTab('pending')}
                    className={`px-4 py-2 rounded-xl transition-all flex items-center gap-2 ${
                      creatorSubTab === 'pending' ? 'bg-black text-white shadow-sm' : 'text-slate-500 hover:text-black'
                    }`}
                  >
                    <span>Verification Queue</span>
                    {pendingApps.length > 0 && (
                      <span className="bg-rose-500 text-white text-[10px] px-1.5 py-0.2 rounded-full">
                        {pendingApps.length}
                      </span>
                    )}
                  </button>
                  <button
                    onClick={() => setCreatorSubTab('directory')}
                    className={`px-4 py-2 rounded-xl transition-all ${
                      creatorSubTab === 'directory' ? 'bg-black text-white shadow-sm' : 'text-slate-500 hover:text-black'
                    }`}
                  >
                    Live Creators ({creatorsList.length})
                  </button>
                  <button
                    onClick={() => setCreatorSubTab('add')}
                    className={`px-4 py-2 rounded-xl transition-all flex items-center gap-1.5 ${
                      creatorSubTab === 'add' ? 'bg-black text-white shadow-sm' : 'text-slate-500 hover:text-black'
                    }`}
                  >
                    <Plus className="w-3.5 h-3.5" />
                    <span>Direct Onboard</span>
                  </button>
                </div>
              </div>

              {/* Sub-tab 1: Pending Verification Queue */}
              {creatorSubTab === 'pending' && (
                <div className="space-y-4">
                  {pendingApps.length > 0 ? (
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                      {pendingApps.map((app) => (
                        <div
                          key={app.id}
                          className="bg-white rounded-3xl p-6 border border-slate-200/80 shadow-sm space-y-4"
                        >
                          <div className="flex items-start gap-4">
                            <AvatarImage
                              src={app.photoUrl}
                              alt={app.legalName}
                              className="w-16 h-16 rounded-2xl object-cover ring-2 ring-slate-100 shadow-md"
                            />
                            <div className="flex-1">
                              <h4 className="text-base font-black text-slate-900">{app.legalName}</h4>
                              <p className="text-xs font-bold text-slate-500">{app.profession}</p>
                              <div className="flex flex-wrap gap-2 mt-2">
                                <span className="bg-indigo-50 text-indigo-700 text-[10px] font-black px-2 py-0.5 rounded-md">
                                  {app.subscriptionPlan}
                                </span>
                                <span className="bg-slate-100 text-slate-600 text-[10px] font-bold px-2 py-0.5 rounded-md">
                                  Age: {app.age}
                                </span>
                                <span className="bg-emerald-50 text-emerald-700 text-[10px] font-bold px-2 py-0.5 rounded-md">
                                  UPI: {app.payoutUpiId || 'Not set'}
                                </span>
                              </div>
                            </div>
                          </div>

                          <div className="bg-slate-50 p-3.5 rounded-2xl border border-slate-200/60 text-xs space-y-1.5">
                            <p className="text-slate-500">
                              <span className="font-bold text-slate-700">Bio:</span> {app.bio || 'No bio provided'}
                            </p>
                            <p className="text-slate-500">
                              <span className="font-bold text-slate-700">Govt ID:</span> {app.govtIdType} (Verified in form)
                            </p>
                            <p className="text-slate-500">
                              <span className="font-bold text-slate-700">Requested Rate:</span> {app.videoCallPrice} Coins/min
                            </p>
                          </div>

                          <div className="flex items-center gap-3 pt-2">
                            <button
                              onClick={() => handleApproveCreator(app.id)}
                              className="flex-1 bg-black hover:bg-slate-800 text-white font-black text-xs py-2.5 px-4 rounded-xl transition-all shadow-md flex items-center justify-center gap-2"
                            >
                              <Check className="w-4 h-4 text-emerald-400" />
                              <span>Approve & Publish Live</span>
                            </button>
                            <button
                              onClick={() => {
                                setRejectingAppId(app.id);
                                setSelectedKycApp(app);
                              }}
                              className="bg-rose-50 hover:bg-rose-100 text-rose-600 font-black text-xs py-2.5 px-4 rounded-xl transition-all"
                            >
                              Reject
                            </button>
                          </div>
                        </div>
                      ))}
                    </div>
                  ) : (
                    <div className="bg-white rounded-3xl p-12 text-center border border-slate-200/80 shadow-sm max-w-lg mx-auto">
                      <CheckCircle2 className="w-12 h-12 text-emerald-500 mx-auto mb-3" />
                      <h4 className="text-base font-black text-slate-900">Zero Pending Applications</h4>
                      <p className="text-xs font-semibold text-slate-400 mt-1">
                        All creator requests have been verified. When new users tap "Become a Creator" in the app, their requests will appear here instantly!
                      </p>
                    </div>
                  )}
                </div>
              )}

              {/* Sub-tab 2: Live Creators Directory */}
              {creatorSubTab === 'directory' && (
                <div className="bg-white rounded-3xl p-6 border border-slate-200/80 shadow-sm">
                  <div className="overflow-x-auto">
                    <table className="w-full text-left text-xs">
                      <thead>
                        <tr className="border-b border-slate-100 text-slate-400 font-extrabold uppercase tracking-wider text-[10px]">
                          <th className="pb-3 px-4">Creator Profile</th>
                          <th className="pb-3 px-4">Rates</th>
                          <th className="pb-3 px-4">Online Status</th>
                          <th className="pb-3 px-4">Home Feed</th>
                          <th className="pb-3 px-4 text-right">Actions</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-slate-100">
                        {creatorsList.map((c) => (
                          <tr key={c.id} className="hover:bg-slate-50/70 transition-all">
                            <td className="py-4 px-4">
                              <div className="flex items-center gap-3.5">
                                <AvatarImage
                                  src={c.photoUrl}
                                  alt={c.name}
                                  className="w-12 h-12 rounded-full object-cover ring-2 ring-slate-100 shadow-sm"
                                />
                                <div>
                                  <p className="font-black text-slate-900 text-sm">{c.name}</p>
                                  <p className="text-[11px] text-slate-500">{c.profession} • Age {c.age}</p>
                                  <p className="text-[11px] text-slate-400">{c.phone || c.email}</p>
                                </div>
                              </div>
                            </td>
                            <td className="py-4 px-4">
                              <p className="font-extrabold text-slate-900">{c.videoCallPrice} Coins/min (Video)</p>
                              <p className="text-[11px] text-slate-400">{c.voiceCallPrice} Coins/min (Voice)</p>
                            </td>
                            <td className="py-4 px-4">
                              <span
                                className={`text-[10px] font-black px-2.5 py-0.5 rounded-full ${
                                  c.isOnline ? 'bg-emerald-100 text-emerald-800' : 'bg-slate-100 text-slate-600'
                                }`}
                              >
                                {c.isOnline ? 'Online' : 'Offline'}
                              </span>
                            </td>
                            <td className="py-4 px-4">
                              <span
                                className={`text-[10px] font-black px-2.5 py-0.5 rounded-full ${
                                  c.isActive ? 'bg-indigo-100 text-indigo-800' : 'bg-rose-100 text-rose-800'
                                }`}
                              >
                                {c.isActive ? 'Visible on Feed' : 'Hidden'}
                              </span>
                            </td>
                            <td className="py-4 px-4 text-right space-x-2">
                              <button
                                onClick={() => handleToggleCreatorActive(c.id, c.isActive)}
                                className={`px-3 py-1 rounded-xl text-xs font-bold transition-all ${
                                  c.isActive ? 'bg-slate-100 text-slate-700 hover:bg-slate-200' : 'bg-emerald-50 text-emerald-700'
                                }`}
                              >
                                {c.isActive ? 'Hide' : 'Show Live'}
                              </button>
                              <button
                                onClick={() => setDeletingUser({ id: c.userId, name: c.name })}
                                title="Permanently Delete Creator & Account from DB"
                                className="p-1.5 rounded-xl text-slate-400 hover:text-rose-600 hover:bg-rose-50 border border-transparent hover:border-rose-100 transition-all inline-flex items-center"
                              >
                                <Trash2 className="w-3.5 h-3.5" />
                              </button>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}

              {/* Sub-tab 3: Direct Onboard Form */}
              {creatorSubTab === 'add' && (
                <div className="bg-white rounded-3xl p-8 border border-slate-200/80 shadow-sm max-w-2xl mx-auto">
                  <h4 className="text-lg font-black text-slate-900 mb-1">Directly Add New Creator</h4>
                  <p className="text-xs text-slate-400 mb-6">Create an official verified creator profile without KYC wait</p>

                  <form onSubmit={handleDirectCreate} className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <label className="text-xs font-bold text-slate-700 mb-1 block">Full Name</label>
                        <input
                          type="text"
                          required
                          value={newCreatorForm.name}
                          onChange={(e) => setNewCreatorForm({ ...newCreatorForm, name: e.target.value })}
                          className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2 text-xs font-bold text-slate-800"
                        />
                      </div>
                      <div>
                        <label className="text-xs font-bold text-slate-700 mb-1 block">Age</label>
                        <input
                          type="number"
                          value={newCreatorForm.age}
                          onChange={(e) => setNewCreatorForm({ ...newCreatorForm, age: Number(e.target.value) })}
                          className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2 text-xs font-bold text-slate-800"
                        />
                      </div>
                    </div>

                    <div>
                      <label className="text-xs font-bold text-slate-700 mb-1 block">Profession / Category</label>
                      <input
                        type="text"
                        required
                        value={newCreatorForm.profession}
                        onChange={(e) => setNewCreatorForm({ ...newCreatorForm, profession: e.target.value })}
                        className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2 text-xs font-bold text-slate-800"
                      />
                    </div>

                    <div>
                      <label className="text-xs font-bold text-slate-700 mb-1 block">Profile Picture URL</label>
                      <input
                        type="url"
                        placeholder="https://..."
                        value={newCreatorForm.photoUrl}
                        onChange={(e) => setNewCreatorForm({ ...newCreatorForm, photoUrl: e.target.value })}
                        className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2 text-xs font-bold text-slate-800"
                      />
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <label className="text-xs font-bold text-slate-700 mb-1 block">Video Call Price (Coins/min)</label>
                        <input
                          type="number"
                          value={newCreatorForm.videoCallPrice}
                          onChange={(e) => setNewCreatorForm({ ...newCreatorForm, videoCallPrice: Number(e.target.value) })}
                          className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2 text-xs font-bold text-slate-800"
                        />
                      </div>
                      <div>
                        <label className="text-xs font-bold text-slate-700 mb-1 block">Voice Call Price (Coins/min)</label>
                        <input
                          type="number"
                          value={newCreatorForm.voiceCallPrice}
                          onChange={(e) => setNewCreatorForm({ ...newCreatorForm, voiceCallPrice: Number(e.target.value) })}
                          className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2 text-xs font-bold text-slate-800"
                        />
                      </div>
                    </div>

                    <button
                      type="submit"
                      className="w-full bg-black hover:bg-slate-800 text-white font-black text-xs py-3 rounded-xl transition-all mt-4"
                    >
                      Publish Creator to Mobile App Home Feed
                    </button>
                  </form>
                </div>
              )}
            </div>
          )}

          {/* VIEW 4: STORE & WALLET */}
          {activeMenu === 'wallet' && (
            <div className="space-y-6 max-w-7xl mx-auto">
              <div>
                <h3 className="text-2xl font-black text-slate-900">Wallet & Diamonds Store</h3>
                <p className="text-xs font-semibold text-slate-400">Manage virtual coin packages, user purchases, and wallet controls</p>
              </div>

              {/* Diamond Packages Row */}
              <div className="bg-white rounded-3xl p-6 border border-slate-200/80 shadow-sm">
                <h4 className="text-base font-black text-slate-900 mb-4">Official Diamond Coin Packages</h4>
                <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-4">
                  {[
                    { diamonds: 200, inr: 100 },
                    { diamonds: 300, inr: 150 },
                    { diamonds: 500, inr: 250 },
                    { diamonds: 800, inr: 400 },
                    { diamonds: 1000, inr: 500 },
                    { diamonds: 2000, inr: 1000 },
                  ].map((pkg) => (
                    <div key={pkg.diamonds} className="p-4 rounded-2xl border border-slate-200 bg-slate-50 text-center">
                      <Coins className="w-6 h-6 text-amber-500 mx-auto mb-1.5" />
                      <p className="font-black text-slate-900 text-base">{pkg.diamonds}</p>
                      <p className="text-[11px] text-slate-400 font-bold">Diamonds</p>
                      <p className="text-xs font-black text-indigo-600 mt-2">₹{pkg.inr}</p>
                    </div>
                  ))}
                </div>
              </div>

              {/* Transactions Ledger */}
              <div className="bg-white rounded-3xl p-6 border border-slate-200/80 shadow-sm">
                <h4 className="text-base font-black text-slate-900 mb-4">Recent Wallet Transactions</h4>
                <div className="overflow-x-auto">
                  <table className="w-full text-left text-xs">
                    <thead>
                      <tr className="border-b border-slate-100 text-slate-400 font-extrabold uppercase tracking-wider text-[10px]">
                        <th className="pb-3 px-4">User</th>
                        <th className="pb-3 px-4">Amount</th>
                        <th className="pb-3 px-4">Type</th>
                        <th className="pb-3 px-4">Status</th>
                        <th className="pb-3 px-4 text-right">Date</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-100">
                      {allTxns.length > 0 ? (
                        allTxns.slice(0, 10).map((t) => (
                          <tr key={t.id} className="hover:bg-slate-50/70 transition-all">
                            <td className="py-3 px-4">
                              <p className="font-bold text-slate-900">{t.userName || 'Customer'}</p>
                              <p className="text-[10px] text-slate-400 font-mono">TXN: {t.id.substring(0, 8)}</p>
                            </td>
                            <td className="py-3 px-4 font-black text-slate-900">
                              {t.coins} Diamonds (₹{t.amountInr})
                            </td>
                            <td className="py-3 px-4">
                              <span className="bg-slate-100 text-slate-700 text-[10px] font-bold px-2 py-0.5 rounded-md">
                                {t.type}
                              </span>
                            </td>
                            <td className="py-3 px-4">
                              <span className="bg-emerald-100 text-emerald-800 text-[10px] font-bold px-2 py-0.5 rounded-full">
                                {t.status}
                              </span>
                            </td>
                            <td className="py-3 px-4 text-right text-[11px] text-slate-400">
                              {new Date(t.createdAt).toLocaleDateString()}
                            </td>
                          </tr>
                        ))
                      ) : (
                        <tr>
                          <td colSpan={5} className="py-8 text-center text-slate-400 font-semibold">
                            No wallet transactions yet.
                          </td>
                        </tr>
                      )}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          )}

          {/* VIEW 5: LIVE CALLS */}
          {activeMenu === 'calls' && (
            <div className="space-y-6 max-w-7xl mx-auto">
              <div>
                <h3 className="text-2xl font-black text-slate-900">Live & Completed Calls</h3>
                <p className="text-xs font-semibold text-slate-400">Agora video connection sessions and coin deductions</p>
              </div>

              <div className="bg-white rounded-3xl p-6 border border-slate-200/80 shadow-sm">
                <div className="overflow-x-auto">
                  <table className="w-full text-left text-xs">
                    <thead>
                      <tr className="border-b border-slate-100 text-slate-400 font-extrabold uppercase tracking-wider text-[10px]">
                        <th className="pb-3 px-4">Caller</th>
                        <th className="pb-3 px-4">Creator</th>
                        <th className="pb-3 px-4">Type</th>
                        <th className="pb-3 px-4">Duration</th>
                        <th className="pb-3 px-4">Coins Deducted</th>
                        <th className="pb-3 px-4 text-right">Status</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-100">
                      {allCalls.length > 0 ? (
                        allCalls.map((c) => (
                          <tr key={c.id} className="hover:bg-slate-50/70 transition-all">
                            <td className="py-3.5 px-4 font-bold text-slate-900">{c.callerName}</td>
                            <td className="py-3.5 px-4 font-bold text-indigo-600">{c.creatorName}</td>
                            <td className="py-3.5 px-4 font-semibold text-slate-600">{c.callType}</td>
                            <td className="py-3.5 px-4 font-mono text-slate-600">{c.durationFormatted}</td>
                            <td className="py-3.5 px-4 font-black text-slate-900">{c.coins} Diamonds</td>
                            <td className="py-3.5 px-4 text-right">
                              <span className="bg-emerald-100 text-emerald-800 text-[10px] font-bold px-2 py-0.5 rounded-full">
                                {c.status}
                              </span>
                            </td>
                          </tr>
                        ))
                      ) : (
                        <tr>
                          <td colSpan={6} className="py-8 text-center text-slate-400 font-semibold">
                            No call sessions recorded yet.
                          </td>
                        </tr>
                      )}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          )}

          {/* VIEW 6: APP SETTINGS */}
          {activeMenu === 'settings' && (
            <div className="space-y-6 max-w-4xl mx-auto">
              <div>
                <h3 className="text-2xl font-black text-slate-900">App & Wallet Controls</h3>
                <p className="text-xs font-semibold text-slate-400">Global configurations requested by administrator</p>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {/* Setting A: Freeze Balance */}
                <div className="bg-white rounded-3xl p-6 border border-slate-200/80 shadow-sm flex flex-col justify-between">
                  <div>
                    <div className="flex items-center gap-3 mb-3">
                      <div className="w-10 h-10 rounded-2xl bg-amber-50 text-amber-600 flex items-center justify-center">
                        <Lock className="w-5 h-5" />
                      </div>
                      <div>
                        <h4 className="text-sm font-black text-slate-900">A. Freeze Balance</h4>
                        <p className="text-[11px] text-slate-400">Restrict wallet balance usage</p>
                      </div>
                    </div>
                    <p className="text-xs text-slate-500 leading-relaxed">
                      When enabled, user wallet balances are frozen and cannot be spent on calls or gifts according to safety rules.
                    </p>
                  </div>

                  <div className="mt-6 flex items-center justify-between pt-4 border-t border-slate-100">
                    <span className="text-xs font-bold text-slate-600">
                      Current: {settings.isFreezeBalance ? 'Frozen' : 'Allowed'}
                    </span>
                    <button
                      onClick={() => handleUpdateSettings({ isFreezeBalance: !settings.isFreezeBalance })}
                      className={`px-4 py-2 rounded-xl text-xs font-black transition-all ${
                        settings.isFreezeBalance
                          ? 'bg-rose-600 text-white'
                          : 'bg-black text-white hover:bg-slate-800'
                      }`}
                    >
                      {settings.isFreezeBalance ? 'Disable Freeze' : 'Enable Freeze'}
                    </button>
                  </div>
                </div>

                {/* Setting B: Video Connection Control */}
                <div className="bg-white rounded-3xl p-6 border border-slate-200/80 shadow-sm flex flex-col justify-between">
                  <div>
                    <div className="flex items-center gap-3 mb-3">
                      <div className="w-10 h-10 rounded-2xl bg-indigo-50 text-indigo-600 flex items-center justify-center">
                        <Video className="w-5 h-5" />
                      </div>
                      <div>
                        <h4 className="text-sm font-black text-slate-900">B. Video Connection Control</h4>
                        <p className="text-[11px] text-slate-400">Enable / Disable video calls</p>
                      </div>
                    </div>
                    <p className="text-xs text-slate-500 leading-relaxed">
                      When enabled, users can initiate Agora video sessions. When disabled, new video connections are temporarily blocked.
                    </p>
                  </div>

                  <div className="mt-6 flex items-center justify-between pt-4 border-t border-slate-100">
                    <span className="text-xs font-bold text-slate-600">
                      Current: {settings.isVideoConnectionEnabled ? 'Enabled' : 'Disabled'}
                    </span>
                    <button
                      onClick={() => handleUpdateSettings({ isVideoConnectionEnabled: !settings.isVideoConnectionEnabled })}
                      className={`px-4 py-2 rounded-xl text-xs font-black transition-all ${
                        settings.isVideoConnectionEnabled
                          ? 'bg-emerald-600 text-white'
                          : 'bg-black text-white hover:bg-slate-800'
                      }`}
                    >
                      {settings.isVideoConnectionEnabled ? 'Turn OFF' : 'Turn ON'}
                    </button>
                  </div>
                </div>
              </div>

              {/* Setting C: Payment Account Configuration */}
              <div className="bg-white rounded-3xl p-6 border border-slate-200/80 shadow-sm">
                <div className="flex items-center gap-3 mb-4">
                  <div className="w-10 h-10 rounded-2xl bg-emerald-50 text-emerald-600 flex items-center justify-center">
                    <CreditCard className="w-5 h-5" />
                  </div>
                  <div>
                    <h4 className="text-sm font-black text-slate-900">C. Payment Account Configuration</h4>
                    <p className="text-[11px] text-slate-400">Configure administrator UPI ID for creator subscriptions & coin recharges</p>
                  </div>
                </div>

                <div className="max-w-md space-y-3">
                  <label className="text-xs font-bold text-slate-700 block">Administrator UPI ID</label>
                  <div className="flex items-center gap-3">
                    <input
                      type="text"
                      value={upiInput}
                      onChange={(e) => setUpiInput(e.target.value)}
                      placeholder="e.g. XYX12438383@ybl"
                      className="flex-1 bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-xs font-bold text-slate-900 focus:outline-none focus:ring-2 focus:ring-black"
                    />
                    <button
                      onClick={() => handleUpdateSettings({ paymentUpiId: upiInput })}
                      className="bg-black hover:bg-slate-800 text-white font-black text-xs px-5 py-2.5 rounded-xl transition-all"
                    >
                      Save UPI
                    </button>
                  </div>
                  <p className="text-[11px] text-slate-400">
                    Payment configuration is securely stored in PostgreSQL and used for automated in-app payment confirmation.
                  </p>
                </div>
              </div>
            </div>
          )}
        </main>
      </div>

      {/* Reject Modal */}
      {rejectingAppId && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl p-6 max-w-md w-full shadow-2xl space-y-4">
            <h4 className="text-base font-black text-slate-900">Reject Creator Application</h4>
            <p className="text-xs text-slate-500">
              Provide feedback reason to the applicant. They can update and re-submit.
            </p>
            <textarea
              rows={3}
              value={rejectionReason}
              onChange={(e) => setRejectionReason(e.target.value)}
              placeholder="e.g. Please provide a clear profile photo..."
              className="w-full bg-slate-50 border border-slate-200 rounded-2xl p-3 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-black"
            />
            <div className="flex items-center justify-end gap-3 pt-2">
              <button
                onClick={() => setRejectingAppId(null)}
                className="px-4 py-2 rounded-xl text-xs font-bold text-slate-600 hover:bg-slate-100"
              >
                Cancel
              </button>
              <button
                onClick={handleRejectCreator}
                className="px-4 py-2 rounded-xl text-xs font-black bg-rose-600 text-white hover:bg-rose-700"
              >
                Confirm Rejection
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Permanent Account Deletion Modal */}
      {deletingUser && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl p-6 max-w-md w-full shadow-2xl space-y-4 border border-slate-100 animate-slide-up">
            <div className="w-12 h-12 rounded-2xl bg-rose-50 border border-rose-200 text-rose-600 flex items-center justify-center">
              <AlertTriangle className="w-6 h-6 text-rose-600" />
            </div>
            <div>
              <h4 className="text-base font-black text-slate-900">Permanently Delete Account?</h4>
              <p className="text-xs text-slate-500 mt-1 leading-relaxed">
                Are you sure you want to permanently delete <strong className="text-slate-900">{deletingUser.name}</strong>?
                This will <span className="font-bold text-rose-600">completely purge</span> the user profile, wallet ledger, call sessions, messages, and creator application from PostgreSQL and the platform.
              </p>
            </div>
            <div className="bg-rose-50 p-3 rounded-2xl border border-rose-200/70 text-[11px] font-bold text-rose-700">
              ⚠️ This action is irreversible. All data in PostgreSQL will be erased immediately.
            </div>
            <div className="flex items-center justify-end gap-3 pt-2">
              <button
                disabled={isDeleting}
                onClick={() => setDeletingUser(null)}
                className="px-4 py-2 rounded-xl text-xs font-bold text-slate-600 hover:bg-slate-100"
              >
                Cancel
              </button>
              <button
                disabled={isDeleting}
                onClick={handleConfirmDelete}
                className="px-5 py-2.5 rounded-xl text-xs font-black bg-rose-600 text-white hover:bg-rose-700 shadow-md shadow-rose-600/20 flex items-center gap-1.5"
              >
                {isDeleting ? (
                  <RefreshCw className="w-3.5 h-3.5 animate-spin" />
                ) : (
                  <Trash2 className="w-3.5 h-3.5" />
                )}
                <span>Permanent Delete</span>
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// ---------------------------------------------------------------------------
// Purely Pill-Shaped Sidebar Nav Item
// ---------------------------------------------------------------------------
function SidebarPill({
  icon,
  label,
  sublabel,
  active,
  badge,
  badgeColor = 'bg-[#84CC16]',
  onClick,
}: {
  icon: React.ReactNode;
  label: string;
  sublabel?: string;
  active: boolean;
  badge?: number | string;
  badgeColor?: string;
  onClick: () => void;
}) {
  return (
    <button
      onClick={onClick}
      className={`w-full flex items-center justify-between px-4 py-3 rounded-2xl font-extrabold text-xs transition-all duration-200 ${
        active
          ? 'bg-black text-white shadow-lg shadow-black/10'
          : 'text-slate-500 hover:text-black hover:bg-slate-100'
      }`}
    >
      <div className="flex items-center gap-3">
        <span className={active ? 'text-white' : 'text-slate-400'}>{icon}</span>
        <span>{label}</span>
      </div>

      {badge !== undefined && (
        <span
          className={`text-[10px] font-black px-2 py-0.5 rounded-full ${
            active ? 'bg-white/20 text-white' : `${badgeColor} text-white`
          }`}
        >
          {badge}
        </span>
      )}
    </button>
  );
}

// ---------------------------------------------------------------------------
// Bulletproof Avatar Image Component (With Initial Gradient Fallback)
// ---------------------------------------------------------------------------
function AvatarImage({
  src,
  alt,
  className = 'w-10 h-10 rounded-full object-cover',
}: {
  src?: string | null;
  alt: string;
  className?: string;
}) {
  const [hasError, setHasError] = useState(false);

  useEffect(() => {
    setHasError(false);
  }, [src]);

  let cleanUrl = '';
  if (src && typeof src === 'string' && src.trim().length > 0) {
    const s = src.trim();
    if (!s.startsWith('/data/') && !s.startsWith('file:') && !s.startsWith('content:')) {
      if (s.includes('/uploads/')) {
        cleanUrl = '/uploads/' + s.split('/uploads/')[1];
      } else {
        cleanUrl = s;
      }
    }
  }

  if (!cleanUrl || hasError) {
    const initial = (alt && alt.trim().length > 0 ? alt.trim()[0] : 'U').toUpperCase();
    return (
      <div
        className={`${className} bg-gradient-to-tr from-slate-900 to-indigo-700 text-white font-black text-sm flex items-center justify-center ring-2 ring-slate-100 shadow-sm shrink-0 select-none`}
      >
        {initial}
      </div>
    );
  }

  return (
    <img
      src={cleanUrl}
      alt={alt}
      onError={() => setHasError(true)}
      className={`${className} shrink-0`}
    />
  );
}
