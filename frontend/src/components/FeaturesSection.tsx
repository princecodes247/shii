import { useMemo } from 'react';
import {
  AiMagicIcon,
  AiMicIcon,
  Calendar01Icon,
  CheckmarkBadge01Icon,
  Message01Icon,
  OpenSourceIcon,
  Video01Icon,
} from 'hugeicons-react';

const features = [
  {
    icon: AiMagicIcon,
    title: 'AI Summaries',
    description: 'Flawless recaps that capture context.',
  },
  {
    icon: AiMicIcon,
    title: 'Live Sync',
    description: 'Transcribe instantly as you speak.',
    hasAudio: true,
  },
  {
    icon: CheckmarkBadge01Icon,
    title: 'Auto-Tasking',
    description: 'Tasks are detected and assigned.',
  },
  {
    icon: OpenSourceIcon,
    title: 'Open Source',
    description: 'Fully transparent. Fork, extend, and self-host.',
  },
];

const audioBars = Array.from({ length: 24 }).map(() => ({
  dur: 0.8 + Math.random() * 1.5,
  delay: Math.random() * -2,
}));

export default function FeaturesSection() {
  const bars = useMemo(() => audioBars, []);
  return (
    <section className="grid grid-cols-1 md:grid-cols-3 gap-4 w-full max-w-[1000px] px-8">
      {features.map((feature, i) => {
        const Icon = feature.icon;
        return (
          <div
            key={i}
            className="relative bg-card border border-card-border rounded-3xl p-8 flex flex-col relative overflow-hidden transition-colors duration-300 hover:border-white/15"
          >
            <div className="text-text-muted mb-3 flex items-center justify-start">
              <Icon size={28} />
            </div>
            <h3 className="text-lg font-semibold tracking-tight mb-1 text-white flex items-center gap-2">
              {feature.title}
            </h3>
            <p className="text-[0.95rem] text-text-muted leading-normal mb-auto">
              {feature.description}
            </p>
            {feature.hasAudio && (
              <div className="flex absolute bottom-0 left-0 gap-[3px] opacity-[0.01] h-20 w-full mt-2.5 justify-between items-end">
                {bars.map((bar, j) => (
                  <div
                    key={j}
                    className="audio-bar w-[5px] rounded-[3px]"
                    style={{
                      animationDuration: `${bar.dur}s`,
                      animationDelay: `${bar.delay}s`,
                    }}
                  />
                ))}
              </div>
            )}
          </div>
        );
      })}
      <div className="wide-bento min-h-[250px] md:col-span-2 bg-card border border-card-border rounded-3xl flex flex-row items-center justify-between relative transition-colors duration-300 hover:border-white/15 pl-0">
        <div className="app-window-inner rounded-tl-3xl md:rounded-l-3xl border border-card-border md:border-none overflow-hidden md:overflow-visible bg-bg w-[250px] h-full p-4 flex flex-col">
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
    </section>
  );
}
