import UIKit

// MARK: - Presenter
protocol NowPlayingViewPresenterProtocol: AnyObject {
    init(audioPlayer: AudioPlayerProtocol,
         audioPlayerDelegate: AudioPlayerDelegateHandlerProtocol)
    func setComment()
    func activateAsDataReceiver()
    func play()
    func pause()
    func playerStatus() -> String
}

final class NowPlayingViewPresenter: NowPlayingViewPresenterProtocol {

    private weak var view: NowPlayingViewProtocol?
    private let audioPlayer: AudioPlayerProtocol
    private let audioPlayerDelegate: AudioPlayerDelegateHandlerProtocol

    // MARK: - Init
    required init(audioPlayer: AudioPlayerProtocol,
                  audioPlayerDelegate: AudioPlayerDelegateHandlerProtocol) {
        self.audioPlayer = audioPlayer
        self.audioPlayerDelegate = audioPlayerDelegate
        dataOnPresenter()
    }

    // MARK: - Binding
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
        var dataForView = TransferData.initial
        let songData = audioPlayerDelegate.currentSongData()
        dataForView.radioName = songData.radioName
        dataForView.artistName = songData.artistName
        dataForView.trackName = songData.trackName
        if let image = songData.image {
            dataForView.image = image
        }
        view?.setComment(transferDataForRadio: dataForView)
    }
    func activateAsDataReceiver() {
        dataOnPresenter()
    }
}

// MARK: - PlayerDataPresenterProtocol
extension NowPlayingViewPresenter: PlayerDataPresenterProtocol {

    func dataOnPresenter() {
        if let current = audioPlayerDelegate.presenterForData as AnyObject?, current === self {
            return
        }
        audioPlayerDelegate.setPresenterForData(presenter: self)
    }
    func dataOfSong(artistName: String, trackName: String) {
        view?.dataOfSong(artistName: artistName, trackName: trackName)
    }
    func dataOfSongImage(image: UIImage?) {
        guard let image else { return }
        view?.dataOfSongImage(image: image)
    }
}
