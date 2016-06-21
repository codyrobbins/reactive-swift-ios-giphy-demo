import UIKit
import AVFoundation

class GifCollectionViewCell: UICollectionViewCell {
  // Constants.
  private let notificationCenter = NSNotificationCenter.defaultCenter()
  
  // Properties.
  private var player: AVPlayer!

  // Outlets.
  @IBOutlet weak var trendedLabel: UILabel!

  // Video playing.
  var gif: Gif! {
    didSet {
      if let url = NSURL(string: gif.url) {
        setPlayer(url)
        addPlayerToLayer()
        addObserverForPlaybackReady()
        addObserverForPlaybackEnded()
        setTrendedLabelVisibility()
      }
    }
  }

  private func setPlayer(url: NSURL) {
    player = AVPlayer(URL: url)
  }

  private func addPlayerToLayer() {
    playerLayer.player = player
  }

  private var playerLayer: AVPlayerLayer {
    return layer as! AVPlayerLayer
  }

  private func addObserverForPlaybackReady() {
    player.addObserver(self, forKeyPath: "status", options: .New, context: nil)
  }

  private func addObserverForPlaybackEnded() {
    notificationCenter.addObserver(self, selector: #selector(replay), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
  }

  private func setTrendedLabelVisibility() {
    trendedLabel.hidden = isNeverTrended
  }

  private var isNeverTrended: Bool {
    return !gif.trended
  }

  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if isNotificationForThisPlayerAndPlaybackReady(object) {
      startPlaying()
    } else {
      super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
    }
  }

  private func isNotificationForThisPlayerAndPlaybackReady(object: AnyObject?) -> Bool {
    return object === player && isPlaybackReady
  }

  private var isPlaybackReady: Bool {
    return player.status == AVPlayerStatus.ReadyToPlay
  }

  private func startPlaying() {
    player.play()
  }

  @objc func replay(notification: NSNotification) {
    if isNotificationForThisPlayerItem(notification) {
      seekToBeginning()
      startPlaying()
    }
  }

  private func isNotificationForThisPlayerItem(notification: NSNotification) -> Bool {
    return notification.object === playerItem
  }

  private var playerItem: AVPlayerItem {
    return player.currentItem!
  }

  private func seekToBeginning() {
    player.seekToTime(kCMTimeZero)
  }

  // Deinitializer.
  deinit {
    prepareForReuse()
  }

  override func prepareForReuse() {
    unsubscribeFromPlaybackReadyNotifications()
    unsubscribeFromPlaybackEndedNotifications()
  }

  private func unsubscribeFromPlaybackReadyNotifications() {
    player.removeObserver(self, forKeyPath: "status")
  }

  private func unsubscribeFromPlaybackEndedNotifications() {
    notificationCenter.removeObserver(self)
  }

  // Override for the class to use for the view's layer so it can play video.
  override class func layerClass() -> AnyClass {
    return AVPlayerLayer.self
  }
}