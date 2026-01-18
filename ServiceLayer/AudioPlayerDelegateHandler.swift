
import UIKit
import FRadioPlayer

// MARK: - AudioPlayerDelegateHandlerProtocol
protocol AudioPlayerDelegateHandlerProtocol: AnyObject, FRadioPlayerDelegate {
    init(imageLoader: ImageLoaderServiceProtocol)
    var presenterForData: DataPresenterProtocol? { get }
    var playerStatus: PlayerStatus { get set }
    func togglePlayPause() -> PlayerStatus
    func dataRequest(artistName: String, trackName: String, image: UIImage)
    func setPresenterForData(presenter: DataPresenterProtocol?)
}

// MARK: - AudioPlayerDelegateHandler
final class AudioPlayerDelegateHandler: AudioPlayerDelegateHandlerProtocol {
    
    // MARK: - Properties
    private(set) weak var presenterForData: DataPresenterProtocol?
    var playerStatus: PlayerStatus = .pause
    private let imageLoader: ImageLoaderServiceProtocol
    
    // MARK: - Init (DI)
    init(imageLoader: ImageLoaderServiceProtocol) {
        self.imageLoader = imageLoader
    }
    
    // MARK: - Presenter binding
    func setPresenterForData(presenter: DataPresenterProtocol?) {
        self.presenterForData = presenter
    }
    
    // MARK: - Player state
    func togglePlayPause() -> PlayerStatus {
        playerStatus = (playerStatus == .pause) ? .play : .pause
        return playerStatus
    }
    
    // MARK: - Data forwarding
    func dataRequest(artistName: String, trackName: String, image: UIImage) {
        presenterForData?.dataRequest?(
            trackName: trackName,
            artistName: artistName,
            image: image
        )
    }
    
    // MARK: - FRadioPlayerDelegate
    func radioPlayer(_ player: FRadioPlayer, metadataDidChange artistName: String?, trackName: String?) {
        let safeArtist = artistName ?? "Имя артиста неизвестно"
        let safeTrack = trackName ?? "Название песни неизвестно"
        DispatchQueue.main.async { [weak self] in
            self?.presenterForData?.dataOfSong(
                artistName: safeArtist,
                trackName: safeTrack
            )
        }
    }
    func radioPlayer(_ player: FRadioPlayer, artworkDidChange artworkURL: URL?) {
        guard let artworkURL else {
            print("Нет ссылки на изображение")
            return
        }
        let updatedURL = artworkURL
            .absoluteString
            .replacingOccurrences(of: "/100x100bb.jpg", with: "/300x300bb.jpg")
        guard let url = URL(string: updatedURL) else { return }
        imageLoader.loadImage(from: url) { [weak self] result in
            switch result {
            case .success(let image):
                self?.presenterForData?.dataOfSongImage(image: image)
            case .failure(let error):
                print("Ошибка загрузки обложки: \(error)")
            }
        }
    }
    
    // MARK: - FRadioPlayer callbacks (unused for now)
    func radioPlayer(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState) {}
    func radioPlayer(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState) {}
}

// MARK: - Player Status
enum PlayerStatus {
    case play
    case pause
}
