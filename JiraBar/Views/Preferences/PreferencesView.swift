import SwiftUI
import Defaults
import LaunchAtLogin

struct PreferencesView: View {
    @Default(.username) var username
    @Default(.jiraHost) var jiraHost
    @Default(.maxResults) var maxResults
    
    @FromKeychain(.jiraToken) var jiraToken
    
    @StateObject private var jiraTokenValidator = JiraTokenValidator()
    @State private var selection = 3

    var body: some View {

        TabView (selection: $selection) {
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
                .tag(1)
            
            TabsPrefView()
                .tag(2)
            
            VStack (alignment: .leading){
                HStack(alignment: .center) {
                    Text("Max Number Results:").frame(width: 130, alignment: .leading)
                    TextField("", text: $maxResults)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disableAutocorrection(true)
                        .textContentType(.password)
                        .frame(width: 40)
                }
                HStack(alignment: .center) {
                    Text("Launch at login:").frame(width: 130, alignment: .leading)
                    LaunchAtLogin.Toggle{Text("")}
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .tabItem{Text("General")}
            .tag(3)
        }
        .padding()
        .frame(width: 500)
    }
}

#Preview {
    PreferencesView()
}
