import Foundation
import Mapper

struct Gif: Mappable {
  // Constants.
          let url:       String
  private let trendedAt: String

  // Initializer.
  init(map: Mapper) throws {
    try url       = map.from("images.fixed_height.mp4")
    try trendedAt = map.from("trending_datetime")
  }

  // Properties.
  var trended: Bool {
    return trendedAt != "1970-01-01 00:00:00"
  }
}