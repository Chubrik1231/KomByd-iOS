import Foundation

extension String {
    // Безопасный и быстрый декодер HTML-сущностей без использования WebKit / NSAttributedString
    func decodingHTMLEntities() -> String {
        var result = self
        let namedEntities: [String: String] = [
            "&oacute;": "ó", "&Oacute;": "Ó",
            "&quot;": "\"", "&amp;": "&", "&apos;": "'",
            "&lt;": "<", "&gt;": ">", "&nbsp;": " ",
            "&ndash;": "–", "&mdash;": "—", "&hellip;": "…",
            "&bdquo;": "„", "&rdquo;": "”", "&bull;": "•"
        ]
        for (entity, replacement) in namedEntities {
            result = result.replacingOccurrences(of: entity, with: replacement)
        }

        // Декодирование числовых сущностей &#123;
        if let regex = try? NSRegularExpression(pattern: "&#([0-9]+);", options: []) {
            let nsString = result as NSString
            let matches = regex.matches(in: result, options: [], range: NSRange(location: 0, length: nsString.length))
            for match in matches.reversed() {
                let codeStr = nsString.substring(with: match.range(at: 1))
                if let code = UInt32(codeStr), let scalar = UnicodeScalar(code) {
                    let char = String(Character(scalar))
                    result = (result as NSString).replacingCharacters(in: match.range, with: char)
                }
            }
        }
        return result
    }
}
