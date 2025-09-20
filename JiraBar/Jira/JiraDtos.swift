import Foundation
//
// MARK: issues
//
struct JiraResponse: Codable {
    var isLast: Bool
    var issues: [Issue]?
    
    enum CodingKeys: String, CodingKey {
        case isLast
        case issues
    }
}

struct Issue: Codable {
    var key: String
    var fields: Fields
    
    enum CodingKeys: String, CodingKey {
        case key
        case fields
    }
}

struct Fields: Codable {
    var summary: String
    var status: IssueStatus
    var issuetype: IssueType
    var project: Project
    var assignee: User?
    
    enum CodingKeys: String, CodingKey {
        case summary
        case status
        case issuetype
        case project
        case assignee
    }
}

struct IssueStatus: Codable {
    var name: String
    var iconUrl: URL?
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconUrl
    }
}

struct IssueType: Codable {
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case name
    }
}

struct Project: Codable {
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case name
    }
}

struct User: Codable {
    var name: String?
    var displayName: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case displayName
    }
}

//
// MARK: transitions
//
struct TransitionsResponse: Codable {
    var transitions: [Transition]
    
    enum CodingKeys: String, CodingKey {
        case transitions
    }
}

struct Transition: Codable {
    var name: String
    var id: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case id
    }
}
