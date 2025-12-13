import Foundation

/// Supported languages for output text.
public enum Language {
    case simplifiedChinese  // 简体中文 (Default)
    case traditionalChinese // 繁体中文
    case japanese           // 日本語
    case english            // English
}

/// Global configuration for the GanZhi library.
public struct GanZhiConfig {
    /// The current language used for text output.
    /// Defaults to .simplifiedChinese.
    public static var language: Language = .simplifiedChinese
}

