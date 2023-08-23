//
//  Tag-CoreDataHelpers.swift
//  PortfolioApp
//
//  Created by Genki on 8/23/23.
//

import Foundation

//CoreData(Tag)のオプション性を回避するコード
extension Tag {
    var tagID: UUID {
        id ?? UUID()
    }
    
    var tagName: String {
        name ?? ""
    }
    
    //完了してないアクティブな課題のみを表示する(チェックされていないToDo)
    var tagActiveIssues: [Issue] {
        let result = issues?.allObjects as? [Issue] ?? []
        return result.filter { $0.completed == false }
    }
    
    static var example: Tag {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        let tag = Tag(context: viewContext)
        tag.id = UUID()
        tag.name = "Example Tag"
        return tag
    }
}

extension Tag: Comparable {
    public static func < (lhs: Tag, rhs: Tag) -> Bool {
        let left = lhs.tagName.localizedLowercase
        let right = rhs.tagName.localizedLowercase
        
        if left == right {
            return lhs.tagID.uuidString < rhs.tagID.uuidString
        } else {
            return left < right
        }
    }
}
