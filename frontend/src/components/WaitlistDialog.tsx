'use client';

import { useState, useEffect, useCallback } from 'react';

export default function WaitlistDialog({ onClose }: { onClose: () => void }) {
  const [email, setEmail] = useState('');
  const [submitted, setSubmitted] = useState(false);

  const handleKeyDown = useCallback((e: KeyboardEvent) => {
    if (e.key === 'Escape') onClose();
  }, [onClose]);

  useEffect(() => {
    document.addEventListener('keydown', handleKeyDown);
    document.body.style.overflow = 'hidden';
    return () => {
      document.removeEventListener('keydown', handleKeyDown);
      document.body.style.overflow = '';
    };
  }, [handleKeyDown]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (email) setSubmitted(true);
  };

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm"
      onClick={onClose}
    >
      <div
        className="relative w-full max-w-md mx-4 bg-card border border-card-border rounded-3xl p-8 shadow-2xl"
        onClick={(e) => e.stopPropagation()}
      >
        <button
          onClick={onClose}
          className="absolute top-4 right-4 text-text-muted hover:text-text-main transition-colors cursor-pointer"
        >
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M18 6L6 18" /><path d="M6 6l12 12" /></svg>
        </button>

        {submitted ? (
          <div className="text-center py-6">
            <div className="text-3xl mb-4">&#10003;</div>
            <h3 className="text-xl font-semibold text-white mb-2">You&apos;re on the list!</h3>
            <p className="text-text-muted">We&apos;ll be in touch soon.</p>
          </div>
        ) : (
          <>
            <h3 className="text-xl font-semibold text-white mb-2">Join the waitlist</h3>
            <p className="text-text-muted text-sm mb-6">
              Get early access and help shape how Shii works.
            </p>
            <form onSubmit={handleSubmit} className="flex flex-col gap-4">
              <input
                type="email"
                required
                placeholder="Enter your email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full px-4 py-3 rounded-xl bg-bg border border-card-border text-text-main text-sm outline-none focus:border-accent transition-colors placeholder:text-zinc-600"
              />
              <button
                type="submit"
                className="w-full px-6 py-3 rounded-full bg-accent text-black font-semibold text-sm border-none cursor-pointer transition-colors hover:bg-accent-hover"
              >
                Join waitlist
              </button>
            </form>
          </>
        )}
      </div>
    </div>
  );
}
