# Quiz Mode Input Component Style

This document contains a standalone, extracted version of the Quiz Mode input component (`ActiveTypingCard`). It includes the typing sound effect, character-level validation, and animation effects.

## Dependencies

Ensure you have the following packages installed:

```bash
npm install framer-motion clsx tailwind-merge
```

## Component Code

You can copy the following code into a new file (e.g., `QuizInput.tsx`) to use it.

```tsx
import React, { useState, useRef, useEffect } from 'react';
import { motion } from 'framer-motion';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

// --- Utility ---
function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// --- Hook: Typing Sound ---
function useTypingSound(enabled: boolean) {
  const acRef = useRef<AudioContext | null>(null);

  useEffect(() => {
    if (!acRef.current) {
      try {
        acRef.current = new (window.AudioContext || (window as any).webkitAudioContext)();
      } catch {}
    }
  }, []);

  const playKey = (type: 'char' | 'enter' | 'delete' = 'char') => {
    if (!acRef.current) return;
    try {
      const ac = acRef.current;
      if (ac.state === 'suspended') ac.resume();
      const osc = ac.createOscillator();
      const gain = ac.createGain();

      if (type === 'enter') {
        osc.frequency.value = 600;
        osc.type = 'sine';
        gain.gain.value = 0.05;
      } else if (type === 'delete') {
        osc.frequency.value = 300;
        osc.type = 'sawtooth';
        gain.gain.value = 0.02;
      } else {
        osc.frequency.value = 400 + Math.random() * 100;
        osc.type = 'triangle';
        gain.gain.value = 0.03;
      }

      osc.connect(gain);
      gain.connect(ac.destination);

      const now = ac.currentTime;
      osc.start(now);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.1);
      osc.stop(now + 0.1);
    } catch {}
  };

  return { playKey };
}

// --- Component: Quiz Input ---
interface QuizInputProps {
  targetEn: string;
  targetZh: string;
  onComplete: () => void;
  onRequestHint?: () => void;
}

export const QuizInput: React.FC<QuizInputProps> = ({
  targetEn,
  targetZh,
  onComplete,
  onRequestHint,
}) => {
  const [input, setInput] = useState('');
  const [isError, setIsError] = useState(false);
  const [highlight, setHighlight] = useState(false);
  const inputRef = useRef<HTMLInputElement>(null);
  const { playKey } = useTypingSound(true);

  // Auto-focus logic
  useEffect(() => {
    const t = window.setTimeout(() => inputRef.current?.focus(), 100);
    return () => window.clearTimeout(t);
  }, [targetEn]);

  // Handle Enter key
  const onKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    const k = e.key;
    if (k === 'Enter') {
      e.preventDefault();
      // Compare input with target (case-insensitive)
      if (input.trim().toLowerCase() === targetEn.trim().toLowerCase()) {
        playKey('enter');
        setInput('');
        onComplete();
      } else {
        // Error handling
        setIsError(true); 
        setHighlight(true);
        
        // Reset visual error state after animation
        setTimeout(() => {
            setIsError(false);
            setHighlight(false);
        }, 1000);
        
        onRequestHint?.();
      }
      return;
    }

    if (k.length === 1 && !e.metaKey && !e.ctrlKey && !e.altKey) {
      playKey('char');
    } else if (k === 'Backspace') {
      playKey('delete');
    }
  };

  const onChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setInput(e.target.value);
    setIsError(false);
  };

  // Character mapping logic
  const targetChars = targetEn.split('');
  const inputChars = input.split('');
  const maxLength = Math.max(targetChars.length, inputChars.length);
  const displayChars = Array.from({ length: maxLength }, (_, i) => targetChars[i] || '');

  return (
    <motion.div
      layoutId="active-card"
      initial={{ opacity: 0, scale: 0.98, y: 20 }}
      animate={{ opacity: 1, scale: 1, y: 0 }}
      transition={{ type: 'spring', bounce: 0.2, duration: 0.5 }}
      className={cn(
        "relative w-full max-w-3xl mx-auto p-8 rounded-2xl overflow-hidden transition-all duration-300",
        "bg-white border border-gray-200 shadow-xl",
        isError
          ? "border-red-500/40 shadow-[0_0_30px_rgba(239,68,68,0.15)]"
          : "shadow-gray-200/50 hover:bg-gray-50"
      )}
      onClick={() => inputRef.current?.focus()}
    >
      {/* Error Flash Animation Overlay */}
      {isError && (
        <motion.div
          className="absolute inset-0 border-2 border-red-500/20 rounded-2xl pointer-events-none z-50"
          initial={{ x: 0 }}
          animate={{ x: [-6, 6, -4, 4, -2, 2, 0] }}
          transition={{ duration: 0.4 }}
        />
      )}

      {/* Top Gradient Decorative Bar */}
      <div
        className={cn(
          "absolute top-0 left-1/2 -translate-x-1/2 h-[1px] w-1/2 bg-gradient-to-r from-transparent via-cyan-500 to-transparent opacity-50",
          isError && "via-red-500"
        )}
      />

      {/* Chinese Hint Badge */}
      <div className="text-center mb-6">
        <span className="inline-block px-3 py-1 rounded-full bg-gray-100 text-gray-600 text-sm font-medium tracking-wide border border-gray-200">
          {targetZh}
        </span>
      </div>

      {/* Interactive Input Area */}
      <div className="relative min-h-[64px] flex flex-wrap justify-center items-end gap-x-[1px] gap-y-4 font-mono text-2xl sm:text-3xl cursor-text text-gray-800">
        {/* Hidden Input Field (Handles Typing) */}
        <input
          ref={inputRef}
          value={input}
          onChange={onChange}
          onKeyDown={onKeyDown}
          className="absolute inset-0 opacity-0 z-10 cursor-text w-full h-full"
          autoComplete="off"
          autoCorrect="off"
          autoCapitalize="off"
          spellCheck="false"
        />

        {/* Visual Character Rendering */}
        {displayChars.map((char, i) => {
          const inputChar = inputChars[i];
          const isTyped = inputChar !== undefined;
          const isCorrect = isTyped && inputChar.toLowerCase() === (char || '').toLowerCase();
          const isCurrent = i === inputChars.length;

          return (
            <span key={i} className="relative flex flex-col items-center w-[1ch]">
              {/* Character Text */}
              <span
                className={cn(
                  "transition-all duration-300 relative z-0 select-none",
                  // Placeholder state
                  !isTyped && (highlight ? "text-gray-400" : "text-transparent"),
                  // Correct state
                  isTyped && isCorrect && "text-cyan-600 drop-shadow-[0_0_10px_rgba(34,211,238,0.5)] scale-100 font-bold",
                  // Incorrect state
                  isTyped && !isCorrect && "text-red-500 drop-shadow-[0_0_10px_rgba(248,113,113,0.4)]"
                )}
              >
                {isTyped ? inputChar : char}
              </span>

              {/* Underline Indicator */}
              <span
                className={cn(
                  "absolute -bottom-2 left-0 w-full h-[2px] rounded-full transition-all duration-300",
                  !isTyped && "bg-gray-200 w-[60%] left-[20%]",
                  isTyped && isCorrect && "bg-cyan-500/60 shadow-[0_0_8px_rgba(34,211,238,0.6)] w-full left-0",
                  isTyped && !isCorrect && "bg-red-500/60 w-full left-0"
                )}
              />

              {/* Blinking Cursor (Current Position) */}
              {isCurrent && (
                <div className="absolute -left-[1px] -top-1 bottom-[-6px] w-[2px] bg-cyan-400 z-20 shadow-[0_0_12px_rgba(34,211,238,1)] animate-pulse" />
              )}
            </span>
          );
        })}

        {/* Overflow Indicator (if input is longer than target) */}
        {inputChars.length > targetChars.length && (
          <span className="text-red-400/50 text-lg self-center ml-2 animate-pulse">...</span>
        )}
      </div>
    </motion.div>
  );
};
```

## Usage Example

```tsx
export default function Page() {
  return (
    <div className="min-h-screen bg-gray-50 p-10 flex items-center justify-center">
      <QuizInput 
        targetEn="Hello World" 
        targetZh="你好世界" 
        onComplete={() => alert('Correct!')}
        onRequestHint={() => console.log('Hint requested')}
      />
    </div>
  )
}
```
