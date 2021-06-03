//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Arjun Dangal on 03/06/2021.
//

import Foundation

public class URLSessionHTTPCLient : HTTPClient {

     private let session : URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    struct UnexpectedValueRepresentationError : Error{
        
    }
    
   public func get(from url : URL, completion : @escaping (HTTPClientResult) -> Void){
 
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
