//
//  GithubClient.swift
//  jiraBar
//
//  Created by Pavel Makhov on 2023-10-29.
//

import Foundation
import Alamofire

public class GithubClient {
    
    func getLatestRelease(completion:@escaping (((LatestRelease?) -> Void))) -> Void {
             let headers: HTTPHeaders = [
                 .contentType("application/json"),
                 .accept("application/json")
             ]
             AF.request("https://api.github.com/repos/menubar-apps/JiraBar/releases/latest",
                        method: .get,
                        encoding: JSONEncoding.default,
                        headers: headers)
                 .validate(statusCode: 200..<300)
                 .responseDecodable(of: LatestRelease.self) { response in
                     switch response.result {
                     case .success(let latestRelease):
                         completion(latestRelease)
                     case .failure(let error):
                         completion(nil)
                         if let data = response.data {
                             let json = String(data: data, encoding: String.Encoding.utf8)
                         }
                         sendNotification(body: error.localizedDescription)
                     }
                 }
         }
}
