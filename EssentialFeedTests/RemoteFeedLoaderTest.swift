//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Arjun Dangal on 25/05/2021.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests : XCTestCase{
    
    func test_init_doesNotRequestsDataFromURL(){
        let client = HTTPClientSpy()
        _ = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL(){
        let url =  URL(string: "https://aurl.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load()
        XCTAssertEqual(url, client.requestedURLs.first)
    }
    func test_loadTwice_requestsDataFromURLTwice(){
        let url =  URL(string: "https://aurl.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load()
        sut.load()
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError(){
        let (sut, client)  = makeSUT()
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load{
            capturedErrors.append($0)
        }
        let clientError =  NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
        XCTAssertEqual(capturedErrors,[ .connectivity])
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse(){
        let (sut, client)  = makeSUT()
        var capturedErrors = [RemoteFeedLoader.Error]()

        sut.load{
            capturedErrors.append($0)
        }
        let invalidJSON = Data(bytes: "invalidJson".utf8)
        client.complete(withStatusCode: 200, data : invalidJSON)
            XCTAssertEqual(capturedErrors,[ .invalidData])

        }
    
    
    func test_load_deliverssErrorOn200HTTPResponseWithInvalidJSON(){
        let (sut, client)  = makeSUT()
        let samples = [199,201,300]
        samples.enumerated().forEach { (index,code) in
            var capturedErrors = [RemoteFeedLoader.Error]()
            sut.load{
                capturedErrors.append($0)
            }
            client.complete(withStatusCode: code, at: index)
            XCTAssertEqual(capturedErrors,[ .invalidData])

        }
     }
    
    
    
    
    
    //MARK:- Helpers
    private func makeSUT(url : URL =  URL(string: "https://aurl.com")!) -> (sut : RemoteFeedLoader, client : HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy : HTTPClient{
        var requestedURLs : [URL]{
        return messages.map{$0.url}
        }
        var completions = [(Error) -> Void]()
        
        private var messages = [(url : URL, completion : (HTTPClientResult) -> Void)]()
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
         }
        
        func complete(with error : Error, at index: Int = 0){
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code : Int, data : Data = Data(), at index : Int = 0){
            let response = HTTPURLResponse(url: requestedURLs[index],statusCode: code,httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success(data,response))
        }
        
    }

 
}
