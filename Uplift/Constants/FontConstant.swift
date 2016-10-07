// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

#if os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIFont
  typealias Font = UIFont
#elseif os(OSX)
  import AppKit.NSFont
  typealias Font = NSFont
#endif

// swiftlint:disable file_length

protocol FontConvertible {
  func font(size: CGFloat) -> Font!
}

extension FontConvertible where Self: RawRepresentable, Self.RawValue == String {
  func font(size: CGFloat) -> Font! {
    return Font(font: self, size: size)
  }
}

extension Font {
  convenience init!<FontType: FontConvertible
    where FontType: RawRepresentable, FontType.RawValue == String>
    (font: FontType, size: CGFloat) {
      self.init(name: font.rawValue, size: size)
  }
}

struct FontFamily {
  enum OpenSans: String, FontConvertible {
    case ExtraboldItalic = "OpenSans-ExtraboldItalic"
    case BoldItalic = "OpenSans-BoldItalic"
    case Italic = "OpenSans-Italic"
    case Bold = "OpenSans-Bold"
    case Extrabold = "OpenSans-Extrabold"
    case Light = "OpenSans-Light"
    case LightItalic = "OpenSansLight-Italic"
    case Regular = "OpenSans"
    case Semibold = "OpenSans-Semibold"
    case SemiboldItalic = "OpenSans-SemiboldItalic"
  }
  enum Montserrat: String, FontConvertible {
    case Bold = "Montserrat-Bold"
    case Light = "Montserrat-Light"
    case Regular = "Montserrat-Regular"
  }
}
