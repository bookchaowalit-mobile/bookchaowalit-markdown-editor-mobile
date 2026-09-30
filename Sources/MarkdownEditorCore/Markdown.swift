import Foundation

public struct Heading: Equatable {
    public let level: Int
    public let title: String
    public let slug: String
    public let line: Int
}

public struct DocumentStats: Equatable {
    public let words: Int
    public let characters: Int
    public let readingMinutes: Int
}

public enum Markdown {
    /// ATX headings (`#` … `######`) outside fenced code blocks, with
    /// GitHub-style anchors; repeated anchors get `-1`, `-2` … suffixes.
    public static func outline(_ text: String) -> [Heading] {
        var headings: [Heading] = []
        var used: [String: Int] = [:]
        var inFence = false
        for (index, raw) in text.components(separatedBy: "\n").enumerated() {
            let line = raw.trimmingCharacters(in: .whitespaces)
            if line.hasPrefix("```") || line.hasPrefix("~~~") { inFence.toggle(); continue }
            if inFence { continue }
            let hashes = line.prefix(while: { $0 == "#" }).count
            guard (1...6).contains(hashes) else { continue }
            let rest = line.dropFirst(hashes)
            guard rest.isEmpty || rest.first == " " else { continue } // "#hashtag" is not a heading
            var title = rest.trimmingCharacters(in: .whitespaces)
            // Optional closing sequence: "## Title ##"
            while title.hasSuffix("#") { title.removeLast() }
            title = title.trimmingCharacters(in: .whitespaces)
            guard !title.isEmpty else { continue }
            let base = slug(title)
            let n = used[base, default: 0]
            used[base] = n + 1
            headings.append(Heading(level: hashes, title: title, slug: n == 0 ? base : "\(base)-\(n)", line: index + 1))
        }
        return headings
    }

    /// Lower-case, drop punctuation except `-` and `_`, spaces to `-`.
    public static func slug(_ title: String) -> String {
        var out = ""
        for ch in title.lowercased() {
            if ch.isLetter || ch.isNumber || ch == "-" || ch == "_" { out.append(ch) }
            else if ch == " " { out.append("-") }
        }
        return out
    }

    /// Word/character counts over prose (fenced code excluded) and reading time at 200 wpm.
    public static func stats(_ text: String) -> DocumentStats {
        var inFence = false
        var words = 0
        for raw in text.components(separatedBy: "\n") {
            let line = raw.trimmingCharacters(in: .whitespaces)
            if line.hasPrefix("```") || line.hasPrefix("~~~") { inFence.toggle(); continue }
            if inFence { continue }
            words += line.split(whereSeparator: { $0.isWhitespace })
                .filter { token in token.contains(where: { $0.isLetter || $0.isNumber }) }
                .count
        }
        let minutes = words == 0 ? 0 : max(1, Int((Double(words) / 200).rounded(.up)))
        return DocumentStats(words: words, characters: text.count, readingMinutes: minutes)
    }

    /// Wraps the selection (character offsets) in `marker`, or unwraps it if it
    /// is already wrapped. Returns the new text and the adjusted selection.
    public static func toggle(_ marker: String, in text: String, selection: Range<Int>) -> (text: String, selection: Range<Int>) {
        var chars = Array(text)
        let m = Array(marker)
        let lower = max(0, min(selection.lowerBound, chars.count))
        let upper = max(lower, min(selection.upperBound, chars.count))
        let before = lower >= m.count ? Array(chars[(lower - m.count)..<lower]) : []
        let after = upper + m.count <= chars.count ? Array(chars[upper..<(upper + m.count)]) : []
        if before == m && after == m {
            chars.removeSubrange(upper..<(upper + m.count))
            chars.removeSubrange((lower - m.count)..<lower)
            return (String(chars), (lower - m.count)..<(upper - m.count))
        }
        chars.insert(contentsOf: m, at: upper)
        chars.insert(contentsOf: m, at: lower)
        return (String(chars), (lower + m.count)..<(upper + m.count))
    }

    /// Toggles a task list item on the 1-based `line`: "- [ ]" ↔ "- [x]".
    public static func toggleTask(in text: String, line: Int) -> String {
        var lines = text.components(separatedBy: "\n")
        guard lines.indices.contains(line - 1) else { return text }
        let l = lines[line - 1]
        if let r = l.range(of: "- [ ] ") { lines[line - 1] = l.replacingCharacters(in: r, with: "- [x] ") }
        else if let r = l.range(of: "- [x] ", options: .caseInsensitive) { lines[line - 1] = l.replacingCharacters(in: r, with: "- [ ] ") }
        return lines.joined(separator: "\n")
    }
}
