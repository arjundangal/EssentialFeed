//
//  CachedFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Arjun Dangal on 18/06/2021.
//

import XCTest
import EssentialFeed



class CachedFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation(){
        let (_,store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion(){
        let items = [uniqueImage(), uniqueImage()]
        let (sut,store) = makeSUT()
        
        sut.save(items){_ in}
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError(){
        let items = [uniqueImage(), uniqueImage()]
        let (sut,store) = makeSUT()
        let deletionError = anyNSError()
        
        sut.save(items){_ in}
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion(){
        let timeStamp = Date()
        let items = uniqueImageFeed()
        let (sut,store) = makeSUT(currentDate : { timeStamp })
        
        
        sut.save(items.models){_ in}
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed,.insert(items.local, timeStamp)])
    }
    
    func test_save_failsOnInsertionError(){
        let (sut,store) = makeSUT()
        let insertionError = anyNSError()
        
        var receivedError : Error?
        let exp = expectation(description: "Wait for save completion")
        sut.save(uniqueImageFeed().models){error in
            receivedError = error
            exp.fulfill()
        }
        store.completeDeletionSuccessfully()
        store.completeDeletion(with: insertionError)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, insertionError)
    }
    
    func test_save_failsOnDeletionError(){
        let (sut,store) = makeSUT()
        let deletionError = anyNSError()
        
        var receivedError : Error?
        let exp = expectation(description: "Wait for save completion")
        sut.save(uniqueImageFeed().models){error in
            receivedError = error
            exp.fulfill()
        }
        store.completeDeletion(with: deletionError)
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertNotNil(receivedError,"Expected error but found nil insted")
    }
    
    
    
    func test_save_succedsOnSuccessfulCacheInsertions(){
        let (sut,store) = makeSUT()
        
        var receivedError : Error?
        let exp = expectation(description: "Wait for save completion")
        sut.save(uniqueImageFeed().models){ error in
            receivedError = error
            exp.fulfill()
        }
        
        store.completeDeletionSuccessfully()
        store.completInsertionSuccessfully()
        
        wait(for: [exp], timeout: 1.0)
        
        
        XCTAssertNil(receivedError)
    }
    
    
    func test_save_doesNotDeliverDelitionErrorAfterSUTInstanceHasBeenDeallocated(){
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate : Date.init)
        
        var receivedResults : [LocalFeedLoader.SaveResult] = []
        sut?.save([uniqueImage()]){ error in
            receivedResults.append(error)
        }
        
        sut = nil
        store.completeDeletion(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_save_doesNotDelicerInsertionErrorAfterSUTInstanceHasBeenDeallocated(){
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate : Date.init)
        
        var receivedResults : [LocalFeedLoader.SaveResult] = []
        sut?.save([uniqueImage()]){ error in
            receivedResults.append(error)
        }
        store.completeDeletionSuccessfully()
        sut = nil
        
        store.completeInsertion(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    
    
    
    //MARK:- Helpers
    private func makeSUT(currentDate : @escaping () -> Date = Date.init,  file : StaticString = #filePath, line : UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate : currentDate)
        checkForMemoryLeaks(store, file: file, line: line)
        checkForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func uniqueImage() -> FeedItem{
        return FeedItem(id: UUID(), description: nil, location: nil, imageURL: anyURL())
    }
    
    private func uniqueImageFeed() -> (models: [FeedItem], local: [LocalFeedImage]){
        let models = [uniqueImage(),uniqueImage()]
        let local = models.map{LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.imageURL)}
        return (models,local)
    }
    
    private func anyURL() -> URL{
        return URL(string: "http://aurl.com")!
    }
    
    private func anyNSError() -> NSError{
        return NSError(domain : "anyError", code: 1)
    }
    
    
}



