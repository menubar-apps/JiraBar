//
//  GithubDtos.swift
//  jiraBar
//
//  Created by Pavel Makhov on 2023-10-29.
//

import Foundation

struct LatestRelease: Codable {
    
    var name: String
    var htmlUrl: String
    var assets: [Asset]
    
    enum CodingKeys: String, CodingKey {
        case name
        case assets
        case htmlUrl = "html_url"
    }
}

struct Asset: Codable {
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case name
    }
}
