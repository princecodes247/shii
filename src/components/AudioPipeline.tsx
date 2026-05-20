import React from 'react';
import styles from './AudioPipeline.module.css';

export default function AudioPipeline() {
  return (
    <div className={styles.pipelineWrapper}>
      <div className={styles.superPipeline}>
        {/* Left Side: Flowing audio stream */}
        <div className={styles.spLeft}>
          <div className={styles.audioStream}>
            {Array.from({ length: 120 }).map((_, i) => {
              const scaleFactor = 1.5 + Math.random() * 4;
              return (
                <div
                  key={`s-${i}`}
                  className={styles.streamBar}
                  style={{
                    animationDelay: `${i * 0.1}s`,
                    '--scale-factor': scaleFactor
                  } as React.CSSProperties}
                ></div>
              );
            })}
          </div>
        </div>

        {/* Center: Energy Field Converter (Absolute) */}
        <div className={styles.energyField}></div>

        {/* Right Side: Curvy Marquee Decoded Text */}
        <div className={styles.spRight}>
          <svg className={styles.textCurveSvg} viewBox="0 0 1000 300" preserveAspectRatio="xMinYMid slice">
            <path id="textPathOut" d="M0,150 C300,150 400,100 1000,50" fill="none" />
            <text className={styles.decodedText}>
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
