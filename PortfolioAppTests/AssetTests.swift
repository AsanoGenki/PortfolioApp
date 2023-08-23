//
//  AssetTest.swift
//  PortfolioAppTests
//
//  Created by Genki on 8/25/23.
//

import XCTest
@testable import PortfolioApp

final class AssetTests: XCTestCase {
    
    //コードが期待するすべての色がアセットカタログに含まれていることを確認する
    func testColorsExisst() {
        let allColors = ["Dark Blue", "Dark Gray", "Gold", "Gray", "Green",
                         "Light Blue", "Midnight", "Orange", "Pink", "Purple", "Red", "Teal"]

        for color in allColors {
            XCTAssertNotNil(UIColor(named: color), "Failed to load color '\(color)' from asset catalog.")
        }
    }
    
    //Award.allAwardsプロパティが空かどうかをチェック
    func testAwardsLoadCorrectly() {
        XCTAssertTrue(Award.allAwards.isEmpty == false, "Failed to load awards from JSON.")
    }
}
