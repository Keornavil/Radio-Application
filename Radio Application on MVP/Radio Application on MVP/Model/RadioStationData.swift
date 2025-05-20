





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

class RadioStationData: RadioStationDataProtocol {
    
    private var presenterForData: DataPresenterProtocol?
    let networkService: NetworkServiceProtocol
    required init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    
    var radioStations: [SearchResponse.RadioStation] = []
    var radioStationsImages: [UIImage] = []
    
    func setPresenterForData(presenter: DataPresenterProtocol) {
        presenterForData = presenter
    }
    
    public func loadDataFromNetwork() {
        fetchRadioStationsData {
            self.radioStationsImages = Array(repeating: UIImage(), count: self.radioStations.count)
            self.loadImages {
                self.presenterForData?.succesLoadData!()
                
            }
        }
    }
    
    
    
    private func fetchRadioStationsData(completion: @escaping () -> ()) {
        networkService.getComments { (result: Result<SearchResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let searchResponse):
                    self.radioStations.append(contentsOf: searchResponse.results)
                    completion()
                    
                case .failure(let error):
                    print("Error fetching radio stations: \(error)")
                    
                }
            }
        }
    }
    
    private func loadImages(completion: @escaping () -> ()) {
        let dispatchGroup = DispatchGroup()
        let defaultImageURLString = "https://w7.pngwing.com/pngs/912/537/png-transparent-mute-mute-music-no-sound-sound-volume-audio-controls-ui-icons-free-icon.png"
        
        for (index, imageData) in self.radioStations.enumerated() {
            guard let imageURL = URL(string: imageData.image ?? defaultImageURLString) else { continue }
            dispatchGroup.enter()
            
            KingfisherManager.shared.retrieveImage(with: imageURL) { result in
                switch result {
                case .success(let value):
                    self.radioStationsImages[index] = value.image
                case .failure(let error):
                    print("Error loading image: \(error)")
                    print("Error in \(imageURL)")
                    
                    guard let defaultImageURL = URL(string: defaultImageURLString) else {
                        dispatchGroup.leave()
                        return
                    }
                    KingfisherManager.shared.retrieveImage(with: defaultImageURL) { result in
                        switch result {
                        case .success(let value):
                            self.radioStationsImages[index] = value.image
                        case .failure(let error):
                            print("Error loading default image: \(error)")
                        }
                        dispatchGroup.leave()
                    }
                    return
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
}

