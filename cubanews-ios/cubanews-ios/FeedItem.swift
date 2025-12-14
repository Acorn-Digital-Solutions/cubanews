//
//  FeedItem.swift
//  cubanews-ios
//

import Foundation

enum NewsSourceName: String, Codable, CaseIterable {
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

    // Human-friendly display name in UpperCamelCase for UI pills
    var displayName: String {
        switch self {
        case .ADNCUBA: return "AdnCuba"
        case .CATORCEYMEDIO: return "CatorceYMedio"
        case .DIARIODECUBA: return "DiarioDeCuba"
        case .CIBERCUBA: return "CiberCuba"
        case .ELTOQUE: return "ElToque"
        case .CUBANET: return "Cubanet"
        case .unknown: return "Unknown"
        }
    }

    // Asset name for the source icon (matches assets in Assets.xcassets)
    var imageName: String {
        switch self {
        case .ADNCUBA: return "adncuba"
        case .CATORCEYMEDIO: return "catorceymedio"
        case .DIARIODECUBA: return "ddc"
        case .CIBERCUBA: return "cibercuba"
        case .ELTOQUE: return "eltoque"
        case .CUBANET: return "cubanet"
        case .unknown: return "cubanewsIdentity"
        }
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
    var saved: Bool = false

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
        imageLoadingState: ImageLoadingState = .LOADING,
        saved: Bool = false
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
        self.saved = saved
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
        aiSummary = try? container.decodeIfPresent(String.self, forKey: .aiSummary)
        image = try? container.decodeIfPresent(String.self, forKey: .image)
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

extension Array where Element == FeedItem {
    func removingDuplicates() -> [FeedItem] {
        var seen = Set<Int64>()
        return self.filter { item in
            if seen.contains(item.id) {
                return false
            } else {
                seen.insert(item.id)
                return true
            }
        }
    }
}
