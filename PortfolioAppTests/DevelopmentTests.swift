//
//  DevelopmentTest.swift
//  PortfolioAppTests
//
//  Created by Genki on 8/25/23.
//

import CoreData
import XCTest
@testable import PortfolioApp

final class DevelopmentTests: BaseTestCase {
    
    //サンプルデータ作成時、5つのTagと50個のIssueが作成されるか検証
    func testSampleDataCreationWorks() {
        dataController.createSampleData()
        
        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 5, "There should be 5 sample tags.")
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), 50, "There should be 50 sample issues.")
    }
    
    //deleteAllメソッドが実際に全て削除することを確認
    func testDeleteAllClearsEverything() {
        dataController.createSampleData()
        dataController.deleteAll()
        
        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 0, "deleteAll() should leave 0 tags.")
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), 0, "deleteAll() should leave 0 issues.")
    }
    
    //サンプルのTag作成時に内部に問題がないか確認
    func testExampleTagHasNoIssues() {
        let tag = Tag.example
        XCTAssertEqual(tag.issues?.count, 0, "The example tag should have 0 issues.")
    }
    
    //Issue.example作成時にpriorityが2であるかを確認
    func testExampleIssueIsHighPriority() {
        let issue = Issue.example
        XCTAssertEqual(issue.priority, 2, "The example issue should be high priority.")
    }

}
