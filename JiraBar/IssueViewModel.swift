//
//  IssueViewModel.swift
//  jiraBar
//
//  Created by Pavel Makhov on 2023-10-21.
//

import Foundation

class IssueViewModel: ObservableObject {
    private var client = JiraClient()

    @Published var transitions: [Transition] = []
    
    func getTransitionsForIssue(issueKey: String) {
          client.getTransitionsByIssueKey(issueKey: issueKey) { transitions in 
              self.transitions = transitions
          }
      }
}
