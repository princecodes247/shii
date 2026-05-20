import {
  AiMagicIcon,
  AiMicIcon,
  CheckmarkBadge01Icon,
  Video01Icon,
  Calendar01Icon,
  Message01Icon,
  AppleIcon,
  GithubIcon,
  StarIcon,
  OpenSourceIcon
} from 'hugeicons-react';
import AudioPipeline from '@/components/AudioPipeline';

export default function Home() {
  return (
    <div className="min-h-screen flex flex-col items-center pb-16 relative">

      {/* Ambient Animated Background */}
      <div className="glow-bg absolute -top-[10%] left-1/2 -translate-x-1/2 w-[800px] h-[800px] z-0 pointer-events-none" />

      <header className="w-full max-w-[1000px] px-8 py-6 flex justify-between items-center z-100 relative">
        <div className="text-xl font-bold tracking-tight text-text-main flex items-center gap-2">
          <div className="logo-icon w-6 h-6 rounded-[6px]" />
          Shii
        </div>
        <nav className="flex gap-8 items-center">
          <a
            href="https://github.com/shii"
            target="_blank"
            rel="noopener noreferrer"
            className="text-sm font-medium text-text-main flex items-center gap-2 px-4 py-2 rounded-full border border-card-border bg-card transition-all duration-200 hover:border-white/20 hover:bg-[#1a1a1e]"
          >
            <StarIcon size={14} />
            Star on GitHub
            <GithubIcon size={16} />
          </a>
        </nav>
      </header>

      <main className="bento-grid grid grid-cols-3 auto-rows-[220px] gap-4 w-full max-w-[1000px] mt-4 px-8 z-10">

        {/* Main Hero Bento */}
        <div className="hero-bento col-span-3 row-span-2 flex flex-col items-center justify-center text-center bg-transparent border-none rounded-3xl p-16 px-8 pb-8 relative overflow-hidden">
          <h1 className="hero-title text-[4.5rem] font-bold leading-[1.05] tracking-[-0.04em] mb-6 text-white relative z-2">
            Capture meetings with<br />
            Intelligent AI and <span className="text-accent font-semibold">precise</span><br />
            insights
          </h1>
          <p className="text-xl font-normal text-text-muted max-w-[600px] mx-auto mb-10 leading-normal relative z-2">
            Save <span className="text-accent font-semibold">50+ hours</span> of manual note-taking per month
          </p>
          <div className="flex gap-4 justify-center z-2 relative">
            <button className="px-8 py-3 rounded-full bg-accent text-black font-semibold text-base border-none cursor-pointer transition-colors duration-200 hover:bg-accent-hover">
              Buy $89 <span className="line-through opacity-50">$119</span>
            </button>
            <button className="px-8 py-3 rounded-full bg-[#18181b] text-white font-medium text-base border border-card-border cursor-pointer flex items-center gap-2 transition-colors duration-200 hover:bg-card-border">
              Download
              <AppleIcon size={16} />
            </button>
          </div>
        </div>

        <AudioPipeline />

        {/* Feature 1: AI Summaries */}
        <div className="feature-bento col-span-1 row-span-1 bg-card border border-card-border rounded-3xl p-8 flex flex-col relative overflow-hidden transition-colors duration-300 hover:border-white/15">
          <div className="text-text-muted mb-3 flex items-center justify-start">
            <AiMagicIcon size={28} />
          </div>
          <h3 className="text-lg font-semibold tracking-tight mb-1 text-white flex items-center gap-2">AI Summaries</h3>
          <p className="text-[0.95rem] text-text-muted leading-normal mb-auto">Flawless recaps that capture context.</p>
        </div>

        {/* Feature 2: Real-time Sync */}
        <div className="feature-bento col-span-1 row-span-1 bg-card border border-card-border rounded-3xl p-8 flex flex-col relative overflow-hidden transition-colors duration-300 hover:border-white/15">
          <div className="text-text-muted mb-3 flex items-center justify-start">
            <AiMicIcon size={28} />
          </div>
          <h3 className="text-lg font-semibold tracking-tight mb-1 text-white flex items-center gap-2">Live Sync</h3>
          <p className="text-[0.95rem] text-text-muted leading-normal mb-auto">Transcribe instantly as you speak.</p>

          {/* Real Audio Waveform Simulation */}
          <div className="flex gap-[3px] h-20 w-full mt-2.5 justify-between items-end">
            {Array.from({ length: 24 }).map((_, i) => {
              const dur = 0.8 + Math.random() * 1.5;
              const delay = Math.random() * -2;
              return (
                <div
                  key={i}
                  className="audio-bar w-[5px] rounded-[3px]"
                  style={{
                    animationDuration: `${dur}s`,
                    animationDelay: `${delay}s`,
                  }}
                />
              );
            })}
          </div>
        </div>

        {/* Feature 3: Action Items */}
        <div className="feature-bento col-span-1 row-span-1 bg-card border border-card-border rounded-3xl p-8 flex flex-col relative overflow-hidden transition-colors duration-300 hover:border-white/15">
          <div className="text-text-muted mb-3 flex items-center justify-start">
            <CheckmarkBadge01Icon size={28} />
          </div>
          <h3 className="text-lg font-semibold tracking-tight mb-1 text-white flex items-center gap-2">Auto-Tasking</h3>
          <p className="text-[0.95rem] text-text-muted leading-normal mb-auto">Tasks are detected and assigned.</p>
        </div>

        {/* Feature 4: Open Source */}
        <div className="feature-bento col-span-1 row-span-1 bg-card border border-card-border rounded-3xl p-8 flex flex-col relative overflow-hidden transition-colors duration-300 hover:border-white/15">
          <div className="text-text-muted mb-3 flex items-center justify-start">
            <OpenSourceIcon size={28} />
          </div>
          <h3 className="text-lg font-semibold tracking-tight mb-1 text-white flex items-center gap-2">Open Source</h3>
          <p className="text-[0.95rem] text-text-muted leading-normal mb-auto">Fully transparent. Fork, extend, and self-host.</p>
        </div>

        {/* Wide Feature: Integrations */}
        <div className="wide-bento col-span-2 row-span-1 bg-card border border-card-border rounded-3xl flex flex-row items-center justify-between relative overflow-hidden transition-colors duration-300 hover:border-white/15 pl-0">
          <div className="app-window-inner bg-bg w-[250px] h-full p-4 flex flex-col">
            <div className="flex gap-1.5 mb-4">
              <div className="w-2.5 h-2.5 rounded-full bg-[#ef4444]" />
              <div className="w-2.5 h-2.5 rounded-full bg-[#f59e0b]" />
              <div className="w-2.5 h-2.5 rounded-full bg-chip-green" />
            </div>
            <div className="text-[0.8rem] text-text-muted mb-2 font-semibold">Integrations</div>

            <div className="app-row flex items-center gap-3 p-2.5 rounded-lg mb-2">
              <div className="w-2 h-2 bg-chip-green rounded-full" />
              <span className="text-[0.85rem] text-text-main flex-1">Zoom</span>
              <span className="text-xs text-zinc-500">1</span>
            </div>
            <div className="app-row flex items-center gap-3 p-2.5 rounded-lg mb-2">
              <div className="w-2 h-2 bg-chip-green rounded-full" />
              <span className="text-[0.85rem] text-text-main flex-1">Meet</span>
              <span className="text-xs text-zinc-500">1</span>
            </div>
          </div>

          <div className="pr-8">
            <h3 className="text-lg font-semibold tracking-tight mb-1 text-white flex items-center gap-2">Connected Ecosystem</h3>
            <p className="text-[0.95rem] text-text-muted leading-normal mb-6">Works seamlessly with your tools.</p>
            <div className="flex gap-4">
              <div className="p-2 rounded-lg bg-card-border text-text-main"><Video01Icon size={20} /></div>
              <div className="p-2 rounded-lg bg-card-border text-text-main"><Calendar01Icon size={20} /></div>
              <div className="p-2 rounded-lg bg-card-border text-text-main"><Message01Icon size={20} /></div>
            </div>
          </div>
        </div>

      </main>
    </div>
  );
}
