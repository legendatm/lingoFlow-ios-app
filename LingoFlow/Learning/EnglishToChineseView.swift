//
//  EnglishToChineseView.swift
//  LingoFlow
//
//  Created by Chen Desheng on 2025/12/29.
//

import SwiftUI

// M1 - 英-中模式 ( EnglishToChineseView.swift )
// 继承 WordCardView 的设计风格
// 1. 中上部：英文拼写 + 音标 + 发音 icon
// 2. 顶部：文字提示 “英-中模式，看英文回忆中文”
// 3. 中下部：例句（默认毛玻璃遮挡），button “提示一下” 点击后透明
// 4. 点击其余位置：跳转回 WordCardView

struct EnglishToChineseView: View {
    @Environment(\.dismiss) var dismiss
    @State private var word: StudyWord = .mock
    @State private var isHintRevealed = false
    
    // Action to navigate back to WordCardView (M0)
    var onSwitchToDetail: (() -> Void)?
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "F8F9FA")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                
                // Mode Badge (Moved to top)
                Text("英-中模式，看英文回忆中文")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.lingoPurple)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.lingoPurple.opacity(0.1))
                    .clipShape(Capsule())
                    .padding(.bottom, 20)
                
                Spacer()
                
                // Main Content
                VStack(spacing: 32) {
                    // 1. Word & Phonetic Section
                    VStack(spacing: 20) {
                        Text(word.text)
                            .font(.system(size: 48, weight: .regular, design: .serif))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)
                        
                        HStack(spacing: 12) {
                            Text(word.phonetic)
                                .font(.system(size: 20, weight: .medium, design: .serif))
                                .foregroundStyle(.secondary)
                            
                            Button(action: {
                                // Mock play audio
                            }) {
                                Image(systemName: "speaker.wave.2.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(Color.lingoPurple)
                                    .symbolEffect(.bounce, value: true)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.5))
                        .clipShape(Capsule())
                    }
                    
                    // 2. Recall Prompt (Removed from here)
                    
                    // 3. Example Section with Blur
                    if let example = word.examples.first {
                        ZStack {
                            // Actual Content (Always there, but maybe blurred)
                            VStack(spacing: 16) {
                                Text(example.english)
                                    .font(.system(size: 22, weight: .medium, design: .serif))
                                    .foregroundStyle(Color(hex: "2D3436"))
                                    .lineSpacing(8)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(32)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .shadow(color: .black.opacity(0.06), radius: 20, x: 0, y: 10)
                            // Apply blur if not revealed
                            .blur(radius: isHintRevealed ? 0 : 12)
                            .animation(.easeInOut(duration: 0.4), value: isHintRevealed)
                            
                            // Overlay Button (Only when not revealed)
                            if !isHintRevealed {
                                Button(action: {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        isHintRevealed = true
                                    }
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 12))
                                        Text("提示一下")
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Color.lingoPurple)
                                    .clipShape(Capsule())
                                    .shadow(color: Color.lingoPurple.opacity(0.4), radius: 8, x: 0, y: 4)
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
                
                Spacer()
                
                // 底部提示
                Text("点击任意位置继续")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary.opacity(0.6))
                    .padding(.bottom, 40)
            }
        }
        .contentShape(Rectangle()) // Make the whole ZStack tappable
        .onTapGesture {
            // Jump back to WordCardView
            // Use callback or dismiss
            if let onSwitch = onSwitchToDetail {
                onSwitch()
            } else {
                dismiss()
            }
        }
    }
    
    // Reuse header from WordCardView style
    private var headerView: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            
            Spacer()
            
            // Progress Bar (Simplified or same)
            HStack(spacing: 6) {
                Text("5")
                    .foregroundStyle(Color.lingoPurple)
                    .fontWeight(.bold)
                Text("/")
                    .foregroundStyle(.secondary)
                Text("20")
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            Spacer()
            
            // Menu
            Menu {
                Button("标记熟知", action: {})
                Button("移除单词", action: {})
                Button("刷新数据", action: {})
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    EnglishToChineseView()
}
