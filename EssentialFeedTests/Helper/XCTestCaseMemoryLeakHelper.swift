//
//  XCTestCaseMemoryLeakHelper.swift
//  EssentialFeedTests
//
//  Created by Arjun Dangal on 01/06/2021.
//

import XCTest

extension XCTestCase {
     func checkForMemoryLeaks(_ instance : AnyObject, file : StaticString =  #filePath, line : UInt = #line ){
        addTeardownBlock {[weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential Memory Leak",file: file, line:line)
        }
    }


}
