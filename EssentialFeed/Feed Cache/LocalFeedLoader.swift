//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Arjun Dangal on 16/09/2021.
//

import Foundation

public final class LocalFeedLoader {
   private let store : FeedStore
   private let currentDate : () -> Date
    
  public typealias SaveResult = Error?
    
   public init(store : FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
   public func save(_ items : [FeedItem], completion: @escaping (Error?) -> Void){
        store.deleteCachedFeed(items){[weak self] error in
            guard let self = self else {return}
             if let cacheDeletionError = error{
                completion(cacheDeletionError)
            }else{
                self.cache(items, with: completion)

            }
        }
    }
    
    private func cache(_ items : [FeedItem], with completion: @escaping (Error?) -> Void){
        store.insert(items.toLocal(), timestamp: self.currentDate()) {[weak self] (insertionError) in
            guard self != nil else {return}
            
            completion(insertionError)
        }
    }
    
    public func load(completion: @escaping (Error?) -> Void){
        store.retrieve{ loadError in
            completion(loadError)
        }
        
    }
    
}

private extension Array where Element == FeedItem{
    func toLocal() -> [LocalFeedImage]{
        return map{LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.imageURL)}
    }
}
