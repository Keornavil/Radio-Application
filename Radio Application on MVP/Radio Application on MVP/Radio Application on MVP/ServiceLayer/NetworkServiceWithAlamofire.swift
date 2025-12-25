





import Foundation
import Alamofire

protocol NetworkServiceProtocol {
    func getStationsFromNetwork<T: Decodable>(urlString: String, completion: @escaping (Result<T, Error>) -> ())
}

class NetworkServiceWithAlamofire: NetworkServiceProtocol {
    

    func getStationsFromNetwork<T: Decodable>(urlString: String, completion: @escaping (Result<T, Error>) -> Void) {
        AF.request(urlString)
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let userResults):
                    completion(.success(userResults))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
