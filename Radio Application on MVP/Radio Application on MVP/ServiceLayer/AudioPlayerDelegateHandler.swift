





import UIKit
import FRadioPlayer
import Kingfisher

protocol AudioPlayerDelegateHandlerProtocol: AnyObject, FRadioPlayerDelegate {
    var presenterForData: DataPresenterProtocol? { get }
    var playerStatus: PlayerStatus? { get set }
    func togglePlayPause() -> PlayerStatus
    func dataRequest(artistName: String, trackName: String, image: UIImage)
    func setPresenterForData(presenter: DataPresenterProtocol)
}

class AudioPlayerDelegateHandler: AudioPlayerDelegateHandlerProtocol {
    
    
    var presenterForData: DataPresenterProtocol?
    var playerStatus: PlayerStatus?
    
    func radioPlayer(_ player: FRadioPlayer, metadataDidChange artistName: String?, trackName: String?) {
        DispatchQueue.main.async {
            let artistName = artistName ?? "Имя артиста неизвестно"
            let trackName = trackName ?? "Название песни неизвестно"
            self.presenterForData?.dataOfSong(artistName: artistName, trackName: trackName)
        }
    }
    

    func radioPlayer(_ player: FRadioPlayer, artworkDidChange artworkURL: URL?) {
        guard let artworkURL = artworkURL else {
            print("Данные об обложке не найдены")
            return
        }
        
        let defaultSize = "/100x100bb.jpg"
        let updateSize = "/300x300bb.jpg"
        
        // Создаем новый URL с обновленным размером
        guard let updateArtworkURL = URL( string: artworkURL.absoluteString.replacingOccurrences(of: defaultSize, with: updateSize)) else { return }
        
        DispatchQueue.main.async {
            KingfisherManager.shared.retrieveImage(with: updateArtworkURL) { result in
                switch result {
                case .success(let value):
                    self.presenterForData?.dataOfSongImage(image: value.image)
                case .failure(let error):
                    print("Ошибка при загрузке изображения: \(error)")
                }
            }
        }
    }
    
    func setPresenterForData(presenter: DataPresenterProtocol) {
        presenterForData = presenter
    }
    
    func dataRequest(artistName: String, trackName: String, image: UIImage) {
        presenterForData?.dataRequest!(trackName: trackName, artistName: artistName, image: image)
    }
    
    
    func togglePlayPause() -> PlayerStatus {
        playerStatus = (playerStatus == .pause) ? .play : .pause
        return playerStatus!

    }
    
    func radioPlayer(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState) {
        
    }
    
    func radioPlayer(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState) {
        
    }
}

enum PlayerStatus {
    case play
    case pause
}
