





import Foundation
import UIKit
import Kingfisher

protocol RadioStationDataProtocol: AnyObject {
    func loadDataFromNetwork()
    func setPresenterForData(presenter: DataPresenterProtocol)
    var radioStations: [SearchResponse.RadioStation] { get }
    var radioStationsImages: [UIImage] { get }
    init(networkService: NetworkServiceProtocol)
}

// MARK: - RadioStationData
final class RadioStationData: RadioStationDataProtocol {
    
    // MARK: - Dependencies
    private let networkService: NetworkServiceProtocol
    
    // MARK: - Presenter binding
    private weak var presenterForData: DataPresenterProtocol?
    
    // MARK: - Data storage
    var radioStations: [SearchResponse.RadioStation] = []
    var radioStationsImages: [UIImage] = []
    let urlString = "https://raw.githubusercontent.com/Keornavil/Radio-Json-Link/main/RadioLink.json"
    
    // MARK: - Init
    required init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    // MARK: - Presenter binding
    func setPresenterForData(presenter: DataPresenterProtocol) {
        presenterForData = presenter
    }
    
    // MARK: - Public API
    func loadDataFromNetwork() {
        fetchRadioStationsData { [weak self] in
            guard let self else { return }
            self.radioStationsImages = Array(
                repeating: UIImage(),
                count: self.radioStations.count
            )
            self.loadImages { [weak self] in
                guard let self else { return }
                self.presenterForData?.succesLoadData?()
            }
        }
    }
}

// MARK: - Network
private extension RadioStationData {
    
    func fetchRadioStationsData(completion: @escaping () -> Void) {
        networkService.getStationsFromNetwork(urlString: urlString) { [weak self] (result: Result<SearchResponse, Error>) in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let searchResponse):
                    // Перезаписываем, чтобы не копились дубли
                    self.radioStations = searchResponse.results
                    completion()
                    
                case .failure(let error):
                    print("Error fetching radio stations: \(error)")
                }
            }
        }
    }
}

// MARK: - Images loading
private extension RadioStationData {
    
    private func loadImages(completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        let defaultImageURLString =
        "https://w7.pngwing.com/pngs/912/537/png-transparent-mute-mute-music-no-sound-sound-volume-audio-controls-ui-icons-free-icon.png"
        let defaultURL = URL(string: defaultImageURLString)
        for (index, station) in radioStations.enumerated() {
            dispatchGroup.enter()
            let imageURL = URL(string: station.image ?? "") ?? defaultURL
            guard let url = imageURL else {
                dispatchGroup.leave()
                continue
            }
            KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
                guard let self else {
                    dispatchGroup.leave()
                    return
                }
                switch result {
                case .success(let value):
                    self.radioStationsImages[index] = value.image
                    dispatchGroup.leave()
                case .failure(let error):
                    print("Error loading image: \(error)")
                    print("Error in \(url)")
                    guard let defaultURL else {
                        dispatchGroup.leave()
                        return
                    }
                    KingfisherManager.shared.retrieveImage(with: defaultURL) { [weak self] fallbackResult in
                        if case .success(let value) = fallbackResult {
                            self?.radioStationsImages[index] = value.image
                        } else if case .failure(let fallbackError) = fallbackResult {
                            print("Error loading default image: \(fallbackError)")
                        }
                        dispatchGroup.leave()
                    }
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
}
