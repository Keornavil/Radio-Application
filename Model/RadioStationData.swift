
import Foundation
import UIKit

protocol RadioStationDataProtocol: AnyObject {
    func loadDataFromNetwork()
    func setPresenterForData(presenter: DataPresenterProtocol)
    var radioStations: [SearchResponse.RadioStation] { get }
    var radioStationsImages: [UIImage] { get }
    init(networkService: NetworkServiceProtocol,
         imageLoader: ImageLoaderServiceProtocol)
}

// MARK: - RadioStationData
final class RadioStationData: RadioStationDataProtocol {
    
    // MARK: - Dependencies
    private let networkService: NetworkServiceProtocol
    private let imageLoader: ImageLoaderServiceProtocol
    
    // MARK: - Presenter binding
    private weak var presenterForData: DataPresenterProtocol?
    
    // MARK: - Data storage
    var radioStations: [SearchResponse.RadioStation] = []
    var radioStationsImages: [UIImage] = []
    let urlString = "https://raw.githubusercontent.com/Keornavil/Radio-Json-Link/main/RadioLink.json"
    
    // MARK: - Init
    init(networkService: NetworkServiceProtocol,
         imageLoader: ImageLoaderServiceProtocol) {
        self.networkService = networkService
        self.imageLoader = imageLoader
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
            let url = URL(string: station.image ?? "") ?? defaultURL
            guard let url, let defaultURL else { dispatchGroup.leave(); continue }
            loadImageWithFallback(url: url, fallbackURL: defaultURL) { [weak self] image in
                if let image { self?.radioStationsImages[index] = image }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) { completion() }
    }
    private func loadImageWithFallback(url: URL, fallbackURL: URL, completion: @escaping (UIImage?) -> Void
    ) {
        imageLoader.loadImage(from: url) { [imageLoader] result in
            switch result {
            case .success(let image):
                completion(image)
            case .failure:
                imageLoader.loadImage(from: fallbackURL) { fallbackResult in
                    switch fallbackResult {
                    case .success(let image):
                        completion(image)
                    case .failure:
                        completion(nil)
                    }
                }
            }
        }
    }
}
