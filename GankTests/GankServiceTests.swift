//
//  GankServiceTests.swift
//  Gank
//
//  Created by 叶帆 on 2016/11/19.
//  Copyright © 2016年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import XCTest
@testable import Gank

final class GankServiceTests: XCTestCase {
    func testAllGankHistoryDate() {
        let expectation = self.expectation(description: "get all history date")
        
        allGankHistoryDate(failureHandler: nil, completion: { dates in
            if !dates.isEmpty {
                expectation.fulfill()
            }
        })
        
        waitForExpectations(timeout: 15, handler: nil)
    }
    
    func testHasGankToday() {
        let expectation = self.expectation(description: "get today has gank")
        
        hasGankToday(failureHandler: nil, completion: { hasGankToday in
            print("today has gank: \(hasGankToday)")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 15, handler: nil)
    }
    
    func testGankWithDay() {
        let expectation = self.expectation(description: "get gank with day")
        
        gankWithDay(year:"2016", month:"11", day:"18", failureHandler: nil, completion: { gank in
            if !gank.isEmpty {
                expectation.fulfill()
            }
        })
        
        waitForExpectations(timeout: 15, handler: nil)
    }
    
    func testGankInToday() {
        let expectation = self.expectation(description: "get gank today")
        
        hasGankToday(failureHandler: nil, completion: { hasGankToday in
            if hasGankToday {
                gankInToday(failureHandler: nil, completion: { gank in
                    if !gank.isEmpty {
                        expectation.fulfill()
                    }
                })

            } else {
                expectation.fulfill()
            }
        })
        
        waitForExpectations(timeout: 15, handler: nil)
    }
}
