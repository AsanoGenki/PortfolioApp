//
//  AwardTests.swift
//  PortfolioAppTests
//
//  Created by Genki on 8/25/23.
//

import CoreData
import XCTest
@testable import PortfolioApp

final class AwardTests: BaseTestCase {
    let awards = Award.allAwards
    
    //全てのAwardのIDが名前と同じであるか検証
    func testAwardIDMatchesName() {
        for award in awards {
            XCTAssertEqual(award.id, award.name, "Award ID should always match its name.")
        }
    }
    
    //新規ユーザーがアプリにアクセスした際に、Awardを獲得していないことを確認
    func testNewUserHasUnlockedNoAwards() {
        for award in awards {
            XCTAssertFalse(dataController.hasEarned(award: award), "New users should have no earned awards.")
        }
    }
    
    //ユーザーのIssue作成数に対するAwardの獲得が対応しているか検証
    func testCreatingIssueUnlocksAwards() {
        let value = [1, 10, 20, 50, 100, 250, 500, 1000]
        
        for (count, value) in value.enumerated() {
            var issues = [Issue]()
            
            for _ in 0..<value {
                let issue = Issue(context: managedObjectContext)
                issues.append(issue)
            }
            
            let matches = awards.filter { award in
                award.criterion == "issues" && dataController.hasEarned(award: award)
            }
            
            XCTAssertEqual(matches.count, count + 1, "Adding \(value) issues should unlock \(count + 1) awards")
            
            dataController.deleteAll()
        }
        
    }
    
    func testClosedAwards() {
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]

        for (count, value) in values.enumerated() {
            var issues = [Issue]()

            for _ in 0..<value {
                let issue = Issue(context: managedObjectContext)
                issue.completed = true
                issues.append(issue)
            }

            let matches = awards.filter { award in
                award.criterion == "closed" && dataController.hasEarned(award: award)
            }

            XCTAssertEqual(matches.count, count + 1, "Completing \(value) issues should unlock \(count + 1) awards.")

            for issue in issues {
                dataController.delete(issue)
            }
        }
    }

}
