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
        let retreivalError = anyNSError()
        let exp = expectation(description: "Waiting for load completion")
        var receivedError: Error?
        sut.load { result in
            switch result {
            case .failure(let error):
                receivedError = error
            default:
                XCTFail("Expected failure but got \(String(describing: result)) instead")
            }
            exp.fulfill()
        }
        store.completeRetrieval(with: retreivalError)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(retreivalError, receivedError as NSError?)
    }
    
    
    
    func test_load_deliversNoImagesOnEmptyCache(){
        let (sut,store) = makeSUT()


        let exp = expectation(description: "Waiting for load completion")
        var receivedImages: [FeedItem]?
        sut.load { result in
            switch result{
            case .success(let items):
                receivedImages = items
                exp.fulfill()
          default:
            XCTFail("Expected empty items but got \(String(describing: result)) instead")
          }
        }
        store.completeRetrievalOnEmptyCache()
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedImages?.count,0)
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
    
    private func uniqueImage() -> FeedItem{
        return FeedItem(id: UUID(), description: nil, location: nil, imageURL: anyURL())
    }
    private func anyURL() -> URL{
        return URL(string: "http://aurl.com")!
    }
    
    private func uniqueImageFeed() -> (models: [FeedItem], local: [LocalFeedImage]){
        let models = [uniqueImage(),uniqueImage()]
        let local = models.map{LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.imageURL)}
        return (models,local)
    }

}
