

import UIKit

struct TransferData {
    var radioName: String
    var artistName: String
    var trackName: String
    var image: UIImage

    static let initial = TransferData(
        radioName: "",
        artistName: "Имя артиста неизвестно",
        trackName: "Название песни неизвестно",
        image: UIImage(named: "placeholder") ?? UIImage()
    )
}
