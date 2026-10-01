import XCTest
@testable import MarkdownEditorCore

final class MarkdownTests: XCTestCase {
    private let doc = """
    # Getting Started
    Intro text with #hashtag.
    ## Install ##
    ```
    # not a heading
    ```
    ## Install
    ###### Deep, really!
    #######
    """

    func testOutlineSkipsCodeAndDedupesSlugs() {
        let h = Markdown.outline(doc)
        XCTAssertEqual(h.map(\.title), ["Getting Started", "Install", "Install", "Deep, really!"])
        XCTAssertEqual(h.map(\.slug), ["getting-started", "install", "install-1", "deep-really"])
        XCTAssertEqual(h.map(\.level), [1, 2, 2, 6])
        XCTAssertEqual(h.map(\.line), [1, 3, 7, 8])
    }

    func testStatsExcludeCodeBlocks() {
        let s = Markdown.stats("Hello world — ok\n```\nlet x = 1\n```\n- item two")
        XCTAssertEqual(s.words, 5)
        XCTAssertEqual(s.readingMinutes, 1)
        XCTAssertEqual(Markdown.stats("").readingMinutes, 0)
        XCTAssertEqual(Markdown.stats(String(repeating: "word ", count: 401)).readingMinutes, 3)
    }

    func testToggleWrapsAndUnwraps() {
        let (bold, sel) = Markdown.toggle("**", in: "make this bold", selection: 5..<9)
        XCTAssertEqual(bold, "make **this** bold")
        XCTAssertEqual(sel, 7..<11)
        let (plain, sel2) = Markdown.toggle("**", in: bold, selection: sel)
        XCTAssertEqual(plain, "make this bold")
        XCTAssertEqual(sel2, 5..<9)
        // Empty selection inserts a marker pair with the caret inside.
        let (code, caret) = Markdown.toggle("`", in: "ab", selection: 1..<1)
        XCTAssertEqual(code, "a``b")
        XCTAssertEqual(caret, 2..<2)
        // Out-of-range selections are clamped.
        XCTAssertEqual(Markdown.toggle("_", in: "hi", selection: 0..<99).text, "_hi_")
    }

    func testToggleTask() {
        let text = "- [ ] buy milk\n- [X] done"
        XCTAssertEqual(Markdown.toggleTask(in: text, line: 1), "- [x] buy milk\n- [X] done")
        XCTAssertEqual(Markdown.toggleTask(in: text, line: 2), "- [ ] buy milk\n- [ ] done")
        XCTAssertEqual(Markdown.toggleTask(in: text, line: 9), text)
    }
}
