//
//  ContentView.swift
//  LingoFlow
//
//  Created by Chen Desheng on 2025/12/29.
//

import SwiftUI

// MARK: - Models & Mock Data

enum StudyStatus: String, CaseIterable, Codable {
    case unstudied = "未学习"
    case reviewing = "复习中"
    case mastered = "已掌握"
    
    var color: Color {
        switch self {
        case .unstudied: return .gray
        case .reviewing: return Color.lingoPurple.opacity(0.5)
        case .mastered: return Color.lingoPurple
        }
    }
    
    var icon: String {
        switch self {
        case .unstudied: return "circle"
        case .reviewing: return "arrow.triangle.2.circlepath"
        case .mastered: return "checkmark.circle.fill"
        }
    }
}

struct Word: Identifiable, Hashable {
    let id: Int
    let text: String
    let meaning: String
    let phonetic: String
    var lastReview: Date?
    var status: StudyStatus
    
    static let mockData: [Word] = [
        Word(id: 1, text: "Serendipity", meaning: "意外发现珍奇事物的本领", phonetic: "/ˌser.ənˈdɪp.ə.t̬i/", lastReview: Date(), status: .reviewing),
        Word(id: 2, text: "Ephemeral", meaning: "转瞬即逝的", phonetic: "/əˈfem.ər.əl/", lastReview: nil, status: .unstudied),
        Word(id: 3, text: "Luminous", meaning: "发光的；明亮的", phonetic: "/ˈluː.mə.nəs/", lastReview: Date().addingTimeInterval(-86400), status: .mastered),
        Word(id: 4, text: "Solitude", meaning: "独处；独居", phonetic: "/ˈsɑː.lə.tuːd/", lastReview: nil, status: .unstudied),
        Word(id: 5, text: "Resilience", meaning: "恢复力；弹力", phonetic: "/rɪˈzɪl.jəns/", lastReview: Date(), status: .reviewing),
        Word(id: 6, text: "Ethereal", meaning: "优雅的；轻飘的", phonetic: "/iˈθɪr.i.əl/", lastReview: nil, status: .unstudied),
        Word(id: 7, text: "Petrichor", meaning: "雨后泥土的气味", phonetic: "/ˈpet.rɪ.kɔːr/", lastReview: Date(), status: .reviewing)
    ]
}

// MARK: - Design System Helpers

extension Color {
    // Light: #8B5CF6, Dark: #A78BFA
    static let lingoPurple = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 167/255, green: 139/255, blue: 250/255, alpha: 1)
        default:
            return UIColor(red: 139/255, green: 92/255, blue: 246/255, alpha: 1)
        }
    })
}

// MARK: - Main View

struct ContentView: View {
    // Data State
    @State private var words: [Word] = Word.mockData
    @State private var searchText = ""
    @State private var showImportSheet = false
    
    // Filter State
    @State private var selectedStatus: StudyStatus? = nil
    
    // Debug State
    @State private var showDebugMenu = false
    @State private var selectedDebugMode: DebugMode? = nil
    
    enum DebugMode: Identifiable {
        case m0, m1, m2, m3
        var id: Self { self }
    }
    
    // Derived Data
    var filteredWords: [Word] {
        var result = words
        
        // Filter by text
        if !searchText.isEmpty {
            result = result.filter { $0.text.localizedCaseInsensitiveContains(searchText) || $0.meaning.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Filter by status
        if let status = selectedStatus {
            result = result.filter { $0.status == status }
        }
        
        return result
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 1. Header
                    HStack(spacing: 8) {
                        LingoLogo()
                            .frame(width: 28, height: 28)
                        
                        HStack(spacing: 0) {
                            Text("Lingo")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                            Text("Flow")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.lingoPurple)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(Color(.systemGroupedBackground))
                    
                    // 2. Pinned Statistics Module
                    StatsCardView()
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                        .background(Color(.systemGroupedBackground))
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // 2. Word Book (Management + List + Pagination)
                            WordBookView(
                                words: filteredWords,
                                allWords: words,
                                searchText: $searchText,
                                selectedStatus: $selectedStatus,
                                showImportSheet: $showImportSheet,
                                onAction: { action, word in
                                    handleWordAction(action, for: word)
                                }
                            )
                            .padding(.horizontal)
                            .padding(.bottom, 100)
                        }
                        .padding(.top, 8)
                    }
                }
                .sheet(isPresented: $showImportSheet) {
                    NavigationStack {
                        VStack {
                            ContentUnavailableView("导入功能即将上线", systemImage: "square.and.arrow.down", description: Text("支持从 CSV 或文本文件导入单词"))
                        }
                        .navigationTitle("导入单词")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("关闭") { showImportSheet = false }
                            }
                        }
                    }
                    .presentationDetents([.medium])
                }
                
                // Debug Floating Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Menu {
                            Button("M0 - 单词卡片") { selectedDebugMode = .m0 }
                            Button("M1 - 英中模式") { selectedDebugMode = .m1 }
                            Button("M2 - 中英模式") { selectedDebugMode = .m2 }
                            Button("M3 - 音频模式") { selectedDebugMode = .m3 }
                        } label: {
                            Image(systemName: "ant.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.black.opacity(0.8))
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                    }
                }
            }
            .fullScreenCover(item: $selectedDebugMode) { mode in
                switch mode {
                case .m0: WordCardView()
                case .m1: EnglishToChineseView(onSwitchToDetail: { selectedDebugMode = .m0 })
                case .m2: ChineseToEnglishView(onSwitchToDetail: { selectedDebugMode = .m0 })
                case .m3: AudioModeView(onSwitchToDetail: { selectedDebugMode = .m0 })
                }
            }
        }
        .tint(Color.lingoPurple)
    }
    
    func handleWordAction(_ action: WordRowAction, for word: Word) {
        // Mock logic for interactions
        switch action {
        case .delete:
            if let index = words.firstIndex(where: { $0.id == word.id }) {
                words.remove(at: index)
            }
        case .toggleStatus:
            if let index = words.firstIndex(where: { $0.id == word.id }) {
                words[index].status = words[index].status == .mastered ? .reviewing : .mastered
            }
        case .edit:
            break
        }
    }
}

// MARK: - Subviews

struct LingoLogo: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 139/255, green: 92/255, blue: 246/255), // #8b5cf6
                            Color(red: 109/255, green: 40/255, blue: 217/255)  // #6d28d9
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Image(systemName: "book.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
        }
    }
}

struct StatsCardView: View {
    @State private var showLearning = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("今日复习")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("12")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        Text("/ 40")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundStyle(.tertiary)
                    }
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.lingoPurple.opacity(0.15), lineWidth: 6)
                    Circle()
                        .trim(from: 0, to: 0.3)
                        .stroke(Color.lingoPurple, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Text("30%")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.lingoPurple)
                    }
                }
                .frame(width: 54, height: 54)
            }
            
            Button(action: { showLearning = true }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("开始学习")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.lingoPurple)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: Color.lingoPurple.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .fullScreenCover(isPresented: $showLearning) {
                WordCardView()
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

enum WordRowAction {
    case edit, delete, toggleStatus
}

struct WordBookView: View {
    let words: [Word]
    let allWords: [Word]
    @Binding var searchText: String
    @Binding var selectedStatus: StudyStatus?
    @Binding var showImportSheet: Bool
    let onAction: (WordRowAction, Word) -> Void
    
    // Pagination State
    @State private var currentPage = 1
    @State private var isSearching = false
    let itemsPerPage = 20
    
    var totalPages: Int {
        max(1, (words.count + itemsPerPage - 1) / itemsPerPage)
    }
    
    var paginatedWords: [Word] {
        let startIndex = (currentPage - 1) * itemsPerPage
        let endIndex = min(startIndex + itemsPerPage, words.count)
        guard startIndex < endIndex else { return [] }
        return Array(words[startIndex..<endIndex])
    }
    
    var showSearchBar: Bool {
        isSearching || !searchText.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 1.1 Management Header
            HStack(spacing: 12) {
                if showSearchBar {
                    // Search Bar
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                        
                        TextField("搜索单词...", text: $searchText)
                            .font(.subheadline)
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .transition(.move(edge: .leading).combined(with: .opacity))
                } else {
                    // Progress Bar
                    StudyProgressView(words: allWords)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }
                
                // Actions
                HStack(spacing: 4) {
                    if showSearchBar {
                        Button("取消") {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                searchText = ""
                                isSearching = false
                            }
                        }
                        .font(.subheadline)
                        .foregroundStyle(Color.lingoPurple)
                    } else {
                        Button(action: { showImportSheet = true }) {
                            Image(systemName: "square.and.arrow.down")
                                .font(.body)
                                .foregroundStyle(Color.lingoPurple)
                                .frame(width: 36, height: 36)
                                .background(Color.lingoPurple.opacity(0.1))
                                .clipShape(Circle())
                        }
                        
                        Menu {
                            Section {
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        isSearching = true
                                    }
                                }) {
                                    Label("搜索", systemImage: "magnifyingglass")
                                }
                            }
                            
                            Section("筛选状态") {
                                Button(action: { selectedStatus = nil }) {
                                    Label("全部", systemImage: selectedStatus == nil ? "checkmark" : "")
                                }
                                ForEach(StudyStatus.allCases, id: \.self) { status in
                                    Button(action: { selectedStatus = status }) {
                                        Label(status.rawValue, systemImage: selectedStatus == status ? "checkmark" : "")
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: selectedStatus == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                                .font(.body)
                                .foregroundStyle(Color.lingoPurple)
                                .frame(width: 36, height: 36)
                                .background(Color.lingoPurple.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            
            Divider()
            
            // 1.2 Word List
            if words.isEmpty {
                ContentUnavailableView("没有找到单词", systemImage: "text.magnifyingglass")
                    .frame(height: 200)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(paginatedWords) { word in
                        VStack(spacing: 0) {
                            WordRowView(word: word) { action in
                                onAction(action, word)
                            }
                            
                            if word != paginatedWords.last {
                                Divider()
                                    .padding(.leading, 16)
                            }
                        }
                    }
                }
            }
            
            // Pagination Footer
            if totalPages > 1 {
                Divider()
                HStack {
                    Button(action: { if currentPage > 1 { currentPage -= 1 } }) {
                        Image(systemName: "chevron.left")
                            .font(.body)
                            .foregroundStyle(currentPage > 1 ? Color.primary : Color.secondary.opacity(0.5))
                            .frame(width: 44, height: 44)
                    }
                    .disabled(currentPage <= 1)
                    
                    Spacer()
                    
                    Text("\(currentPage) / \(totalPages)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                    
                    Spacer()
                    
                    Button(action: { if currentPage < totalPages { currentPage += 1 } }) {
                        Image(systemName: "chevron.right")
                            .font(.body)
                            .foregroundStyle(currentPage < totalPages ? Color.primary : Color.secondary.opacity(0.5))
                            .frame(width: 44, height: 44)
                    }
                    .disabled(currentPage >= totalPages)
                }
                .padding(.horizontal, 8)
                .background(Color(.secondarySystemGroupedBackground))
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        .onChange(of: searchText) { _ in
            currentPage = 1 // Reset page on search
        }
        .onChange(of: selectedStatus) { _ in
            currentPage = 1 // Reset page on filter
        }
    }
}

struct WordRowView: View {
    let word: Word
    let actionHandler: (WordRowAction) -> Void
    @State private var showDetail = false
    
    var body: some View {
        Button(action: { showDetail.toggle() }) {
            HStack(spacing: 12) {
                // ID Badge
                Text("\(word.id)")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.tertiary)
                    .frame(width: 24, alignment: .leading)
                
                // Content: English | Phonetic | Spacer | Chinese | Status
                HStack(alignment: .center, spacing: 8) {
                    Text(word.text)
                        .font(.system(size: 15, weight: .medium, design: .serif))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    if !word.phonetic.isEmpty {
                        Text(word.phonetic)
                            .font(.system(size: 11, weight: .regular, design: .serif))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer(minLength: 8)
                    
                    Text(word.meaning)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                
                // Status Dot
                Circle()
                    .fill(word.status.color)
                    .frame(width: 8, height: 8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .contentShape(Rectangle()) // Ensure tap area covers the whole row
        }
        .buttonStyle(.plain) // Remove default button styling for list rows
        .popover(isPresented: $showDetail) {
            WordDetailView(word: word)
                .presentationCompactAdaptation(.popover)
                .frame(minWidth: 300, minHeight: 200)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                actionHandler(.delete)
            } label: {
                Label("删除", systemImage: "trash")
            }
            
            Button {
                actionHandler(.toggleStatus) // Reset/Refresh logic mock
            } label: {
                Label("重置", systemImage: "arrow.counterclockwise")
            }
            .tint(.orange)
        }
        .contextMenu {
            Button { actionHandler(.edit) } label: {
                Label("编辑", systemImage: "pencil")
            }
            Button { actionHandler(.toggleStatus) } label: {
                Label(word.status == .mastered ? "标记为复习中" : "标记为已掌握", systemImage: "checkmark.circle")
            }
            Divider()
            Button(role: .destructive) { actionHandler(.delete) } label: {
                Label("删除", systemImage: "trash")
            }
        }
    }
}

struct StudyProgressView: View {
    let words: [Word]
    
    var body: some View {
        let total = Double(max(words.count, 1))
        let unstudied = words.filter { $0.status == .unstudied }
        let reviewing = words.filter { $0.status == .reviewing }
        let mastered = words.filter { $0.status == .mastered }
        
        let unstudiedCount = unstudied.count
        let reviewingCount = reviewing.count
        let masteredCount = mastered.count
        
        VStack(spacing: 8) {
            // Bar
            GeometryReader { geo in
                HStack(spacing: 0) {
                    if masteredCount > 0 {
                        Color.lingoPurple
                            .frame(width: geo.size.width * (Double(masteredCount) / total))
                    }
                    if reviewingCount > 0 {
                        Color.lingoPurple.opacity(0.5)
                            .frame(width: geo.size.width * (Double(reviewingCount) / total))
                    }
                    if unstudiedCount > 0 {
                        Color.gray.opacity(0.3)
                            .frame(width: geo.size.width * (Double(unstudiedCount) / total))
                    }
                }
            }
            .frame(height: 8)
            .clipShape(Capsule())
            
            // Labels
            HStack {
                StatusLabel(title: "已掌握", count: masteredCount, color: .lingoPurple)
                Spacer()
                StatusLabel(title: "复习中", count: reviewingCount, color: .lingoPurple.opacity(0.5))
                Spacer()
                StatusLabel(title: "未学习", count: unstudiedCount, color: .gray.opacity(0.5))
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

struct StatusLabel: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text("\(title) \(count)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// Custom Button Style for better touch feedback
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct WordDetailView: View {
    let word: Word
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(word.text)
                        .font(.system(size: 32, weight: .bold, design: .serif))
                    
                    HStack(spacing: 12) {
                        Text(word.phonetic)
                            .font(.system(size: 18, weight: .regular, design: .serif))
                            .foregroundStyle(.secondary)
                        
                        Button(action: {}) {
                            Image(systemName: "speaker.wave.2.circle.fill")
                                .foregroundStyle(Color.lingoPurple)
                                .font(.title3)
                        }
                    }
                }
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "bookmark")
                        .font(.title3)
                        .foregroundStyle(Color.lingoPurple)
                        .padding(8)
                        .background(Color.lingoPurple.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            
            Divider()
            
            // Meaning
            VStack(alignment: .leading, spacing: 8) {
                Text("释义")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                Text(word.meaning)
                    .font(.body)
                    .lineSpacing(4)
            }
            
            // Example (Mock)
            VStack(alignment: .leading, spacing: 8) {
                Text("例句")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("It was pure serendipity that we met.")
                        .font(.system(.body, design: .serif))
                        .italic()
                    Text("我们相遇纯属机缘巧合。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding(24)
        .background(Color(.systemBackground))
    }
}

#Preview {
    ContentView()
}
