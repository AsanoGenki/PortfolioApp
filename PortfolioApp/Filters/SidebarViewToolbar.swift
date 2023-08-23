//
//  SidebarViewToolbar.swift
//  PortfolioApp
//
//  Created by Genki on 8/24/23.
//

import SwiftUI

struct SidebarViewToolbar: View {
    @EnvironmentObject var dataController: DataController
    @State private var showingAwards = false
    var body: some View {
        Button(action: dataController.newTag) {
            Label("Add tag", systemImage: "plus")
        }
        
        Button {
            showingAwards.toggle()
        } label: {
            Label("Show awards", systemImage: "rosette")
        }
        .sheet(isPresented: $showingAwards, content: AwardsView.init)
        
        #if DEBUG
        Button {
            dataController.deleteAll()
            dataController.createSampleData()
        } label: {
            Label("ADD SAMPLES", systemImage: "flame")
        }
        #endif
    }
}

struct SidebarViewToolbar_Previews: PreviewProvider {
    static var previews: some View {
        SidebarViewToolbar()
    }
}
