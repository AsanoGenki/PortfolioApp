//
//  PortfolioAppApp.swift
//  PortfolioApp
//
//  Created by Genki on 8/21/23.
//

import SwiftUI

@main
struct PortfolioAppApp: App {
    @StateObject var dataController = DataController()
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView()
            } content: {
                ContentView()
            } detail: {
                DetailView()
            }
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
            //アプリ起動時にDataControllerインスタンスにアクセス
        }
    }
}
