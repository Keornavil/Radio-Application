import UIKit
import FRadioPlayer
import AVFoundation
import MediaPlayer

// MARK: - AudioPlayerDelegateHandlerProtocol
protocol AudioPlayerDelegateHandlerProtocol: AnyObject, FRadioPlayerDelegate {
    init(imageLoader: ImageLoaderServiceProtocol)
    var presenterForData: PlayerDataPresenterProtocol? { get }
    var playerStatus: PlayerStatus { get set }
    func togglePlayPause() -> PlayerStatus
    func currentSongData() -> (artistName: String, trackName: String, image: UIImage?)
    func dataRequest(artistName: String, trackName: String, image: UIImage)
    func setCurrentStationName(_ stationName: String)
    func configurePlaybackHandlers(play: @escaping () -> Void, pause: @escaping () -> Void)
    func setPresenterForData(presenter: PlayerDataPresenterProtocol?)
}

// MARK: - AudioPlayerDelegateHandler
final class AudioPlayerDelegateHandler: AudioPlayerDelegateHandlerProtocol {
    
    // MARK: - Properties
    private(set) weak var presenterForData: PlayerDataPresenterProtocol?
    var playerStatus: PlayerStatus = .pause {
        didSet {
            nowPlayingService.updatePlaybackState(isPlaying: playerStatus == .play)
        }
    }
    private let imageLoader: ImageLoaderServiceProtocol
    private let nowPlayingService: NowPlayingServiceProtocol
    private var lastArtistName = "Имя артиста неизвестно"
    private var lastTrackName = "Название песни неизвестно"
    private var lastArtworkImage: UIImage?
    private var lastStationName = "Radio"
    private var playHandler: (() -> Void)?
    private var pauseHandler: (() -> Void)?
    
    // MARK: - Init (DI)
    required convenience init(imageLoader: ImageLoaderServiceProtocol) {
        self.init(
            imageLoader: imageLoader,
            nowPlayingService: NowPlayingInfoService()
        )
    }

    init(imageLoader: ImageLoaderServiceProtocol, nowPlayingService: NowPlayingServiceProtocol) {
        self.imageLoader = imageLoader
        self.nowPlayingService = nowPlayingService
        self.nowPlayingService.configureAudioSessionForPlayback()
    }
    
    // MARK: - Presenter binding
    func setPresenterForData(presenter: PlayerDataPresenterProtocol?) {
        self.presenterForData = presenter
        replayLastKnownData(to: presenter)
    }
    
    // MARK: - Player state
    func togglePlayPause() -> PlayerStatus {
        playerStatus = (playerStatus == .pause) ? .play : .pause
        return playerStatus
    }

    func currentSongData() -> (artistName: String, trackName: String, image: UIImage?) {
        (lastArtistName, lastTrackName, lastArtworkImage)
    }
    
    // MARK: - Data forwarding
    func setCurrentStationName(_ stationName: String) {
        lastStationName = stationName
        syncNowPlayingInfo()
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
        lastArtistName = artistName
        lastTrackName = trackName
        lastArtworkImage = image
        syncNowPlayingInfo()
    }
    
    // MARK: - FRadioPlayerDelegate
    func radioPlayer(_ player: FRadioPlayer, metadataDidChange artistName: String?, trackName: String?) {
        let safeArtist = artistName ?? "Имя артиста неизвестно"
        let safeTrack = trackName ?? "Название песни неизвестно"
        lastArtistName = safeArtist
        lastTrackName = safeTrack
        syncNowPlayingInfo()
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
                self?.lastArtworkImage = image
                self?.syncNowPlayingInfo()
                DispatchQueue.main.async {
                    self?.presenterForData?.dataOfSongImage(image: image)
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
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            presenter.dataOfSong(artistName: self.lastArtistName, trackName: self.lastTrackName)
            presenter.dataOfSongImage(image: self.lastArtworkImage)
        }
    }

    private func syncNowPlayingInfo() {
        nowPlayingService.updateNowPlayingInfo(
            artistName: lastArtistName,
            trackName: lastTrackName,
            stationName: lastStationName,
            artwork: lastArtworkImage,
            isPlaying: playerStatus == .play
        )
    }
}

// MARK: - Player Status
enum PlayerStatus {
    case play
    case pause
}

protocol NowPlayingServiceProtocol: AnyObject {
    func configureAudioSessionForPlayback()
    func configureRemoteCommands(
        onPlay: @escaping () -> Void,
        onPause: @escaping () -> Void,
        onToggle: @escaping () -> Void
    )
    func updateNowPlayingInfo(
        artistName: String,
        trackName: String,
        stationName: String,
        artwork: UIImage?,
        isPlaying: Bool
    )
    func updatePlaybackState(isPlaying: Bool)
}

final class NowPlayingInfoService: NowPlayingServiceProtocol {
    private let audioSession: AVAudioSession
    private let nowPlayingInfoCenter: MPNowPlayingInfoCenter
    private let commandCenter: MPRemoteCommandCenter
    private var cachedNowPlayingInfo: [String: Any] = [:]

    init(
        audioSession: AVAudioSession = .sharedInstance(),
        nowPlayingInfoCenter: MPNowPlayingInfoCenter = .default(),
        commandCenter: MPRemoteCommandCenter = .shared()
    ) {
        self.audioSession = audioSession
        self.nowPlayingInfoCenter = nowPlayingInfoCenter
        self.commandCenter = commandCenter
    }

    func configureAudioSessionForPlayback() {
        do {
            try audioSession.setCategory(
                .playback,
                mode: .default,
                options: [.allowAirPlay, .allowBluetoothA2DP, .allowBluetoothHFP]
            )
            try audioSession.setActive(true)
        } catch {
            print("Audio session configuration failed: \(error)")
        }
    }

    func configureRemoteCommands(
        onPlay: @escaping () -> Void,
        onPause: @escaping () -> Void,
        onToggle: @escaping () -> Void
    ) {
        commandCenter.playCommand.removeTarget(nil)
        commandCenter.pauseCommand.removeTarget(nil)
        commandCenter.togglePlayPauseCommand.removeTarget(nil)

        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.nextTrackCommand.isEnabled = false
        commandCenter.previousTrackCommand.isEnabled = false
        commandCenter.changePlaybackPositionCommand.isEnabled = false
        commandCenter.seekForwardCommand.isEnabled = false
        commandCenter.seekBackwardCommand.isEnabled = false

        commandCenter.playCommand.addTarget { [weak self] _ in
            onPlay()
            self?.updatePlaybackState(isPlaying: true)
            return .success
        }
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            onPause()
            self?.updatePlaybackState(isPlaying: false)
            return .success
        }
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            onToggle()
            guard self != nil else { return .commandFailed }
            return .success
        }
    }

    func updateNowPlayingInfo(
        artistName: String,
        trackName: String,
        stationName: String,
        artwork: UIImage?,
        isPlaying: Bool
    ) {
        DispatchQueue.main.async {
            var info: [String: Any] = [
                MPMediaItemPropertyArtist: artistName,
                MPMediaItemPropertyTitle: trackName,
                MPMediaItemPropertyAlbumTitle: stationName,
                MPNowPlayingInfoPropertyIsLiveStream: true,
                MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
            ]

            if let artwork {
                info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(
                    boundsSize: artwork.size,
                    requestHandler: { _ in artwork }
                )
            }

            self.cachedNowPlayingInfo = info
            self.nowPlayingInfoCenter.nowPlayingInfo = info
            if #available(iOS 13.0, *) {
                self.nowPlayingInfoCenter.playbackState = isPlaying ? .playing : .paused
            }
        }
    }

    func updatePlaybackState(isPlaying: Bool) {
        DispatchQueue.main.async {
            self.cachedNowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
            self.nowPlayingInfoCenter.nowPlayingInfo = self.cachedNowPlayingInfo
            if #available(iOS 13.0, *) {
                self.nowPlayingInfoCenter.playbackState = isPlaying ? .playing : .paused
            }
        }
    }
}
