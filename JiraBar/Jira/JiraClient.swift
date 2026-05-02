import Foundation
import Alamofire
import Defaults
import UserNotifications
import KeychainAccess


public class JiraClient {
    @Default(.instanceType) var instanceType
    @Default(.serverAuthType) var serverAuthType
    @Default(.orgName) var orgName
    @Default(.jiraHost) var jiraHost
    @Default(.jiraUsername) var jiraUsername
    @Default(.jiraServerUsername) var jiraServerUsername
    @Default(.jql) var jql
    @Default(.maxResults) var maxResults
    
    @FromKeychain(.jiraToken) var jiraToken
    @FromKeychain(.jiraServerToken) var jiraServerToken

    // MARK: - URL helpers

    /// Base URL for all API calls, derived from the selected instance type.
    private var baseUrl: String {
        switch instanceType {
        case .cloud:
            return "https://\(orgName).atlassian.net"
        case .server:
            // Trim any trailing slash the user may have typed.
            return jiraHost.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        }
    }

    /// Jira Server/Data Center only supports REST API v2.
    /// Cloud supports both v2 and v3; we use v3 for richer field types on Cloud.
    private var apiVersion: String {
        switch instanceType {
        case .cloud:  return "3"
        case .server: return "2"
        }
    }

    // MARK: - Auth header

    private var activeUsername: String {
        switch instanceType {
        case .cloud:  return jiraUsername
        case .server: return jiraServerUsername
        }
    }

    private var activeToken: String {
        switch instanceType {
        case .cloud:  return jiraToken
        case .server: return jiraServerToken
        }
    }

    private func authHeaders() -> HTTPHeaders {
        var headers: HTTPHeaders = [.accept("application/json")]
        switch instanceType {
        case .cloud:
            // Cloud always uses Basic auth: email + API token
            if !activeToken.isEmpty {
                headers.add(.authorization(username: activeUsername, password: activeToken))
            }
        case .server:
            switch serverAuthType {
            case .basic:
                // Older Jira Server (pre-8.14): Basic auth with username + password
                if !activeToken.isEmpty {
                    headers.add(.authorization(username: activeUsername, password: activeToken))
                }
            case .pat:
                // Jira Server 8.14+ / Data Center: Bearer token (PAT)
                if !activeToken.isEmpty {
                    headers.add(.authorization(bearerToken: activeToken))
                }
            }
        }
        return headers
    }

    // MARK: - API calls

    func getIssuesByJql(completion: @escaping ((JiraResponse) -> Void)) -> Void {
        // Cloud introduced the /search/jql endpoint; Server only supports /search
        let searchPath = instanceType == .cloud ? "search/jql" : "search"
        let url = "\(baseUrl)/rest/api/\(apiVersion)/\(searchPath)"
        let parameters: [String: Any] = [
            "jql": jql,
            "fields": "id,assignee,summary,status,issuetype,project",
            "maxResults": maxResults
        ]

        AF.request(url, method: .get, parameters: parameters, headers: authHeaders())
            .validate(statusCode: 200..<300)
            .responseDecodable(of: JiraResponse.self) { response in
                switch response.result {
                case .success(let response):
                    completion(response)
                case .failure(let error):
                    print("\(url):  \(error)")
                    completion(JiraResponse())
                    sendNotification(body: error.localizedDescription)
                }
            }
    }
    
    func getTransitionsByIssueKey(issueKey: String, completion: @escaping (([Transition]) -> Void)) -> Void {
        let url = "\(baseUrl)/rest/api/2/issue/\(issueKey)/transitions"

        AF.request(url, method: .get, parameters: nil, headers: authHeaders())
            .validate(statusCode: 200..<300)
            .responseDecodable(of: TransitionsResponse.self) { response in
                switch response.result {
                case .success(let response):
                    completion(response.transitions)
                case .failure(let error):
                    print("\(url):  \(error)")
                    completion([Transition]())
                    sendNotification(body: error.localizedDescription)
                }
            }
    }
    
    func transitionIssue(issueKey: String, to: String, completion: @escaping (() -> Void)) -> Void {
        let url = "\(baseUrl)/rest/api/2/issue/\(issueKey)/transitions"
        let parameters = [
            "transition": [
                "id": to
            ]
        ]
        
        var headers = authHeaders()
        headers.add(.contentType("application/json"))

        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    sendNotification(body: "Successfully transitioned issue")
                    completion()
                case .failure(let error):
                    print("\(url):  \(error)")
                    print(response.debugDescription)
                    sendNotification(body: error.localizedDescription)
                }
            }
    }
    
    func validateCredentials(completion: @escaping (Bool) -> Void) {
        switch instanceType {
        case .cloud:
            // Cloud: /myself is a reliable auth probe
            let url = "\(baseUrl)/rest/api/\(apiVersion)/myself"
            AF.request(url, method: .get, parameters: nil, headers: authHeaders())
                .validate(statusCode: 200..<300)
                .response { response in
                    switch response.result {
                    case .success:  completion(true)
                    case .failure(let error):
                        print(error)
                        completion(false)
                    }
                }
        case .server:
            // /myself returns 401 on some Server instances even with valid PATs.
            // Validate via a lightweight search and require a non-anonymous user context.
            let url = "\(baseUrl)/rest/api/2/search"
            let parameters: [String: Any] = ["jql": "reporter = currentUser()", "maxResults": 1]
            AF.request(url, method: .get, parameters: parameters, headers: authHeaders())
                .validate(statusCode: 200..<300)
                .responseData { response in
                    switch response.result {
                    case .success:
                        let usernameHeader = response.response?
                            .value(forHTTPHeaderField: "X-AUSERNAME")?
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .lowercased()
                        if let usernameHeader, !usernameHeader.isEmpty {
                            completion(usernameHeader != "anonymous")
                        } else {
                            completion(true)
                        }
                    case .failure(let error):
                        print(error)
                        completion(false)
                    }
                }
        }
    }
}


func sendNotification(body: String = "") {
  let content = UNMutableNotificationContent()
  content.title = "JiraBar Error"

  if body.count > 0 {
    content.body = body
  }

  let uuidString = UUID().uuidString
  let request = UNNotificationRequest(
    identifier: uuidString,
    content: content, trigger: nil)

  let notificationCenter = UNUserNotificationCenter.current()
  notificationCenter.requestAuthorization(options: [.alert, .sound]) { _, _ in }
  notificationCenter.add(request)
}
