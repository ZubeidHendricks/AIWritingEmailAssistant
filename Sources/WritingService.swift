import Foundation

enum WriteError: Error { case notConfigured }

enum Tone: String, CaseIterable, Identifiable {
    case professional = "Professional", friendly = "Friendly", direct = "Direct", apologetic = "Apologetic"
    var id: String { rawValue }
}

/// A writing template that composes a solid draft from a few inputs — fully
/// on-device, no model required. The generative "AI rewrite" is the Remote seam.
struct WritingTemplate: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
    let topicPrompt: String      // what the single input field asks for
    let isPremium: Bool

    static let all: [WritingTemplate] = [
        .init(id: "email", name: "Email", icon: "envelope", topicPrompt: "What's the email about?", isPremium: false),
        .init(id: "reply", name: "Reply", icon: "arrowshape.turn.up.left", topicPrompt: "What are you replying to?", isPremium: false),
        .init(id: "apology", name: "Apology", icon: "hand.raised", topicPrompt: "What are you apologizing for?", isPremium: true),
        .init(id: "request", name: "Request", icon: "questionmark.bubble", topicPrompt: "What are you asking for?", isPremium: true),
        .init(id: "bio", name: "Bio", icon: "person.text.rectangle", topicPrompt: "A few words about you", isPremium: true),
        .init(id: "caption", name: "Caption", icon: "text.below.photo", topicPrompt: "What's the post about?", isPremium: true),
    ]
}

struct DraftComposer {
    static func compose(template: WritingTemplate, topic: String, tone: Tone) -> String {
        let t = topic.trimmingCharacters(in: .whitespacesAndNewlines)
        let topicText = t.isEmpty ? "the matter at hand" : t
        let (greeting, signoff) = salutation(for: tone)
        switch template.id {
        case "email":
            return "\(greeting)\n\n\(opening(tone)) regarding \(topicText). \(body(tone))\n\n\(closing(tone))\n\(signoff)"
        case "reply":
            return "\(greeting)\n\nThanks for your message about \(topicText). \(body(tone)) Let me know if anything needs clarifying.\n\n\(signoff)"
        case "apology":
            return "\(greeting)\n\nI want to sincerely apologize for \(topicText). \(apologyBody(tone))\n\n\(signoff)"
        case "request":
            return "\(greeting)\n\n\(opening(tone)) to ask about \(topicText). \(requestBody(tone)) I'd appreciate your help.\n\n\(signoff)"
        case "bio":
            return bio(topicText, tone: tone)
        case "caption":
            return caption(topicText, tone: tone)
        default:
            return topicText
        }
    }

    private static func salutation(for tone: Tone) -> (String, String) {
        switch tone {
        case .professional: return ("Dear team,", "Best regards,")
        case .friendly: return ("Hi there!", "Cheers,")
        case .direct: return ("Hello,", "Thanks,")
        case .apologetic: return ("Hello,", "With apologies,")
        }
    }
    private static func opening(_ tone: Tone) -> String {
        switch tone {
        case .professional: return "I'm writing to you"
        case .friendly: return "Just reaching out"
        case .direct: return "I'm contacting you"
        case .apologetic: return "I'm reaching out"
        }
    }
    private static func body(_ tone: Tone) -> String {
        switch tone {
        case .professional: return "Please find the relevant details below, and don't hesitate to reach out with questions."
        case .friendly: return "Happy to share more whenever works for you."
        case .direct: return "Here are the key points you need."
        case .apologetic: return "I appreciate your patience and understanding."
        }
    }
    private static func apologyBody(_ tone: Tone) -> String {
        "I take full responsibility and am taking steps to make it right. Please let me know how I can help."
    }
    private static func requestBody(_ tone: Tone) -> String {
        "If it's possible, it would make a real difference."
    }
    private static func closing(_ tone: Tone) -> String {
        switch tone {
        case .professional: return "Thank you for your time."
        case .friendly: return "Talk soon!"
        case .direct: return "Appreciate it."
        case .apologetic: return "Thank you for understanding."
        }
    }
    private static func bio(_ topic: String, tone: Tone) -> String {
        "\(topic.capitalizedFirst). Passionate about doing great work and connecting with good people. Always learning, always building."
    }
    private static func caption(_ topic: String, tone: Tone) -> String {
        switch tone {
        case .friendly: return "\(topic.capitalizedFirst) ✨ Couldn't be happier to share this!"
        default: return "\(topic.capitalizedFirst). #moments"
        }
    }
}

/// Production generation/rewrite via an LLM. Wire your endpoint here.
struct RemoteWriter {
    let apiKey: String
    func rewrite(_ text: String, tone: Tone) async throws -> String { throw WriteError.notConfigured }
}

extension String {
    var capitalizedFirst: String { isEmpty ? self : prefix(1).uppercased() + dropFirst() }
}
