//
//  IssueRow.swift
//  PortfolioApp
//
//  Created by Genki on 8/24/23.
//

import SwiftUI

struct IssueRow: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var issue: Issue
    @State var testBool = false

    
    var body: some View {
        NavigationLink(value: issue) {
            HStack {
                Image(systemName: issue.completed ? "checkmark.circle" : "circle")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(issue.completed ? .blue : .primary)
                    .onTapGesture {
                        issue.completed.toggle()
                    }
                
                VStack(alignment: .leading) {
                    Text(issue.issueTitle)
                        .font(.headline)
                        .lineLimit(1)
                        .strikethrough(issue.completed)
                        
                    
                    Text(issue.issueTagsList)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(issue.issueFormattedCreationDate)
                        .accessibilityLabel(issue.issueCreationDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                }
                .foregroundColor(.secondary)
            }
        }
        .accessibilityIdentifier(issue.issueTitle)
    }
    
}

struct IssueRow_Previews: PreviewProvider {
    static var previews: some View {
        IssueRow(issue: .example)
    }
}
