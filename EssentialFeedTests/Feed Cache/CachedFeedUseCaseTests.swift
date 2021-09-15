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
    typealias InsertionCompletion = (Error?) -> Void

    var deletionCompletions = [DeletionCompletion]()
    var insertionCompletions = [DeletionCompletion]()

    enum ReceivedMessages : Equatable {
        case deleteCacheFeed
        case insert([FeedItem], Date)
    }
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
    
    func insert(_ items : [FeedItem], timestamp : Date, completion : @escaping InsertionCompletion){
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

class LocalFeedLoader {
    let store : FeedStore
    let currentDate : () -> Date
    init(store : FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items : [FeedItem], completion: @escaping (Error?) -> Void){
        store.deleteCachedFeed(items){[unowned self] error in
             if error == nil{
                self.store.insert(items, timestamp: self.currentDate(),completion: completion)
            }else{
                completion(error)

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
    
        sut.save(items){_ in}
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError(){
        let items = [uniqueItem(), uniqueItem()]
        let (sut,store) = makeSUT()
        let deletionError = anyNSError()
     
        sut.save(items){_ in}
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
 
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion(){
        let timeStamp = Date()
        let items = [uniqueItem(), uniqueItem()]
        let (sut,store) = makeSUT(currentDate : { timeStamp })
 
        sut.save(items){_ in}
        store.completeDeletionSuccessfully()
       
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed,.insert(items, timeStamp)])
      }
    

 
    
    func test_save_failsOnInsertionError(){
        let items = [uniqueItem(), uniqueItem()]
        let (sut,store) = makeSUT()
        let insertionError = anyNSError()
        
        var receivedError : Error?
        let exp = expectation(description: "Wait for save completion")
        sut.save(items){error in
            receivedError = error
            exp.fulfill()
        }
        store.completeDeletionSuccessfully()
        store.completeDeletion(with: insertionError)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, insertionError)
    }
 
    func test_save_failsOnDeletionError(){
        let items = [uniqueItem(), uniqueItem()]
        let (sut,store) = makeSUT()
        let deletionError = anyNSError()
        
        var receivedError : Error?
        let exp = expectation(description: "Wait for save completion")
        sut.save(items){error in
            receivedError = error
            exp.fulfill()
        }
        store.completeDeletion(with: deletionError)
      
         wait(for: [exp], timeout: 1.0)
        XCTAssertNotNil(receivedError,"Expected error but found nil insted")
    }
    
    
    
    func test_save_succedsOnSuccessfulCacheInsertions(){
        let items = [uniqueItem(), uniqueItem()]
        let (sut,store) = makeSUT()
 
        var receivedError : Error?
        let exp = expectation(description: "Wait for save completion")
        sut.save(items){ error in
            receivedError = error
            exp.fulfill()
        }

        store.completeDeletionSuccessfully()
        store.completInsertionSuccessfully()
        
        wait(for: [exp], timeout: 1.0)

       
        XCTAssertNil(receivedError)
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



