import UIKit
import RxCocoa
import RxSwift
import Moya
import Moya_ModelMapper

class ViewController: UIViewController {
  // Outlets.
  @IBOutlet weak var searchBar:              UISearchBar!
  @IBOutlet weak var ratingSegmentedControl: UISegmentedControl!
  @IBOutlet weak var collectionView:         UICollectionView!

  // Constants.
  private let giphy      = RxMoyaProvider<Giphy>()
  private let disposeBag = DisposeBag()
  private let ratings    = ["r", "pg"]

  // Methods.
  override func viewDidLoad() {
    super.viewDidLoad()
    bindToInputs()
  }

  private func bindToInputs() {
    Observable
      .combineLatest(searchBar.rx_text, ratingSegmentedControl.rx_value) {
        [$0, $1]
      }
      .throttle(0.25, scheduler: MainScheduler.instance)
      .distinctUntilChanged()
      .flatMap { _ in
        self.scrollToTopAndReturnGifs()
      }
      .bindTo(collectionView.rx_itemsWithCellIdentifier("gif", cellType: GifCollectionViewCell.self)) { _, gif, cell in
        cell.gif = gif
      }
      .addDisposableTo(disposeBag)
  }

  private func scrollToTopAndReturnGifs() -> Observable<[Gif]> {
    scrollToTop()
    return gifs
  }

  private func scrollToTop() {
    collectionView.contentOffset = CGPointZero
  }

  private var gifs: Observable<[Gif]> {
    return giphy
      .request(request)
      .mapArray(Gif.self, keyPath: "data")
  }

  private var request: Giphy {
    if isQueryEmpty {
      return .Trending(rating)
    } else {
      return .Search(rating, query)
    }
  }

  private var isQueryEmpty: Bool {
    return query == ""
  }

  private var query: String {
    return searchBar.text!
  }

  private var rating: String {
    return ratings[selectedRating]
  }

  private var selectedRating: Int {
    return ratingSegmentedControl.selectedSegmentIndex
  }
}