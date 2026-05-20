import styles from './page.module.css';
import {
  AiMagicIcon,
  AiMicIcon,
  CheckmarkBadge01Icon,
  Video01Icon,
  Calendar01Icon,
  Message01Icon,
  AppleIcon
} from 'hugeicons-react';
import AudioPipeline from '@/components/AudioPipeline';

export default function Home() {
  return (
    <div className={styles.container}>

      {/* Ambient Animated Background */}
      <div className={styles.glowBg}></div>

      <header className={styles.header}>
        <div className={styles.logo}>
          <div className={styles.logoIcon}></div>
          Shii
        </div>
        <nav className={styles.nav}>
          <a href="#features" className={styles.navLink}>Features</a>
          <a href="#pricing" className={styles.navLink}>Pricing</a>
          <a href="#docs" className={styles.navLink}>Docs</a>
        </nav>
      </header>

      <main className={styles.bentoGrid}>

        {/* Main Hero Bento */}
        <div className={`${styles.bentoCard} ${styles.heroBento}`}>
          <h1 className={styles.heroTitle}>
            Capture meetings with<br />
            Intelligent AI and <span className={styles.highlightText}>precise</span><br />
            insights
          </h1>
          <p className={styles.heroSubtitle}>
            Save <span className={styles.highlightText} style={{ fontWeight: 600 }}>50+ hours</span> of manual note-taking per month
          </p>
          <div className={styles.ctaContainer}>
            <button className={styles.primaryBtn}>Buy $89 <span style={{ textDecoration: 'line-through', opacity: 0.5 }}>$119</span></button>
            <button className={styles.secondaryBtn}>
              Download
              <AppleIcon size={16} />
            </button>
          </div>
        </div>

        <AudioPipeline />
        {/* Feature 1: AI Summaries */}
        <div className={`${styles.bentoCard} ${styles.featureBento}`}>
          <div className={styles.iconWrapper}>
            <AiMagicIcon size={28} />
          </div>
          <h3 className={styles.bentoTitle}>AI Summaries</h3>
          <p className={styles.bentoDesc}>Flawless recaps that capture context.</p>
        </div>

        {/* Feature 2: Real-time Sync */}
        <div className={`${styles.bentoCard} ${styles.featureBento}`}>
          <div className={styles.iconWrapper}>
            <AiMicIcon size={28} />
          </div>
          <h3 className={styles.bentoTitle}>Live Sync</h3>
          <p className={styles.bentoDesc}>Transcribe instantly as you speak.</p>

          {/* Real Audio Waveform Simulation */}
          <div className={styles.realWaveform}>
            {Array.from({ length: 24 }).map((_, i) => {
              const dur = 0.8 + Math.random() * 1.5;
              const delay = Math.random() * -2;
              return (
                <div
                  key={i}
                  className={styles.audioBar}
                  style={{
                    animationDuration: `${dur}s`,
                    animationDelay: `${delay}s`,
                  }}
                ></div>
              );
            })}
          </div>
        </div>

        {/* Feature 3: Action Items */}
        <div className={`${styles.bentoCard} ${styles.featureBento}`}>
          <div className={styles.iconWrapper}>
            <CheckmarkBadge01Icon size={28} />
          </div>
          <h3 className={styles.bentoTitle}>Auto-Tasking</h3>
          <p className={styles.bentoDesc}>Tasks are detected and assigned.</p>
        </div>

        {/* Wide Feature: Integrations */}
        <div className={`${styles.bentoCard} ${styles.wideBento}`} style={{ paddingLeft: '0rem' }}>
          <div className={styles.appWindow}>
            <div className={styles.appHeader}>
              <div className={styles.dot} style={{ background: '#ef4444' }}></div>
              <div className={styles.dot} style={{ background: '#f59e0b' }}></div>
              <div className={styles.dot} style={{ background: '#22c55e' }}></div>
            </div>
            <div style={{ fontSize: '0.8rem', color: '#a1a1aa', marginBottom: '0.5rem', fontWeight: 600 }}>Integrations</div>

            <div className={styles.appRow}>
              <div style={{ width: 8, height: 8, background: '#22c55e', borderRadius: '50%' }}></div>
              <span style={{ fontSize: '0.85rem', color: '#fafafa', flex: 1 }}>Zoom</span>
              <span style={{ fontSize: '0.75rem', color: '#71717a' }}>1</span>
            </div>
            <div className={styles.appRow}>
              <div style={{ width: 8, height: 8, background: '#22c55e', borderRadius: '50%' }}></div>
              <span style={{ fontSize: '0.85rem', color: '#fafafa', flex: 1 }}>Meet</span>
              <span style={{ fontSize: '0.75rem', color: '#71717a' }}>1</span>
            </div>
          </div>

          <div style={{ paddingRight: '2rem' }}>
            <h3 className={styles.bentoTitle}>Connected Ecosystem</h3>
            <p className={styles.bentoDesc} style={{ marginBottom: '1.5rem' }}>Works seamlessly with your tools.</p>
            <div style={{ display: 'flex', gap: '1rem' }}>
              <div style={{ padding: '0.5rem', borderRadius: '8px', background: '#27272a', color: '#fafafa' }}><Video01Icon size={20} /></div>
              <div style={{ padding: '0.5rem', borderRadius: '8px', background: '#27272a', color: '#fafafa' }}><Calendar01Icon size={20} /></div>
              <div style={{ padding: '0.5rem', borderRadius: '8px', background: '#27272a', color: '#fafafa' }}><Message01Icon size={20} /></div>
            </div>
          </div>
        </div>

      </main>
    </div>
  );
}
