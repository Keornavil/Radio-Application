import UIKit
import AVFoundation
import MediaPlayer

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
            guard !self.cachedNowPlayingInfo.isEmpty else { return }
            self.cachedNowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
            self.nowPlayingInfoCenter.nowPlayingInfo = self.cachedNowPlayingInfo
            if #available(iOS 13.0, *) {
                self.nowPlayingInfoCenter.playbackState = isPlaying ? .playing : .paused
            }
        }
    }
}
