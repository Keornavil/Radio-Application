import Foundation

protocol LivenessServiceProtocol: AnyObject {
    func isOnline() async -> Bool
}

final class NetworkLivenessService: LivenessServiceProtocol {

    private let testURL: URL
    private let timeout: TimeInterval

    init(
        testURL: URL = URL(string: "https://raw.githubusercontent.com/Keornavil/Radio-Json-Link/main/RadioLink.json")!,
        timeout: TimeInterval = 5.0
    ) {
        self.testURL = testURL
        self.timeout = timeout
    }
    func isOnline() async -> Bool {
        if await check(method: "HEAD") { return true }
        return await check(method: "GET")
    }

    private func check(method: String) async -> Bool {
        var request = URLRequest(url: testURL)
        request.httpMethod = method
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
