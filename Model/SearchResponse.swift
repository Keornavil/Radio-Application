
struct SearchResponse: Decodable {
    var results: [RadioStation]
    
    struct RadioStation: Decodable {
        var link: String
        var title: String
        var image: String?
    }
}
