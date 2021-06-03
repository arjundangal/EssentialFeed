//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Arjun Dangal on 31/05/2021.
//

import XCTest
import EssentialFeed


 

class URLSessionHTTPCLient {

     private let session : URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    struct UnexpectedValueRepresentationError : Error{
        
    }
    
    func get(from url : URL, completion : @escaping (HTTPClientResult) -> Void){
 
        session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            }else if let data = data, let response = response as? HTTPURLResponse{
                completion(.success(data, response))
            } else{
                completion(.failure(UnexpectedValueRepresentationError()))
            }
         }.resume()
    }
}



class URLSessionHTTPClientTest : XCTestCase{
    
    override class func setUp() {
        URLProtocolStub.startInterceptingRequest()
    }
    
    override class func tearDown() {
        URLProtocolStub.stopInterceptingRequest()

    }
    
    func test_getFromURL_performsGETRequestWithURL(){
        let url = anyURL()
        let exp = expectation(description: "Wait for request")
       
        
        URLProtocolStub.observeRequest {request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        
        makeSUT().get(from: url) { _ in }
        wait(for: [exp], timeout: 1.0)

    }
 
 
    func test_getFromURL_failsOnRequestError(){
        let requestError = anyNSError()
        
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError)
        
        XCTAssertNotNil(receivedError)

     }

    
    func test_getFromURL_failsOnAllNilValues(){
 
        let receivedError = resultErrorFor(data: nil, response: nil, error: nil)
        
        XCTAssertNotNil(receivedError)
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases(){
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))

     }
    
    func test_getFromURL_succeedsOnHTTPURLResponseWithNilData(){
         let data = anyData()
        
        let response = anyHTTPURLResponse()
        
        let receivedValues = resultValuesFor(data: data, response: response, error: nil)
         XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response.url, response?.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response?.statusCode)
    }
    
    func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData(){
         let response = anyHTTPURLResponse()
        
        let receivedValues = resultValuesFor(data: nil, response: response, error: nil)
        
        let emptyData = Data()
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, response?.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response?.statusCode)
    }

    
    //MARK:- Helpers
    
    private func makeSUT(file : StaticString =  #filePath, line : UInt = #line) -> URLSessionHTTPCLient {
        let sut = URLSessionHTTPCLient()
        checkForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func anyData() -> Data?{
        return Data("anyData".utf8)
    }
    
    private func anyNSError() -> NSError?{
        return NSError(domain : "anyError", code: 1)

    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse?{
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)

    }
    private func nonHTTPURLResponse() -> URLResponse?{
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)


    }

    private func resultValuesFor(data : Data?, response : URLResponse?, error : Error?, file : StaticString =  #filePath, line : UInt = #line) -> (data : Data, response : HTTPURLResponse)? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch result {
        case let .success(data, response):
            return (data : data, response : response)
        default :
            XCTFail("Expected success.  Got \(result) instead", file: file, line: line)
            return nil
        }
        
        
        
    }
    
    private func resultErrorFor(data : Data?, response : URLResponse?, error : Error?, file : StaticString =  #filePath, line : UInt = #line) -> Error? {
        
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
    
            switch result {
            case let  .failure (error):
                return error
             default :
                XCTFail("Expected failure Got \(result) instead", file: file, line: line)
                return nil
            }
            
          
     }
    
    
    private func anyURL() -> URL{
        return URL(string: "http://aurl.com")!

    }
    
    private func resultFor(data : Data?, response : URLResponse?, error : Error?, file : StaticString =  #filePath, line : UInt = #line) -> HTTPClientResult{
        let sut = makeSUT(file : file, line : line)
        let exp = expectation(description: "wait for completion")
        var receivedResult  : HTTPClientResult!
        sut.get(from : anyURL() ){result in
            receivedResult = result
            exp.fulfill()
            
        }
        wait(for: [exp], timeout: 2)
        return receivedResult

    }
    
    
    private class URLProtocolStub : URLProtocol{
        private static var stub : Stub?
        private static var requestObserver : ((URLRequest) -> Void)?
        
        private struct Stub{
            var error : Error?
            var data : Data?
            var response : URLResponse?
        }
        
        
        
        static  func stub(data : Data?, response : URLResponse?, error : Error?){
            stub = Stub(error: error,data: data,response: response)
        }
        
        static func observeRequest(observer : @escaping (URLRequest) -> Void){
            requestObserver = observer
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
             return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            requestObserver?(request)
            return request
        }
        
        override func startLoading() {
            if let data = URLProtocolStub.stub?.data{
                client?.urlProtocol(self, didLoad: data)
            }
            if let response =  URLProtocolStub.stub?.response{
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let error  =  URLProtocolStub.stub?.error{
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
            
        }
        
        static func startInterceptingRequest(){
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest(){
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override func stopLoading() {
            
        }
        
        
        
    }
    
    
    
    
}

