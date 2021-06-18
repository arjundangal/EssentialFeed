//
//  CachedFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Arjun Dangal on 18/06/2021.
//

import XCTest

class FeedStore {
    var deleteCachedFeedCallCount = 0
}

class LocalFeedLoader {
    
    init(store : FeedStore) {
        
        
    }
}

class CachedFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation(){
        let store = FeedStore()
        _ = LocalFeedLoader(store : store)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }

}



