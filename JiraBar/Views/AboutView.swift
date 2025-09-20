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
                openURL(URL(string:"https://github.com/menubar-apps/JiraBar/issues/new?assignees=&labels=enhancement&projects=&template=feature_request.md&title=")!)
            }) {
                HStack {
                    Image(systemName: "star.fill")
                    Text("Feature Request")
                }
                .frame(width: 150)
            }
            Button(action: {
                openURL(URL(string:"https://github.com/menubar-apps/JiraBar/issues/new?assignees=&labels=bug&projects=&template=bug_report.md&title=")!)
            }) {
                HStack {
                    Image(systemName: "ladybug.fill")
                    Text("Bug Report")
                }
                .frame(width: 150)
            }

           Button(action: {
               openURL(URL(string: "https://www.buymeacoffee.com/streetturtle")!)
           }) {
               HStack {
                   Image("bmc-logo-no-background")
                       .resizable()
                       .scaledToFit()
                       .padding(.top, 2)
                   Text("Buy me a coffee")
               }
               .frame(width: 150)
           }
        }
        .padding()
    }
}

#Preview {
    AboutView()
}

