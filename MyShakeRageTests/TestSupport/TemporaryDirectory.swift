import Foundation

struct TemporaryDirectory {
    let url: URL

    init(fileManager: FileManager = .default) throws {
        let parent = fileManager.temporaryDirectory
        let url = parent.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        self.url = url
    }

    func remove(fileManager: FileManager = .default) throws {
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }
}
