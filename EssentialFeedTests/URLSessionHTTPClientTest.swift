//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Arjun Dangal on 31/05/2021.
//

import XCTest

class URLSessionHTTPCLient {

     private let session : URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url : URL){
        session.dataTask(with: url) { (data, response, error) in
            
        }
    }
}



class URLSessionHTTPClientTest : XCTestCase{
 
    func test(){
        let url = URL(string: "http://aurl.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPCLient(session: session)
        sut.get(from : url)
        XCTAssertEqual(session.receivedURLs, [url])
    }

    //MARK:- Helpers
    
    private class URLSessionSpy : URLSession{
        var receivedURLs = [URL]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLs.append(url)
            return FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask : URLSessionDataTask{}
    
    
}

