import styles from './page.module.css';

export default function Home() {
  return (
    <div className={styles.container}>
      
      {/* Ambient Animated Background */}
      <div className={styles.ambientBg}>
        <div className={styles.orb1}></div>
        <div className={styles.orb2}></div>
        <div className={styles.orb3}></div>
      </div>

      <header className={styles.header}>
        <div className={styles.logo}>Shii</div>
        <nav className={styles.nav}>
          <a href="#features" className={styles.navLink}>Features</a>
          <a href="#pricing" className={styles.navLink}>Pricing</a>
          <button className={styles.loginBtn}>Sign In</button>
        </nav>
      </header>

      <main className={styles.bentoGrid}>
        
        {/* Main Hero Bento */}
        <div className={`${styles.bentoCard} ${styles.heroBento}`}>
          <h1 className={styles.heroTitle}>
            Meetings, magically distilled.
          </h1>
          <p className={styles.heroSubtitle}>
            Shii listens, understands, and extracts the perfect summary and action items from every conversation. Your intelligent meeting sidekick.
          </p>
          <div className={styles.ctaContainer}>
            <button className={styles.primaryBtn}>Start for free</button>
            <button className={styles.secondaryBtn}>Watch demo</button>
          </div>
        </div>

        {/* Feature 1: AI Summaries */}
        <div className={`${styles.bentoCard} ${styles.featureBento}`}>
          <div className={styles.iconWrapper}>
            <span className={styles.sparkleIcon}>✨</span>
          </div>
          <h3 className={styles.bentoTitle}>Brilliant Summaries</h3>
          <p className={styles.bentoDesc}>Flawless recaps that capture context, not just words.</p>
          
          <div className={styles.mockupContainer}>
             <div className={`${styles.mockupItem} ${styles.mockupItem1}`}>
                <div style={{flex: 1}}>
                  <div style={{height: '10px', width: '30%', background: '#fff', borderRadius: '5px', marginBottom: '8px'}}></div>
                  <div style={{height: '8px', width: '90%', background: 'rgba(255,255,255,0.4)', borderRadius: '4px'}}></div>
                </div>
             </div>
             <div className={`${styles.mockupItem} ${styles.mockupItem2}`}>
                <div style={{flex: 1}}>
                  <div style={{height: '10px', width: '40%', background: '#fff', borderRadius: '5px', marginBottom: '8px'}}></div>
                  <div style={{height: '8px', width: '70%', background: 'rgba(255,255,255,0.4)', borderRadius: '4px'}}></div>
                </div>
             </div>
          </div>
        </div>

        {/* Tall Feature: Real-time Sync */}
        <div className={`${styles.bentoCard} ${styles.tallBento}`}>
          <div style={{display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', zIndex: 2}}>
             <div className={styles.iconWrapper}>
               <span className={styles.micIcon}>🎙️</span>
             </div>
             <div style={{background: 'rgba(244, 63, 94, 0.2)', padding: '0.4rem 0.8rem', borderRadius: '20px', display: 'flex', alignItems: 'center', gap: '8px'}}>
                <div className={styles.pulseDot}></div>
                <span style={{fontSize: '0.8rem', fontWeight: 600, color: '#f43f5e'}}>Live</span>
             </div>
          </div>
          
          <h3 className={styles.bentoTitle} style={{marginTop: 'auto'}}>Lightning Fast</h3>
          <p className={styles.bentoDesc}>Transcribe instantly as you speak. No delays, absolute accuracy.</p>
          
          <div className={styles.waveform}>
             <div className={styles.bar} style={{animationDelay: '0.1s', height: '40%'}}></div>
             <div className={styles.bar} style={{animationDelay: '0.4s', height: '80%'}}></div>
             <div className={styles.bar} style={{animationDelay: '0.2s', height: '60%'}}></div>
             <div className={styles.bar} style={{animationDelay: '0.5s', height: '100%'}}></div>
             <div className={styles.bar} style={{animationDelay: '0.3s', height: '50%'}}></div>
             <div className={styles.bar} style={{animationDelay: '0.6s', height: '90%'}}></div>
             <div className={styles.bar} style={{animationDelay: '0.1s', height: '30%'}}></div>
             <div className={styles.bar} style={{animationDelay: '0.7s', height: '70%'}}></div>
          </div>
        </div>

        {/* Feature 2: Action Items */}
        <div className={`${styles.bentoCard} ${styles.featureBento}`}>
          <div className={styles.iconWrapper}>
            <span className={styles.boltIcon}>⚡</span>
          </div>
          <h3 className={styles.bentoTitle}>Auto-Tasking</h3>
          <p className={styles.bentoDesc}>Action items are instantly detected and assigned.</p>
          
          <div className={styles.mockupContainer}>
             <div style={{display: 'flex', alignItems: 'center', gap: '1rem', background: 'rgba(0,0,0,0.3)', padding: '1rem', borderRadius: '12px', border: '1px solid rgba(255,255,255,0.05)'}}>
                <div style={{width: '20px', height: '20px', borderRadius: '6px', background: 'linear-gradient(135deg, #60a5fa, #3b82f6)', display: 'flex', alignItems: 'center', justify: 'center'}}><span style={{color: '#fff', fontSize: '10px'}}>✓</span></div>
                <div style={{flex: 1}}>
                   <div style={{height: '10px', width: '80%', background: '#fff', borderRadius: '5px', marginBottom: '6px'}}></div>
                   <div style={{height: '8px', width: '30%', background: 'rgba(255,255,255,0.3)', borderRadius: '4px'}}></div>
                </div>
                <div style={{width: '24px', height: '24px', borderRadius: '50%', background: '#8b5cf6', border: '2px solid #222'}}></div>
             </div>
          </div>
        </div>

        {/* Wide Feature: Integrations */}
        <div className={`${styles.bentoCard} ${styles.wideBento}`}>
          <div style={{maxWidth: '400px', zIndex: 2}}>
             <h3 className={styles.bentoTitle}>Connected Ecosystem</h3>
             <p className={styles.bentoDesc}>Works flawlessly with Zoom, Google Meet, Teams, Notion, and Slack.</p>
          </div>
          <div style={{display: 'flex', gap: '1rem', zIndex: 2, flexWrap: 'wrap'}}>
             {['📹', '📅', '💬', '📝', '⚡'].map((icon, i) => (
                <div key={i} style={{width: '64px', height: '64px', borderRadius: '18px', background: 'rgba(255,255,255,0.05)', border: '1px solid rgba(255,255,255,0.1)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '1.8rem', backdropFilter: 'blur(10px)', boxShadow: '0 10px 20px rgba(0,0,0,0.3)', transform: `translateY(${i % 2 === 0 ? '0' : '-10px'})`}}>
                  {icon}
                </div>
             ))}
          </div>
        </div>

      </main>
    </div>
  );
}
