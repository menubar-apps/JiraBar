//
//  IssueView.swift
//  jiraBar
//
//  Created by Pavel Makhov on 2023-09-13.
//

import SwiftUI

struct IssueView: View {
    
    var viewModel: ViewModel
    var issue: Issue
    @State private var isHovering = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                
                HStack {
                    Text("#" + issue.key)
                        .font(.footnote)
                        .padding([.leading, .trailing], 4)
                        .padding([.top, .bottom], 2)
                        .background(
                            RoundedRectangle(cornerRadius: 50, style: .continuous)
                                .stroke(Color.accentColor)
                        )
                    Text(" " + issue.fields.summary).fontWeight(.bold)
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Assignee: " + (issue.fields.assignee?.displayName ?? "unassigned"))
                            .foregroundColor(.secondary)
                            .font(.footnote)
                        Text("Creator: " + (issue.fields.creator?.displayName ?? "<empty>"))
                            .foregroundColor(.secondary)
                            .font(.footnote)
                    }
                }
            }
            .padding([.top, .bottom], 4)
            .padding(8)
            
            Spacer()
        }
        .whenHovered{ over in isHovering = over }
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous).fill(.primary.opacity(isHovering ? 0.1 : 0))
        )

    }
}

struct IssueView_Previews: PreviewProvider {
    static var previews: some View {
        
        VStack (alignment: .leading) {
            IssueView(viewModel: ViewModel(),issue: Issue(key: "ASD-1234", fields: Fields(summary: "Some task summary", status: IssueStatus(name: "some status"), issuetype: IssueType(name: "Bug"), project: Project(name: "Project Name"))))
            IssueView(viewModel: ViewModel(),issue: Issue(key: "CNF-872", fields: Fields(summary: "Create something with long title", status: IssueStatus(name: "some status"), issuetype: IssueType(name: "Bug"), project: Project(name: "Project Name"))))
        }.padding()
    }
}
