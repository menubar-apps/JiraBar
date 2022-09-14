//
//  TokenValidator.swift
//  jiraBar
//
//  Created by Pavel Makhov on 2022-09-14.
//

import Foundation
import SwiftUI

class JiraTokenValidator: ObservableObject {
    
    @Published var iconName: String!;
    @Published var iconColor: Color!;
    
    init() {
        setLoading()
    }
    
    func setLoading() {
        
        self.iconName = "clock.fill"
        self.iconColor = Color(.systemGray)
    }
    
    func setInvalid() {
        self.iconName = "exclamationmark.circle.fill"
        self.iconColor = Color(.systemRed)
    }
    
    func setValid() {
        self.iconName = "checkmark.circle.fill"
        self.iconColor = Color(.systemGreen)
        
    }
    
    func validate() {
        setLoading()
        
        JiraClient().getMyself() { myself in
            if myself != nil {
                self.setValid()
            }
            else {
                self.setInvalid()
            }
            
        }
    }
}
