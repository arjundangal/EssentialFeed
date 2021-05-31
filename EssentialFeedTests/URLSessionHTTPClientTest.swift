//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Arjun Dangal on 31/05/2021.
//

import XCTest
import EssentialFeed


protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}

class URLSessionHTTPCLient {

     private let session : HTTPSession
    
    init(session: HTTPSession) {
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
 
     
    
    func test_getFromURL_resumesDataTaskWithURL(){
        let url = URL(string: "http://aurl.com")!
        let session = HTTPSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url : url , task : task)
        let sut = URLSessionHTTPCLient(session: session)
        sut.get(from : url){_ in}
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError(){
        let url = URL(string: "http://aurl.com")!
        let session = HTTPSessionSpy()
        let error = NSError(domain: "any error", code: 1)
        session.stub(url : url , error : error)
        
        let sut = URLSessionHTTPCLient(session: session)
        
        let exp = expectation(description: "wait for completion")
        
        sut.get(from : url){result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default :
                XCTFail("Expected failure with error. Got Result Instead")
            }
            
            exp.fulfill()
            
        }
        wait(for: [exp], timeout: 1)
    }

    //MARK:- Helpers
    
    private class HTTPSessionSpy : HTTPSession{
         private var stubs = [URL : Stub]()
        
        private struct Stub{
            var task : HTTPSessionTask
            var error : Error?
        }
        
        func stub(url : URL, task : HTTPSessionTask = FakeURLSessionDataTask(), error : Error? = nil){
            stubs[url] = .init(task: task, error: error)
        }
        
        
        
         func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
            guard let stub = stubs[url] else{
                fatalError("could not find stub for test")
            }
                completionHandler(nil, nil, stub.error)
                return stub.task
            
        }
    }
    
    private class FakeURLSessionDataTask : HTTPSessionTask{
         func resume() {
            
        }
    }
    private class URLSessionDataTaskSpy : HTTPSessionTask{
        var resumeCallCount = 0
        
         func resume() {
            resumeCallCount += 1
        }
    }

    
}

