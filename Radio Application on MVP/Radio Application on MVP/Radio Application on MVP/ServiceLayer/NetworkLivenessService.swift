
import Foundation

protocol LivenessServiceProtocol: AnyObject {
    func isOnline() async -> Bool
}

final class NetworkLivenessService: LivenessServiceProtocol {

    private let testURL: URL
    private let timeout: TimeInterval

    init(
        testURL: URL = URL(string: "https://raw.githubusercontent.com/Keornavil/Radio-Json-Link/main/RadioLink.json")!,
        timeout: TimeInterval = 1.5
    ) {
        self.testURL = testURL
        self.timeout = timeout
    }
    func isOnline() async -> Bool {
        var request = URLRequest(url: testURL)
        request.httpMethod = "HEAD"          // вместо GET
        request.timeoutInterval = timeout

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else { return false }
            return (200...299).contains(http.statusCode)
        } catch {
            return false
        }
    }
}
