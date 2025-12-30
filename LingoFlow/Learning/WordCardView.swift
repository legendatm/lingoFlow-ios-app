//
//  WordCardView.swift
//  LingoFlow
//
//  Created by Chen Desheng on 2025/12/29.
//

import SwiftUI

// MARK: - Models

struct StudyWord: Identifiable {
    let id = UUID()
    let text: String
    let phonetic: String
    let meanings: [WordMeaning]
    let examples: [WordExample]
    let mnemonic: String?
    
    static let mock = StudyWord(
        text: "Serendipity",
        phonetic: "/ˌser.ənˈdɪp.ə.t̬i/",
        meanings: [
            WordMeaning(pos: "n.", definition: "意外发现珍奇事物的本领；机缘凑巧"),
            WordMeaning(pos: "n.", definition: "（偶然发现的）好运；福气")
        ],
        examples: [
            WordExample(
                english: "It was pure serendipity that we met at the coffee shop right before it started raining.",
                chinese: "我们在下雨前恰好在咖啡店相遇，这纯属机缘巧合。"
            ),
            WordExample(
                english: "Scientific discovery is often a result of serendipity.",
                chinese: "科学发现往往是机缘巧合的结果。"
            )
        ],
        mnemonic: "词根：serendip (锡兰岛古称) + ity (名词后缀)。传说锡兰三王子周游世界，经常意外发现宝物。"
    )
}

struct WordMeaning: Identifiable {
    let id = UUID()
    let pos: String
    let definition: String
}

struct WordExample: Identifiable {
    let id = UUID()
    let english: String
    let chinese: String
}

// MARK: - Helper Views

struct GlassyIcon: View {
    let systemName: String
    let color: Color
    
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(color)
            .frame(width: 32, height: 32)
            .background(.ultraThinMaterial)
            .background(color.opacity(0.1))
            .clipShape(Circle())
    }
}

struct POSBadge: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .bold, design: .serif))
            .foregroundStyle(Color.lingoPurple)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.lingoPurple.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

// M0 - 单词卡片模式，显示完整的单词信息。
struct WordCardView: View {
    @Environment(\.dismiss) var dismiss
    @State private var word: StudyWord = .mock
    
    var body: some View {
        ZStack {
            Color(hex: "F8F9FA") // Softer background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header & Progress
                VStack(spacing: 12) {
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
                        
                        // Progress Bar
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
                        
                        // Word Management Menu
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
                .padding(.top, 10)
                .padding(.bottom, 10)
                
                // Content
                ScrollView {
                    VStack(spacing: 16) { // Reduced spacing between cards from 24 to 16
                        // 1. Word Header
                        VStack(spacing: 16) {
                            Text(word.text)
                                .font(.system(size: 40, weight: .regular, design: .serif))
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.center)
                            
                            HStack(spacing: 12) {
                                Text(word.phonetic)
                                    .font(.system(size: 18, weight: .medium, design: .serif))
                                    .foregroundStyle(.secondary)
                                
                                Button(action: {
                                    // Mock play audio
                                }) {
                                    Image(systemName: "speaker.wave.2.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(Color.lingoPurple)
                                        .symbolEffect(.bounce, value: true)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)) // Squarer corners
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 24)
                        .padding(.bottom, 0) // Removed bottom padding completely
                        
                        // 2. Meanings
                        VStack(alignment: .leading, spacing: 16) { // Reduced internal spacing
                            SectionHeader(
                                icon: "book.fill",
                                title: "释义",
                                color: Color(hex: "7AA2E3")
                            )
                            
                            VStack(alignment: .leading, spacing: 12) { // Reduced list spacing
                                ForEach(word.meanings) { meaning in
                                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                                        Text(meaning.pos)
                                            .font(.system(.body, design: .serif))
                                            .fontWeight(.bold)
                                            .foregroundStyle(Color.lingoPurple)
                                        
                                        Text(meaning.definition)
                                            .font(.system(size: 17))
                                            .foregroundStyle(Color(hex: "2D3436"))
                                            .lineSpacing(4)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20) // Reduced padding
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 8)
                        
                        // 3. Examples
                        if let firstExample = word.examples.first {
                            VStack(alignment: .leading, spacing: 16) {
                                SectionHeader(
                                    icon: "quote.opening",
                                    title: "例句",
                                    color: Color(hex: "97C1A9")
                                )
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(alignment: .top, spacing: 12) {
                                        Text(firstExample.english)
                                            .font(.system(size: 17, weight: .medium, design: .serif))
                                            .foregroundStyle(Color(hex: "2D3436"))
                                            .lineSpacing(5)
                                            .fixedSize(horizontal: false, vertical: true)
                                        
                                        Spacer()
                                        
                                        Button(action: {}) {
                                            Image(systemName: "speaker.wave.2.circle")
                                                .font(.body)
                                                .foregroundStyle(Color(hex: "97C1A9"))
                                        }
                                    }
                                    
                                    Text(firstExample.chinese)
                                        .font(.system(size: 15))
                                        .foregroundStyle(Color(hex: "757575"))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 8)
                        }
                        
                        // 4. Mnemonic
                        if let mnemonic = word.mnemonic {
                            VStack(alignment: .leading, spacing: 12) {
                                SectionHeader(
                                    icon: "lightbulb.fill",
                                    title: "助记",
                                    color: Color(hex: "F4A261")
                                )
                                
                                Text(mnemonic)
                                    .font(.subheadline)
                                    .foregroundStyle(Color(hex: "555555"))
                                    .lineSpacing(4)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 8)
                        }
                        
                        // Bottom Padding for ScrollView
                        Spacer().frame(height: 100)
                    }
                    .padding(.horizontal)
                }
                
                // Bottom Interaction Bar
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        StudyActionButton(
                            title: "认识",
                            color: Color.lingoPurple, // Main Purple
                            action: {
                                // Handle know
                            }
                        )
                        
                        StudyActionButton(
                            title: "模糊",
                            color: Color.lingoPurple.opacity(0.7), // Medium Purple
                            action: {
                                // Handle vague
                            }
                        )
                        
                        StudyActionButton(
                            title: "忘记",
                            color: Color.lingoPurple.opacity(0.4), // Light Purple
                            action: {
                                // Handle forgot
                            }
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(
                        ZStack {
                            // Blur Layer
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .blur(radius: 20) // Enhance blur
                            
                            // Gradient Overlay for texture
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0.2),
                                            .white.opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .stroke(.white.opacity(0.3), lineWidth: 1)
                        )
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8) // Lift up slightly
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Components

struct SectionHeader: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                GlassyIcon(systemName: icon, color: color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(1)
                
                Spacer()
                
                Button(action: {
                    // Refresh action
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                        .foregroundStyle(.secondary.opacity(0.5))
                }
            }
            
            Divider()
                .opacity(0.5)
        }
    }
}

struct StudyActionButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(color)
                .foregroundStyle(.white)
                .clipShape(Capsule())
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// Helper for Hex Colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    WordCardView()
}
