//
//  ViewModel.swift
//  jiraBar
//
//  Created by Pavel Makhov on 2023-09-13.
//

import Foundation
import Defaults

class ViewModel: ObservableObject {
    
    @Default(.selectedTab) var selectedTab
    
    @Default(.jqlTab1) var jqlTab1
    @Default(.jqlTab2) var jqlTab2
    @Default(.jqlTab3) var jqlTab3
    
    private var client = JiraClient()
    
    @Published var issues: [Issue] = []
    
    @Published var dictForFirstTab: [String:[Issue]] = [:]
    @Published var dictForSecondTab: [String:[Issue]] = [:]
    @Published var dictForThirdTab: [String:[Issue]] = [:]

    @Published var issuesTab1: [Issue] = []
    @Published var issuesTab2: [Issue] = []
    @Published var issuesTab3: [Issue] = []
    
    @Published var tab1Loading: Bool = false
    @Published var tab2Loading: Bool = false
    @Published var tab3Loading: Bool = false
    
    @Published var issueKeyToTransition: [String: [Transition]] = [:]
    
    @Published var popupIsShown = false
    
    @Published var error: String?
    
    init() {
        print("HI!")
    }
    
//    func getIssueForSelectedTab() -> [String: [Issue]] {
    func getIssueForSelectedTab() -> [Issue] {
        switch selectedTab {
        case .first:
            return issuesTab1
//            return dictForFirstTab
        case .second:
            return issuesTab2
//            return dictForSecondTab
        case .third:
            return issuesTab3
//            return dictForThirdTab
        }
    }
    
    func getIssuesForFirstTab() {
        tab1Loading = true
        client.getIssuesByJql(jql: jqlTab1) { res in
            self.error = .none
            
            switch res {
            case .success(let issues):
                self.issuesTab1 = issues
//                let temp = Dictionary(grouping: issues) { $0.fields.status.name }.sorted { $0.key < $1.key }
//                self.dictForFirstTab = Dictionary(uniqueKeysWithValues: temp)
                self.tab1Loading = false
            case .failure(let failure):
                switch failure {
                case .unexpected(let message):
                    if let errorMessage = message {
                        self.error = errorMessage
                    } else {
                        self.error = "Unexpected exception"
                    }
                case .credentialsNotSet:
                    self.error = "Please set up authentication parameters in the Preferences"
                }
                
                self.tab1Loading = false
                self.issuesTab1.removeAll()
//                self.dictForFirstTab.removeAll()
            }
        }
    }
    
    func getIssuesForSecondTab() {
        tab2Loading = true
        client.getIssuesByJql(jql: jqlTab2) { res in

            switch res {
            case .success(let issues):
                self.issuesTab2 = issues
//                let temp = Dictionary(grouping: issues) { $0.fields.status.name }.sorted { $0.key < $1.key }
//                self.dictForSecondTab = Dictionary(uniqueKeysWithValues: temp)
                self.tab2Loading = false
            case .failure(let failure):
                switch failure {
                case .unexpected(let message):
                    if let errorMessage = message {
                        self.error = errorMessage
                    } else {
                        self.error = "Unexpected exception"
                    }
                case .credentialsNotSet:
                    self.error = "Please set up authentication parameters in the Preferences"
                }

                self.tab2Loading = false
//                self.dictForSecondTab.removeAll()
                self.issuesTab2.removeAll()
            }
        }
    }
    
    func getIssuesForThirdTab() {
        tab3Loading = true
        client.getIssuesByJql(jql: jqlTab3) { res in
            
            switch res {
            case .success(let issues):
                self.issuesTab3 = issues
//                let temp = Dictionary(grouping: issues) { $0.fields.status.name }.sorted { $0.key < $1.key }
//                self.dictForThirdTab = Dictionary(uniqueKeysWithValues: temp)
                self.tab3Loading = false
            case .failure(let failure):
                switch failure {
                case .unexpected(let message):
                    if let errorMessage = message {
                        self.error = errorMessage
                    } else {
                        self.error = "Unexpected exception"
                    }
                case .credentialsNotSet:
                    self.error = "Please set up authentication parameters in the Preferences"
                }
                
                self.tab3Loading = false
//                self.dictForThirdTab.removeAll()
                self.issuesTab3
            }
        }
        
        
    }
    func getTransitionsForIssue(issueKey: String) {
        client.getTransitionsByIssueKey(issueKey: issueKey) { transitions in
            if var i = self.issuesTab1.first(where: {$0.key == issueKey}) {
                i.transitions = transitions
            }
        }
    }
    private var jqlByTab: String {
        switch selectedTab {
        case .first:
            return jqlTab1
        case .second:
            return jqlTab2
        case .third:
            return jqlTab3
        }
    }
}
