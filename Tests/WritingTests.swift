import XCTest
// WritingService.swift compiled into this test target.

final class WritingTests: XCTestCase {
    private var email: WritingTemplate { WritingTemplate.all.first { $0.id == "email" }! }

    func testDraftContainsTopic() {
        let d = DraftComposer.compose(template: email, topic: "the quarterly review", tone: .professional)
        XCTAssertTrue(d.contains("quarterly review"), "draft: \(d)")
        XCTAssertFalse(d.isEmpty)
    }

    func testAllTemplatesAndTonesProduceText() {
        for t in WritingTemplate.all {
            for tone in Tone.allCases {
                XCTAssertFalse(DraftComposer.compose(template: t, topic: "a project update", tone: tone).isEmpty,
                               "empty for \(t.id)/\(tone)")
            }
        }
    }

    func testToneChangesOutput() {
        let a = DraftComposer.compose(template: email, topic: "x", tone: .professional)
        let b = DraftComposer.compose(template: email, topic: "x", tone: .friendly)
        XCTAssertNotEqual(a, b)
    }

    func testTemplateCatalog() {
        XCTAssertGreaterThanOrEqual(WritingTemplate.all.count, 4)
    }
}
