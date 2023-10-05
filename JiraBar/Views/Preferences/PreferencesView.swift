import SwiftUI
import Defaults

struct PreferencesView: View {
    @Default(.username) var username
    @Default(.jiraHost) var jiraHost
    @Default(.maxResults) var maxResults
    
    @FromKeychain(.jiraToken) var jiraToken
    
    @StateObject private var jiraTokenValidator = JiraTokenValidator()
    
    var body: some View {
        
        
        TabView {
            Form {
                TextField("Username:", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Jira Host:", text: $jiraHost)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                SecureField("Jira Token:", text: $jiraToken)
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
                Text("Jira Server: use your password as a token")
                    .font(.footnote)
            }            .padding()
                .frame(maxWidth: .infinity)
                .onAppear() {
                    jiraTokenValidator.validate()
                }
                .tabItem{Text("Authentication")}
            
            TabsPrefView()
            
            Form{
                TextField("Max Results:", text: $maxResults)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 120)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .tabItem{Text("General")}
        }
        .padding()
        .frame(width: 500)
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
