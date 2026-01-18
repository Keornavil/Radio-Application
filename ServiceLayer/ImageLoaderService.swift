
import Kingfisher
import UIKit

protocol ImageLoaderServiceProtocol {
    func loadImage(from url: URL, completion: @escaping (Result<UIImage, Error>) -> Void)
}

final class ImageLoaderService: ImageLoaderServiceProtocol {
    
    func loadImage(from url: URL, completion: @escaping (Result<UIImage, any Error>) -> Void) {
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let value):
                completion(.success(value.image))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
