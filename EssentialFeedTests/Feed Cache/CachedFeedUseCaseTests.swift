//
//  CachedFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Arjun Dangal on 18/06/2021.
//

import XCTest
import EssentialFeed

class FeedStore {
    var deleteCachedFeedCallCount = 0
    var cacheDeletionCount = 0
    
    func deleteCachedFeed(_ items : [FeedItem]){
        cacheDeletionCount = cacheDeletionCount + 1

     }
    
}

class LocalFeedLoader {
    let store : FeedStore
    init(store : FeedStore) {
        self.store = store
    }
    
    func save(_ items : [FeedItem]){
        store.deleteCachedFeed(items)
    }
    
}

class CachedFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation(){
        let (_,store) = makeSUT()
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion(){
        let (sut,store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.cacheDeletionCount, 1)
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
}



