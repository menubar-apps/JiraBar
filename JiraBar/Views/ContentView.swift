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
    
//    @State private var searchTerm: String = ""

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
//                    let a = viewModel.getIssueForSelectedTab()
//                    ForEach(Array(a.keys.sorted()), id: \.self) { key in
//                        Section(header: Text("\(key) \(a[key]?.count ?? 0)")) {
//                            ForEach(a[key] ?? [], id: \.self) { issue in
//                                if searchTerm == "" || issue.fields.summary.contains(searchTerm) {
//                                    IssueView(viewModel: viewModel, issue: issue)
//                                        .listRowSeparator(.visible)
//                                }
//                            }
//                        }.collapsible(true)
//                    }
                }
                .listStyle(.plain)
            }

            HStack {
                HStack {
//                    Button{
//                        appDelegate.openPrefecencesWindow()
//                    } label: {
//                        HoverableLabelView(iconName: "gear")
//                    }
//                    .buttonStyle(.borderless)

                    Button{
                        openURL(URL(string: link)!)
                    } label: {
                        HoverableLabelView(iconName: "arrow.up.forward.app")
                    }
                    .buttonStyle(.borderless)

                    Button{ appDelegate.openCreateNewIssue() } label: {
                        HoverableLabelView(iconName: "plus.square")
                    }
                    .buttonStyle(.borderless)
                }

//               TextField("Search...", text: $searchTerm)
//                    .padding(.vertical, 8)
//                    .padding(.horizontal, 8)
//                    .padding(.leading, 22)
//                    .cornerRadius(8)
//                    .textFieldStyle(.roundedBorder)
//                    .overlay(
//                        Image(systemName: "plus.circle.fill")
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .foregroundColor(.gray)
//                            .padding(.leading, 8)
//                    ).onSubmit {
//                        self.todos.append(Todo(text: newTodo))
//                        newTodo = ""
//                    }
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
            return jiraHost + "/browse/" + (jqlTab1).addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        case .second:
            return jiraHost + "/browse/" + (jqlTab2).addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        case .third:
            return jiraHost + "/browse/" +  (jqlTab3).addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(viewModel: ViewModel(), appDelegate: AppDelegate())
//    }
//}
