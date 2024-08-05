import UIKit




public class MovieModel: Codable, Equatable {
    let budget: Int? = nil
    let genres: [GenreModel]? = nil
    let homepage: String? = nil
    var id: Int? = nil
    let keywords: [KeywordModel]? = nil
    let originalLanguage: String? = nil
    let originalTitle: String? = nil
    let overview: String? = nil
    let popularity: Double? = nil
    let productionCompanies: [ProductionCompanyModel]? = nil
    let productionCountries: [ProductionCountryModel]? = nil
    let releaseDate: String? = nil
    let revenue: Int? = nil
    let runtime: Int? = nil
    let spokenLanguages: [SpokenLanguageModel]? = nil
    let status: String? = nil
    let tagline: String? = nil
    var title: String? = nil
    let voteAverage: Double? = nil
    let voteCount: Int? = nil
    var image: UIImage? = nil

    enum CodingKeys: String, CodingKey {
        case budget, genres, homepage, id, keywords
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview, popularity
        case productionCompanies = "production_companies"
        case productionCountries = "production_countries"
        case releaseDate = "release_date"
        case revenue, runtime
        case spokenLanguages = "spoken_languages"
        case status, tagline, title
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
    
    init(id: Int?, title: String?) {
        self.id = id
        self.title = title
    }
    
    public static func == (lhs: MovieModel, rhs: MovieModel) -> Bool {
        return lhs.id == rhs.id
    }
}

struct GenreModel: Codable {
    let id: Int?
    let name: String?
}

struct KeywordModel: Codable {
    let id: Int?
    let name: String?
}

struct ProductionCompanyModel: Codable {
    let name: String?
    let id: Int?
}

struct ProductionCountryModel: Codable {
    let iso31661: String?
    let name: String?

    enum CodingKeys: String, CodingKey {
        case iso31661 = "iso_3166_1"
        case name
    }
}

struct SpokenLanguageModel: Codable {
    let iso6391: String?
    let name: String?

    enum CodingKeys: String, CodingKey {
        case iso6391 = "iso_639_1"
        case name
    }
}
