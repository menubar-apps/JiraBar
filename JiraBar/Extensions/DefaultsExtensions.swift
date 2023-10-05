import Foundation
import Defaults

extension Defaults.Keys {
    
    static let username = Key<String>("username", default: "")
    static let jiraHost = Key<String>("jiraHost", default: "https://issues.apache.org/jira")

    static let activeTabs = Key<[TabType]>("activeTabs", default: [.first, .second])
    static let selectedTab = Key<TabType>("selectedTab", default: .first)

    static let enableTab1 = Key<Bool>("enableTab1", default: true)
    static let jqlTab1 = Key<String>("jqlTab1", default: "assignee = currentUser() ORDER BY created DESC")
    static let nameTab1 = Key<String>("nameTab1", default: "Assigned")

    static let enableTab2 = Key<Bool>("enableTab2", default: true)
    static let jqlTab2 = Key<String>("jqlTab2", default: "creator = currentUser() ORDER BY created DESC")
    static let nameTab2 = Key<String>("nameTab2", default: "Created")
    
    static let enableTab3 = Key<Bool>("enableTab3", default: false)
    static let jqlTab3 = Key<String>("jqlTab3", default: "")
    static let nameTab3 = Key<String>("nameTab3", default: "")
    
    static let maxResults = Key<String>("maxResults", default: "10")
}

extension KeychainKeys {
    static let jiraToken: KeychainAccessKey = KeychainAccessKey(key: "jiraToken")
}

enum TabType: String, CaseIterable, Identifiable, Equatable, Defaults.Serializable {
    case first,
         second,
         third
    var id: Self {self}
}
