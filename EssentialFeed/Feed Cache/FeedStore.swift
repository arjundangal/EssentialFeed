//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Arjun Dangal on 16/09/2021.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void

    func deleteCachedFeed(_ items : [FeedItem], completion : @escaping DeletionCompletion)
    func insert(_ items : [FeedItem], timestamp : Date, completion : @escaping InsertionCompletion)
}
