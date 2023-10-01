import SwiftUI

struct AboutView: View {
    @Environment(\.openURL) var openURL

    let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String

    var body: some View {
        
        VStack {
            Image(nsImage: NSImage(named: "AppIcon")!)
            Text("JiraBar").font(.title)
            Text("by Pavel Makhov").font(.caption)
            Text("version " + currentVersion).font(.footnote)
            Divider()
            
            Button(action: {
                openURL(URL(string:"https://menubar-apps.github.io/#jira-bar")!)
            }) {
                HStack {
                    Image(systemName: "house.fill")
                    Text("Home Page")
                }
            }
            Button(action: {
                openURL(URL(string:"https://github.com/menubar-apps/PullBarPro/issues/new?assignees=&labels=&projects=&template=feature_request.md&title=")!)
            }) {
                HStack {
                    Image(systemName: "star.fill")
                    Text("Request a Feature")
                }
            }
            Button(action: {
                openURL(URL(string:"https://github.com/menubar-apps/PullBarPro/issues/new?assignees=&labels=&projects=&template=bug_report.md&title=")!)
            }) {
                HStack {
                    Image(systemName: "ladybug.fill")
                    Text("Report a Bug")
                }
            }
        }.padding()
    }
}

