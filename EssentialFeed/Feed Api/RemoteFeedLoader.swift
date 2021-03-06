//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Arjun Dangal on 25/05/2021.
//

import Foundation

public final class RemoteFeedLoader : FeedLoader{
    private let url : URL
    private let client : HTTPClient
    
    public enum Error : Swift.Error{
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult
    
    public init(url : URL, client : HTTPClient){
        self.client = client
        self.url = url
    }
    
    
    
    public func load(completion : @escaping (Result) -> Void = { _ in }){
        client.get(from:  url){ [weak self] result  in
            guard self != nil else {return}
            switch(result){
            case .success(let data, let response):
                completion(RemoteFeedLoader.map(data, from: response))
                
            case .failure( _):
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do{
            let items = try FeedItemsMapper.map(data, from: response)
            return .success(items.toModels())
        }catch{
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedImage {
    
    func toModels() -> [FeedImage]{
        return map{FeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image)}
    }
}

