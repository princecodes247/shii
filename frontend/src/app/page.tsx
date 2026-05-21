'use client';

import { useState } from 'react';
import {
  AppleIcon,
  GithubIcon,
  StarIcon,
} from 'hugeicons-react';
import AudioPipeline from '@/components/AudioPipeline';
import FeaturesSection from '@/components/FeaturesSection';
import WaitlistDialog from '@/components/WaitlistDialog';
import Logo from '@/components/ui/logo';

export default function Home() {
  const [showDialog, setShowDialog] = useState(false);

  return (
    <div className="min-h-screen flex flex-col items-center relative">

      {/* Ambient Animated Background */}
      <div className="glow-bg absolute -top-[10%] left-1/2 -translate-x-1/2 w-[800px] h-[800px] z-0 pointer-events-none" />

      <header className="w-full max-w-[1000px] px-8 py-6 flex justify-between items-center z-100 relative">
        <div className="text-xl font-bold tracking-tight text-text-main flex items-center gap-2">
          {/* <div className="logo-icon w-6 h-6 rounded-[6px]" /> */}
          <Logo />
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

      <main className="flex flex-col items-center w-full z-10">

        {/* Hero Section */}
        <section className="w-full max-w-[1000px] mt-4 px-8">
          <div className="hero-bento flex flex-col items-center justify-center text-center bg-transparent border-none rounded-3xl p-16 px-8 pb-8 relative overflow-hidden">
            <h1 className="hero-title text-[4.5rem] font-bold leading-[1.05] tracking-[-0.04em] mb-6 text-white relative z-2">
              All your meeting shii,<br />
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-accent to-accent-hover font-semibold">handled.</span><br />
            </h1>
            <p className="text-xl font-normal text-text-muted max-w-[600px] mx-auto mb-10 leading-normal relative z-2">
              Capture <span className="text-transparent bg-clip-text bg-gradient-to-r from-accent to-accent-hover font-semibold">everything</span> and leave with structured notes and tasks.
            </p>
            <div className="flex gap-4 justify-center z-2 relative">
              <button
                onClick={() => setShowDialog(true)}
                className="px-8 py-3 rounded-full bg-accent text-black font-semibold text-base border-none cursor-pointer transition-colors duration-200 hover:bg-accent-hover"
              >
                Buy $9 <span className="line-through opacity-50">$39</span>
              </button>
              <button
                onClick={() => setShowDialog(true)}
                className="px-8 py-3 rounded-full bg-[#18181b] text-white font-medium text-base border border-card-border cursor-pointer flex items-center gap-2 transition-colors duration-200 hover:bg-card-border"
              >
                Download
                <AppleIcon size={16} />
              </button>
            </div>
          </div>
        </section>

        <AudioPipeline />

        <FeaturesSection />

      </main>

      <footer className="w-full py-6 flex items-center justify-center gap-1.5 text-sm text-zinc-600">
        built by <span className="text-zinc-500 font-medium">princecodes</span>
      </footer>

      {showDialog && <WaitlistDialog onClose={() => setShowDialog(false)} />}
    </div>
  );
}
