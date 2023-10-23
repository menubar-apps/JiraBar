import Foundation
import Alamofire
import Defaults
import UserNotifications
import KeychainAccess

public class JiraClient {
    @Default(.username) var username
    @Default(.jiraHost) var jiraHost

    @Default(.maxResults) var maxResults
    
    @FromKeychain(.jiraToken) var jiraToken
    
    func getIssuesByJql(jql: String, completion:@escaping (Result<[Issue], ClientError>) -> Void) -> Void {
        
        if jiraHost.isEmpty || jiraToken.isEmpty || username.isEmpty {
            completion(.failure(.credentialsNotSet))
            return
        }
        
        let url = "\(jiraHost)/rest/api/2/search"
        let parameters = [
            "jql": jql,
            "fields": "id,assignee,creator,summary,status,issuetype,project",
            "maxResults": maxResults
        ]
        var headers: HTTPHeaders = [
            .accept("application/json")
        ]
        
        if !jiraToken.isEmpty {
            headers.add(.authorization(username: username, password: jiraToken))
        }
        
        AF.request(url, method: .get, parameters: parameters, headers: headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: JiraResponse.self) { response in
                switch response.result {
                case .success(let response):
                    completion(.success(response.issues ?? []))
                case .failure(let error):
                   completion(.failure(.unexpected(message: error.localizedDescription)))
                }
            }
    }
    
    func getTransitionsByIssueKey(issueKey: String, completion: @escaping (([Transition]) -> Void)) -> Void {
        let url = "\(jiraHost)/rest/api/2/issue/\(issueKey)/transitions"
        
        var headers: HTTPHeaders = [
            .accept("application/json")
        ]
        
        if !jiraToken.isEmpty {
            headers.add(.authorization(username: username, password: jiraToken))
        }

        AF.request(url, method: .get, parameters: nil, headers: headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: TransitionsResponse.self) { response in
                switch response.result {
                case .success(let response):
                    completion(response.transitions)
                case .failure(let error):
                    print("\(url):  \(error)")
                    completion([Transition]())
                }
            }
    }
    
    func transitionIssue(issueKey: String, to: String, completion: @escaping (() -> Void)) -> Void {
        let url = "\(jiraHost)/rest/api/2/issue/\(issueKey)/transitions"
        let parameters = [
            "transition": [
                "id": to
            ]
        ]
        
        var headers: HTTPHeaders = [
            .accept("application/json"),
            .contentType("application/json")
        ]
        
        if !jiraToken.isEmpty {
            headers.add(.authorization(username: username, password: jiraToken))
        }
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success(let response):
                    completion()
                case .failure(let error):
                    print("\(url):  \(error)")
                    print(response.debugDescription)
//                    completion([Transition]())
                }
            }
    }
    
    func getMyself(completion: @escaping(User?) -> Void) {
        let url = "\(jiraHost)/rest/api/2/myself"
        
        var headers: HTTPHeaders = [
            .accept("application/json")
        ]
        
        if !jiraToken.isEmpty {
            headers.add(.authorization(username: username, password: jiraToken))
        }

        AF.request(url, method: .get, parameters: nil, headers: headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: User.self) { response in
                switch response.result {
                case .success(let user):
                    completion(user)
                case .failure(let error):
                    completion(nil)
                    print(error)
                }
            }
    }
}

enum ClientError: Error {
    case unexpected(message: String?)
    case credentialsNotSet
}
