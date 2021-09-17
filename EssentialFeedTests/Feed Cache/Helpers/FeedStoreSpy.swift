//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Arjun Dangal on 17/09/2021.
//

import Foundation
import EssentialFeed


internal class FeedStoreSpy: FeedStore {
    func retrieve() {
        receivedMessages.append(.retrieval)
    }
    
    enum ReceivedMessages : Equatable {
        case retrieval
        case deleteCacheFeed
        case insert([LocalFeedImage], Date)
    }
    var deletionCompletions = [DeletionCompletion]()
    var insertionCompletions = [DeletionCompletion]()
    
    private(set) var receivedMessages = [ReceivedMessages]()
    
    func deleteCachedFeed(_ items : [FeedItem], completion : @escaping DeletionCompletion){
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCacheFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0){
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0){
        deletionCompletions[index](nil)
    }
    
    func insert(_ items : [LocalFeedImage], timestamp : Date, completion : @escaping InsertionCompletion){
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(items, timestamp))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0){
        insertionCompletions[index](error)
    }
    func completInsertionSuccessfully(at index: Int = 0){
        insertionCompletions[index](nil)
    }
    
   
}
