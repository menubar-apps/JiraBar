import Foundation
//
// MARK: issues
//
struct JiraResponse: Codable {
    var total: Int
    var issues: [Issue]?
    
    enum CodingKeys: String, CodingKey {
        case total
        case issues
    }
}

struct Issue: Codable, Hashable {
    var key: String
    var fields: Fields
    var transitions: [Transition]?
    
    enum CodingKeys: String, CodingKey {
        case key
        case fields
        case transitions
    }
}

struct Fields: Codable, Hashable {
    var summary: String
    var status: IssueStatus
    var issuetype: IssueType
    var project: Project
    var assignee: User?
    var creator: User?
    
    enum CodingKeys: String, CodingKey {
        case summary
        case status
        case issuetype
        case project
        case assignee
        case creator
    }
}

struct IssueStatus: Codable, Hashable {
    var name: String
    var iconUrl: URL?
    
    enum CodingKeys: String, CodingKey {
        case name
        case iconUrl
    }
}

struct IssueType: Codable, Hashable {
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case name
    }
}

struct Project: Codable, Hashable {
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case name
    }
}

struct User: Codable, Hashable {
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

struct Transition: Codable, Hashable {
    var name: String
    var id: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case id
    }
}
