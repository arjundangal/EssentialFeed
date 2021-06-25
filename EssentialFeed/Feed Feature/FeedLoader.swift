//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Arjun Dangal on 25/05/2021.
//

import Foundation

public enum LoadFeedResult{
    case success([FeedItem])
    case failure(Error)
}
 
public protocol FeedLoader {
     func load(completion : @escaping (LoadFeedResult) -> Void)
}
