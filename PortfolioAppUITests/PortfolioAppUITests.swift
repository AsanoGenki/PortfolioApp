//
//  PortfolioAppUITests.swift
//  PortfolioAppUITests
//
//  Created by Genki on 8/25/23.
//

import XCTest

extension XCUIElement {
    func clear() {
        guard let stringValue = self.value as? String else {
            XCTFail("Failed to clear text in XCUIElement.")
            return
        }

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        typeText(deleteString)
    }
}

final class PortfolioAppUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()
    }

    //ナビゲーションバー要素が存在するか確認
    func testAppStartsWithNavigationBar() throws {
        XCTAssertTrue(app.navigationBars.element.exists, "There should be a navigation bar when the app launches.")
    }
    
    //「Filters」(戻るボタン)、「Filter」、および「New Issue」ボタンがすべて存在することを確認
    func testAppHasBasicButtonsOnLaunch() throws {
        XCTAssertTrue(app.navigationBars.buttons["Filters"].exists, "There should be a Filters button launch.")
        XCTAssertTrue(app.navigationBars.buttons["Filter"].exists, "There should be a Filter button launch.")
        XCTAssertTrue(app.navigationBars.buttons["New Issue"].exists, "There should be a New Issue button launch.")
    }
    
    //アプリ起動時にセルがないことを確認
    func testNoIssuesAtStart() {
        XCTAssertEqual(app.cells.count, 0, "There should be no list rows initially.")
    }
    
    func testCreatingAndDeletingIssues() {
        //5つのissueを作成し、それぞれが正しく作成されたか確認
        for tapCount in 1...5 {
            app.buttons["New Issue"].tap()
            app.buttons["Issues"].tap()

            XCTAssertEqual(app.cells.count, tapCount, "There should be \(tapCount) rows in the list.")
        }
        //5つのissueを削除し、それぞれが正しく削除されたか確認
        for tapCount in (0...4).reversed() {
            app.cells.firstMatch.swipeLeft()
            app.buttons["Delete"].tap()

            XCTAssertEqual(app.cells.count, tapCount, "There should be \(tapCount) rows in the list.")
        }
    }
    
    //Detail Viewの検査
    func testEditingIssueTitleUpdatesCorrectly() {
        XCTAssertEqual(app.cells.count, 0, "There should be no list rows initially.")

        app.buttons["New issue"].tap()
        
        app.textFields["Enter the issue title here"].tap()
        app.textFields["Enter the issue title here"].clear()
        app.typeText("My New Issue")
        
        app.buttons["Issues"].tap()
        XCTAssertTrue(app.buttons["My New Issue"].exists, "A My New Issue cell should now exist.")

    }
    
    //Priorityによってアイコンが表示されることを確認
    func testEditingIssuePriorityShowsIcon() {
        app.buttons["New Issue"].tap()
        app.buttons["Priority, Medium"].tap()
        app.buttons["High"].tap()

        app.buttons["Issues"].tap()

        let identifier = "New issue High Priority"
        XCTAssert(app.images[identifier].exists, "A high-priority issue needs an icon next to it.")
    }
    
    //Awardをタップすると「ロック」アラートが表示されることを確認
    func testAllAwardsShowLockedAlert() {
        app.buttons["Filters"].tap()
        app.buttons["Show awards"].tap()

        for award in app.scrollViews.buttons.allElementsBoundByIndex {
            if app.windows.element.frame.contains(award.frame) == false {
                app.swipeUp()
            }
            award.tap()
            XCTAssertTrue(app.alerts["Locked"].exists, "There should be a Locked alert showing for awards.")
            app.buttons["OK"].tap()
        }
    }


    
    
    
}
