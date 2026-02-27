import UIKit

enum PlayerStatus {
    case play
    case pause
}

struct PlayerState {
    var stationName: String
    var artistName: String
    var trackName: String
    var artwork: UIImage?
    var status: PlayerStatus

    static let initial = PlayerState(
        stationName: "Radio",
        artistName: "Имя артиста неизвестно",
        trackName: "Название песни неизвестно",
        artwork: nil,
        status: .pause
    )
}

protocol AudioPlayerStateStoreProtocol: AnyObject {
    func currentState() -> PlayerState
    @discardableResult
    func update(_ mutate: (inout PlayerState) -> Void) -> PlayerState
}

final class AudioPlayerStateStore: AudioPlayerStateStoreProtocol {
    private let queue = DispatchQueue(label: "audio.player.state.queue")
    private let queueKey = DispatchSpecificKey<Void>()
    private var state = PlayerState.initial

    init() {
        queue.setSpecific(key: queueKey, value: ())
    }

    func currentState() -> PlayerState {
        if DispatchQueue.getSpecific(key: queueKey) != nil {
            return state
        }
        return queue.sync { state }
    }

    @discardableResult
    func update(_ mutate: (inout PlayerState) -> Void) -> PlayerState {
        if DispatchQueue.getSpecific(key: queueKey) != nil {
            mutate(&state)
            return state
        }
        return queue.sync {
            mutate(&state)
            return state
        }
    }
}
