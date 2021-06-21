//
//  CachedFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Arjun Dangal on 18/06/2021.
//

import XCTest
import EssentialFeed

class FeedStore {
    
    typealias DeletionCompletion = (Error?) -> Void
    
    var deletionCompletions = [DeletionCompletion]()
 
    enum ReceivedMessages : Equatable {
        case deleteCacheFeed
        case insert([FeedItem], Date)
    }
    private(set) var receivedMessages = [ReceivedMessages]()
    
    func deleteCachedFeed(_ items : [FeedItem], completion : @escaping DeletionCompletion ){
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCacheFeed)
      }
    
    func completeDeletionError(with error: Error, at index: Int = 0){
        deletionCompletions[index](error)
    }
    func completeDeletionSuccessfully(at index: Int = 0){
        deletionCompletions[index](nil)
     }
    
    func insert(_ items : [FeedItem], timestamp : Date){
        receivedMessages.append(.insert(items, timestamp))
    }
}

class LocalFeedLoader {
    let store : FeedStore
    let currentDate : () -> Date
    init(store : FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items : [FeedItem]){
        store.deleteCachedFeed(items){[unowned self] error in
            if error == nil{
                self.store.insert(items, timestamp: self.currentDate())
            }
        }
    }
    
}

class CachedFeedUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation(){
        let (_,store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion(){
        let items = [uniqueItem(), uniqueItem()]
        let (sut,store) = makeSUT()
    
        sut.save(items)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError(){
        let items = [uniqueItem(), uniqueItem()]
        let (sut,store) = makeSUT()
        let deletionError = anyNSError()
     
        sut.save(items)
        store.completeDeletionError(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
 
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion(){
        let timeStamp = Date()
        let items = [uniqueItem(), uniqueItem()]
        let (sut,store) = makeSUT(currentDate : { timeStamp })
 
        sut.save(items)
        store.completeDeletionSuccessfully()
       
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed,.insert(items, timeStamp)])
      }
    
    //MARK:- Helpers
    
    private func makeSUT(currentDate : @escaping () -> Date = Date.init,  file : StaticString = #filePath, line : UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore){
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate : currentDate)
        checkForMemoryLeaks(store, file: file, line: line)
        checkForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    
    private func uniqueItem() -> FeedItem{
        return FeedItem(id: UUID(), description: nil, location: nil, imageURL: anyURL())
    }
    
    private func anyURL() -> URL{
        return URL(string: "http://aurl.com")!
    }
    
    private func anyNSError() -> NSError{
        return NSError(domain : "anyError", code: 1)
     }
    
}



