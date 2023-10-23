//
//  IssueView.swift
//  jiraBar
//
//  Created by Pavel Makhov on 2023-09-13.
//

import SwiftUI

struct IssueView: View {
    
    @ObservedObject var viewModel: ViewModel
    var issue: Issue
    @State private var isHovering = false
    @StateObject private var issueViewModel = IssueViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            HStack {
                Text(issue.key)
                    .font(.footnote)
                    .padding([.leading, .trailing], 6)
                    .padding([.top, .bottom], 2)
                    .background(
                        RoundedRectangle(cornerRadius: 50, style: .continuous)
                            .stroke(Color.accentColor)
                    )
                Text(" " + issue.fields.summary).fontWeight(.bold)
                Spacer()
                Menu {
                    Button(action: {
                    }) {
                        Text("Copy link")
                    }
                    Button(action: {
                    }) {
                        Text("Copy title")
                    }
                    
                    Button(action: {
                    } ) {
                        Text("Copy issue key")
                    }
                } label: {
                    Image(systemName: "square.on.square")
                        .foregroundColor(.secondary)
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .frame(width: 20)
            }
//            .border(.red)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Assignee: " + (issue.fields.assignee?.displayName ?? "unassigned"))
                        .foregroundColor(.secondary)
                        .font(.footnote)
                    Text("Creator: " + (issue.fields.creator?.displayName ?? "<empty>"))
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
                
                Spacer()
                
                Menu {
                    ForEach(issueViewModel.transitions, id: \.id) {transition in
                        Button(action: {
                        }) {
                            Text(transition.name)
                        }
                    }
                } label: {
                    Text(issue.fields.status.name)
                        .font(.subheadline)
                }
                .menuStyle(BorderlessButtonMenuStyle())
                .padding([.leading, .trailing], 4)
                .padding([.top, .bottom], 2)
                .background(
                    RoundedRectangle(cornerRadius: 50, style: .continuous)
                        .stroke(Color.accentColor)
                )
                .foregroundColor(.secondary)
                
                .frame(width: 80, alignment: .trailing)
//                .padding()
            }
//            .border(.red)
        }
        .padding()
        .whenHovered{ over in
            isHovering = over
            issueViewModel.getTransitionsForIssue(issueKey: issue.key)
        }
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
            .frame(width: 400, height: 200)
    }
}
