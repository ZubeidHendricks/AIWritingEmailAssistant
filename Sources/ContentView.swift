import SwiftUI
import AppFactoryKit

// AI Writing / Email Assistant — pick a template + tone, drop in a topic, get a
// ready-to-send draft on-device. Pro unlocks all templates and AI rewrite (wired
// behind RemoteWriter / LLM).
struct ContentView: View {
    @EnvironmentObject private var factory: AppFactory

    @State private var template: WritingTemplate = .all[0]
    @State private var tone: Tone = .professional
    @State private var topic = ""

    // Variable reward per ../PLAYBOOK.md: three tone variants revealed one at a
    // time as flip cards — anticipation, not loss aversion. No persistence.
    @State private var drafts: [ToneDraft] = []
    @State private var revealedCount = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Template").font(.headline)
                    templateGrid

                    Text("Tone").font(.headline)
                    Picker("Tone", selection: $tone) {
                        ForEach(Tone.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)

                    Text(template.topicPrompt).font(.headline)
                    TextField("Type here…", text: $topic, axis: .vertical)
                        .lineLimit(2...4)
                        .textFieldStyle(.roundedBorder)

                    Button { generate() } label: {
                        Label("Generate Draft", systemImage: "sparkles").frame(maxWidth: .infinity, minHeight: 50)
                    }
                    .buttonStyle(.borderedProminent).tint(.blue)

                    if !drafts.isEmpty {
                        Text("Three takes — tap each card to reveal").font(.headline)
                        ForEach(Array(drafts.enumerated()), id: \.element.id) { index, d in
                            if index <= revealedCount {
                                DraftCard(draft: d, isRevealed: index < revealedCount) {
                                    reveal(index)
                                }
                            }
                        }
                        if revealedCount == drafts.count {
                            Button { factory.requirePremium(feature: "ai_rewrite") {} } label: {
                                Label("AI Rewrite (Pro)", systemImage: "wand.and.stars").frame(maxWidth: .infinity, minHeight: 46)
                            }.buttonStyle(.borderedProminent).tint(.blue)
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Writing Assistant")
        }
    }

    private var templateGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 10)], spacing: 10) {
            ForEach(WritingTemplate.all) { t in
                Button { select(t) } label: {
                    VStack(spacing: 6) {
                        Image(systemName: t.icon).font(.title3)
                        Text(t.name).font(.caption2)
                    }
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(RoundedRectangle(cornerRadius: 12).strokeBorder(template == t ? .blue : .secondary.opacity(0.25), lineWidth: template == t ? 2 : 1))
                    .overlay(alignment: .topTrailing) {
                        if t.isPremium && !factory.subscriptions.isSubscribed {
                            Image(systemName: "lock.fill").font(.system(size: 10)).padding(5)
                        }
                    }
                }
                .buttonStyle(.plain).tint(.blue)
            }
        }
    }

    private func select(_ t: WritingTemplate) {
        if t.isPremium && !factory.subscriptions.isSubscribed { factory.presentPaywall(placement: "template_\(t.id)"); return }
        template = t
    }

    /// Chosen tone first, then two other tones — three takes on the same draft.
    private func generate() {
        let tones = [tone] + Tone.allCases.filter { $0 != tone }.prefix(2)
        drafts = tones.map {
            ToneDraft(tone: $0, text: DraftComposer.compose(template: template, topic: topic, tone: $0))
        }
        revealedCount = 0
    }

    private func reveal(_ index: Int) {
        guard index == revealedCount else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.spring(duration: 0.45)) { revealedCount = index + 1 }
    }
}

struct ToneDraft: Identifiable {
    let tone: Tone
    let text: String
    var id: String { tone.id }
}

/// Face-down card that flips to the draft on tap (reveal pattern per
/// ../PLAYBOOK.md; see AffirmationsManifestation's AffirmCardsView).
struct DraftCard: View {
    let draft: ToneDraft
    let isRevealed: Bool
    let onReveal: () -> Void

    var body: some View {
        Button(action: onReveal) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isRevealed ? AnyShapeStyle(.quaternary.opacity(0.5)) : AnyShapeStyle(.blue.opacity(0.12)))
                if isRevealed {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(draft.tone.rawValue).font(.subheadline.bold()).foregroundStyle(.blue)
                            Spacer()
                            Button { UIPasteboard.general.string = draft.text } label: {
                                Image(systemName: "doc.on.doc")
                            }
                            .buttonStyle(.borderless)
                        }
                        Text(draft.text)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                    }
                    .padding()
                    .transition(.scale.combined(with: .opacity))
                } else {
                    Label("Tap to reveal the \(draft.tone.rawValue.lowercased()) take", systemImage: "hand.tap")
                        .font(.callout)
                        .foregroundStyle(.blue)
                        .frame(minHeight: 72)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(isRevealed)
        .animation(.spring(duration: 0.45), value: isRevealed)
    }
}
