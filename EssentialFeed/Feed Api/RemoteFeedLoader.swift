//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Arjun Dangal on 25/05/2021.
//

import Foundation

public enum HTTPClientResult {
    case success(Data,HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
 }

public final class RemoteFeedLoader{
   private let url : URL
    private let client : HTTPClient
    
    public enum Error : Swift.Error{
        case connectivity
        case invalidData
    }
    
   public init(url : URL, client : HTTPClient){
    
        self.client = client
        self.url = url
    }
    
     public func load(completion : @escaping (Error) -> Void = { _ in }){
        client.get(from:  url){ result  in
            
            switch(result){
            case .success(let response):
                completion(.invalidData)
            case .failure(let error):
                completion(.connectivity)
             
            }
        }
     }
}
