





import Foundation
import UIKit

protocol NowPlayingViewProtocol: AnyObject {
    func setComment(transferDataForRadio: TransferData)
    func dataOfSong(artistName: String, trackName: String)
    func dataOfSongImage(image: UIImage)
    
}

protocol NowPlayingViewPresenterProtocol: AnyObject {
    init (view: NowPlayingViewProtocol, router: RouterProtocol, audioPlayer: AudioPlayerProtocol,audioPlayerDelegate: AudioPlayerDelegateHandlerProtocol, transferDataForRadio: TransferData)
    func setComment()
    func routeForDelegate()
    func play()
    func pause()
    func playerStatus() -> String
    
}

class NowPlayingViewPresenter: NowPlayingViewPresenterProtocol {
    
    weak var view: NowPlayingViewProtocol?
    var router: RouterProtocol?
    var transferDataForRadio: TransferData
    var audioPlayer: AudioPlayerProtocol?
    var audioPlayerDelegate: AudioPlayerDelegateHandlerProtocol!
    private var previousPresenter: DataPresenterProtocol?
    private var artistNameRadio: String?
    private var trackNameRadio: String?
    private var imageRadio: UIImage?
    
    required init(view: NowPlayingViewProtocol, router: RouterProtocol, audioPlayer: AudioPlayerProtocol, audioPlayerDelegate: AudioPlayerDelegateHandlerProtocol, transferDataForRadio: TransferData) {
        self.view = view
        self.router = router
        self.audioPlayer = audioPlayer
        self.audioPlayerDelegate = audioPlayerDelegate
        self.transferDataForRadio = transferDataForRadio
        dataOnPresenter()
    }
    
    func play() {
        audioPlayer?.play()
    }
    
    func pause() {
        audioPlayer?.pause()
    }
    
    func playerStatus() -> String {
        let status = audioPlayerDelegate.togglePlayPause()
        (status == .pause) ? pause() : play()
        return (status == .pause) ? "play.circle" : "pause.circle"
    }
    
    func dataOnPresenter() {
        self.previousPresenter = audioPlayerDelegate?.presenterForData
        audioPlayerDelegate.setPresenterForData(presenter: self)
    }
    
    func routeForDelegate() {
        audioPlayerDelegate.setPresenterForData(presenter: previousPresenter!)
        audioPlayerDelegate.dataRequest(artistName: artistNameRadio!, trackName: trackNameRadio!, image: imageRadio!)
    }
    
    public func setComment() {
        self.view?.setComment(transferDataForRadio: transferDataForRadio)
        artistNameRadio = transferDataForRadio.artistName
        trackNameRadio = transferDataForRadio.trackName
        imageRadio = transferDataForRadio.image
    }
}

extension NowPlayingViewPresenter: DataPresenterProtocol {
    
    
    func dataOfSong(artistName: String, trackName: String) {
        artistNameRadio = artistName
        trackNameRadio = trackName
        self.view?.dataOfSong(artistName: artistName, trackName: trackName)
    }
    
    func dataOfSongImage(image: UIImage?) {
        guard let image = image else {
            return
        }
        self.view?.dataOfSongImage(image: image)
        imageRadio = image
    }
}
