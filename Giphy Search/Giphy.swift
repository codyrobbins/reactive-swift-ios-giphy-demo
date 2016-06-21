import Foundation
import Moya

// API calls.
enum Giphy {
  case Trending(String)
  case Search(String, String)
}

// API call details.
extension Giphy: TargetType {
  // Base URL.
  var baseURL: NSURL {
    return NSURL(string: "https://api.giphy.com/v1/")!
  }

  // Request method.
  var method: Moya.Method {
    return .GET
  }

  // Paths.
  var path: String {
    switch self {
    case .Trending:
      return "stickers/trending"
    case .Search:
      return "gifs/search"
    }
  }

  // Parameters.
  var parameters: [String: AnyObject]? {
    switch self {
    case .Search(let rating, let query):
      return allParameters(rating, parameters: ["q": query])
    case .Trending(let rating):
      return allParameters(rating, parameters: [:])
    }
  }

  private func allParameters(rating: String, parameters: [String: AnyObject]) -> [String: AnyObject] {
    var newParameters = parameters

    newParameters["rating"]  = rating
    newParameters["api_key"] = "dc6zaTOxFJmzC"

    return newParameters
  }

  // Sample data.
  var sampleData: NSData {
    return NSData()
  }
}