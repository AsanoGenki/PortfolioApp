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
    @Environment(\.scenePhase) var scenePhase
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView()
            } content: {
                ContentView()
            } detail: {
                DetailView()
            }
            //アプリ起動時にDataControllerインスタンスにアクセス
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
            
            //シーンのフェイズの変化を監視
                .onChange(of: scenePhase) { phase in
                    if phase != .active {
                        dataController.save()
                    }
                }
        }
    }
}
