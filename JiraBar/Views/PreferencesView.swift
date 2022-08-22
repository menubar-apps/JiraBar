import SwiftUI
import Defaults

struct PreferencesView: View {
    @Default(.jiraUsername) var jiraUsername
    @Default(.jiraToken) var jiraToken
    @Default(.jiraHost) var jiraHost
    @Default(.jql) var jql
    @Default(.refreshRate) var refreshRate
    @Default(.maxResults) var maxResults
    
    var body: some View {
        
        Spacer()
        HStack {
                Spacer()
                Form {
                    TextField("Jira Username:", text: $jiraUsername)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    SecureField("Jira Token:", text: $jiraToken)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Text("Jira Cloud: generate an [API Token](https://id.atlassian.com/manage/api-tokens)")
                        .font(.footnote)
                    Text("Jira Server: use your password as a token")
                        .font(.footnote)
                    
                    Divider()
                    
                    TextField("Jira Host:", text: $jiraHost)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("JQL query:", text: $jql)
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
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
