//
//  AudioModeView.swift
//  LingoFlow
//
//  Created by Chen Desheng on 2025/12/29.
//

import SwiftUI
import AudioToolbox

// M3 - 音频模式 ( AudioModeView.swift )
// 继承 WordCardView 的设计风格
// 1. 中上部：高度模糊的单词 + 音频播放 Icon (点击播放单词音频)
// 2. 顶部：文字提示 “听力模式，听英文回忆单词”
// 3. 中下部：高度模糊的英文例句 + 提示一下 Icon (点击播放例句音频)
// 4. 底部：文字提示 “点击任意位置继续”
// 5. 点击其余位置：跳转回 WordCardView
// 注意：任何操作都不会显示单词或例句的文本，仅播放音频。

struct AudioModeView: View {
    @Environment(\.dismiss) var dismiss
    @State private var word: StudyWord = .mock
    
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
                
                // Mode Badge
                Text("听力模式，听英文回忆单词")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.lingoPurple)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.lingoPurple.opacity(0.1))
                    .clipShape(Capsule())
                    .padding(.bottom, 20)
                
                Spacer()
                
                // Main Content
                VStack(spacing: 40) {
                    
                    // 1. Blurred Word Section
                    VStack(spacing: 24) {
                        ZStack {
                            // Blurred Word Text
                            Text(word.text)
                                .font(.system(size: 48, weight: .regular, design: .serif))
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.center)
                                .blur(radius: 20) // High blur
                            
                            // Audio Button Overlay
                            Button(action: {
                                // Play Word Audio
                                AudioServicesPlaySystemSound(1057) // Mock sound
                            }) {
                                Image(systemName: "speaker.wave.3.fill")
                                    .font(.system(size: 44))
                                    .foregroundStyle(Color.lingoPurple)
                                    .symbolEffect(.bounce, value: true)
                                    .padding(24)
                                    .background(Color.white.opacity(0.8))
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // 2. Blurred Example Section
                    if let example = word.examples.first {
                        ZStack {
                            // Blurred Example Text
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
                            .blur(radius: 15) // High blur
                            
                            // Audio Hint Button Overlay
                            Button(action: {
                                // Play Example Audio
                                AudioServicesPlaySystemSound(1057) // Mock sound
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "speaker.wave.2.fill")
                                    Text("提示一下")
                                        .fontWeight(.semibold)
                                }
                                .font(.system(size: 16))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 14)
                                .background(Color.lingoPurple)
                                .clipShape(Capsule())
                                .shadow(color: Color.lingoPurple.opacity(0.4), radius: 10, x: 0, y: 5)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
                
                Spacer()
                
                // Bottom Prompt
                Text("点击任意位置继续")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary.opacity(0.6))
                    .padding(.bottom, 40)
            }
        }
        .contentShape(Rectangle()) // Make the whole ZStack tappable
        .onTapGesture {
            // Jump back to WordCardView
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
    AudioModeView()
}
