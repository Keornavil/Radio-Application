import UIKit
import FRadioPlayer

// MARK: - AudioPlayerDelegateHandlerProtocol
protocol AudioPlayerDelegateHandlerProtocol: AnyObject, FRadioPlayerDelegate {
    init(imageLoader: ImageLoaderServiceProtocol)
    var presenterForData: PlayerDataPresenterProtocol? { get }
    var playerStatus: PlayerStatus { get set }
    func togglePlayPause() -> PlayerStatus
    func currentSongData() -> (radioName: String, artistName: String, trackName: String, image: UIImage?)
    func dataRequest(artistName: String, trackName: String, image: UIImage)
    func setCurrentStationName(_ stationName: String)
    func configurePlaybackHandlers(play: @escaping () -> Void, pause: @escaping () -> Void)
    func setPresenterForData(presenter: PlayerDataPresenterProtocol?)
}

// MARK: - AudioPlayerDelegateHandler
final class AudioPlayerDelegateHandler: AudioPlayerDelegateHandlerProtocol {
    
    // MARK: - Properties
    private(set) weak var presenterForData: PlayerDataPresenterProtocol?
    var playerStatus: PlayerStatus {
        get { stateStore.currentState().status }
        set {
            let snapshot = stateStore.update { $0.status = newValue }
            syncNowPlayingInfo(with: snapshot)
        }
    }
    private let imageLoader: ImageLoaderServiceProtocol
    private let nowPlayingService: NowPlayingServiceProtocol
    private let stateStore: AudioPlayerStateStoreProtocol
    private var playHandler: (() -> Void)?
    private var pauseHandler: (() -> Void)?
    
    // MARK: - Init (DI)
    required convenience init(imageLoader: ImageLoaderServiceProtocol) {
        self.init(
            imageLoader: imageLoader,
            nowPlayingService: NowPlayingInfoService(),
            stateStore: AudioPlayerStateStore()
        )
    }

    init(
        imageLoader: ImageLoaderServiceProtocol,
        nowPlayingService: NowPlayingServiceProtocol,
        stateStore: AudioPlayerStateStoreProtocol
    ) {
        self.imageLoader = imageLoader
        self.nowPlayingService = nowPlayingService
        self.stateStore = stateStore
        self.nowPlayingService.configureAudioSessionForPlayback()
    }
    
    // MARK: - Presenter binding
    func setPresenterForData(presenter: PlayerDataPresenterProtocol?) {
        self.presenterForData = presenter
        replayLastKnownData(to: presenter)
    }
    
    // MARK: - Player state
    func togglePlayPause() -> PlayerStatus {
        let snapshot = stateStore.update { state in
            state.status = (state.status == .pause) ? .play : .pause
        }
        syncNowPlayingInfo(with: snapshot)
        return snapshot.status
    }

    func currentSongData() -> (radioName: String, artistName: String, trackName: String, image: UIImage?) {
        let snapshot = stateStore.currentState()
        return (snapshot.stationName, snapshot.artistName, snapshot.trackName, snapshot.artwork)
    }
    
    // MARK: - Data forwarding
    func setCurrentStationName(_ stationName: String) {
        let snapshot = stateStore.update { $0.stationName = stationName }
        syncNowPlayingInfo(with: snapshot)
    }

    func configurePlaybackHandlers(play: @escaping () -> Void, pause: @escaping () -> Void) {
        playHandler = play
        pauseHandler = pause

        nowPlayingService.configureRemoteCommands(
            onPlay: { [weak self] in
                self?.playerStatus = .play
                self?.playHandler?()
            },
            onPause: { [weak self] in
                self?.playerStatus = .pause
                self?.pauseHandler?()
            },
            onToggle: { [weak self] in
                guard let self else { return }
                let status = self.togglePlayPause()
                (status == .play ? self.playHandler : self.pauseHandler)?()
            }
        )
    }

    func dataRequest(artistName: String, trackName: String, image: UIImage) {
        let snapshot = stateStore.update { state in
            state.artistName = artistName
            state.trackName = trackName
            state.artwork = image
        }
        syncNowPlayingInfo(with: snapshot)
    }
    
    // MARK: - FRadioPlayerDelegate
    func radioPlayer(_ player: FRadioPlayer, metadataDidChange artistName: String?, trackName: String?) {
        let safeArtist = artistName ?? "Имя артиста неизвестно"
        let safeTrack = trackName ?? "Название песни неизвестно"
        let snapshot = stateStore.update { state in
            state.artistName = safeArtist
            state.trackName = safeTrack
        }
        syncNowPlayingInfo(with: snapshot)
        DispatchQueue.main.async { [weak self] in
            self?.presenterForData?.dataOfSong(
                artistName: snapshot.artistName,
                trackName: snapshot.trackName
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
                guard let self else { return }
                let snapshot = self.stateStore.update { $0.artwork = image }
                self.syncNowPlayingInfo(with: snapshot)
                DispatchQueue.main.async {
                    self.presenterForData?.dataOfSongImage(image: image)
                }
            case .failure(let error):
                print("Ошибка загрузки обложки: \(error)")
            }
        }
    }
    
    // MARK: - FRadioPlayer callbacks (unused for now)
    func radioPlayer(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState) {}
    func radioPlayer(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState) {}

    private func replayLastKnownData(to presenter: PlayerDataPresenterProtocol?) {
        guard let presenter else { return }
        let snapshot = stateStore.currentState()
        DispatchQueue.main.async {
            presenter.dataOfSong(artistName: snapshot.artistName, trackName: snapshot.trackName)
            presenter.dataOfSongImage(image: snapshot.artwork)
        }
    }

    private func syncNowPlayingInfo(with snapshot: PlayerState) {
        nowPlayingService.updateNowPlayingInfo(
            artistName: snapshot.artistName,
            trackName: snapshot.trackName,
            stationName: snapshot.stationName,
            artwork: snapshot.artwork,
            isPlaying: snapshot.status == .play
        )
    }
}
