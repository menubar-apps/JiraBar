import Foundation
import Defaults

extension Defaults.Keys {
    static let jiraUsername = Key<String>("jiraUsername", default: "")
    
    static let jiraHost = Key<String>("jiraHost", default: "")
    static let jql = Key<String>("jql", default: "")
    
    static let refreshRate = Key<Int>("refreshRate", default: 5)
    static let maxResults = Key<String>("maxResults", default: "10")
}

extension KeychainKeys {
    static let jiraToken: KeychainAccessKey = KeychainAccessKey(key: "jiraToken")
}
