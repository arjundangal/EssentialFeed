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
        
        expect(sut, toCompleteWithResult: .failure(.connectivity)) {
            let clientError =  NSError(domain: "Test", code: 0)
            client.complete(with: clientError)

        }
     }

    
    func test_load_deliversErrorOnNon200HTTPResponse(){
        let (sut, client)  = makeSUT()
       
        let samples = [199,201,300]
        samples.enumerated().forEach { (index,code) in
            expect(sut, toCompleteWithResult: .failure(.invalidData)) {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json ,at: index)
             }
        }
     }
    
    
    func test_load_deliverssErrorOn200HTTPResponseWithInvalidJSON(){
        let (sut, client)  = makeSUT()
        expect(sut, toCompleteWithResult: .failure(.invalidData)) {
            let invalidJSON = Data("invalidJson".utf8)

            client.complete(withStatusCode: 200, data : invalidJSON)
         }
        
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList(){
        let (sut, client) = makeSUT()
 
         expect(sut, toCompleteWithResult: .success([])) {
            let emptyListJSON = Data("{\"items\" : []}".utf8)
            client.complete(withStatusCode: 200, data: emptyListJSON)

        }
        
    }
  
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems(){
        let (sut, client) = makeSUT()
 
        let item1  = makeItem(id : UUID(),
                               imageURL : URL(string: "https://aurl.com")!)
 
        let item2  = makeItem(id : UUID(),
                              description: "a description",
                              location : "a location",
                              imageURL : URL(string: "https://aurl.com")!)
 
        let items = [item1.model, item2.model]
        expect(sut, toCompleteWithResult: .success(items)) {
            let data = makeItemsJSON([item1.json, item2.json])
             client.complete(withStatusCode: 200, data:  data)
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTHasBeenDeallocated(){
        let url = URL(string: "http://anyurl.com")!
        let client = HTTPClientSpy()
        var sut : RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load{
            capturedResults.append($0)
        }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        
      
        XCTAssertTrue(capturedResults.isEmpty)
        
        
        
    }
    
    //MARK:- Helpers
    
    private func makeItem(id : UUID, description : String? = nil, location : String? = nil, imageURL : URL)->(model : FeedItem, json : [String : Any]){
        let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        let json = [
            "id" : id.uuidString,
            "description" : description,
            "location"  : location,
            "image" : imageURL.absoluteString
        ].reduce(into: [String : Any]()) { (acc, e) in
            if let value = e.value {
                acc[e.key] = value
            }
        }
        return (item, json)
    }
    
    private func makeItemsJSON(_ items : [[String : Any]]) -> Data{
        let itemsJSON = ["items" : items]
        return try! JSONSerialization.data(withJSONObject: itemsJSON)
    }
    
    
    private func expect(_ sut : RemoteFeedLoader,  toCompleteWithResult expectedResult : RemoteFeedLoader.Result, when action : () -> Void, file : StaticString =  #filePath, line : UInt = #line){
        
        let exp = expectation(description: "Waiting for load to complete")
        
         sut.load{ receivedResult in
            switch(receivedResult, expectedResult){
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file : file, line : line)
            
            case let (.failure(receivedError), .failure(expectedError)):
              XCTAssertEqual(receivedError, expectedError, file : file, line : line)
              
            default :
                XCTFail("Expected result \(expectedResult) got \(receivedResult)", file: file, line : line)
             }
            exp.fulfill()
        }
         action()
        
        wait(for : [exp], timeout: 1.0)
      }
    
    private func makeSUT(url : URL =  URL(string: "https://aurl.com")!, file : StaticString =  #filePath, line : UInt = #line) -> (sut : RemoteFeedLoader, client : HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        checkForMemoryLeaks(sut)
        checkForMemoryLeaks(client)
        return (sut, client)
    }
    
    private func checkForMemoryLeaks(_ instance : AnyObject, file : StaticString =  #filePath, line : UInt = #line ){
        addTeardownBlock {[weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential Memory Leak",file: file, line:line)
        }
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
        
        func complete(withStatusCode code : Int, data : Data, at index : Int = 0){
            let response = HTTPURLResponse(url: requestedURLs[index],statusCode: code,httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success(data,response))
        }
     }
 }
