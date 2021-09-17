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
        
        expect(sut: sut, toCompleteWith: .failure(anyNSError())) {
            store.completeRetrieval(with: anyNSError())
        }
        
    }
    
    
    func test_load_deliversNoImagesOnEmptyCache(){
        let (sut,store) = makeSUT()
        
        expect(sut: sut, toCompleteWith: .success([FeedImage]())) {
            store.completeRetrievalOnEmptyCache()
        }
        
    }
    
    
    
    //MARK:- Helpers
    private func makeSUT(currentDate : @escaping () -> Date = Date.init,  file : StaticString = #filePath, line : UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate : currentDate)
        checkForMemoryLeaks(store, file: file, line: line)
        checkForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(sut: LocalFeedLoader, toCompleteWith expectedResult: LoadFeedResult, when action: () -> Void){
        
        let exp = expectation(description: "Waiting for load completion")

        sut.load { receivedResult in
            switch (receivedResult, expectedResult){
            case let (.success(receivedImages), .success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError , expectedError)
            default:
                XCTFail("Expected result \(expectedResult) but got \(String(describing: receivedResult)) instead")
            }
            exp.fulfill()
            
        }
        action()
        wait(for: [exp], timeout: 1.0)
        
        
    }
    
    
    private func anyNSError() -> NSError{
        return NSError(domain : "anyError", code: 1)
    }
    
    private func uniqueImage() -> FeedImage{
        return FeedImage(id: UUID(), description: nil, location: nil, imageURL: anyURL())
    }
    private func anyURL() -> URL{
        return URL(string: "http://aurl.com")!
    }
    
    private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]){
        let models = [uniqueImage(),uniqueImage()]
        let local = models.map{LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.imageURL)}
        return (models,local)
    }
    
}
