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
    
    var deleteCachedFeedCallCount = 0
    var cacheDeletionCount = 0
    var insertCallCount = 0
    var deletionCompletions = [DeletionCompletion]()
    
    func deleteCachedFeed(_ items : [FeedItem], completion : @escaping DeletionCompletion ){
        cacheDeletionCount = cacheDeletionCount + 1
        deletionCompletions.append(completion)
      }
    
    func completeDeletionError(with error: Error, at index: Int = 0){
        
    }
    func completeDeletionSuccessfully(at index: Int = 0){
        insertCallCount  += 1
    }
}

class LocalFeedLoader {
    let store : FeedStore
    init(store : FeedStore) {
        self.store = store
    }
    
    func save(_ items : [FeedItem]){
        store.deleteCachedFeed(items){[weak self] error in
            if error == nil{
                self?.store.completeDeletionSuccessfully()
            }
        }
    }
    
}

class CachedFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation(){
        let (_,store) = makeSUT()
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion(){
        let items = [uniqueItem(), uniqueItem()]
        let (sut,store) = makeSUT()
    
        sut.save(items)
        
        XCTAssertEqual(store.cacheDeletionCount, 1)
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError(){
        let items = [uniqueItem(), uniqueItem()]
        let (sut,store) = makeSUT()
        let deletionError = anyNSError()
     
        sut.save(items)
        store.completeDeletionError(with: deletionError)
        
        XCTAssertEqual(store.insertCallCount, 0)
    }
    func test_save_RequestCacheInsertionOnSuccessfulDeletion(){
        let items = [uniqueItem(), uniqueItem()]
        let (sut,store) = makeSUT()
 
        sut.save(items)
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.insertCallCount, 1)
    }
    
    
    //MARK:- Helpers
    
    private func makeSUT(file : StaticString = #filePath, line : UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore){
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
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



