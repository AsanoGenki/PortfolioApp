//
//  PerformanceTests.swift
//  PortfolioAppTests
//
//  Created by Genki on 8/25/23.
//

import XCTest
@testable import PortfolioApp

class PerformanceTests: BaseTestCase {
    
    //ユーザーが獲得した賞をどれだけ速く計算できるかを監視
    func testAwardCalculationPerformance() {
        // テストデータを大量生成
        for _ in 1...100 {
            dataController.createSampleData()
        }

        // 多くのAwardをシミュレーションして確認
        let awards = Array(repeating: Award.allAwards, count: 25).joined()
        XCTAssertEqual(awards.count, 500, "This checks the awards count is constant. Change this if you add awards.")

        measure {
            _ = awards.filter(dataController.hasEarned).count
        }
    }
}
