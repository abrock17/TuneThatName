import Foundation

public struct Playlist: Equatable, Printable {
    
    public let name: String!
    public var uri: NSURL?
    public var songs = [Song]()
    public var description: String {
        return "Song:[name:\(name), uri:\(uri), number of songs:\(songs.count)]"
    }
    
    public init(name: String!) {
        self.name = name
    }

    public init(name: String!, uri: NSURL!) {
        self.name = name
        self.uri = uri
    }

    public init(name: String!, uri: NSURL!, songs: [Song]!) {
        self.name = name
        self.uri = uri
        self.songs = songs
    }
}

public func ==(x: Playlist, y: Playlist) -> Bool {
    return x.name == y.name && x.uri == y.uri && x.songs == y.songs
}
