





import Foundation
import Alamofire

protocol NetworkServiceProtocol {
    func getComments<T: Decodable>(completion: @escaping (Result<T, Error>) -> ())

}

class NetworkServiceWithAlamofire: NetworkServiceProtocol {
    
    let urlString = "https://raw.githubusercontent.com/Keornavil/Radio-Json-Link/main/RadioLink.json"
    

    func getComments<T: Decodable>(completion: @escaping (Result<T, Error>) -> Void) {
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
