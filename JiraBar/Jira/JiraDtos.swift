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
    
    enum CodingKeys: String, CodingKey {
        case summary
        case status
        case issuetype
    }
}

struct IssueStatus: Codable {
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case name
    }
}

struct IssueType: Codable {
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case name
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
    
    enum CodingKeys: String, CodingKey {
        case name
    }
}
