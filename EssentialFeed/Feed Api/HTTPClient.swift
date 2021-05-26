//
//  HTTPURLResponse.swift
//  EssentialFeed
//
//  Created by Arjun Dangal on 26/05/2021.
//

import Foundation

public enum HTTPClientResult {
    case success(Data,HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
 }

