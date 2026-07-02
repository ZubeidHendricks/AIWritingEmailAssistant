import SwiftUI
import AppFactoryKit

// Writing Assistant — payments via native StoreKit 2 (no third-party SDK).
private enum Product {
    static let yearly = "writing_pro_yearly"
    static let weekly = "writing_pro_weekly"
}

@MainActor
enum WritingAssistantFactory {
    static func make() -> AppFactory {
        let config = AppFactoryConfiguration(
            appName: "Writing Assistant",
            purchaseProvider: StoreKit2PurchaseProvider(productIDs: [Product.yearly, Product.weekly]),
            onboarding: OnboardingConfiguration(
                slides: [
                    .init(systemImage: "square.and.pencil",
                          title: "Never Stare at a Blank Page",
                          message: "Pick a template, set the tone, and get a ready-to-send draft in seconds."),
                    .init(systemImage: "envelope.open",
                          title: "Emails, Replies & More",
                          message: "Professional emails, apologies, requests, bios and captions — all offline.")
                ],
                presentsPaywallOnFinish: true,
                accent: .blue
            ),
            paywall: PaywallConfiguration(
                headline: "Unlock Writing Assistant Pro",
                subheadline: "Every template, every tone.",
                benefits: [
                    .init(systemImage: "square.grid.2x2", title: "All templates", subtitle: "Apology, request, bio, caption & more"),
                    .init(systemImage: "wand.and.stars", title: "AI rewrite"),
                    .init(systemImage: "infinity", title: "Unlimited drafts"),
                    .init(systemImage: "nosign", title: "No ads")
                ],
                productIDs: [Product.yearly, Product.weekly],
                highlightedProductID: Product.yearly,
                ctaTitle: "Continue",
                dismissButtonDelay: 4,
                isDismissable: true,
                termsURL: URL(string: "https://zubeidhendricks.github.io/AIWritingEmailAssistant/terms.html"),
                privacyURL: URL(string: "https://zubeidhendricks.github.io/AIWritingEmailAssistant/privacy.html"),
                style: PaywallStyle(accent: .blue, heroSystemImage: "square.and.pencil.circle")
            )
        )
        return AppFactory(config)
    }
}

@main
struct WritingAssistantApp: App {
    @StateObject private var factory = WritingAssistantFactory.make()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .appFactoryRoot(factory)
                .tint(.blue)
        }
    }
}
