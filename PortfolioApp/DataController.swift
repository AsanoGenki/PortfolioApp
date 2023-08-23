//
//  DataController.swift
//  PortfolioApp
//
//  Created by Genki on 8/21/23.
//

import CoreData
import SwiftUI

enum SortType: String {
    case dateCreated = "creationDate"
    case dateModified = "modificationDate"
}

enum Status {
    case all, open, closed
}

class DataController: ObservableObject {
    //CoreDataのデータをiCloudと共有
    let container: NSPersistentCloudKitContainer
    
    @Published var selectedFilter: Filter? = Filter.all
    @Published var selectedIssue: Issue?
    
    @Published var filterText = ""
    @Published var filterTokens = [Tag]()
    
    @Published var filterEnabled = false
    @Published var filterPriority = -1
    @Published var filterStatus = Status.all
    @Published var sortType = SortType.dateCreated
    @Published var sortNewestFirst = true
    
    private var saveTask: Task<Void, Error>?
    
    //static varを使うと初期化されずに前回の値を引き継いだままになる(静的変数)
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()
    
    //検索トークンの実装
    var suggestedFilterTokens: [Tag] {
        guard filterText.starts(with: "#") else {
            return []
        }
        
        let trimmedFilterText = String(filterText.dropFirst()).trimmingCharacters(in: .whitespaces)
        let request = Tag.fetchRequest()
        
        if trimmedFilterText.isEmpty == false {
            request.predicate = NSPredicate(format: "name CONTAINS[c] %@", trimmedFilterText)
        }
        
        return (try? container.viewContext.fetch(request).sorted()) ?? []
    }
    
    //Entityをテストと実際のコードに渡って、1回だけロードさせる
    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
            fatalError("Failed to locate model file.")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model file.")
        }
        
        return managedObjectModel
    }()
    
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)
        
        // テストとプレビューの目的のために、
        // 一時的に/dev/nullに書き込むことによってin-memory databaseを作成
        // アプリの実行終了後にデータは破棄される
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }
        
        //CoreDataとiCloudをシームレスに同期(別のデバイスを使用している場合に変更が互いに更新される)
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        container.persistentStoreDescriptions.first?.setOption(
            true as NSNumber,
            forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
        )
        
        NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator,
            queue: .main,
            using: remoteStoreChanged
        )
        
        //persistentStoreをロード
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }

            //UIテストの有効化
            #if DEBUG
            if CommandLine.arguments.contains("enable-testing") {
                self.deleteAll()
                UIView.setAnimationsEnabled(false)
            }
            #endif
        }
    }
    
    //外部で発生した変更を検出し、UIを更新(複数のデバイス間で作業する場合に有効)
    func remoteStoreChanged(_ notification: Notification) {
        objectWillChange.send()
    }
    
    //テストとプレビュー用にissueとtagを生成
    func createSampleData() {
        let viewContext = container.viewContext
        
        for i in 1...5 {
            let tag = Tag(context: viewContext)
            tag.id = UUID()
            tag.name = "Tag \(i)"
            
            
            for j in 1...10 {
                let issue = Issue(context: viewContext)
                issue.title = "Issue \(i)-\(j)"
                issue.content = "Description goes here"
                issue.creationDate = .now
                issue.completed = Bool.random()
                issue.priority = Int16.random(in: 0...2)
                tag.addToIssues(issue)
            }
        }
        
        try? viewContext.save()
    }
    
    func save() {
        saveTask?.cancel()
        
        //hasChangesはコンテキストが所有するオブジェクトに変更があるかどうかチェック可能とする
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }
    
    //遅延後に変更を保存する(データの安全性を確保)
    func queueSave() {
        saveTask?.cancel()
        
        saveTask = Task { @MainActor in
            try await Task.sleep(for: .seconds(3))
            save()
        }
    }
    
    func delete(_ object: NSManagedObject) {
        //手動で再描画を行う
        objectWillChange.send()
        
        container.viewContext.delete(object)
        save()
    }
    
    //FetchRequestに一致するオブジェクトを削除
    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            //ビューコンテキストを更新(mergeChanges)
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
    }
    
    func deleteAll() {
        let request1: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
        delete(request1)
        
        let request2: NSFetchRequest<NSFetchRequestResult> = Issue.fetchRequest()
        delete(request2)
        
        save()
    }
    
    //選択されていないタグを取得して、タグを複数選択させる(SwiftUIの組み込みビューは単一の選択しかサポートしていないため)
    func missingTags(from issue: Issue) -> [Tag] {
        let request = Tag.fetchRequest()
        let allTags = (try? container.viewContext.fetch(request)) ?? []
        
        let allTagsSet = Set(allTags)
        let difference = allTagsSet.symmetricDifference(issue.issueTags)
        
        return difference.sorted()
    }
    
    func issuesForSelectedFilter() -> [Issue] {
        let filter = selectedFilter ?? .all
        //データベースからデータを取得する際の条件を含んだクエリを構築
        var predicates = [NSPredicate]()
        
        //フィルタリング処理
        if let tag = filter.tag {
            //Issueのタグ関係には特定のタグが含まれている必要があることを指す
            let tagPredicate = NSPredicate(format: "tags CONTAINS %@", tag)
            predicates.append(tagPredicate)
        } else {
            let datePredicate = NSPredicate(format: "modificationDate > %@", filter.minModificationDate as NSDate)
            predicates.append(datePredicate)
        }
        
        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)
        
        if trimmedFilterText.isEmpty == false {
            //CONTAINS[c]述語形式を使用し、大文字と小文字を区別しない比較を行う
            let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", trimmedFilterText)
            let contentPredicate = NSPredicate(format: "content CONTAINS[c] %@", trimmedFilterText)
            let combinedPredicate = NSCompoundPredicate(
                orPredicateWithSubpredicates: [titlePredicate, contentPredicate]
            )
            predicates.append(combinedPredicate)
        }
        
        if filterTokens.isEmpty == false {
            let tokenPredicate = NSPredicate(format: "ANY tags IN %@", filterTokens)
            predicates.append(tokenPredicate)
        }
        
        if filterEnabled {
            if filterPriority >= 0 {
                let priorityFilter = NSPredicate(format: "priority = %d", filterPriority)
                predicates.append(priorityFilter)
            }
            
            if filterStatus != .all {
                let lookForClosed = filterStatus == .closed
                let statusFilter = NSPredicate(format: "completed = %@", NSNumber(value: lookForClosed))
                predicates.append(statusFilter)
            }
        }
        
        let request = Issue.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(key: sortType.rawValue, ascending: sortNewestFirst)]
        
        let allIssues = (try? container.viewContext.fetch(request)) ?? []
        return allIssues
        
    }
    
    //新しいTagを生成
    func newTag() {
        let tag = Tag(context: container.viewContext)
        tag.id = UUID()
        tag.name = NSLocalizedString("New tag", comment: "Create a new tag")
        save()
    }
    
    //新しいIssueを生成
    func newIssue() {
        let issue = Issue(context: container.viewContext)
        issue.title = NSLocalizedString("New issue", comment: "Create a new issue")
        issue.creationDate = .now
        issue.priority = 1
        
        //新しいIssueを自動的に割り当てる
        if let tag = selectedFilter?.tag {
            issue.addToTags(tag)
        }
        
        save()
        
        selectedIssue = issue
    }
    
    //フェッチリクエストによるカウント
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }
    
    //Awardの評価
    func hasEarned(award: Award) -> Bool {
        switch award.criterion {
        case "issues":
            let fetchRequest = Issue.fetchRequest()
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value
            
        case "closed":
            let fetchRequest = Issue.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "completed = true")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value
            
        case "tags":
            let fetchRequest = Tag.fetchRequest()
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value
            
        default:
            return false
        }
    }
    
    
    
}
