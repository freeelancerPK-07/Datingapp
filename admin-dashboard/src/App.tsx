import React, { useState, useEffect } from 'react';
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
  Filter,
  DollarSign,
  ChevronRight,
  Calendar,
  Phone,
  Mail,
  Award,
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
    'dashboard' | 'users' | 'creators' | 'wallet' | 'transactions' | 'calls' | 'settings'
  >('dashboard');

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

  // Direct Onboard Form
  const [newCreatorForm, setNewCreatorForm] = useState({
    name: '',
    age: 23,
    profession: 'Lifestyle & Dating Consultant',
    photoUrl: '',
    videoCallPrice: 500,
    voiceCallPrice: 300,
    bio: 'Verified consultation expert on LinkUp.',
    email: '',
    phone: '',
    isActive: true,
    isFeatured: true,
  });

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 4000);
  };

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
        showToast(data.error || 'Failed to onboard creator');
      }
    } catch (e) {
      showToast('Error onboarding creator');
    }
  };

  // Filtered Users
  const filteredUsers = usersList.filter((u) => {
    const q = userSearchQuery.toLowerCase();
    const matchesQ =
      u.name.toLowerCase().includes(q) ||
      u.email.toLowerCase().includes(q) ||
      u.phone.toLowerCase().includes(q);
    if (!matchesQ) return false;
    if (userRoleFilter === 'CREATORS_ONLY' && !u.isCreator) return false;
    if (userRoleFilter === 'ACTIVE_ONLY' && !u.isActive) return false;
    if (userRoleFilter === 'BLOCKED_ONLY' && u.isActive) return false;
    return true;
  });

  return (
    <div className="flex h-screen bg-[#F8FAFC] text-slate-800 font-sans antialiased overflow-hidden">
      {/* Toast Notification */}
      {toastMessage && (
        <div className="fixed top-5 right-5 z-50 flex items-center gap-3 bg-slate-900 text-white px-5 py-3 rounded-xl shadow-2xl border border-slate-700 animate-slide-in">
          <CheckCircle2 className="w-5 h-5 text-emerald-400" />
          <span className="text-sm font-semibold">{toastMessage}</span>
        </div>
      )}

      {/* =========================================================================
          LEFT SIDEBAR (Dark Slate Theme #111827)
          ========================================================================= */}
      <aside className="w-64 bg-[#111827] text-slate-300 flex flex-col border-r border-slate-800 shrink-0">
        {/* Brand Header */}
        <div className="p-6 border-b border-slate-800 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-indigo-500 to-indigo-600 flex items-center justify-center text-white font-black text-xl shadow-lg shadow-indigo-500/20">
              L
            </div>
            <div>
              <h1 className="font-extrabold text-white text-base tracking-tight leading-none">LinkUp</h1>
              <p className="text-[11px] text-slate-400 font-medium mt-1">Admin Console</p>
            </div>
          </div>
          <div
            className={`w-2.5 h-2.5 rounded-full ${apiConnected ? 'bg-emerald-400 shadow-[0_0_8px_#34D399]' : 'bg-rose-500'}`}
            title={apiConnected ? 'Backend Connected' : 'Disconnected'}
          />
        </div>

        {/* Navigation Menu */}
        <div className="flex-1 overflow-y-auto px-3 py-4 space-y-6">
          <div>
            <p className="px-3 text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-2">Main Menu</p>
            <nav className="space-y-1">
              <SidebarItem
                icon={<LayoutDashboard className="w-4 h-4" />}
                label="Dashboard Overview"
                active={activeMenu === 'dashboard'}
                onClick={() => setActiveMenu('dashboard')}
              />
              <SidebarItem
                icon={<Users className="w-4 h-4" />}
                label="User Management"
                badge={stats.totalUsers ? stats.totalUsers.toString() : undefined}
                active={activeMenu === 'users'}
                onClick={() => setActiveMenu('users')}
              />
              <SidebarItem
                icon={<Sparkles className="w-4 h-4" />}
                label="Creator Management"
                badge={pendingApps.length > 0 ? `${pendingApps.length} New` : undefined}
                badgeColor="bg-amber-500/20 text-amber-300"
                active={activeMenu === 'creators'}
                onClick={() => setActiveMenu('creators')}
              />
              <SidebarItem
                icon={<Coins className="w-4 h-4" />}
                label="Wallet & Diamonds"
                active={activeMenu === 'wallet'}
                onClick={() => setActiveMenu('wallet')}
              />
              <SidebarItem
                icon={<CreditCard className="w-4 h-4" />}
                label="Payments & Transactions"
                active={activeMenu === 'transactions'}
                onClick={() => setActiveMenu('transactions')}
              />
              <SidebarItem
                icon={<Video className="w-4 h-4" />}
                label="Live Calls & Sessions"
                active={activeMenu === 'calls'}
                onClick={() => setActiveMenu('calls')}
              />
            </nav>
          </div>

          <div>
            <p className="px-3 text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-2">Configuration</p>
            <nav className="space-y-1">
              <SidebarItem
                icon={<Settings className="w-4 h-4" />}
                label="App Settings"
                active={activeMenu === 'settings'}
                onClick={() => setActiveMenu('settings')}
              />
            </nav>
          </div>
        </div>

        {/* Footer Admin Profile */}
        <div className="p-4 border-t border-slate-800 bg-[#0B0F19] flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-full bg-indigo-600/30 border border-indigo-500/40 flex items-center justify-center font-bold text-indigo-300 text-sm">
              AD
            </div>
            <div className="overflow-hidden">
              <p className="text-xs font-bold text-white truncate">Super Admin</p>
              <p className="text-[10px] text-slate-400 truncate">admin@linkup.com</p>
            </div>
          </div>
        </div>
      </aside>

      {/* =========================================================================
          MAIN CONTENT AREA
          ========================================================================= */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Top Header Bar */}
        <header className="h-16 bg-white border-b border-slate-200 px-8 flex items-center justify-between shrink-0">
          <div>
            <h2 className="text-lg font-extrabold text-slate-900 leading-none">
              {activeMenu === 'dashboard' && 'Dashboard Overview'}
              {activeMenu === 'users' && 'User Management'}
              {activeMenu === 'creators' && 'Creator Management & Verification'}
              {activeMenu === 'wallet' && 'Wallet & Diamond Packages'}
              {activeMenu === 'transactions' && 'Payments & Transactions'}
              {activeMenu === 'calls' && 'Live Calls & History'}
              {activeMenu === 'settings' && 'Platform & App Settings'}
            </h2>
            <p className="text-xs text-slate-500 font-medium mt-1">Real-time production platform administration</p>
          </div>

          <div className="flex items-center gap-4">
            {/* Live Connection Tag */}
            <div className="flex items-center gap-2 px-3 py-1.5 rounded-full bg-slate-100 border border-slate-200 text-xs font-semibold">
              <span className={`w-2 h-2 rounded-full ${apiConnected ? 'bg-emerald-500 animate-pulse' : 'bg-rose-500'}`} />
              <span className="text-slate-600">{apiConnected ? 'API Connected (Port 5000)' : 'Backend Offline'}</span>
            </div>

            {/* Refresh Button */}
            <button
              onClick={loadDashboardData}
              disabled={loading}
              className="p-2 rounded-xl border border-slate-200 text-slate-600 hover:bg-slate-50 transition-colors"
              title="Refresh Data"
            >
              <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin text-indigo-600' : ''}`} />
            </button>

            {/* Notifications Bell */}
            <div className="relative p-2 rounded-xl border border-slate-200 text-slate-600">
              <Bell className="w-4 h-4" />
              {pendingApps.length > 0 && (
                <span className="absolute -top-1 -right-1 w-4 h-4 bg-rose-500 text-white rounded-full text-[10px] font-black flex items-center justify-center">
                  {pendingApps.length}
                </span>
              )}
            </div>
          </div>
        </header>

        {/* Scrollable View Container */}
        <main className="flex-1 overflow-y-auto p-8">
          {/* VIEW 1: DASHBOARD OVERVIEW */}
          {activeMenu === 'dashboard' && (
            <div className="space-y-8 max-w-7xl mx-auto">
              {/* Top 4 Primary Metric Cards */}
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
                <MetricCard
                  title="Total Registered Users"
                  value={stats.totalUsers.toLocaleString()}
                  subtext="Real DB user accounts"
                  change="+100%"
                  icon={<Users className="w-5 h-5 text-indigo-600" />}
                  iconBg="bg-indigo-50"
                />
                <MetricCard
                  title="Approved Creators"
                  value={stats.totalCreators.toLocaleString()}
                  subtext={`${stats.liveCreators} currently live`}
                  change={stats.liveCreators > 0 ? 'Live Now' : 'Idle'}
                  icon={<Sparkles className="w-5 h-5 text-amber-600" />}
                  iconBg="bg-amber-50"
                />
                <MetricCard
                  title="Diamonds Sold"
                  value={stats.totalDiamondsSold.toLocaleString()}
                  subtext="Purchased by users"
                  change="Wallet"
                  icon={<Coins className="w-5 h-5 text-emerald-600" />}
                  iconBg="bg-emerald-50"
                />
                <MetricCard
                  title="Total Revenue (INR)"
                  value={`₹${stats.totalRevenue.toLocaleString()}`}
                  subtext="Successful payments"
                  change="Razorpay"
                  icon={<DollarSign className="w-5 h-5 text-blue-600" />}
                  iconBg="bg-blue-50"
                />
              </div>

              {/* Secondary Metrics Row */}
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-5">
                <div className="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm flex items-center justify-between">
                  <div>
                    <p className="text-xs font-bold text-slate-500 uppercase tracking-wider">Total Video Calls</p>
                    <p className="text-2xl font-black text-slate-900 mt-1">{stats.totalCalls}</p>
                    <p className="text-[11px] text-slate-400 font-medium mt-0.5">{stats.completedCalls} completed sessions</p>
                  </div>
                  <div className="p-3 bg-purple-50 text-purple-600 rounded-xl">
                    <Video className="w-6 h-6" />
                  </div>
                </div>

                <div className="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm flex items-center justify-between">
                  <div>
                    <p className="text-xs font-bold text-slate-500 uppercase tracking-wider">Pending KYC Queue</p>
                    <p className="text-2xl font-black text-amber-600 mt-1">{pendingApps.length}</p>
                    <p className="text-[11px] text-slate-400 font-medium mt-0.5">Awaiting admin review</p>
                  </div>
                  <div className="p-3 bg-amber-50 text-amber-600 rounded-xl">
                    <Clock className="w-6 h-6" />
                  </div>
                </div>

                <div className="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm flex items-center justify-between">
                  <div>
                    <p className="text-xs font-bold text-slate-500 uppercase tracking-wider">Wallet Freeze Status</p>
                    <p className={`text-2xl font-black mt-1 ${settings.isFreezeBalance ? 'text-rose-600' : 'text-emerald-600'}`}>
                      {settings.isFreezeBalance ? 'Frozen' : 'Normal'}
                    </p>
                    <p className="text-[11px] text-slate-400 font-medium mt-0.5">
                      {settings.isFreezeBalance ? 'Diamond usage blocked' : 'Usage allowed'}
                    </p>
                  </div>
                  <div className={`p-3 rounded-xl ${settings.isFreezeBalance ? 'bg-rose-50 text-rose-600' : 'bg-emerald-50 text-emerald-600'}`}>
                    {settings.isFreezeBalance ? <Lock className="w-6 h-6" /> : <Unlock className="w-6 h-6" />}
                  </div>
                </div>
              </div>

              {/* Two Column Grid: Pending Queue on Left & Recent Activity on Right */}
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                {/* Pending Verification Requests Widget */}
                <div className="bg-white rounded-2xl border border-slate-200/80 shadow-sm p-6">
                  <div className="flex items-center justify-between mb-5">
                    <div className="flex items-center gap-2">
                      <div className="w-2.5 h-2.5 rounded-full bg-amber-500 animate-pulse" />
                      <h3 className="text-base font-extrabold text-slate-900">Creator Verification Requests</h3>
                    </div>
                    <span className="text-xs font-bold bg-amber-100 text-amber-800 px-2.5 py-1 rounded-full">
                      {pendingApps.length} Pending
                    </span>
                  </div>

                  {pendingApps.length === 0 ? (
                    <div className="py-12 text-center text-slate-400">
                      <CheckCircle2 className="w-10 h-10 mx-auto text-emerald-400 mb-2" />
                      <p className="text-sm font-bold text-slate-700">Verification Queue is Clean</p>
                      <p className="text-xs text-slate-400 mt-1">When users apply from mobile app, they appear here.</p>
                    </div>
                  ) : (
                    <div className="space-y-4">
                      {pendingApps.map((app) => (
                        <div
                          key={app.id}
                          className="p-4 rounded-xl border border-slate-200 hover:border-indigo-300 transition-all bg-slate-50/50 flex items-center justify-between"
                        >
                          <div className="flex items-center gap-3">
                            <div className="w-12 h-12 rounded-full overflow-hidden bg-slate-200 shrink-0">
                              {app.photoUrl ? (
                                <img src={app.photoUrl} alt="" className="w-full h-full object-cover" />
                              ) : (
                                <div className="w-full h-full bg-indigo-600 text-white font-bold flex items-center justify-center text-base">
                                  {app.legalName?.[0] || 'C'}
                                </div>
                              )}
                            </div>
                            <div>
                              <div className="flex items-center gap-2">
                                <p className="font-extrabold text-sm text-slate-900">{app.legalName}</p>
                                <span className="text-[10px] font-bold bg-emerald-100 text-emerald-800 px-2 py-0.5 rounded">
                                  ₹299 Paid
                                </span>
                              </div>
                              <p className="text-xs text-slate-500 font-medium">
                                {app.profession} • {app.age} yrs • {app.govtIdType}
                              </p>
                              <p className="text-[11px] text-indigo-600 font-semibold mt-0.5">UPI: {app.payoutUpiId || 'Not provided'}</p>
                            </div>
                          </div>

                          <div className="flex items-center gap-2">
                            <button
                              onClick={() => setSelectedKycApp(app)}
                              className="p-2 text-slate-600 hover:bg-slate-200 rounded-lg text-xs font-bold"
                              title="Inspect KYC"
                            >
                              <Eye className="w-4 h-4" />
                            </button>
                            <button
                              onClick={() => handleApproveCreator(app.id)}
                              className="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg text-xs font-bold flex items-center gap-1.5 shadow-sm shadow-emerald-600/20"
                            >
                              <Check className="w-3.5 h-3.5" /> Approve
                            </button>
                            <button
                              onClick={() => setRejectingAppId(app.id)}
                              className="px-2.5 py-1.5 bg-rose-50 text-rose-600 hover:bg-rose-100 rounded-lg text-xs font-bold"
                            >
                              <X className="w-3.5 h-3.5" />
                            </button>
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>

                {/* Recent Transactions Widget */}
                <div className="bg-white rounded-2xl border border-slate-200/80 shadow-sm p-6">
                  <div className="flex items-center justify-between mb-5">
                    <h3 className="text-base font-extrabold text-slate-900">Recent Transactions</h3>
                    <button
                      onClick={() => setActiveMenu('transactions')}
                      className="text-xs font-bold text-indigo-600 hover:text-indigo-800 flex items-center gap-1"
                    >
                      View All <ChevronRight className="w-3.5 h-3.5" />
                    </button>
                  </div>

                  {recentTxns.length === 0 ? (
                    <div className="py-12 text-center text-slate-400">
                      <CreditCard className="w-10 h-10 mx-auto text-slate-300 mb-2" />
                      <p className="text-sm font-bold text-slate-700">No Transactions Yet</p>
                      <p className="text-xs text-slate-400 mt-1">Live payments made on mobile will show up here.</p>
                    </div>
                  ) : (
                    <div className="divide-y divide-slate-100">
                      {recentTxns.map((t) => (
                        <div key={t.id} className="py-3 flex items-center justify-between">
                          <div className="flex items-center gap-3">
                            <div className="w-9 h-9 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center font-bold">
                              ₹
                            </div>
                            <div>
                              <p className="text-xs font-extrabold text-slate-900">{t.userName}</p>
                              <p className="text-[11px] text-slate-400">{t.description}</p>
                            </div>
                          </div>
                          <div className="text-right">
                            <p className="text-xs font-black text-slate-900">+₹{t.amountInr}</p>
                            <span className="text-[10px] font-bold text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded">
                              {t.status}
                            </span>
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              </div>
            </div>
          )}

          {/* VIEW 2: USERS MANAGEMENT */}
          {activeMenu === 'users' && (
            <div className="space-y-6 max-w-7xl mx-auto">
              <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
                {/* Search Bar */}
                <div className="relative w-full sm:w-96">
                  <Search className="w-4 h-4 absolute left-3 top-3 text-slate-400" />
                  <input
                    type="text"
                    placeholder="Search by name, phone or email..."
                    value={userSearchQuery}
                    onChange={(e) => setUserSearchQuery(e.target.value)}
                    className="w-full pl-9 pr-4 py-2 bg-white rounded-xl border border-slate-200 text-sm font-medium focus:outline-none focus:border-indigo-600"
                  />
                </div>

                {/* Filter Chips */}
                <div className="flex items-center gap-2">
                  <button
                    onClick={() => setUserRoleFilter('ALL')}
                    className={`px-3 py-1.5 rounded-xl text-xs font-bold transition-colors ${
                      userRoleFilter === 'ALL' ? 'bg-indigo-600 text-white' : 'bg-white border border-slate-200 text-slate-600'
                    }`}
                  >
                    All ({usersList.length})
                  </button>
                  <button
                    onClick={() => setUserRoleFilter('CREATORS_ONLY')}
                    className={`px-3 py-1.5 rounded-xl text-xs font-bold transition-colors ${
                      userRoleFilter === 'CREATORS_ONLY' ? 'bg-indigo-600 text-white' : 'bg-white border border-slate-200 text-slate-600'
                    }`}
                  >
                    Creators Only
                  </button>
                  <button
                    onClick={() => setUserRoleFilter('ACTIVE_ONLY')}
                    className={`px-3 py-1.5 rounded-xl text-xs font-bold transition-colors ${
                      userRoleFilter === 'ACTIVE_ONLY' ? 'bg-indigo-600 text-white' : 'bg-white border border-slate-200 text-slate-600'
                    }`}
                  >
                    Active Accounts
                  </button>
                </div>
              </div>

              {/* Users Table */}
              <div className="bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden">
                <table className="w-full text-left text-sm">
                  <thead className="bg-slate-50 border-b border-slate-200 text-xs font-bold text-slate-500 uppercase tracking-wider">
                    <tr>
                      <th className="py-3.5 px-6">User</th>
                      <th className="py-3.5 px-6">Contact</th>
                      <th className="py-3.5 px-6">Role</th>
                      <th className="py-3.5 px-6">Wallet Balance</th>
                      <th className="py-3.5 px-6">Status</th>
                      <th className="py-3.5 px-6 text-right">Actions</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {filteredUsers.length === 0 ? (
                      <tr>
                        <td colSpan={6} className="py-12 text-center text-slate-400 font-medium">
                          No users found matching your search.
                        </td>
                      </tr>
                    ) : (
                      filteredUsers.map((u) => (
                        <tr key={u.id} className="hover:bg-slate-50/50 transition-colors">
                          <td className="py-4 px-6">
                            <div className="flex items-center gap-3">
                              <div className="w-10 h-10 rounded-full overflow-hidden bg-slate-200 shrink-0">
                                {u.avatarUrl ? (
                                  <img src={u.avatarUrl} alt="" className="w-full h-full object-cover" />
                                ) : (
                                  <div className="w-full h-full bg-slate-700 text-white font-bold flex items-center justify-center text-sm">
                                    {u.name?.[0] || 'U'}
                                  </div>
                                )}
                              </div>
                              <div>
                                <p className="font-extrabold text-slate-900">{u.name}</p>
                                <p className="text-xs text-slate-400">ID: {u.id.slice(0, 8)}...</p>
                              </div>
                            </div>
                          </td>
                          <td className="py-4 px-6 text-slate-600 text-xs font-medium">
                            <div>{u.phone || 'No phone'}</div>
                            <div className="text-slate-400">{u.email || 'No email'}</div>
                          </td>
                          <td className="py-4 px-6">
                            <span
                              className={`text-[10px] font-black px-2.5 py-1 rounded-full uppercase tracking-wider ${
                                u.role === 'CREATOR' ? 'bg-amber-100 text-amber-800' : 'bg-slate-100 text-slate-700'
                              }`}
                            >
                              {u.role}
                            </span>
                          </td>
                          <td className="py-4 px-6 font-extrabold text-slate-900">
                            {u.walletBalance} Diamonds
                          </td>
                          <td className="py-4 px-6">
                            <span
                              className={`text-[11px] font-bold px-2 py-0.5 rounded-full ${
                                u.isActive ? 'bg-emerald-100 text-emerald-800' : 'bg-rose-100 text-rose-800'
                              }`}
                            >
                              {u.isActive ? 'Active' : 'Blocked'}
                            </span>
                          </td>
                          <td className="py-4 px-6 text-right">
                            <button
                              onClick={() => handleToggleUserBlock(u.id)}
                              className={`px-3 py-1.5 rounded-lg text-xs font-bold transition-colors ${
                                u.isActive
                                  ? 'bg-rose-50 text-rose-600 hover:bg-rose-100'
                                  : 'bg-emerald-50 text-emerald-600 hover:bg-emerald-100'
                              }`}
                            >
                              {u.isActive ? 'Block User' : 'Unblock'}
                            </button>
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* VIEW 3: CREATOR MANAGEMENT */}
          {activeMenu === 'creators' && (
            <div className="space-y-6 max-w-7xl mx-auto">
              {/* Creator Sub-Tabs */}
              <div className="flex items-center justify-between border-b border-slate-200 pb-4">
                <div className="flex items-center gap-3">
                  <button
                    onClick={() => setCreatorSubTab('pending')}
                    className={`px-4 py-2 rounded-xl text-xs font-black transition-all ${
                      creatorSubTab === 'pending'
                        ? 'bg-slate-900 text-white shadow'
                        : 'bg-white border border-slate-200 text-slate-600 hover:bg-slate-50'
                    }`}
                  >
                    Pending Verification ({pendingApps.length})
                  </button>
                  <button
                    onClick={() => setCreatorSubTab('directory')}
                    className={`px-4 py-2 rounded-xl text-xs font-black transition-all ${
                      creatorSubTab === 'directory'
                        ? 'bg-slate-900 text-white shadow'
                        : 'bg-white border border-slate-200 text-slate-600 hover:bg-slate-50'
                    }`}
                  >
                    Active Creators Directory ({creatorsList.length})
                  </button>
                </div>

                <button
                  onClick={() => setCreatorSubTab('add')}
                  className="px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-xs font-bold flex items-center gap-2 shadow-sm"
                >
                  <Plus className="w-4 h-4" /> Add Creator Directly
                </button>
              </div>

              {/* Sub-tab 1: Pending Queue */}
              {creatorSubTab === 'pending' && (
                <div>
                  {pendingApps.length === 0 ? (
                    <div className="bg-white p-12 rounded-2xl border border-slate-200 text-center">
                      <CheckCircle2 className="w-12 h-12 mx-auto text-emerald-500 mb-2" />
                      <h4 className="text-base font-extrabold text-slate-900">Zero Pending Applications</h4>
                      <p className="text-xs text-slate-400 mt-1 max-w-md mx-auto">
                        All creator KYC verification requests have been processed. New submissions from the mobile app
                        will appear here instantly.
                      </p>
                    </div>
                  ) : (
                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                      {pendingApps.map((app) => (
                        <div key={app.id} className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm space-y-4">
                          <div className="flex items-start justify-between">
                            <div className="flex items-center gap-3">
                              <div className="w-14 h-14 rounded-full overflow-hidden bg-slate-200">
                                {app.photoUrl ? (
                                  <img src={app.photoUrl} alt="" className="w-full h-full object-cover" />
                                ) : (
                                  <div className="w-full h-full bg-indigo-600 text-white font-bold flex items-center justify-center text-lg">
                                    {app.legalName?.[0] || 'C'}
                                  </div>
                                )}
                              </div>
                              <div>
                                <h4 className="font-extrabold text-slate-900">{app.legalName}</h4>
                                <p className="text-xs text-slate-500">{app.profession}</p>
                                <p className="text-[11px] text-slate-400 mt-0.5">{app.age} yrs • {app.govtIdType}</p>
                              </div>
                            </div>
                            <span className="text-[10px] font-black bg-amber-100 text-amber-800 px-2 py-0.5 rounded">
                              Pending
                            </span>
                          </div>

                          <div className="bg-slate-50 p-3 rounded-xl space-y-1 text-xs">
                            <div className="flex justify-between">
                              <span className="text-slate-500">Subscription:</span>
                              <span className="font-bold text-slate-900">₹299 Creator Pass (Paid)</span>
                            </div>
                            <div className="flex justify-between">
                              <span className="text-slate-500">Payout UPI:</span>
                              <span className="font-bold text-indigo-600">{app.payoutUpiId || 'N/A'}</span>
                            </div>
                            <div className="flex justify-between">
                              <span className="text-slate-500">Rates:</span>
                              <span className="font-bold text-slate-900">{app.videoCallPrice} Coins/min</span>
                            </div>
                          </div>

                          <div className="flex items-center gap-2 pt-2">
                            <button
                              onClick={() => setSelectedKycApp(app)}
                              className="flex-1 py-2 bg-slate-100 hover:bg-slate-200 rounded-xl text-xs font-bold text-slate-700 flex items-center justify-center gap-1.5"
                            >
                              <Eye className="w-3.5 h-3.5" /> Inspect KYC
                            </button>
                            <button
                              onClick={() => handleApproveCreator(app.id)}
                              className="flex-1 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-bold flex items-center justify-center gap-1.5 shadow-sm shadow-emerald-600/20"
                            >
                              <Check className="w-3.5 h-3.5" /> Approve & Live
                            </button>
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              )}

              {/* Sub-tab 2: Active Directory */}
              {creatorSubTab === 'directory' && (
                <div className="bg-white rounded-2xl border border-slate-200 overflow-hidden">
                  <table className="w-full text-left text-sm">
                    <thead className="bg-slate-50 border-b border-slate-200 text-xs font-bold text-slate-500 uppercase tracking-wider">
                      <tr>
                        <th className="py-3.5 px-6">Creator</th>
                        <th className="py-3.5 px-6">Rates</th>
                        <th className="py-3.5 px-6">Rating</th>
                        <th className="py-3.5 px-6">Active / Inactive</th>
                        <th className="py-3.5 px-6">Currently Live</th>
                        <th className="py-3.5 px-6">Homepage Feature</th>
                        <th className="py-3.5 px-6 text-right">Action</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-100">
                      {creatorsList.length === 0 ? (
                        <tr>
                          <td colSpan={7} className="py-12 text-center text-slate-400 font-medium">
                            No approved creators yet. Approve applicants from the Pending Queue.
                          </td>
                        </tr>
                      ) : (
                        creatorsList.map((c) => (
                          <tr key={c.id} className="hover:bg-slate-50/50 transition-colors">
                            <td className="py-4 px-6">
                              <div className="flex items-center gap-3">
                                <img src={c.photoUrl} alt="" className="w-10 h-10 rounded-full object-cover bg-slate-200" />
                                <div>
                                  <p className="font-extrabold text-slate-900">{c.name}</p>
                                  <p className="text-xs text-slate-400">{c.profession}</p>
                                </div>
                              </div>
                            </td>
                            <td className="py-4 px-6 text-xs font-bold text-slate-700">
                              {c.videoCallPrice} Coins/min
                            </td>
                            <td className="py-4 px-6 font-bold text-amber-500 text-xs">
                              ★ {c.rating} ({c.reviewCount})
                            </td>
                            <td className="py-4 px-6">
                              <button
                                onClick={() => handleToggleCreatorActive(c.id, c.isActive)}
                                className={`px-2.5 py-1 rounded-full text-xs font-bold ${
                                  c.isActive ? 'bg-emerald-100 text-emerald-800' : 'bg-slate-100 text-slate-600'
                                }`}
                              >
                                {c.isActive ? 'Active' : 'Inactive'}
                              </button>
                            </td>
                            <td className="py-4 px-6">
                              <span
                                className={`inline-flex items-center gap-1.5 text-xs font-bold ${
                                  c.isOnline ? 'text-emerald-600' : 'text-slate-400'
                                }`}
                              >
                                <span className={`w-2 h-2 rounded-full ${c.isOnline ? 'bg-emerald-500' : 'bg-slate-300'}`} />
                                {c.isOnline ? 'Online' : 'Offline'}
                              </span>
                            </td>
                            <td className="py-4 px-6">
                              <button
                                onClick={() => handleToggleFeatured(c.id, c.isFeatured)}
                                className={`px-2.5 py-1 rounded-full text-xs font-bold ${
                                  c.isFeatured ? 'bg-indigo-100 text-indigo-800' : 'bg-slate-100 text-slate-500'
                                }`}
                              >
                                {c.isFeatured ? 'Featured' : 'Standard'}
                              </button>
                            </td>
                            <td className="py-4 px-6 text-right">
                              <button
                                onClick={() => handleToggleCreatorActive(c.id, true)}
                                className="text-xs font-bold text-rose-600 hover:text-rose-800"
                              >
                                Deactivate
                              </button>
                            </td>
                          </tr>
                        ))
                      )}
                    </tbody>
                  </table>
                </div>
              )}

              {/* Sub-tab 3: Add Creator Directly Form */}
              {creatorSubTab === 'add' && (
                <div className="bg-white rounded-2xl border border-slate-200 p-8 max-w-2xl mx-auto shadow-sm">
                  <h3 className="text-base font-extrabold text-slate-900 mb-1">Onboard Creator Directly</h3>
                  <p className="text-xs text-slate-500 mb-6">
                    Bypass user self-application and publish a verified creator straight to the mobile app home feed.
                  </p>

                  <form onSubmit={handleDirectCreate} className="space-y-4">
                    <div>
                      <label className="block text-xs font-bold text-slate-700 mb-1">Creator Name</label>
                      <input
                        type="text"
                        required
                        value={newCreatorForm.name}
                        onChange={(e) => setNewCreatorForm({ ...newCreatorForm, name: e.target.value })}
                        className="w-full px-3 py-2 border border-slate-200 rounded-xl text-sm"
                        placeholder="e.g. Priya Sharma"
                      />
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <label className="block text-xs font-bold text-slate-700 mb-1">Age</label>
                        <input
                          type="number"
                          value={newCreatorForm.age}
                          onChange={(e) => setNewCreatorForm({ ...newCreatorForm, age: Number(e.target.value) })}
                          className="w-full px-3 py-2 border border-slate-200 rounded-xl text-sm"
                        />
                      </div>
                      <div>
                        <label className="block text-xs font-bold text-slate-700 mb-1">Profession</label>
                        <input
                          type="text"
                          required
                          value={newCreatorForm.profession}
                          onChange={(e) => setNewCreatorForm({ ...newCreatorForm, profession: e.target.value })}
                          className="w-full px-3 py-2 border border-slate-200 rounded-xl text-sm"
                        />
                      </div>
                    </div>

                    <div>
                      <label className="block text-xs font-bold text-slate-700 mb-1">Profile Photo URL</label>
                      <input
                        type="url"
                        value={newCreatorForm.photoUrl}
                        onChange={(e) => setNewCreatorForm({ ...newCreatorForm, photoUrl: e.target.value })}
                        className="w-full px-3 py-2 border border-slate-200 rounded-xl text-sm"
                        placeholder="https://images.unsplash.com/photo-..."
                      />
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <label className="block text-xs font-bold text-slate-700 mb-1">Video Call Rate (Coins/min)</label>
                        <input
                          type="number"
                          value={newCreatorForm.videoCallPrice}
                          onChange={(e) =>
                            setNewCreatorForm({ ...newCreatorForm, videoCallPrice: Number(e.target.value) })
                          }
                          className="w-full px-3 py-2 border border-slate-200 rounded-xl text-sm"
                        />
                      </div>
                      <div>
                        <label className="block text-xs font-bold text-slate-700 mb-1">Voice Call Rate (Coins/min)</label>
                        <input
                          type="number"
                          value={newCreatorForm.voiceCallPrice}
                          onChange={(e) =>
                            setNewCreatorForm({ ...newCreatorForm, voiceCallPrice: Number(e.target.value) })
                          }
                          className="w-full px-3 py-2 border border-slate-200 rounded-xl text-sm"
                        />
                      </div>
                    </div>

                    <div className="pt-4 flex justify-end gap-3">
                      <button
                        type="button"
                        onClick={() => setCreatorSubTab('directory')}
                        className="px-4 py-2 bg-slate-100 hover:bg-slate-200 rounded-xl text-xs font-bold"
                      >
                        Cancel
                      </button>
                      <button
                        type="submit"
                        className="px-5 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-xs font-bold shadow"
                      >
                        Publish Creator Live
                      </button>
                    </div>
                  </form>
                </div>
              )}
            </div>
          )}

          {/* VIEW 4: WALLET & DIAMONDS */}
          {activeMenu === 'wallet' && (
            <div className="space-y-6 max-w-7xl mx-auto">
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-5">
                <MetricCard
                  title="Diamonds Sold (All Time)"
                  value={stats.totalDiamondsSold.toLocaleString()}
                  subtext="Purchased by user accounts"
                  change="Total"
                  icon={<Coins className="w-5 h-5 text-emerald-600" />}
                  iconBg="bg-emerald-50"
                />
                <MetricCard
                  title="Total Revenue Generated"
                  value={`₹${stats.totalRevenue.toLocaleString()}`}
                  subtext="Converted from INR gateways"
                  change="Revenue"
                  icon={<DollarSign className="w-5 h-5 text-indigo-600" />}
                  iconBg="bg-indigo-50"
                />
                <MetricCard
                  title="Emergency Balance Freeze"
                  value={settings.isFreezeBalance ? 'FROZEN' : 'ACTIVE'}
                  subtext="Administrative restriction"
                  change={settings.isFreezeBalance ? 'Restricted' : 'Normal'}
                  icon={<Lock className="w-5 h-5 text-rose-600" />}
                  iconBg="bg-rose-50"
                />
              </div>

              {/* Diamond Package Configuration */}
              <div className="bg-white rounded-2xl border border-slate-200 p-6 shadow-sm">
                <h3 className="text-base font-extrabold text-slate-900 mb-1">Standard Diamond Recharge Packages</h3>
                <p className="text-xs text-slate-500 mb-5">Current pricing tiers shown inside mobile app wallet.</p>

                <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-4">
                  {[
                    { diamonds: 200, inr: 100 },
                    { diamonds: 300, inr: 150 },
                    { diamonds: 500, inr: 250 },
                    { diamonds: 800, inr: 400 },
                    { diamonds: 1000, inr: 500 },
                    { diamonds: 2000, inr: 1000 },
                  ].map((pkg) => (
                    <div key={pkg.diamonds} className="p-4 rounded-xl border border-slate-200 text-center bg-slate-50">
                      <Coins className="w-6 h-6 text-amber-500 mx-auto mb-1" />
                      <p className="font-black text-slate-900 text-base">{pkg.diamonds}</p>
                      <p className="text-xs text-slate-500">Diamonds</p>
                      <p className="text-sm font-black text-indigo-600 mt-2">₹{pkg.inr}</p>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* VIEW 5: PAYMENTS & TRANSACTIONS */}
          {activeMenu === 'transactions' && (
            <div className="space-y-6 max-w-7xl mx-auto">
              <div className="bg-white rounded-2xl border border-slate-200 overflow-hidden shadow-sm">
                <div className="p-5 border-b border-slate-200 flex items-center justify-between">
                  <h3 className="text-base font-extrabold text-slate-900">Payment & Transaction Ledger</h3>
                  <span className="text-xs font-bold text-slate-500">{allTxns.length} Total Records</span>
                </div>

                <table className="w-full text-left text-sm">
                  <thead className="bg-slate-50 border-b border-slate-200 text-xs font-bold text-slate-500 uppercase tracking-wider">
                    <tr>
                      <th className="py-3.5 px-6">Reference ID</th>
                      <th className="py-3.5 px-6">User</th>
                      <th className="py-3.5 px-6">Package</th>
                      <th className="py-3.5 px-6">Amount</th>
                      <th className="py-3.5 px-6">Status</th>
                      <th className="py-3.5 px-6 text-right">Date</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {allTxns.length === 0 ? (
                      <tr>
                        <td colSpan={6} className="py-12 text-center text-slate-400 font-medium">
                          No transactions recorded yet in PostgreSQL.
                        </td>
                      </tr>
                    ) : (
                      allTxns.map((t) => (
                        <tr key={t.id} className="hover:bg-slate-50/50">
                          <td className="py-4 px-6 font-mono text-xs text-slate-500">{t.referenceId}</td>
                          <td className="py-4 px-6 font-extrabold text-slate-900">{t.userName}</td>
                          <td className="py-4 px-6 text-xs text-slate-600 font-medium">{t.description}</td>
                          <td className="py-4 px-6 font-black text-slate-900">₹{t.amountInr}</td>
                          <td className="py-4 px-6">
                            <span className="text-[11px] font-bold px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800">
                              {t.status}
                            </span>
                          </td>
                          <td className="py-4 px-6 text-right text-xs text-slate-400 font-medium">
                            {new Date(t.createdAt).toLocaleDateString()}
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* VIEW 6: LIVE CALLS & SESSIONS */}
          {activeMenu === 'calls' && (
            <div className="space-y-6 max-w-7xl mx-auto">
              <div className="bg-white rounded-2xl border border-slate-200 overflow-hidden shadow-sm">
                <div className="p-5 border-b border-slate-200 flex items-center justify-between">
                  <h3 className="text-base font-extrabold text-slate-900">Video & Voice Call Sessions</h3>
                  <span className="text-xs font-bold text-slate-500">{allCalls.length} Recorded Sessions</span>
                </div>

                <table className="w-full text-left text-sm">
                  <thead className="bg-slate-50 border-b border-slate-200 text-xs font-bold text-slate-500 uppercase tracking-wider">
                    <tr>
                      <th className="py-3.5 px-6">Session ID</th>
                      <th className="py-3.5 px-6">Caller User</th>
                      <th className="py-3.5 px-6">Creator</th>
                      <th className="py-3.5 px-6">Type</th>
                      <th className="py-3.5 px-6">Duration</th>
                      <th className="py-3.5 px-6">Coins Spent</th>
                      <th className="py-3.5 px-6 text-right">Status</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {allCalls.length === 0 ? (
                      <tr>
                        <td colSpan={7} className="py-12 text-center text-slate-400 font-medium">
                          No live call sessions initiated yet.
                        </td>
                      </tr>
                    ) : (
                      allCalls.map((c) => (
                        <tr key={c.id} className="hover:bg-slate-50/50">
                          <td className="py-4 px-6 font-mono text-xs text-slate-500">{c.id.slice(0, 8)}</td>
                          <td className="py-4 px-6 font-extrabold text-slate-900">{c.callerName}</td>
                          <td className="py-4 px-6 font-extrabold text-indigo-600">{c.creatorName}</td>
                          <td className="py-4 px-6 text-xs font-bold text-slate-600">{c.callType}</td>
                          <td className="py-4 px-6 text-xs text-slate-600">{c.durationFormatted}</td>
                          <td className="py-4 px-6 font-black text-slate-900">{c.coins} Diamonds</td>
                          <td className="py-4 px-6 text-right">
                            <span className="text-[11px] font-bold px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800">
                              {c.status}
                            </span>
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* VIEW 7: APP SETTINGS */}
          {activeMenu === 'settings' && (
            <div className="space-y-6 max-w-4xl mx-auto">
              <div className="bg-white rounded-2xl border border-slate-200 p-8 shadow-sm space-y-6">
                <div>
                  <h3 className="text-base font-extrabold text-slate-900">Wallet & App Controls</h3>
                  <p className="text-xs text-slate-500 mt-1">Configure global platform kill-switches and financial security.</p>
                </div>

                {/* Freeze Balance Toggle */}
                <div className="p-4 rounded-xl border border-slate-200 flex items-center justify-between">
                  <div>
                    <p className="font-extrabold text-sm text-slate-900">Freeze Diamond Balance</p>
                    <p className="text-xs text-slate-500 mt-0.5">
                      Restrict diamond usage across all user accounts according to administrative rules.
                    </p>
                  </div>
                  <button
                    onClick={() => handleUpdateSettings({ isFreezeBalance: !settings.isFreezeBalance })}
                    className={`px-4 py-2 rounded-xl text-xs font-bold transition-all ${
                      settings.isFreezeBalance
                        ? 'bg-rose-600 text-white shadow-sm'
                        : 'bg-slate-100 text-slate-700 hover:bg-slate-200'
                    }`}
                  >
                    {settings.isFreezeBalance ? 'Freeze Enabled' : 'Freeze Disabled'}
                  </button>
                </div>

                {/* Video Connection Killswitch */}
                <div className="p-4 rounded-xl border border-slate-200 flex items-center justify-between">
                  <div>
                    <p className="font-extrabold text-sm text-slate-900">Video Connection Control</p>
                    <p className="text-xs text-slate-500 mt-0.5">Allow or globally block users from initiating new video calls.</p>
                  </div>
                  <button
                    onClick={() => handleUpdateSettings({ isVideoConnectionEnabled: !settings.isVideoConnectionEnabled })}
                    className={`px-4 py-2 rounded-xl text-xs font-bold transition-all ${
                      settings.isVideoConnectionEnabled
                        ? 'bg-emerald-600 text-white shadow-sm'
                        : 'bg-rose-600 text-white shadow-sm'
                    }`}
                  >
                    {settings.isVideoConnectionEnabled ? 'Connections Enabled' : 'Connections Blocked'}
                  </button>
                </div>

                {/* Payment Account Configuration */}
                <div className="p-5 rounded-xl border border-slate-200 space-y-3">
                  <div>
                    <p className="font-extrabold text-sm text-slate-900">Payment Account Configuration</p>
                    <p className="text-xs text-slate-500 mt-0.5">
                      Official administrative UPI ID receiving payment remittances and deposits.
                    </p>
                  </div>
                  <div className="flex gap-3">
                    <input
                      type="text"
                      value={upiInput}
                      onChange={(e) => setUpiInput(e.target.value)}
                      className="flex-1 px-4 py-2 border border-slate-200 rounded-xl text-sm font-semibold focus:outline-none focus:border-indigo-600"
                      placeholder="e.g. XYX12438383@ybl"
                    />
                    <button
                      onClick={() => handleUpdateSettings({ paymentUpiId: upiInput })}
                      className="px-5 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-xs font-bold shadow"
                    >
                      Save UPI
                    </button>
                  </div>
                </div>
              </div>
            </div>
          )}
        </main>
      </div>

      {/* =========================================================================
          KYC INSPECTOR MODAL
          ========================================================================= */}
      {selectedKycApp && (
        <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl max-w-2xl w-full p-8 shadow-2xl border border-slate-200 space-y-6 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between border-b border-slate-100 pb-4">
              <div>
                <h3 className="text-lg font-black text-slate-900">Applicant KYC Verification</h3>
                <p className="text-xs text-slate-400">Review government identification & banking details</p>
              </div>
              <button
                onClick={() => setSelectedKycApp(null)}
                className="p-2 rounded-xl text-slate-400 hover:bg-slate-100"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="grid grid-cols-2 gap-4 text-xs">
              <div className="p-3 bg-slate-50 rounded-xl">
                <span className="text-slate-400">Full Legal Name:</span>
                <p className="font-extrabold text-slate-900 text-sm mt-0.5">{selectedKycApp.legalName}</p>
              </div>
              <div className="p-3 bg-slate-50 rounded-xl">
                <span className="text-slate-400">Age:</span>
                <p className="font-extrabold text-slate-900 text-sm mt-0.5">{selectedKycApp.age} years</p>
              </div>
              <div className="p-3 bg-slate-50 rounded-xl">
                <span className="text-slate-400">Govt ID Type:</span>
                <p className="font-extrabold text-slate-900 text-sm mt-0.5">{selectedKycApp.govtIdType}</p>
              </div>
              <div className="p-3 bg-slate-50 rounded-xl">
                <span className="text-slate-400">Payout UPI ID:</span>
                <p className="font-extrabold text-indigo-600 text-sm mt-0.5">{selectedKycApp.payoutUpiId || 'N/A'}</p>
              </div>
              <div className="p-3 bg-slate-50 rounded-xl col-span-2">
                <span className="text-slate-400">Creator Bio:</span>
                <p className="font-medium text-slate-700 mt-1">{selectedKycApp.bio || 'No bio provided.'}</p>
              </div>
            </div>

            <div className="pt-4 border-t border-slate-100 flex items-center justify-end gap-3">
              <button
                onClick={() => setSelectedKycApp(null)}
                className="px-4 py-2 bg-slate-100 text-slate-700 rounded-xl text-xs font-bold"
              >
                Close
              </button>
              <button
                onClick={() => handleApproveCreator(selectedKycApp.id)}
                className="px-5 py-2 bg-emerald-600 text-white rounded-xl text-xs font-bold shadow-sm"
              >
                Approve & Publish to Mobile Feed
              </button>
            </div>
          </div>
        </div>
      )}

      {/* =========================================================================
          REJECTION FEEDBACK MODAL
          ========================================================================= */}
      {rejectingAppId && (
        <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl max-w-md w-full p-6 shadow-2xl border border-slate-200 space-y-4">
            <h3 className="text-base font-extrabold text-slate-900">Reason for Rejection</h3>
            <p className="text-xs text-slate-500">Provide helpful feedback to the applicant so they can re-apply.</p>
            <textarea
              rows={3}
              value={rejectionReason}
              onChange={(e) => setRejectionReason(e.target.value)}
              placeholder="e.g. Government ID was blurred. Please re-submit a clear photo."
              className="w-full p-3 border border-slate-200 rounded-xl text-xs font-medium focus:outline-none focus:border-rose-500"
            />
            <div className="flex justify-end gap-2 pt-2">
              <button
                onClick={() => setRejectingAppId(null)}
                className="px-4 py-2 bg-slate-100 text-slate-600 rounded-xl text-xs font-bold"
              >
                Cancel
              </button>
              <button
                onClick={handleRejectCreator}
                className="px-4 py-2 bg-rose-600 text-white rounded-xl text-xs font-bold"
              >
                Confirm Rejection
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// ---------------------------------------------------------------------------
// Helper Subcomponents
// ---------------------------------------------------------------------------
function SidebarItem({
  icon,
  label,
  active,
  onClick,
  badge,
  badgeColor = 'bg-slate-800 text-slate-300',
}: {
  icon: React.ReactNode;
  label: string;
  active: boolean;
  onClick: () => void;
  badge?: string;
  badgeColor?: string;
}) {
  return (
    <button
      onClick={onClick}
      className={`w-full flex items-center justify-between px-3.5 py-2.5 rounded-xl text-xs font-bold transition-all ${
        active
          ? 'bg-indigo-600 text-white shadow-md shadow-indigo-600/20'
          : 'text-slate-400 hover:text-white hover:bg-slate-800/60'
      }`}
    >
      <div className="flex items-center gap-3">
        {icon}
        <span>{label}</span>
      </div>
      {badge && <span className={`text-[10px] font-black px-2 py-0.5 rounded-full ${badgeColor}`}>{badge}</span>}
    </button>
  );
}

function MetricCard({
  title,
  value,
  subtext,
  change,
  icon,
  iconBg,
}: {
  title: string;
  value: string;
  subtext: string;
  change: string;
  icon: React.ReactNode;
  iconBg: string;
}) {
  return (
    <div className="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm flex flex-col justify-between">
      <div className="flex items-center justify-between mb-3">
        <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">{title}</span>
        <div className={`p-2.5 rounded-xl ${iconBg}`}>{icon}</div>
      </div>
      <div>
        <h3 className="text-2xl font-black text-slate-900 tracking-tight">{value}</h3>
        <div className="flex items-center justify-between mt-1 text-xs">
          <span className="text-slate-400 font-medium">{subtext}</span>
          <span className="font-bold text-indigo-600">{change}</span>
        </div>
      </div>
    </div>
  );
}
