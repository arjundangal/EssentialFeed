//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Arjun Dangal on 26/05/2021.
//

import Foundation

 struct RemoteFeedImage : Decodable  {
     let id : UUID
     let description : String?
     let location : String?
     let image : URL
    
 }

internal final class FeedItemsMapper {
    private struct Root : Decodable {
        let items : [RemoteFeedImage]
     }
     
 
    private static var OK_200 : Int{
        return 200
    }
    
 
    internal static func map (_ data : Data, from response : HTTPURLResponse) throws -> [RemoteFeedImage] {
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
}


