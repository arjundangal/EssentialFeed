//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Arjun Dangal on 25/05/2021.
//

import Foundation

public struct FeedItem : Equatable  {
    let id : UUID
    let description : String?
    let location : String?
    let imageURL : URL
    
}
