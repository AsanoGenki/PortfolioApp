//
//  PortfolioAppTests.swift
//  PortfolioAppTests
//
//  Created by Genki on 8/25/23.
//

import CoreData
import XCTest
@testable import PortfolioApp

class BaseTestCase: XCTestCase {
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }
}
