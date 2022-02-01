import Foundation
import Alamofire
import Defaults
import UserNotifications


public class JiraClient {
    @Default(.jiraUsername) var jiraUsername
    @Default(.jiraToken) var jiraToken
    @Default(.jiraHost) var jiraHost
    @Default(.jql) var jql
    @Default(.maxResults) var maxResults
    
    func getIssuesByJql(completion:@escaping ((JiraResponse) -> Void)) -> Void {
        let url = "\(jiraHost)/rest/api/2/search"
        let parameters = [
            "jql": jql,
            "fields":"id,assignee,summary,status,issuetype,project",
            "maxResults": maxResults
        ]
        let headers: HTTPHeaders = [
            .authorization(username: jiraUsername, password: jiraToken),
            .accept("application/json")
        ]
        AF.request(url, method: .get, parameters: parameters, headers: headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: JiraResponse.self) { response in
                switch response.result {
                case .success(let response):
                    completion(response)
                case .failure(let error):
                    print("\(url):  \(error)")
                    completion(JiraResponse(total: 0))
                    sendNotification(body: error.localizedDescription)
                }
            }
    }
    
    func getTransitionsByIssueKey(issueKey: String, completion: @escaping (([Transition]) -> Void)) -> Void {
        let url = "\(jiraHost)/rest/api/2/issue/\(issueKey)/transitions"
        
        AF.request(url, method: .get)
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
    
    func transitionIssue(issueKey: String, to: String) -> Void {
        let url = "\(jiraHost)/rest/api/2/issue/\(issueKey)/transitions"
        let parameters = [
            "transition": [
                "id": issueKey
            ]
        ]
        
        AF.request(url, method: .post, parameters: parameters)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success(let response):
                    sendNotification(body: "Successfully transitioned issue")
                case .failure(let error):
                    print("\(url):  \(error)")
//                    completion([Transition]())
                    sendNotification(body: error.localizedDescription)
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
  
  // you can alse add a subtitle
//  content.subtitle = "subtitle here... "

  let uuidString = UUID().uuidString
  let request = UNNotificationRequest(
    identifier: uuidString,
    content: content, trigger: nil)

  let notificationCenter = UNUserNotificationCenter.current()
  notificationCenter.requestAuthorization(options: [.alert, .sound]) { _, _ in }
  notificationCenter.add(request)
}
