# AIWritingEmailAssistant

Generated from niche `ai-writing` (AI Text, tier A, score 77).

**Utility:** Draft, rewrite, fix tone of text/emails
**Primary ASO keyword:** `ai writer`
**Also target:** `email writer`, `ai writing`, `paraphrase`, `grammar fix`
**Paywall hook:** Unlimited generations, tones, longer outputs

> Pure LLM wrapper, cheap to build. Niche it (cold email, dating, reviews) to stand out.

## Engagement (see ../PLAYBOOK.md)

Variable reward: each generation produces three tone variants of the draft,
revealed one at a time as flip cards (light haptic per reveal, next card appears
after the previous is revealed). No persistence.

## Build it

```bash
brew install xcodegen        # once
cd AIWritingEmailAssistant
xcodegen generate
open AIWritingEmailAssistant.xcodeproj
```

The app runs immediately on a MockPurchaseProvider (real paywall UI, fake
purchases). To go live:

1. Replace `revenueCatKey` in `Sources/App.swift` with your RevenueCat key.
2. In App Store Connect create products `ai-writing_yearly` and `ai-writing_weekly`,
   map them into a RevenueCat offering, entitlement id `premium`.
3. Build the real feature in `Sources/ContentView.swift`.
4. **Guideline 4.3:** make the function, UI, screenshots and keywords genuinely
   distinct from any sibling app. Re-niche, never reskin.

Bundle id: `com.zubeid.aiwriting`

## Ship to TestFlight

This app ships with a Fastlane lane + GitHub Actions workflow. One-time account
setup (API key, signing) is documented in the kit's `Tools/appgen/DEPLOYMENT.md`.
Once your GitHub secrets are set, trigger the **TestFlight** workflow (or push a
`v*` tag), or run locally:

```bash
bundle install
bundle exec fastlane beta
```
