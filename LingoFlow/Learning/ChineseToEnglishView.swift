//
//  ChineseToEnglishView.swift
//  LingoFlow
//
//  Created by Chen Desheng on 2025/12/29.
//

import SwiftUI
import AudioToolbox

// M2 - 中-英模式 ( ChineseToEnglishView.swift )
// 继承 WordCardView 的设计风格
// 1. 中上部：下划线输入框 (Quiz Input Style) + 提示按钮 + 音频按钮
// 2. 顶部：文字提示 “中-英模式，看中文回忆英文”
// 3. 中间：中文释义
// 4. 中下部：英文例句 (无音频/中文)
// 5. 底部：文字提示 “点击任意位置继续”
// 6. 点击其余位置：跳转回 WordCardView

struct ChineseToEnglishView: View {
    @Environment(\.dismiss) var dismiss
    @State private var word: StudyWord = .mock
    
    // Input State
    @State private var input: String = ""
    @State private var isHintActive: Bool = false
    @FocusState private var isInputFocused: Bool
    
    // Action to navigate back to WordCardView (M0)
    var onSwitchToDetail: (() -> Void)?
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "F8F9FA")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header (Reused)
                headerView
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                
                // Mode Badge (Moved to top)
                Text("中-英模式，看中文回忆英文")
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
                    
                    // 1. Quiz Input Section
                    VStack(spacing: 24) {
                        // Input Area
                        ZStack {
                            // Hidden TextField for input capture
                            TextField("", text: $input)
                                .opacity(0.01) // Invisible but interactive
                                .focused($isInputFocused)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .keyboardType(.asciiCapable)
                                .onChange(of: input) { newValue in
                                    // Limit input length
                                    if newValue.count > word.text.count + 3 {
                                        input = String(newValue.prefix(word.text.count + 3))
                                    }
                                    
                                    // Check correctness (Simple check)
                                    if newValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == word.text.lowercased() {
                                        // Correct!
                                        // Play success sound?
                                        AudioServicesPlaySystemSound(1057) // System sound
                                    }
                                }
                            
                            // Visual Rendering
                            HStack(spacing: 4) {
                                let targetChars = Array(word.text)
                                let inputChars = Array(input)
                                let maxLength = max(targetChars.count, inputChars.count)
                                
                                ForEach(0..<maxLength, id: \.self) { index in
                                    if index < targetChars.count {
                                        // Character Slot
                                        let char = targetChars[index]
                                        let inputChar = index < inputChars.count ? inputChars[index] : nil
                                        
                                        CharacterSlot(
                                            targetChar: char,
                                            inputChar: inputChar,
                                            isActive: index == inputChars.count,
                                            showHint: isHintActive
                                        )
                                    } else if index < inputChars.count {
                                        // Overflow Input
                                        Text(String(inputChars[index]))
                                            .font(.system(size: 32, weight: .medium, design: .serif))
                                            .foregroundStyle(.red)
                                            .overlay(alignment: .bottom) {
                                                Rectangle()
                                                    .fill(.red)
                                                    .frame(height: 2)
                                                    .offset(y: 4)
                                            }
                                    }
                                }
                            }
                        }
                        .frame(height: 60)
                        .onTapGesture {
                            isInputFocused = true
                        }
                        
                        // Hint & Audio Actions
                        HStack(spacing: 0) {
                            // Hint Button with Border
                            Button(action: {
                                // Flash hint logic
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isHintActive = true
                                }
                                
                                // Hide hint after 1s
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        isHintActive = false
                                    }
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "lightbulb.min")
                                        .font(.system(size: 14))
                                    Text("提示一下")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .foregroundStyle(Color.lingoPurple.opacity(0.8))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                            }
                            
                            // Divider
                            Rectangle()
                                .fill(Color.lingoPurple.opacity(0.2))
                                .frame(width: 1, height: 20)
                            
                            // Audio Button
                            Button(action: {
                                // Play Audio
                            }) {
                                Image(systemName: "speaker.wave.2.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(Color.lingoPurple)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.lingoPurple.opacity(0.2), lineWidth: 1)
                        )
                    }
                    
                    // 2. Chinese Meaning
                    VStack(spacing: 12) {
                        ForEach(word.meanings) { meaning in
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text(meaning.pos)
                                    .font(.system(.body, design: .serif))
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.lingoPurple)
                                
                                Text(meaning.definition)
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundStyle(Color(hex: "2D3436"))
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    // 3. English Example (No Chinese, No Audio)
                    if let example = word.examples.first {
                        maskedExampleText(sentence: example.english, targetWord: word.text)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .lineSpacing(6)
                    }
                }
                
                Spacer()
                
                // 4. Bottom Prompt
                Text("点击任意位置继续")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary.opacity(0.6))
                    .padding(.bottom, 40)
            }
        }
        .contentShape(Rectangle()) // Tappable background
        .onTapGesture {
            if isInputFocused {
                isInputFocused = false
            } else {
                // Navigate back
                if let onSwitch = onSwitchToDetail {
                    onSwitch()
                } else {
                    dismiss()
                }
            }
        }
        .onAppear {
            // Auto focus input
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isInputFocused = true
            }
        }
    }
    
    // Helper to mask target word in example
    private func maskedExampleText(sentence: String, targetWord: String) -> Text {
        var result = Text("")
        var currentIndex = sentence.startIndex
        
        // Case insensitive search
        while let range = sentence.range(of: targetWord, options: [.caseInsensitive], range: currentIndex..<sentence.endIndex) {
            // Text before match
            let prefix = String(sentence[currentIndex..<range.lowerBound])
            result = result + Text(prefix)
                .font(.system(size: 18, weight: .regular, design: .serif))
                .foregroundStyle(Color.secondary)
            
            // Mask
            let maskLength = targetWord.count + 2
            let maskString = String(repeating: "_", count: maskLength)
            result = result + Text(maskString)
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundStyle(Color.lingoPurple)
            
            currentIndex = range.upperBound
        }
        
        // Remaining text
        let suffix = String(sentence[currentIndex...])
        result = result + Text(suffix)
            .font(.system(size: 18, weight: .regular, design: .serif))
            .foregroundStyle(Color.secondary)
            
        return result
    }
    
    // Reuse header
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

// Subview for Character Slot
struct CharacterSlot: View {
    let targetChar: Character
    let inputChar: Character?
    let isActive: Bool
    let showHint: Bool
    
    var body: some View {
        let isCorrect = inputChar != nil && inputChar!.lowercased() == targetChar.lowercased()
        let isError = inputChar != nil && !isCorrect
        
        VStack(spacing: 4) {
            ZStack {
                // Hint (Ghost Text)
                if showHint {
                    Text(String(targetChar))
                        .font(.system(size: 32, weight: .medium, design: .serif))
                        .foregroundStyle(Color.secondary.opacity(0.3))
                }
                
                // Input Char
                if let char = inputChar {
                    Text(String(char))
                        .font(.system(size: 32, weight: .medium, design: .serif))
                        .foregroundStyle(isError ? .red : (isCorrect ? Color.lingoPurple : .primary))
                }
                
                // Cursor
                if isActive {
                    Rectangle()
                        .fill(Color.lingoPurple)
                        .frame(width: 2, height: 30)
                        .opacity(isActive ? 1 : 0) // Blink logic needs state, simplified here
                }
            }
            .frame(width: 24, height: 40)
            
            // Underline
            Rectangle()
                .fill(underlineColor)
                .frame(width: 24, height: 2)
        }
    }
    
    var underlineColor: Color {
        if let inputChar = inputChar {
            if inputChar.lowercased() == targetChar.lowercased() {
                return Color.lingoPurple
            } else {
                return .red
            }
        }
        return Color.gray.opacity(0.3)
    }
}

#Preview {
    ChineseToEnglishView()
}
