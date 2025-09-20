import SwiftUI
import Defaults

struct PreferencesView: View {
    @Default(.jiraUsername) var jiraUsername
    @Default(.orgName) var orgName
    @Default(.jql) var jql
    @Default(.refreshRate) var refreshRate
    @Default(.maxResults) var maxResults
    
    @FromKeychain(.jiraToken) var jiraToken
    
    @StateObject private var jiraTokenValidator = JiraTokenValidator()
    
    @State private var orgNameState: String = ""

    var body: some View {
        
        Spacer()
        HStack {
            Spacer()
            Form {
                TextField("Username:", text: $jiraUsername)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                LabeledContent("Org Name:") {
                    HStack {
                        Text("https://")
                            .foregroundColor(.secondary)
                        
                        DebounceTextField(label: "", value: $orgNameState) { value in
                            orgNameState = orgNameState.trimmingCharacters(in: .whitespaces)
                            orgName = orgNameState
                            jiraTokenValidator.validate()
                        }
                        .labelsHidden()
                        .frame(width: 150)
                        .onAppear {
                            orgNameState = orgName
                        }
                        
                        Text(".atlassian.net")
                            .foregroundColor(.secondary)
                    }
                }
                
                SecureField("Token:", text: $jiraToken)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .overlay(
                        Image(systemName: jiraTokenValidator.iconName).foregroundColor(jiraTokenValidator.iconColor)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 8)
                    )
                    .onChange(of: jiraToken) { _ in
                        jiraTokenValidator.validate()
                    }
                
                Text("Jira Cloud: generate an [API Token](https://id.atlassian.com/manage/api-tokens)")
                    .font(.footnote)
               
                Divider()
                
                TextField("JQL Query:", text: $jql)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Text("Use advanced search in Jira to create a JQL query and then paste it here")
                    .font(.footnote)
                TextField("Max Results:", text: $maxResults)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 120)
                Picker("Refresh Rate:", selection: $refreshRate) {
                    Text("1 minute").tag(1)
                    Text("5 minutes").tag(5)
                    Text("10 minutes").tag(10)
                    Text("15 minutes").tag(15)
                    Text("30 minutes").tag(30)
                }
                .frame(width: 200)
            }
            Spacer()
            
        }
        .padding()
        .frame(width: 500)
        .onAppear() {
            jiraTokenValidator.validate()
        }
    }
}

#Preview {
    PreferencesView()
}
