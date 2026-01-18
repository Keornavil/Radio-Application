





import Foundation
import UIKit

// MARK: - View
protocol NowPlayingViewProtocol: AnyObject {
    func setComment(transferDataForRadio: TransferData)
    func dataOfSong(artistName: String, trackName: String)
    func dataOfSongImage(image: UIImage)
}

// MARK: - Presenter
protocol NowPlayingViewPresenterProtocol: AnyObject {
    init(router: RouterProtocol,
         audioPlayer: AudioPlayerProtocol,
         audioPlayerDelegate: AudioPlayerDelegateHandlerProtocol,
         transferDataForRadio: TransferData)
    func setComment()
    func routeForDelegate()
    func play()
    func pause()
    func playerStatus() -> String
}

final class NowPlayingViewPresenter: NowPlayingViewPresenterProtocol {

    private weak var view: NowPlayingViewProtocol?
    private let router: RouterProtocol
    private let audioPlayer: AudioPlayerProtocol
    private let audioPlayerDelegate: AudioPlayerDelegateHandlerProtocol
    private let transferDataForRadio: TransferData
    private weak var previousPresenter: DataPresenterProtocol?
    private var artistNameRadio: String
    private var trackNameRadio: String
    private var imageRadio: UIImage

    // MARK: - Init
    required init(router: RouterProtocol,
                  audioPlayer: AudioPlayerProtocol,
                  audioPlayerDelegate: AudioPlayerDelegateHandlerProtocol,
                  transferDataForRadio: TransferData) {
        self.router = router
        self.audioPlayer = audioPlayer
        self.audioPlayerDelegate = audioPlayerDelegate
        self.transferDataForRadio = transferDataForRadio
        self.artistNameRadio = transferDataForRadio.artistName
        self.trackNameRadio  = transferDataForRadio.trackName
        self.imageRadio      = transferDataForRadio.image
        dataOnPresenter()
    }
    // MARK: Binding
    func attachView(_ view: NowPlayingViewProtocol) {
        self.view = view
    }
    
    // MARK: - Player controls
    func play() { audioPlayer.play() }
    func pause() { audioPlayer.pause() }
    func playerStatus() -> String {
        let status = audioPlayerDelegate.togglePlayPause()
        (status == .pause) ? pause() : play()
        return (status == .pause) ? "play.circle" : "pause.circle"
    }

    // MARK: - View setup
    func setComment() {
        view?.setComment(transferDataForRadio: transferDataForRadio)
    }

    // MARK: - Restore delegate routing back
    func routeForDelegate() {
        guard let previousPresenter else { return }
        audioPlayerDelegate.setPresenterForData(presenter: previousPresenter)
        audioPlayerDelegate.dataRequest(
            artistName: artistNameRadio,
            trackName: trackNameRadio,
            image: imageRadio
        )
    }
}

// MARK: - DataPresenterProtocol
extension NowPlayingViewPresenter: DataPresenterProtocol {

    func dataOnPresenter() {
        previousPresenter = audioPlayerDelegate.presenterForData
        audioPlayerDelegate.setPresenterForData(presenter: self)
    }
    func dataOfSong(artistName: String, trackName: String) {
        artistNameRadio = artistName
        trackNameRadio = trackName
        view?.dataOfSong(artistName: artistName, trackName: trackName)
    }
    func dataOfSongImage(image: UIImage?) {
        guard let image else { return }
        imageRadio = image
        view?.dataOfSongImage(image: image)
    }
}
