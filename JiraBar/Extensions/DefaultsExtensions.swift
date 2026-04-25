import Foundation
import Defaults

enum JiraInstanceType: String, Defaults.Serializable {
    case cloud
    case server
}

extension Defaults.Keys {
    static let jiraUsername = Key<String>("jiraUsername", default: "")
    
    static let orgName = Key<String>("orgName", default: "")
    /// Base URL for self-hosted Jira Server / Data Center instances.
    /// Ignored when instanceType == .cloud.
    static let jiraHost = Key<String>("jiraHost", default: "https://jira.example.com")
    static let jql = Key<String>("jql", default: "")
    
    static let refreshRate = Key<Int>("refreshRate", default: 5)
    static let maxResults = Key<String>("maxResults", default: "10")
    
    /// Defaults to .cloud so existing users are unaffected.
    static let instanceType = Key<JiraInstanceType>("instanceType", default: .cloud)
}

extension KeychainKeys {
    /// API token for Jira Cloud. Kept under the original key name so existing users are unaffected.
    static let jiraToken: KeychainAccessKey = KeychainAccessKey(key: "jiraToken")
    /// Password or PAT for self-hosted Jira Server / Data Center. Separate key to avoid clobbering the Cloud token.
    static let jiraServerToken: KeychainAccessKey = KeychainAccessKey(key: "jiraServerToken")
}
