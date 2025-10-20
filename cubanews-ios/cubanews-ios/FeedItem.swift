//
//  FeedItem.swift
//  cubanews-ios
//

import Foundation

enum NewsSourceName: String, Codable {
    case ADNCUBA
    case CATORCEYMEDIO
    case DIARIODECUBA
    case CIBERCUBA
    case ELTOQUE
    case CUBANET
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self).uppercased()
        self = NewsSourceName(rawValue: rawValue) ?? .unknown
    }
}


struct InteractionData: Codable {
    let feedid: Int64
    let likes: Int?
    let comments: Int?
    let shares: Int?

    init(feedid: Int64, likes: Int? = nil, comments: Int? = nil, shares: Int? = nil) {
        self.feedid = feedid
        self.likes = likes
        self.comments = comments
        self.shares = shares
    }
}

enum ImageLoadingState: String, Codable {
    case LOADING
    case LOADED
    case ERROR
}

struct FeedItem: Identifiable, Codable, Equatable {
    let id: Int64
    let title: String
    let url: String
    let source: NewsSourceName
    let updated: Int64
    let isoDate: String
    let feedts: Int64?
    let content: String?
    let tags: [String]
    let score: Int
    let interactions: InteractionData
    let aiSummary: String?
    let image: String?
    var imageBytes: Data?
    var imageLoadingState: ImageLoadingState

    init(
        id: Int64,
        title: String,
        url: String,
        source: NewsSourceName,
        updated: Int64 = 0,
        isoDate: String = "",
        feedts: Int64? = nil,
        content: String? = nil,
        tags: [String] = [],
        score: Int = 0,
        interactions: InteractionData = InteractionData(feedid: 0),
        aiSummary: String? = nil,
        image: String? = nil,
        imageBytes: Data? = nil,
        imageLoadingState: ImageLoadingState = .LOADING
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.source = source
        self.updated = updated
        self.isoDate = isoDate
        self.feedts = feedts
        self.content = content
        self.tags = tags
        self.score = score
        self.interactions = interactions
        self.aiSummary = aiSummary
        self.image = image
        self.imageBytes = imageBytes
        self.imageLoadingState = imageLoadingState
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int64.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        url = try container.decode(String.self, forKey: .url)
        source = try container.decode(NewsSourceName.self, forKey: .source)
        isoDate = try container.decode(String.self, forKey: .isoDate)
        content = try? container.decode(String.self, forKey: .content)
        tags = (try? container.decode([String].self, forKey: .tags)) ?? []
        score = (try? container.decode(Int.self, forKey: .score)) ?? 0
        interactions = (try? container.decode(InteractionData.self, forKey: .interactions)) ?? InteractionData(feedid: 0)
        aiSummary = try? container.decode(String.self, forKey: .aiSummary)
        image = try? container.decode(String.self, forKey: .image)
        imageBytes = nil
        imageLoadingState = .LOADING
        
        // Handle updated as String even if it's numeric
        if let updatedInt = try? container.decode(Int64.self, forKey: .updated) {
            updated = updatedInt
        } else if let updatedString = try? container.decode(String.self, forKey: .updated),
                  let updatedInt64 = Int64(updatedString){
            updated = updatedInt64
        } else {
            updated = 0
        }

        // Handle feedts as Int64 even if it's a string
        if let feedtsInt = try? container.decode(Int64.self, forKey: .feedts) {
            feedts = feedtsInt
        } else if let feedtsString = try? container.decode(String.self, forKey: .feedts),
                  let feedtsInt64 = Int64(feedtsString) {
            feedts = feedtsInt64
        } else {
            feedts = nil
        }
    }
    
    static func == (lhs: FeedItem, rhs: FeedItem) -> Bool {
        lhs.id == rhs.id
    }
}
