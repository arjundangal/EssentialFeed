//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Arjun Dangal on 17/09/2021.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation(){
        let (_,store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval(){
        let (sut,store) = makeSUT()
        
        sut.load{_ in}
        
        XCTAssertEqual(store.receivedMessages, [.retrieval])
    }
    func test_load_failsOnRetrievalError(){
        let (sut,store) = makeSUT()
        var retreivalError = anyNSError()
        let exp = expectation(description: "Waiting for load completion")
        var receivedError: Error?
        sut.load { error in
            receivedError =  error
            exp.fulfill()
        }
        store.completeRetrieval(with: retreivalError)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(retreivalError, receivedError as NSError?)
    }
    
    //MARK:- Helpers
    private func makeSUT(currentDate : @escaping () -> Date = Date.init,  file : StaticString = #filePath, line : UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate : currentDate)
        checkForMemoryLeaks(store, file: file, line: line)
        checkForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    private func anyNSError() -> NSError{
        return NSError(domain : "anyError", code: 1)
    }
    
    

}
