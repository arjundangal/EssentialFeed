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
    
    func get(from url : URL, completion : @escaping (HTTPClientResult) -> Void){
        session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
             }
         }.resume()
    }
}



class URLSessionHTTPClientTest : XCTestCase{
 
 
    func test_getFromURL_failsOnRequestError(){
        URLProtocolStub.startInterceptingRequest()
        let url = URL(string: "http://aurl.com")!
        let error = NSError(domain: "any error", code: 1)
        URLProtocolStub.stub(url : url, data : nil, response : nil, error : error)
        
        let sut = URLSessionHTTPCLient()
        
        let exp = expectation(description: "wait for completion")
        
        sut.get(from : url){result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertNotNil(receivedError)
            default :
                XCTFail("Expected failure with error. Got Result Instead")
            }
            
            exp.fulfill()
            
        }
        wait(for: [exp], timeout: 2)
        URLProtocolStub.stopInterceptingRequest()
    }

    //MARK:- Helpers
    private class URLProtocolStub : URLProtocol{
        private static var stub : Stub?
        private struct Stub{
            var error : Error?
            var data : Data?
            var response : URLResponse?
        }
        
        static  func stub(url : URL, data : Data?, response : URLResponse?, error : Error?){
            stub = Stub(error: error,data: data,response: response)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
             return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
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
        }
        
        override func stopLoading() {
            
        }
        
        
        
    }
    
    
    
    
}

