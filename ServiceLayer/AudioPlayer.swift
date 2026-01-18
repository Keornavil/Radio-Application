
import Foundation
import FRadioPlayer

protocol AudioPlayerProtocol {
    func setupURLForRadio(url: String)
    func play()
    func pause()
    func stop()
    func setDelegate(delegate: FRadioPlayerDelegate)
}

final class AudioPlayer: AudioPlayerProtocol {
    private let player = FRadioPlayer.shared
    
    func setupURLForRadio(url: String) {
        guard let radioURL = URL(string: url) else {
            print("Ссылка не соответствует URL формату")
            return
        }
        self.player.radioURL = radioURL
    }
    func play() {
        self.player.play()
    }
    func pause() {
        self.player.pause()
    }
    func stop() {
        self.player.stop()
    }
    func setDelegate(delegate: FRadioPlayerDelegate) {
        player.delegate = delegate
    }
}

        
