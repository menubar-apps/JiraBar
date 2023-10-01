//
//  TabsPrefView.swift
//  jiraBar
//
//  Created by Pavel Makhov on 2023-09-21.
//

import SwiftUI
import Defaults

struct TabsPrefView: View {
    @Default(.activeTabs) var activeTabs

    @Default(.enableTab1) var enableTab1
    @Default(.nameTab1) var nameTab1
    @Default(.jqlTab1) var jqlTab1

    @Default(.enableTab2) var enableTab2
    @Default(.nameTab2) var nameTab2
    @Default(.jqlTab2) var jqlTab2

    @Default(.enableTab3) var enableTab3
    @Default(.nameTab3) var nameTab3
    @Default(.jqlTab3) var jqlTab3

    var body: some View {
        Form {
            VStack(alignment: .leading) {
                Toggle(isOn: Binding<Bool>(get: { activeTabs.contains(.first) },
                                           set: { if $0 { self.activeTabs.append(.first) } else { if self.activeTabs.count > 1 { self.activeTabs.removeAll(where: {$0 == .first}) }}})) {
                    Text("Enable first tab")
                }
                                           .toggleStyle(.checkbox)
                VStack {
                    TextField("Tab Name:", text: $nameTab1)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                    TextField("JQL Query:", text: $jqlTab1, axis: .vertical)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    LabeledContent("JQL Query:") {
                        TextEditor(text: $jqlTab1)
                            .alignmentGuide(.firstTextBaseline) { $0[.firstTextBaseline] + 5 }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(height: 50)
                    }
                }
                .padding(.leading, 16)
                .disabled(!activeTabs.contains(.first))
                
                Divider()
                
                Toggle(isOn: Binding<Bool>(get: { activeTabs.contains(.second) },
                                           set: { if $0 { self.activeTabs.append(.second) } else { if self.activeTabs.count > 1 { self.activeTabs.removeAll(where: {$0 == .second}) }}})) {
                    Text("Enable second tab")
                }
                                           .toggleStyle(.checkbox)
                Form {
                    TextField("Tab Name:", text: $nameTab2)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                    TextField("JQL Query:", text: $jqlTab2)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
//                    Form {
//                        TextField("JQL Query", text: $jqlTab2)
                        LabeledContent("JQL Query:") {
                            TextEditor(text: $jqlTab2)
                                .alignmentGuide(.firstTextBaseline) { $0[.firstTextBaseline] + 5 }
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(height: 50)

                        }
//                    }
                }
                .padding(.leading, 16)
                .disabled(!activeTabs.contains(.second))
                
                Divider()
                
                Toggle(isOn: Binding<Bool>(get: { activeTabs.contains(.third) },
                                           set: { if $0 { self.activeTabs.append(.third) } else { if self.activeTabs.count > 1 { self.activeTabs.removeAll(where: {$0 == .third}) }}})) {
                    Text("Enable third tab")
                }
                .toggleStyle(.checkbox)
                
                Form {
                    TextField("Tab Name:", text: $nameTab3)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                    TextField("JQL Query:", text: $jqlTab3)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    LabeledContent("JQL Query:") {
                        TextEditor(text: $jqlTab3)
                            .alignmentGuide(.firstTextBaseline) { $0[.firstTextBaseline] + 5 }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(height: 50)
                            .disabled(activeTabs.contains(.second))

                    }

                }
                .padding(.leading, 16)
                .disabled(!activeTabs.contains(.third))
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .tabItem{Text("Tabs")
            
        }
    }
}

struct TabsPrefView_Previews: PreviewProvider {
    static var previews: some View {
        TabsPrefView()
            .frame(width: 500)
    }
}
