import SwiftUI
import Defaults

struct PreferencesView: View {
    @Default(.instanceType) var instanceType

    var body: some View {
        VStack(spacing: 0) {
            // Segmented toggle — the primary switch between Cloud and Server mode
            Picker("", selection: $instanceType) {
                Text("Jira Cloud").tag(JiraInstanceType.cloud)
                Text("Self-Hosted / Server").tag(JiraInstanceType.server)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top)

            Divider()
                .padding(.top, 8)

            if instanceType == .cloud {
                CloudPreferencesView()
            } else {
                ServerPreferencesView()
            }
        }
        .frame(width: 500)
    }
}

// MARK: - Cloud

private struct CloudPreferencesView: View {
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
                TextField("Email:", text: $jiraUsername)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                LabeledContent("Org Name:") {
                    HStack {
                        Text("https://")
                            .foregroundColor(.secondary)

                        DebounceTextField(label: "", value: $orgNameState) { _ in
                            orgNameState = orgNameState.trimmingCharacters(in: .whitespaces)
                            orgName = orgNameState
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

                LabeledContent("API Token:") {
                    HStack {
                        SecureField("", text: $jiraToken)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Button("Test") {
                            jiraTokenValidator.validate()
                        }

                        Image(systemName: jiraTokenValidator.iconName)
                            .foregroundColor(jiraTokenValidator.iconColor)
                    }
                }

                Text("Generate an [API Token](https://id.atlassian.com/manage/api-tokens) in your Atlassian account settings.")
                    .font(.footnote)

                Divider()

                QuerySection(jql: $jql, maxResults: $maxResults, refreshRate: $refreshRate)
            }
            Spacer()
        }
        .padding()
    }
}

// MARK: - Server

private struct ServerPreferencesView: View {
    @Default(.jiraServerUsername) var jiraUsername
    @Default(.jiraHost) var jiraHost
    @Default(.serverAuthType) var serverAuthType
    @Default(.jql) var jql
    @Default(.refreshRate) var refreshRate
    @Default(.maxResults) var maxResults

    @FromKeychain(.jiraServerToken) var jiraToken

    @StateObject private var jiraTokenValidator = JiraTokenValidator()
    @State private var jiraHostState: String = ""

    var body: some View {
        Spacer()
        HStack {
            Spacer()
            Form {
                LabeledContent("Jira URL:") {
                    DebounceTextField(label: "", value: $jiraHostState) { _ in
                        jiraHostState = jiraHostState.trimmingCharacters(in: .whitespaces)
                        jiraHost = jiraHostState
                    }
                    .labelsHidden()
                    .frame(width: 280)
                    .onAppear {
                        jiraHostState = jiraHost
                    }
                }

                Picker("Auth Type:", selection: $serverAuthType) {
                    Text("Personal Access Token").tag(JiraServerAuthType.pat)
                    Text("Username & Password").tag(JiraServerAuthType.basic)
                }
                .frame(width: 300)

                if serverAuthType == .basic {
                    TextField("Username:", text: $jiraUsername)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                LabeledContent(serverAuthType == .pat ? "Token:" : "Password:") {
                    HStack {
                        SecureField("", text: $jiraToken)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Button("Test") {
                            jiraTokenValidator.validate()
                        }

                        Image(systemName: jiraTokenValidator.iconName)
                            .foregroundColor(jiraTokenValidator.iconColor)
                    }
                }

                if serverAuthType == .pat {
                    Text("Generate a Personal Access Token in your Jira profile settings. Available on Jira Server 8.14+ and Data Center.")
                        .font(.footnote)
                } else {
                    Text("Basic authentication using your Jira username and password. For older Jira Server instances.")
                        .font(.footnote)
                }

                Divider()

                QuerySection(jql: $jql, maxResults: $maxResults, refreshRate: $refreshRate)
            }
            Spacer()
        }
        .padding()
    }
}

// MARK: - Shared query/poll section

private struct QuerySection: View {
    @Binding var jql: String
    @Binding var maxResults: String
    @Binding var refreshRate: Int

    var body: some View {
        TextField("JQL Query:", text: $jql)
            .textFieldStyle(RoundedBorderTextFieldStyle())
        Text("Use advanced search in Jira to create a JQL query and then paste it here.")
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
}

#Preview {
    PreferencesView()
}
