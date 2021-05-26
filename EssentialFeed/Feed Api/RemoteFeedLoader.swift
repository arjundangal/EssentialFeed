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
    
    public enum Result :Equatable{
        case success([FeedItem])
        case failure(Error)
    }
    
   public init(url : URL, client : HTTPClient){
    
        self.client = client
        self.url = url
    }
    
     public func load(completion : @escaping (Result) -> Void = { _ in }){
        client.get(from:  url){ result  in
            
            switch(result){
            case .success(let data, let _):
            
                if let _ = try? JSONSerialization.jsonObject(with: data){
                    completion(.success([]))
                }else{
                    completion(.failure(.invalidData))
                }
            case .failure(let _):
                completion(.failure(.connectivity))
             
            }
        }
     }
}
