import Foundation
import SQLite3

// A lightweight SQLite-backed cache for FeedItem
final class FeedCacheStore {
    private var db: OpaquePointer?
    private let dbURL: URL

    init?(fileName: String = "feed_cache.sqlite") {
        do {
            let docs = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            self.dbURL = docs.appendingPathComponent(fileName)
        } catch {
            print("❌ FeedCacheStore: could not resolve documents directory:", error)
            return nil
        }
        guard open() else { return nil }
        guard createSchema() else { return nil }
    }

    deinit {
        if db != nil {
            sqlite3_close(db)
        }
    }

    private func open() -> Bool {
        if sqlite3_open(dbURL.path, &db) == SQLITE_OK {
            return true
        } else {
            print("❌ FeedCacheStore: failed to open database at \(dbURL.path)")
            return false
        }
    }

    private func createSchema() -> Bool {
        let sql = """
        CREATE TABLE IF NOT EXISTS feed_items (
            id INTEGER PRIMARY KEY,
            title TEXT,
            url TEXT,
            source TEXT,
            updated INTEGER,
            iso_date TEXT,
            feedts INTEGER,
            content TEXT,
            tags TEXT,
            score INTEGER,
            interactions_json TEXT,
            ai_summary TEXT,
            image TEXT,
            image_bytes BLOB,
            image_state TEXT,
            saved INTEGER NOT NULL DEFAULT 0
        );
        """
        return execute(sql: sql)
    }

    private func execute(sql: String) -> Bool {
        var errMsg: UnsafeMutablePointer<Int8>? = nil
        if sqlite3_exec(db, sql, nil, nil, &errMsg) != SQLITE_OK {
            if let err = errMsg { print("❌ FeedCacheStore SQL error:", String(cString: err)) }
            return false
        }
        return true
    }
    
    func loadSaved() -> [FeedItem] {
        let sql = "SELECT id, title, url, source, updated, iso_date, feedts, content, tags, score, interactions_json, ai_summary, image, image_bytes, image_state, saved FROM feed_items WHERE saved=1 ORDER BY feedts DESC;"
        return self.load(sql: sql);
    }

    // Load all cached items ordered by id ascending
    func loadAll() -> [FeedItem] {
        let sql = "SELECT id, title, url, source, updated, iso_date, feedts, content, tags, score, interactions_json, ai_summary, image, image_bytes, image_state, saved FROM feed_items ORDER BY feedts DESC;"
        return self.load(sql: sql);
    }
    
    private func load(sql: String) -> [FeedItem] {
        var stmt: OpaquePointer?
        var result: [FeedItem] = []
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            defer { sqlite3_finalize(stmt) }
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = sqlite3_column_int64(stmt, 0)
                let title = sqlite3_column_text(stmt, 1).flatMap { String(cString: $0) } ?? ""
                let url = sqlite3_column_text(stmt, 2).flatMap { String(cString: $0) } ?? ""
                let sourceRaw = sqlite3_column_text(stmt, 3).flatMap { String(cString: $0) } ?? "unknown"
                let updated = sqlite3_column_int64(stmt, 4)
                let isoDate = sqlite3_column_text(stmt, 5).flatMap { String(cString: $0) } ?? ""
                let feedts: Int64? = {
                    let v = sqlite3_column_int64(stmt, 6)
                    return v == 0 && sqlite3_column_type(stmt, 6) == SQLITE_NULL ? nil : v
                }()
                let content = sqlite3_column_text(stmt, 7).flatMap { String(cString: $0) }
                let tagsJSON = sqlite3_column_text(stmt, 8).flatMap { String(cString: $0) }
                let score = Int(sqlite3_column_int64(stmt, 9))
                let interactionsJSON = sqlite3_column_text(stmt, 10).flatMap { String(cString: $0) }
                let aiSummary = sqlite3_column_text(stmt, 11).flatMap { String(cString: $0) }
                let image = sqlite3_column_text(stmt, 12).flatMap { String(cString: $0) }
                var imageBytes: Data? = nil
                if let blob = sqlite3_column_blob(stmt, 13) {
                    let size = Int(sqlite3_column_bytes(stmt, 13))
                    imageBytes = Data(bytes: blob, count: size)
                }
                let imageStateRaw = sqlite3_column_text(stmt, 14).flatMap { String(cString: $0) } ?? "LOADING"
                let savedInt = sqlite3_column_int(stmt, 15)
                let saved = savedInt != 0

                // Decode tags from JSON array if present
                let tags: [String] = {
                    guard let tagsJSON = tagsJSON, let data = tagsJSON.data(using: .utf8) else { return [] }
                    return (try? JSONDecoder().decode([String].self, from: data)) ?? []
                }()

                // Decode interactions from JSON if present
                let interactions: InteractionData = {
                    guard let interactionsJSON = interactionsJSON, let data = interactionsJSON.data(using: .utf8) else { return InteractionData(feedid: id) }
                    return (try? JSONDecoder().decode(InteractionData.self, from: data)) ?? InteractionData(feedid: id)
                }()

                let item = FeedItem(
                    id: id,
                    title: title,
                    url: url,
                    source: NewsSourceName(rawValue: sourceRaw.uppercased()) ?? .unknown,
                    updated: updated,
                    isoDate: isoDate,
                    feedts: feedts,
                    content: content,
                    tags: tags,
                    score: score,
                    interactions: interactions,
                    aiSummary: aiSummary,
                    image: image,
                    imageBytes: imageBytes,
                    imageLoadingState: ImageLoadingState(rawValue: imageStateRaw) ?? .LOADING,
                    saved: saved
                )
                result.append(item)
                _ = saved
            }
        } else {
            print("❌ FeedCacheStore: failed to prepare loadAll")
        }
        return result
    }

    // Upsert many items without image bytes
    func upsertMany(_ items: [FeedItem]) {
        let sql = """
        INSERT INTO feed_items (id, title, url, source, updated, iso_date, feedts, content, tags, score, interactions_json, ai_summary, image, image_bytes, image_state, saved)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
            title=excluded.title,
            url=excluded.url,
            source=excluded.source,
            updated=excluded.updated,
            iso_date=excluded.iso_date,
            feedts=excluded.feedts,
            content=excluded.content,
            tags=excluded.tags,
            score=excluded.score,
            interactions_json=excluded.interactions_json,
            ai_summary=excluded.ai_summary,
            image=excluded.image,
            image_bytes=COALESCE(excluded.image_bytes, feed_items.image_bytes),
            image_state=excluded.image_state,
            saved=COALESCE(feed_items.saved, excluded.saved);
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK {
            print("❌ FeedCacheStore: failed to prepare upsertMany")
            return
        }
        defer { sqlite3_finalize(stmt) }

        sqlite3_exec(db, "BEGIN TRANSACTION", nil, nil, nil)
        for item in items {
            bind(item: item, to: stmt)
            if sqlite3_step(stmt) != SQLITE_DONE {
                print("❌ FeedCacheStore: upsert failed for id \(item.id)")
            }
            sqlite3_reset(stmt)
            sqlite3_clear_bindings(stmt)
        }
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
    }

    private func bind(item: FeedItem, to stmt: OpaquePointer?) {
        // id
        sqlite3_bind_int64(stmt, 1, item.id)
        // title
        sqlite3_bind_text(stmt, 2, item.title, -1, SQLITE_TRANSIENT)
        // url
        sqlite3_bind_text(stmt, 3, item.url, -1, SQLITE_TRANSIENT)
        // source (store raw string)
        sqlite3_bind_text(stmt, 4, item.source.rawValue, -1, SQLITE_TRANSIENT)
        // updated
        sqlite3_bind_int64(stmt, 5, item.updated)
        // iso_date
        sqlite3_bind_text(stmt, 6, item.isoDate, -1, SQLITE_TRANSIENT)
        // feedts
        if let v = item.feedts { sqlite3_bind_int64(stmt, 7, v) } else { sqlite3_bind_null(stmt, 7) }
        // content
        if let v = item.content { sqlite3_bind_text(stmt, 8, v, -1, SQLITE_TRANSIENT) } else { sqlite3_bind_null(stmt, 8) }
        // tags as JSON
        if let data = try? JSONEncoder().encode(item.tags), let json = String(data: data, encoding: .utf8) {
            sqlite3_bind_text(stmt, 9, json, -1, SQLITE_TRANSIENT)
        } else {
            sqlite3_bind_text(stmt, 9, "[]", -1, SQLITE_TRANSIENT)
        }
        // score
        sqlite3_bind_int64(stmt, 10, Int64(item.score))
        // interactions as JSON
        if let data = try? JSONEncoder().encode(item.interactions), let json = String(data: data, encoding: .utf8) {
            sqlite3_bind_text(stmt, 11, json, -1, SQLITE_TRANSIENT)
        } else {
            let fallback = try? JSONEncoder().encode(InteractionData(feedid: item.id))
            let json = fallback.flatMap { String(data: $0, encoding: .utf8) } ?? "{\"feedid\":0}"
            sqlite3_bind_text(stmt, 11, json, -1, SQLITE_TRANSIENT)
        }
        // ai_summary
        if let v = item.aiSummary { sqlite3_bind_text(stmt, 12, v, -1, SQLITE_TRANSIENT) } else { sqlite3_bind_null(stmt, 12) }
        // image URL
        if let v = item.image { sqlite3_bind_text(stmt, 13, v, -1, SQLITE_TRANSIENT) } else { sqlite3_bind_null(stmt, 13) }
        // image bytes
        if let data = item.imageBytes {
            data.withUnsafeBytes { buf in
                _ = sqlite3_bind_blob(stmt, 14, buf.baseAddress, Int32(buf.count), SQLITE_TRANSIENT)
            }
        } else {
            sqlite3_bind_null(stmt, 14)
        }
        // image state as raw string
        sqlite3_bind_text(stmt, 15, item.imageLoadingState.rawValue, -1, SQLITE_TRANSIENT)
        // saved as 0/1
        let savedValue: Int32 = item.saved ? 1 : 0
        sqlite3_bind_int(stmt, 16, savedValue)
    }

    func upsertImage(for id: Int64, data: Data?, state: ImageLoadingState) {
        let sql = "UPDATE feed_items SET image_bytes = ?, image_state = ? WHERE id = ?;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK {
            print("❌ FeedCacheStore: failed to prepare upsertImage")
            return
        }
        defer { sqlite3_finalize(stmt) }
        if let data = data {
            data.withUnsafeBytes { buf in
                _ = sqlite3_bind_blob(stmt, 1, buf.baseAddress, Int32(buf.count), SQLITE_TRANSIENT)
            }
        } else {
            sqlite3_bind_null(stmt, 1)
        }
        sqlite3_bind_text(stmt, 2, state.rawValue, -1, SQLITE_TRANSIENT)
        sqlite3_bind_int64(stmt, 3, id)
        if sqlite3_step(stmt) != SQLITE_DONE {
            print("❌ FeedCacheStore: upsertImage failed for id \(id)")
        }
    }

    func updateSaved(for id: Int64, saved: Bool) {
        let sql = "UPDATE feed_items SET saved = ? WHERE id = ?;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK {
            print("❌ FeedCacheStore: failed to prepare updateSaved")
            return
        }
        defer { sqlite3_finalize(stmt) }
        sqlite3_bind_int(stmt, 1, saved ? 1 : 0)
        sqlite3_bind_int64(stmt, 2, id)
        if sqlite3_step(stmt) != SQLITE_DONE {
            print("❌ FeedCacheStore: updateSaved failed for id \(id)")
        }
    }

    func clearAll() {
        _ = execute(sql: "DELETE FROM feed_items;")
    }
}

// Provide SQLITE_TRANSIENT for blob/text binding lifecycle
private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

