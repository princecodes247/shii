import React, { useMemo } from 'react';

const streamBars = Array.from({ length: 120 }).map((_, i) => ({
  scaleFactor: 1.5 + Math.random() * 4,
  delay: -(i * 0.1),
})).reverse();

export default function AudioPipeline() {
  const bars = useMemo(() => streamBars, []);
  return (
    <div className="pipeline-wrapper relative w-full h-[200px] mt-8 mb-4">
      <div className="absolute -top-[30px] left-0 w-full h-full flex items-center justify-between pointer-events-none z-0 opacity-40">

        {/* Left Side: Flowing audio stream */}
        <div className="w-1/2 h-full relative flex items-center justify-end">
          <div className="audio-stream flex items-center justify-end gap-1.5 h-[150px] w-full pr-1 overflow-hidden">
            {bars.map((bar, i) => (
              <div
                key={`s-${i}`}
                className="stream-bar w-1 h-[15px] bg-accent rounded-sm opacity-80 origin-center"
                style={{
                  '--scale-factor': bar.scaleFactor,
                  animation: `pulseSound 1.5s ease-in-out ${bar.delay}s infinite`,
                } as React.CSSProperties}
              />
            ))}
          </div>
        </div>

        {/* Center: Energy Field Converter */}
        <div className="energy-field absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-1 h-[250px] z-10" />

        {/* Right Side: Curvy Marquee Decoded Text */}
        <div className="w-1/2 h-full relative">
          <svg className="text-curve-svg w-full h-full absolute top-0 left-0" viewBox="0 0 1000 300" preserveAspectRatio="xMinYMid slice">
            <path id="textPathOut" d="M0,150 C300,150 400,100 1000,50" fill="none" />
            <text className="decoded-text font-mono text-[15px] tracking-wider" fill="#a1a1aa">
              <textPath href="#textPathOut" startOffset="0%">
                <animate attributeName="startOffset" from="-400%" to="0%" begin="0s" dur="60s" repeatCount="indefinite" />
                {Array(20).fill("Alex: Numbers are up 20% this quarter. Sarah: Let's focus on retaining that growth. System: Action item created for Sarah. \u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0").join("")}
              </textPath>
            </text>
          </svg>
        </div>
      </div>
    </div>
  );
}
