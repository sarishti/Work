// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

#if os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  typealias Image = UIImage
#elseif os(OSX)
  import AppKit.NSImage
  typealias Image = NSImage
#endif

// swiftlint:disable file_length
// swiftlint:disable type_body_length
enum Asset: String {
  case Article_default = "article_default"
  case Back_btn = "back_btn"
  case Background_img = "background_img"
  case Category = "category"
  case Gray_line = "gray_line"
  case Share_btn = "share_btn"
  case Source = "source"
  case Time = "time"
  case Up = "up"
  case Up_article = "up_article"
  case Up_selected = "up_selected"
  case Source_cell_bg = "source_cell_bg"
  case News_feed = "news_feed"
  case Source_tab = "source_tab"
  case YourUps = "yourUps"
  case Category_black = "category_black"
  case Source_black = "source_black"
  case Time_black = "time_black"
  case Uped = "uped"

  var image: Image {
    return Image(asset: self)
  }
}
// swiftlint:enable type_body_length

extension Image {
  convenience init!(asset: Asset) {
    self.init(named: asset.rawValue)
  }
}
