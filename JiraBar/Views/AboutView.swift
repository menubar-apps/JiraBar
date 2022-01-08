import SwiftUI

struct AboutView: View {
    let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String

    var body: some View {
        VStack {
            Text("JiraBar").font(.title)
            Text("by Pavel Makhov").font(.caption)
            Text("version " + currentVersion).font(.footnote)
            Divider()
            Link("JiraBar on GitHub", destination: URL(string: "https://github.com/menubar-apps-for-devs/JiraBar")!)
        }.padding()
    }
}

