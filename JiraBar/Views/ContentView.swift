//
//  ContentView.swift
//  jiraBar
//
//  Created by Pavel Makhov on 2023-09-13.
//

import SwiftUI
import Defaults

struct ContentView: View {
    
    var appDelegate: AppDelegate
    @StateObject var viewModel: ViewModel
    @Default(.activeTabs) var activeTabs
    @Default(.selectedTab) var selectedTab
    
    @Environment(\.openURL) var openURL
    
    @Default(.jiraHost) var jiraHost
    
    @Default(.jqlTab1) var jqlTab1
    @Default(.jqlTab2) var jqlTab2
    @Default(.jqlTab3) var jqlTab3
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            
            HStack{
                PickerPlus(
                    activeTabs,
                    selection: selectedTab
                ) { item in
                    Button{
                        withAnimation(.easeInOut(duration: 0.150)) {
                            selectedTab = item
                        }
                    } label: {
                        PickerTabView(tabType: item, viewModel: viewModel)
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .focusable(false)
                    .keyboardShortcut(KeyboardShortcut(["1", "2", "3"][activeTabs.firstIndex(of: item) ?? 0]))
                }
                .pickerBackgroundColor(Color(nsColor: NSColor.textBackgroundColor))
                .cornerRadius(8)
                .borderColor(.gray)
                .padding(2)
                
                Menu {
                    Button(action: {
                        appDelegate.openPrefecencesWindow()
                    }) {
                        Label("Preferences...", systemImage: "books.vertical")
                    }
                    
                    Button(action: {
                        appDelegate.openAboutWindow()
                    } ) {
                        Label("About JiraBar", systemImage: "books.vertical")
                    }
                    Button(action: {
                        appDelegate.quit()
                    }) {
                        Label("Quit", systemImage: "books.vertical")
                    }
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(.secondary)
                }
                .menuStyle(.borderlessButton)
                .frame(width: 20, height: 16)
                .padding(8)
                .padding(.trailing, 2)
                .menuIndicator(.hidden)
                .contentShape(Rectangle())
            }
            
            Divider()
            
            if let error = viewModel.error {
                Label(title: {
                    Text(error)
                        .foregroundColor(.secondary)
                        .frame(maxHeight: .infinity, alignment: .center)
                },
                      icon: {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.background, .yellow)
                })
                .padding(20)
            } else {
                List {                        
                    let b = viewModel.getIssueForSelectedTab()
                    ForEach(b, id:\.key) { issue in
                        IssueView(viewModel: viewModel, issue: issue)
                    }
                }
                .listStyle(.plain)
            }
            
            HStack {
                Spacer()
                Button{
                    openURL(URL(string: link)!)
                } label: {
                    HoverableLabelView(iconName: "arrow.up.forward.app")
                }
                .buttonStyle(.borderless)
                .help("Open search results")
                
                Button{
                    openURL(URL(string: jiraHost + "/secure/CreateIssue!default.jspa")!)
                } label: {
                    HoverableLabelView(iconName: "plus.square")
                }
                .buttonStyle(.borderless)
                .help("Create new issue")
            }
            .padding([.top, .bottom],4)
            .padding([.leading, .trailing], 8)
        }
        .onAppear {
            if activeTabs.contains(.first) { viewModel.getIssuesForFirstTab() }
            if activeTabs.contains(.second) { viewModel.getIssuesForSecondTab() }
            if activeTabs.contains(.third) { viewModel.getIssuesForThirdTab() }
        }
        .onChange(of: viewModel.popupIsShown) { _ in
            if activeTabs.contains(.first) { viewModel.getIssuesForFirstTab() }
            if activeTabs.contains(.second) { viewModel.getIssuesForSecondTab() }
            if activeTabs.contains(.third) { viewModel.getIssuesForThirdTab() }
        }
    }
    
    private var link: String {
        switch selectedTab {
        case .first:
            return jiraHost + "/issues/?jql=" + (jqlTab1).addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        case .second:
            return jiraHost + "/issues/?jql=" + (jqlTab2).addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        case .third:
            return jiraHost + "/issues/?jql=" +  (jqlTab3).addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(viewModel: ViewModel(), appDelegate: AppDelegate())
//    }
//}
