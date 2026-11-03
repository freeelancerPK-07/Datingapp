import React, { useState, useEffect } from 'react';
import {
  ShieldAlert,
  Video,
  CreditCard,
  UserCheck,
  Users,
  UserPlus,
  CheckCircle2,
  XCircle,
  RefreshCw,
  ExternalLink,
  Lock,
  Unlock,
  AlertCircle,
  Sparkles,
  Phone,
  Mail,
  Instagram,
  Eye,
  Sliders,
  DollarSign
} from 'lucide-react';

const API_BASE = 'http://localhost:5000/api/v1';

interface AdminSettings {
  isFreezeBalance: boolean;
  isVideoConnectionEnabled: boolean;
  paymentUpiId: string;
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
  govtIdFrontUrl?: string;
  govtIdBackUrl?: string;
  selfieUrl?: string;
  socialHandle?: string;
  payoutUpiId: string;
  videoCallPrice: number;
  voiceCallPrice: number;
  languages: string[];
  tags: string[];
  subscriptionPlan: string;
  subscriptionPaid: boolean;
  status: string;
  createdAt: string;
  user?: {
    email?: string;
    phone?: string;
    profile?: {
      name?: string;
      avatarUrl?: string;
    };
  };
}

interface Creator {
  id: string;
  userId: string;
  name: string;
  age: number;
  photoUrl: string;
  profession: string;
  videoCallPrice: number;
  voiceCallPrice: number;
  isActive: boolean;
  isApproved: boolean;
  isFeatured: boolean;
  isOnline: boolean;
  rating: number;
  reviewCount: number;
  languages: string[];
  tags: string[];
  email: string;
  phone: string;
}

export default function App() {
  // Settings State
  const [settings, setSettings] = useState<AdminSettings>({
    isFreezeBalance: false,
    isVideoConnectionEnabled: true,
    paymentUpiId: 'XYX12438383@ybl',
  });
  const [upiInput, setUpiInput] = useState('XYX12438383@ybl');
  const [settingsLoading, setSettingsLoading] = useState(false);
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  // Creator State
  const [activeTab, setActiveTab] = useState<'pending' | 'directory' | 'add'>('pending');
  const [pendingApps, setPendingApps] = useState<CreatorApplication[]>([]);
  const [creators, setCreators] = useState<Creator[]>([]);
  const [loadingCreators, setLoadingCreators] = useState(false);
  const [apiConnected, setApiConnected] = useState(false);

  // Modals & Forms
  const [selectedKycApp, setSelectedKycApp] = useState<CreatorApplication | null>(null);
  const [rejectionReason, setRejectionReason] = useState('');
  const [rejectingAppId, setRejectingAppId] = useState<string | null>(null);

  // New Creator Direct Form
  const [newCreatorForm, setNewCreatorForm] = useState({
    name: '',
    age: 23,
    profession: 'Lifestyle & Dating Consultant',
    photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=600&q=80',
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

  // Fetch all initial data
  const loadData = async () => {
    setLoadingCreators(true);
    try {
      // 1. Settings
      const setRes = await fetch(`${API_BASE}/admin/settings`);
      if (setRes.ok) {
        const sData = await setRes.json();
        if (sData.settings) {
          setSettings(sData.settings);
          setUpiInput(sData.settings.paymentUpiId || 'XYX12438383@ybl');
          setApiConnected(true);
        }
      }

      // 2. Pending Applications
      const pendRes = await fetch(`${API_BASE}/admin/creators/pending`);
      if (pendRes.ok) {
        const pData = await pendRes.json();
        setPendingApps(pData.data || []);
      }

      // 3. All Creators
      const crRes = await fetch(`${API_BASE}/admin/creators`);
      if (crRes.ok) {
        const cData = await crRes.json();
        setCreators(cData.data || []);
      }
    } catch (e) {
      console.error('Failed to connect to backend API:', e);
      setApiConnected(false);
    } finally {
      setLoadingCreators(false);
    }
  };

  useEffect(() => {
    loadData();
    const interval = setInterval(loadData, 8000); // Polling for real-time updates
    return () => clearInterval(interval);
  }, []);

  // Update Settings
  const handleUpdateSettings = async (updates: Partial<AdminSettings>) => {
    setSettingsLoading(true);
    try {
      const res = await fetch(`${API_BASE}/admin/settings`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(updates),
      });
      const data = await res.json();
      if (data.success) {
        setSettings(data.settings);
        showToast('App Settings updated successfully!');
      }
    } catch (e) {
      showToast('Error updating settings');
    } finally {
      setSettingsLoading(false);
    }
  };

  // Save UPI ID
  const handleSaveUpi = () => {
    if (!upiInput.trim()) return;
    handleUpdateSettings({ paymentUpiId: upiInput.trim() });
  };

  // Approve Creator
  const handleApprove = async (applicationId: string) => {
    try {
      const res = await fetch(`${API_BASE}/admin/creators/${applicationId}/approve`, {
        method: 'POST',
      });
      const data = await res.json();
      if (data.success) {
        showToast('Creator Approved! Profile is now LIVE on mobile app feed.');
        loadData();
        setSelectedKycApp(null);
      } else {
        showToast(data.error || 'Failed to approve');
      }
    } catch (e) {
      showToast('Approval request failed');
    }
  };

  // Reject Creator
  const handleReject = async () => {
    if (!rejectingAppId) return;
    try {
      const res = await fetch(`${API_BASE}/admin/creators/${rejectingAppId}/reject`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ reason: rejectionReason }),
      });
      const data = await res.json();
      if (data.success) {
        showToast('Application rejected with feedback');
        setRejectingAppId(null);
        setRejectionReason('');
        loadData();
      }
    } catch (e) {
      showToast('Rejection request failed');
    }
  };

  // Toggle Creator Active State
  const handleToggleCreatorActive = async (creatorId: string, current: boolean) => {
    try {
      const res = await fetch(`${API_BASE}/admin/creators/${creatorId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ isActive: !current }),
      });
      if (res.ok) {
        showToast(`Creator ${!current ? 'Activated' : 'Deactivated'}`);
        loadData();
      }
    } catch (e) {
      showToast('Failed to update creator state');
    }
  };

  // Toggle Featured State (Homepage banner)
  const handleToggleCreatorFeatured = async (creatorId: string, current: boolean) => {
    try {
      const res = await fetch(`${API_BASE}/admin/creators/${creatorId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ isFeatured: !current }),
      });
      if (res.ok) {
        showToast(`Creator ${!current ? 'Pinned to Featured' : 'Unpinned'}`);
        loadData();
      }
    } catch (e) {
      showToast('Failed to update featured state');
    }
  };

  // Add Direct Creator
  const handleCreateDirectCreator = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const res = await fetch(`${API_BASE}/admin/creators/create-direct`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newCreatorForm),
      });
      const data = await res.json();
      if (data.success) {
        showToast('New creator published directly to app!');
        setNewCreatorForm({
          name: '',
          age: 23,
          profession: 'Lifestyle & Dating Consultant',
          photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=600&q=80',
          videoCallPrice: 500,
          voiceCallPrice: 300,
          bio: 'Verified consultation expert on LinkUp.',
          email: '',
          phone: '',
          isActive: true,
          isFeatured: true,
        });
        setActiveTab('directory');
        loadData();
      } else {
        showToast(data.error || 'Failed to create creator');
      }
    } catch (e) {
      showToast('Failed to publish creator');
    }
  };

  return (
    <div className="min-h-screen bg-[#FAFAFA] text-[#111111] font-sans antialiased">
      {/* Toast Notification */}
      {toastMessage && (
        <div className="fixed bottom-6 right-6 z-50 bg-[#111111] text-white px-5 py-3 rounded-xl shadow-2xl text-sm font-semibold flex items-center space-x-2 border border-[#27272A] animate-bounce">
          <Sparkles className="w-4 h-4 text-emerald-400" />
          <span>{toastMessage}</span>
        </div>
      )}

      {/* Top Header */}
      <header className="border-b border-[#E4E4E7] bg-white sticky top-0 z-30">
        <div className="max-w-7xl mx-auto px-6 h-16 flex items-center justify-between">
          <div className="flex items-center space-x-3">
            <div className="w-9 h-9 rounded-xl bg-[#111111] text-white flex items-center justify-center font-black text-lg shadow-sm">
              L
            </div>
            <div>
              <h1 className="text-base font-extrabold tracking-tight">LinkUp Admin Console</h1>
              <p className="text-xs text-[#71717A] font-medium">Real-Time Creator Verification & System Controller</p>
            </div>
          </div>

          <div className="flex items-center space-x-4">
            <div className="flex items-center space-x-2 px-3 py-1.5 rounded-full bg-[#F4F4F5] border border-[#E4E4E7] text-xs font-semibold">
              <span className={`w-2 h-2 rounded-full ${apiConnected ? 'bg-emerald-500 animate-pulse' : 'bg-rose-500'}`} />
              <span className="text-[#52525B]">Backend: {apiConnected ? 'Connected (Port 5000)' : 'Offline / Reconnecting'}</span>
            </div>

            <button
              onClick={loadData}
              disabled={loadingCreators}
              className="p-2 rounded-lg hover:bg-[#F4F4F5] border border-[#E4E4E7] transition text-[#71717A] hover:text-[#111111]"
              title="Refresh Data"
            >
              <RefreshCw className={`w-4 h-4 ${loadingCreators ? 'animate-spin' : ''}`} />
            </button>
          </div>
        </div>
      </header>

      {/* Main Two-Column Container */}
      <main className="max-w-7xl mx-auto px-6 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
          
          {/* ========================================================================= */}
          {/* COLUMN 1: WALLET & APP SETTINGS (4 Cols) */}
          {/* ========================================================================= */}
          <section className="lg:col-span-5 space-y-6">
            <div className="flex items-center justify-between mb-2">
              <h2 className="text-sm font-bold uppercase tracking-wider text-[#71717A] flex items-center space-x-2">
                <Sliders className="w-4 h-4 text-[#111111]" />
                <span>Column 1: Wallet & App Settings</span>
              </h2>
            </div>

            {/* A. Freeze Balance */}
            <div className="bg-white rounded-2xl border border-[#E4E4E7] p-6 shadow-sm">
              <div className="flex items-start justify-between">
                <div className="space-y-1">
                  <div className="flex items-center space-x-2">
                    <ShieldAlert className="w-5 h-5 text-[#111111]" />
                    <h3 className="font-bold text-base text-[#111111]">A. Freeze Balance</h3>
                  </div>
                  <p className="text-xs text-[#71717A] leading-relaxed pr-4">
                    When enabled, restricts wallet balance usage. Users cannot burn coins or book new calls.
                  </p>
                </div>

                <button
                  disabled={settingsLoading}
                  onClick={() => handleUpdateSettings({ isFreezeBalance: !settings.isFreezeBalance })}
                  className={`relative inline-flex h-7 w-13 shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none ${
                    settings.isFreezeBalance ? 'bg-[#111111]' : 'bg-[#E4E4E7]'
                  }`}
                >
                  <span
                    className={`pointer-events-none inline-block h-6 w-6 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out ${
                      settings.isFreezeBalance ? 'translate-x-6' : 'translate-x-0'
                    }`}
                  />
                </button>
              </div>

              <div className="mt-4 pt-4 border-t border-[#F4F4F5] flex items-center justify-between text-xs">
                <span className="text-[#71717A] font-medium">Defined Status:</span>
                <span className={`font-bold px-2.5 py-1 rounded-full ${
                  settings.isFreezeBalance ? 'bg-amber-100 text-amber-800' : 'bg-emerald-100 text-emerald-800'
                }`}>
                  {settings.isFreezeBalance ? 'FROZEN (Usage Restricted)' : 'NORMAL (Usage Allowed)'}
                </span>
              </div>
            </div>

            {/* B. Video Connection Control */}
            <div className="bg-white rounded-2xl border border-[#E4E4E7] p-6 shadow-sm">
              <div className="flex items-start justify-between">
                <div className="space-y-1">
                  <div className="flex items-center space-x-2">
                    <Video className="w-5 h-5 text-[#111111]" />
                    <h3 className="font-bold text-base text-[#111111]">B. Video Connection Control</h3>
                  </div>
                  <p className="text-xs text-[#71717A] leading-relaxed pr-4">
                    Global video calling switch. When disabled, blocks new video connections across all users.
                  </p>
                </div>

                <button
                  disabled={settingsLoading}
                  onClick={() => handleUpdateSettings({ isVideoConnectionEnabled: !settings.isVideoConnectionEnabled })}
                  className={`relative inline-flex h-7 w-13 shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none ${
                    settings.isVideoConnectionEnabled ? 'bg-[#111111]' : 'bg-[#E4E4E7]'
                  }`}
                >
                  <span
                    className={`pointer-events-none inline-block h-6 w-6 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out ${
                      settings.isVideoConnectionEnabled ? 'translate-x-6' : 'translate-x-0'
                    }`}
                  />
                </button>
              </div>

              <div className="mt-4 pt-4 border-t border-[#F4F4F5] flex items-center justify-between text-xs">
                <span className="text-[#71717A] font-medium">Connection State:</span>
                <span className={`font-bold px-2.5 py-1 rounded-full ${
                  settings.isVideoConnectionEnabled ? 'bg-emerald-100 text-emerald-800' : 'bg-rose-100 text-rose-800'
                }`}>
                  {settings.isVideoConnectionEnabled ? 'ENABLED (Calls Active)' : 'DISABLED (Kill-Switch Active)'}
                </span>
              </div>
            </div>

            {/* C. Payment Account Configuration */}
            <div className="bg-white rounded-2xl border border-[#E4E4E7] p-6 shadow-sm">
              <div className="flex items-center space-x-2 mb-2">
                <CreditCard className="w-5 h-5 text-[#111111]" />
                <h3 className="font-bold text-base text-[#111111]">C. Payment Account Configuration</h3>
              </div>
              <p className="text-xs text-[#71717A] leading-relaxed mb-4">
                Configure primary administrator UPI ID for creator subscription & diamond wallet recharges.
              </p>

              <div className="space-y-3">
                <label className="block text-xs font-semibold text-[#52525B]">
                  Admin Primary UPI ID
                </label>
                <div className="relative">
                  <input
                    type="text"
                    value={upiInput}
                    onChange={(e) => setUpiInput(e.target.value)}
                    placeholder="e.g. XYX12438383@ybl"
                    className="w-full px-3.5 py-2.5 rounded-xl border border-[#E4E4E7] bg-[#FAFAFA] text-sm font-semibold focus:outline-none focus:ring-2 focus:ring-[#111111] transition"
                  />
                </div>
                <div className="flex items-center justify-between pt-1">
                  <span className="text-[11px] text-[#A1A1AA]">
                    * Verified before production payouts
                  </span>
                  <button
                    disabled={settingsLoading || upiInput === settings.paymentUpiId}
                    onClick={handleSaveUpi}
                    className="px-4 py-2 rounded-xl bg-[#111111] text-white text-xs font-bold hover:bg-[#27272A] disabled:opacity-40 transition shadow-sm"
                  >
                    Save UPI
                  </button>
                </div>
              </div>
            </div>
          </section>

          {/* ========================================================================= */}
          {/* COLUMN 2: CREATOR MANAGEMENT (7 Cols) */}
          {/* ========================================================================= */}
          <section className="lg:col-span-7 space-y-6">
            <div className="flex items-center justify-between mb-2">
              <h2 className="text-sm font-bold uppercase tracking-wider text-[#71717A] flex items-center space-x-2">
                <Users className="w-4 h-4 text-[#111111]" />
                <span>Column 2: Creator Management</span>
              </h2>

              {/* Tabs */}
              <div className="inline-flex p-1 bg-[#E4E4E7] rounded-xl text-xs font-bold">
                <button
                  onClick={() => setActiveTab('pending')}
                  className={`px-3 py-1.5 rounded-lg transition flex items-center space-x-1.5 ${
                    activeTab === 'pending'
                      ? 'bg-white text-[#111111] shadow-sm'
                      : 'text-[#71717A] hover:text-[#111111]'
                  }`}
                >
                  <UserCheck className="w-3.5 h-3.5" />
                  <span>Pending Queue</span>
                  {pendingApps.length > 0 && (
                    <span className="px-1.5 py-0.2 rounded-full bg-[#111111] text-white text-[10px]">
                      {pendingApps.length}
                    </span>
                  )}
                </button>

                <button
                  onClick={() => setActiveTab('directory')}
                  className={`px-3 py-1.5 rounded-lg transition flex items-center space-x-1.5 ${
                    activeTab === 'directory'
                      ? 'bg-white text-[#111111] shadow-sm'
                      : 'text-[#71717A] hover:text-[#111111]'
                  }`}
                >
                  <Users className="w-3.5 h-3.5" />
                  <span>All Creators ({creators.length})</span>
                </button>

                <button
                  onClick={() => setActiveTab('add')}
                  className={`px-3 py-1.5 rounded-lg transition flex items-center space-x-1.5 ${
                    activeTab === 'add'
                      ? 'bg-white text-[#111111] shadow-sm'
                      : 'text-[#71717A] hover:text-[#111111]'
                  }`}
                >
                  <UserPlus className="w-3.5 h-3.5" />
                  <span>+ Add Creator</span>
                </button>
              </div>
            </div>

            {/* TAB 1: PENDING QUEUE */}
            {activeTab === 'pending' && (
              <div className="bg-white rounded-2xl border border-[#E4E4E7] shadow-sm overflow-hidden">
                <div className="p-5 border-b border-[#F4F4F5] flex items-center justify-between">
                  <div>
                    <h3 className="font-bold text-sm text-[#111111]">Pending Creator Verifications</h3>
                    <p className="text-xs text-[#71717A]">
                      Approve applications submitted from the mobile app to make them live on the Home Screen.
                    </p>
                  </div>
                  <span className="text-xs font-bold text-[#71717A]">{pendingApps.length} in queue</span>
                </div>

                {pendingApps.length === 0 ? (
                  <div className="py-16 text-center space-y-2">
                    <CheckCircle2 className="w-10 h-10 text-[#A1A1AA] mx-auto stroke-1" />
                    <p className="text-sm font-bold text-[#52525B]">Queue is All Caught Up!</p>
                    <p className="text-xs text-[#A1A1AA]">
                      No creator applications currently awaiting verification.
                    </p>
                  </div>
                ) : (
                  <div className="divide-y divide-[#F4F4F5]">
                    {pendingApps.map((app) => (
                      <div key={app.id} className="p-5 hover:bg-[#FAFAFA] transition flex flex-col md:flex-row md:items-center justify-between gap-4">
                        <div className="flex items-start space-x-4">
                          <img
                            src={app.photoUrl || app.user?.profile?.avatarUrl || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80'}
                            alt={app.legalName}
                            className="w-14 h-14 rounded-2xl object-cover border border-[#E4E4E7] shrink-0"
                          />
                          <div className="space-y-1">
                            <div className="flex items-center space-x-2">
                              <h4 className="font-extrabold text-sm text-[#111111]">{app.legalName}</h4>
                              <span className="text-xs text-[#71717A] font-semibold">({app.age} yrs)</span>
                              <span className="px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800 text-[10px] font-bold">
                                ₹299 Paid
                              </span>
                            </div>

                            <p className="text-xs font-medium text-[#52525B]">
                              {app.profession} • Call Rate: <span className="font-bold text-[#111111]">{app.videoCallPrice} coins/min</span>
                            </p>

                            <div className="flex items-center space-x-3 text-[11px] text-[#71717A]">
                              <span>ID: {app.govtIdType}</span>
                              {app.payoutUpiId && <span>UPI: {app.payoutUpiId}</span>}
                              {app.socialHandle && (
                                <span className="text-[#111111] font-semibold">@{app.socialHandle}</span>
                              )}
                            </div>
                          </div>
                        </div>

                        <div className="flex items-center space-x-2 self-end md:self-center">
                          <button
                            onClick={() => setSelectedKycApp(app)}
                            className="px-3 py-1.5 rounded-xl border border-[#E4E4E7] text-xs font-bold text-[#52525B] hover:bg-[#F4F4F5] flex items-center space-x-1"
                          >
                            <Eye className="w-3.5 h-3.5" />
                            <span>Inspect KYC</span>
                          </button>

                          <button
                            onClick={() => setRejectingAppId(app.id)}
                            className="px-3 py-1.5 rounded-xl border border-rose-200 text-rose-700 bg-rose-50 text-xs font-bold hover:bg-rose-100 flex items-center space-x-1"
                          >
                            <XCircle className="w-3.5 h-3.5" />
                            <span>Reject</span>
                          </button>

                          <button
                            onClick={() => handleApprove(app.id)}
                            className="px-3.5 py-1.5 rounded-xl bg-[#111111] text-white text-xs font-bold hover:bg-[#27272A] shadow-sm flex items-center space-x-1"
                          >
                            <CheckCircle2 className="w-3.5 h-3.5 text-emerald-400" />
                            <span>Approve & Make Live</span>
                          </button>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            )}

            {/* TAB 2: ACTIVE CREATORS DIRECTORY */}
            {activeTab === 'directory' && (
              <div className="bg-white rounded-2xl border border-[#E4E4E7] shadow-sm overflow-hidden">
                <div className="p-5 border-b border-[#F4F4F5] flex items-center justify-between">
                  <div>
                    <h3 className="font-bold text-sm text-[#111111]">Active Creators Directory</h3>
                    <p className="text-xs text-[#71717A]">
                      Manage live profiles, toggle homepage feature, or activate/deactivate accounts.
                    </p>
                  </div>
                </div>

                <div className="overflow-x-auto">
                  <table className="w-full text-left border-collapse text-xs">
                    <thead>
                      <tr className="bg-[#FAFAFA] border-b border-[#E4E4E7] text-[#71717A] uppercase text-[10px] font-bold tracking-wider">
                        <th className="py-3 px-4">Creator</th>
                        <th className="py-3 px-4">Profession & Pricing</th>
                        <th className="py-3 px-4">Live Status</th>
                        <th className="py-3 px-4">Home Feature</th>
                        <th className="py-3 px-4 text-right">Actions</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-[#F4F4F5]">
                      {creators.length === 0 ? (
                        <tr>
                          <td colSpan={5} className="py-12 text-center text-[#A1A1AA]">
                            No creators in database yet. Click "+ Add Creator" or approve from queue.
                          </td>
                        </tr>
                      ) : (
                        creators.map((c) => (
                          <tr key={c.id} className="hover:bg-[#FAFAFA] transition">
                            <td className="py-3.5 px-4">
                              <div className="flex items-center space-x-3">
                                <img
                                  src={c.photoUrl || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80'}
                                  alt={c.name}
                                  className="w-10 h-10 rounded-xl object-cover border border-[#E4E4E7]"
                                />
                                <div>
                                  <div className="font-extrabold text-[#111111]">{c.name}</div>
                                  <div className="text-[11px] text-[#71717A]">{c.age} yrs • {c.phone}</div>
                                </div>
                              </div>
                            </td>

                            <td className="py-3.5 px-4">
                              <div className="font-semibold text-[#111111]">{c.profession}</div>
                              <div className="text-[#71717A]">{c.videoCallPrice} coins/min (Video)</div>
                            </td>

                            <td className="py-3.5 px-4">
                              <button
                                onClick={() => handleToggleCreatorActive(c.id, c.isActive)}
                                className={`px-2.5 py-1 rounded-full text-[10px] font-bold border transition ${
                                  c.isActive
                                    ? 'bg-emerald-50 text-emerald-800 border-emerald-200'
                                    : 'bg-zinc-100 text-zinc-600 border-zinc-300'
                                }`}
                              >
                                {c.isActive ? 'Active (Live)' : 'Inactive (Hidden)'}
                              </button>
                            </td>

                            <td className="py-3.5 px-4">
                              <button
                                onClick={() => handleToggleCreatorFeatured(c.id, c.isFeatured)}
                                className={`px-2.5 py-1 rounded-full text-[10px] font-bold border transition ${
                                  c.isFeatured
                                    ? 'bg-[#111111] text-white border-[#111111]'
                                    : 'bg-white text-[#71717A] border-[#E4E4E7]'
                                }`}
                              >
                                {c.isFeatured ? '★ Featured on Top' : 'Standard'}
                              </button>
                            </td>

                            <td className="py-3.5 px-4 text-right">
                              <button
                                onClick={() => handleToggleCreatorActive(c.id, true)}
                                className="text-xs font-semibold text-[#71717A] hover:text-[#111111] underline"
                              >
                                Toggle State
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

            {/* TAB 3: ADD NEW CREATOR MANUALLY */}
            {activeTab === 'add' && (
              <div className="bg-white rounded-2xl border border-[#E4E4E7] p-6 shadow-sm">
                <div className="mb-6">
                  <h3 className="font-bold text-base text-[#111111]">Direct Creator Onboarding</h3>
                  <p className="text-xs text-[#71717A]">
                    Add a creator profile directly to the mobile app without manual mobile signup.
                  </p>
                </div>

                <form onSubmit={handleCreateDirectCreator} className="space-y-4">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-xs font-semibold text-[#52525B] mb-1">
                        Creator Full Name *
                      </label>
                      <input
                        type="text"
                        required
                        value={newCreatorForm.name}
                        onChange={(e) => setNewCreatorForm({ ...newCreatorForm, name: e.target.value })}
                        placeholder="e.g. Aanya Singhania"
                        className="w-full px-3.5 py-2.5 rounded-xl border border-[#E4E4E7] text-xs font-medium focus:ring-2 focus:ring-[#111111] outline-none"
                      />
                    </div>

                    <div>
                      <label className="block text-xs font-semibold text-[#52525B] mb-1">
                        Age (Years)
                      </label>
                      <input
                        type="number"
                        min="18"
                        max="80"
                        value={newCreatorForm.age}
                        onChange={(e) => setNewCreatorForm({ ...newCreatorForm, age: Number(e.target.value) })}
                        className="w-full px-3.5 py-2.5 rounded-xl border border-[#E4E4E7] text-xs font-medium focus:ring-2 focus:ring-[#111111] outline-none"
                      />
                    </div>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-xs font-semibold text-[#52525B] mb-1">
                        Profession / Category *
                      </label>
                      <input
                        type="text"
                        required
                        value={newCreatorForm.profession}
                        onChange={(e) => setNewCreatorForm({ ...newCreatorForm, profession: e.target.value })}
                        placeholder="e.g. Relationship Coach / Lifestyle"
                        className="w-full px-3.5 py-2.5 rounded-xl border border-[#E4E4E7] text-xs font-medium focus:ring-2 focus:ring-[#111111] outline-none"
                      />
                    </div>

                    <div>
                      <label className="block text-xs font-semibold text-[#52525B] mb-1">
                        Video Call Price (Coins/Min)
                      </label>
                      <input
                        type="number"
                        value={newCreatorForm.videoCallPrice}
                        onChange={(e) => setNewCreatorForm({ ...newCreatorForm, videoCallPrice: Number(e.target.value) })}
                        className="w-full px-3.5 py-2.5 rounded-xl border border-[#E4E4E7] text-xs font-medium focus:ring-2 focus:ring-[#111111] outline-none"
                      />
                    </div>
                  </div>

                  <div>
                    <label className="block text-xs font-semibold text-[#52525B] mb-1">
                      Profile Photo Image URL *
                    </label>
                    <input
                      type="url"
                      required
                      value={newCreatorForm.photoUrl}
                      onChange={(e) => setNewCreatorForm({ ...newCreatorForm, photoUrl: e.target.value })}
                      placeholder="https://..."
                      className="w-full px-3.5 py-2.5 rounded-xl border border-[#E4E4E7] text-xs font-medium focus:ring-2 focus:ring-[#111111] outline-none"
                    />
                  </div>

                  <div>
                    <label className="block text-xs font-semibold text-[#52525B] mb-1">
                      Creator Bio / Description
                    </label>
                    <textarea
                      rows={2}
                      value={newCreatorForm.bio}
                      onChange={(e) => setNewCreatorForm({ ...newCreatorForm, bio: e.target.value })}
                      className="w-full px-3.5 py-2.5 rounded-xl border border-[#E4E4E7] text-xs font-medium focus:ring-2 focus:ring-[#111111] outline-none"
                    />
                  </div>

                  <div className="flex items-center space-x-6 pt-2">
                    <label className="flex items-center space-x-2 text-xs font-semibold cursor-pointer">
                      <input
                        type="checkbox"
                        checked={newCreatorForm.isActive}
                        onChange={(e) => setNewCreatorForm({ ...newCreatorForm, isActive: e.target.checked })}
                        className="rounded border-[#E4E4E7]"
                      />
                      <span>Publish as Active (Visible immediately)</span>
                    </label>

                    <label className="flex items-center space-x-2 text-xs font-semibold cursor-pointer">
                      <input
                        type="checkbox"
                        checked={newCreatorForm.isFeatured}
                        onChange={(e) => setNewCreatorForm({ ...newCreatorForm, isFeatured: e.target.checked })}
                        className="rounded border-[#E4E4E7]"
                      />
                      <span>Pin to Top of Feed (Featured)</span>
                    </label>
                  </div>

                  <div className="pt-4 flex justify-end">
                    <button
                      type="submit"
                      className="px-6 py-2.5 rounded-xl bg-[#111111] text-white text-xs font-bold hover:bg-[#27272A] shadow-sm transition"
                    >
                      Publish Creator to Mobile App
                    </button>
                  </div>
                </form>
              </div>
            )}
          </section>

        </div>
      </main>

      {/* KYC Inspector Modal */}
      {selectedKycApp && (
        <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl max-w-lg w-full p-6 shadow-2xl border border-[#E4E4E7] space-y-5">
            <div className="flex items-center justify-between border-b border-[#F4F4F5] pb-3">
              <h3 className="font-extrabold text-base">KYC Document Inspection</h3>
              <button
                onClick={() => setSelectedKycApp(null)}
                className="text-[#71717A] hover:text-[#111111] font-bold"
              >
                ✕
              </button>
            </div>

            <div className="space-y-4 text-xs">
              <div className="flex items-center space-x-4">
                <img
                  src={selectedKycApp.photoUrl || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80'}
                  alt={selectedKycApp.legalName}
                  className="w-16 h-16 rounded-2xl object-cover border border-[#E4E4E7]"
                />
                <div>
                  <h4 className="font-bold text-sm">{selectedKycApp.legalName} ({selectedKycApp.age} yrs)</h4>
                  <p className="text-[#71717A]">{selectedKycApp.profession}</p>
                  <p className="text-[#52525B]">Payout UPI: <span className="font-bold">{selectedKycApp.payoutUpiId || 'Not provided'}</span></p>
                </div>
              </div>

              <div className="p-4 rounded-xl bg-[#FAFAFA] border border-[#E4E4E7] space-y-2">
                <div className="font-bold text-[#111111]">Document Details</div>
                <div className="flex justify-between text-[#71717A]">
                  <span>Govt ID Type:</span>
                  <span className="font-semibold text-[#111111]">{selectedKycApp.govtIdType}</span>
                </div>
                <div className="flex justify-between text-[#71717A]">
                  <span>Subscription Status:</span>
                  <span className="font-semibold text-emerald-700">₹299/mo Paid</span>
                </div>
                <div className="flex justify-between text-[#71717A]">
                  <span>Social Handle:</span>
                  <span className="font-semibold text-[#111111]">@{selectedKycApp.socialHandle || 'none'}</span>
                </div>
              </div>

              <div className="flex items-center justify-end space-x-3 pt-2">
                <button
                  onClick={() => {
                    setRejectingAppId(selectedKycApp.id);
                    setSelectedKycApp(null);
                  }}
                  className="px-4 py-2 rounded-xl border border-rose-200 text-rose-700 text-xs font-bold hover:bg-rose-50"
                >
                  Reject Application
                </button>
                <button
                  onClick={() => handleApprove(selectedKycApp.id)}
                  className="px-5 py-2 rounded-xl bg-[#111111] text-white text-xs font-bold hover:bg-[#27272A]"
                >
                  Approve & Publish to Feed
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Rejection Reason Modal */}
      {rejectingAppId && (
        <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl max-w-md w-full p-6 shadow-2xl border border-[#E4E4E7] space-y-4">
            <h3 className="font-extrabold text-base text-rose-700">Reject Application</h3>
            <p className="text-xs text-[#71717A]">
              Provide feedback for why this application was not approved. The applicant can re-submit after fixing.
            </p>

            <textarea
              rows={3}
              value={rejectionReason}
              onChange={(e) => setRejectionReason(e.target.value)}
              placeholder="e.g. Identity proof was blurry, or age was below 18."
              className="w-full px-3.5 py-2.5 rounded-xl border border-[#E4E4E7] text-xs font-medium focus:ring-2 focus:ring-rose-500 outline-none"
            />

            <div className="flex items-center justify-end space-x-2 pt-2">
              <button
                onClick={() => {
                  setRejectingAppId(null);
                  setRejectionReason('');
                }}
                className="px-4 py-2 rounded-xl border border-[#E4E4E7] text-xs font-bold text-[#71717A]"
              >
                Cancel
              </button>
              <button
                onClick={handleReject}
                className="px-4 py-2 rounded-xl bg-rose-600 text-white text-xs font-bold hover:bg-rose-700"
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

