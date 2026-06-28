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
    @State private var draft = ""

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

                    if !draft.isEmpty {
                        Text(draft)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding().background(RoundedRectangle(cornerRadius: 12).fill(.quaternary.opacity(0.5)))
                            .textSelection(.enabled)
                        HStack {
                            Button { UIPasteboard.general.string = draft } label: {
                                Label("Copy", systemImage: "doc.on.doc").frame(maxWidth: .infinity, minHeight: 46)
                            }.buttonStyle(.bordered)
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

    private func generate() {
        draft = DraftComposer.compose(template: template, topic: topic, tone: tone)
    }
}
