//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Arjun Dangal on 17/09/2021.
//

import Foundation
import EssentialFeed


internal class FeedStoreSpy: FeedStore {
    
    enum ReceivedMessages : Equatable {
        case retrieval
        case deleteCacheFeed
        case insert([LocalFeedImage], Date)
    }
    var deletionCompletions = [DeletionCompletion]()
    var insertionCompletions = [DeletionCompletion]()
    var retrievalCompletions = [RetrievalCompletion]()
    
    private(set) var receivedMessages = [ReceivedMessages]()
    
    func deleteCachedFeed(_ items : [FeedImage], completion : @escaping DeletionCompletion){
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
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalCompletions.append(completion)
        receivedMessages.append(.retrieval)
     }

    
    func completeRetrieval(with error: Error, at index: Int = 0){
        retrievalCompletions[index](error)
     }
    
    func completeRetrievalOnEmptyCache(atIndex index: Int = 0){
        retrievalCompletions[index](nil)
    }
   
}
