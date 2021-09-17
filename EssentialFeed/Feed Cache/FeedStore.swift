//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Arjun Dangal on 16/09/2021.
//

import Foundation

public enum RetrieveCacchedFeedResult{
    case empty
    case found(feed: [LocalFeedImage], timeStamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrieveCacchedFeedResult) -> Void

    func deleteCachedFeed(completion : @escaping DeletionCompletion)
    func insert(_ feed : [LocalFeedImage], timestamp : Date, completion : @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}

public struct LocalFeedImage : Equatable  {
    
    public let id : UUID
    public let description : String?
    public let location : String?
    public let url : URL
    
    public init(id: UUID, description: String?, location: String?, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
}
 
