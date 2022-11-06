import Cocoa
import SwiftUI
import Foundation
import Defaults

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @Default(.refreshRate) var refreshRate
    @Default(.jql) var jql
    @Default(.jiraHost) var jiraHost

    let jiraClient = JiraClient()
    
    var statusBarItem: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let menu: NSMenu = NSMenu()

    var timer: Timer? = nil
    
    var preferencesWindow: NSWindow!
    var aboutWindow: NSWindow!
    
    var unknownPersonAvatar: NSImage!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.windowClosed), name: NSWindow.willCloseNotification, object: nil)
        guard let statusButton = statusBarItem.button else { return }
        let icon = NSImage(named: "mark-gradient-white-jira")
        icon?.size = NSSize(width: 18, height: 18)
        icon?.isTemplate = true
        statusButton.image = icon
        statusButton.imagePosition = NSControl.ImagePosition.imageLeft
        
        statusBarItem.menu = menu
        
        timer = Timer.scheduledTimer(
            timeInterval: Double(refreshRate * 60),
            target: self,
            selector: #selector(refreshMenu),
            userInfo: nil,
            repeats: true
        )
        timer?.fire()
        RunLoop.main.add(timer!, forMode: .common)
        
        NSApp.setActivationPolicy(.accessory)
        
        let config = NSImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        unknownPersonAvatar = NSImage(systemSymbolName: "person.crop.circle.badge.questionmark", accessibilityDescription: nil)!.withSymbolConfiguration(config)!

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

}

extension AppDelegate {
    @objc
    func refreshMenu() {
        NSLog("Refreshing menu")
        self.menu.removeAllItems()
        
        jiraClient.getIssuesByJql() { resp in
            if let issues = resp.issues {
                self.statusBarItem.button?.title = String(issues.count)
                let issuesByStatus = Dictionary(grouping: issues) { $0.fields.status.name }
                    .sorted { $0.key < $1.key }

                for (status, issuess) in issuesByStatus {
                    self.menu.addItem(.separator())
                    self.menu.addItem(withTitle: status, action: nil, keyEquivalent: "")
                
                    for issue in issuess {
                        let issueItem = NSMenuItem(title: "", action: #selector(self.openLink), keyEquivalent: "")
                        
                        let issueItemTitle = NSMutableAttributedString(string: "")
                            .appendString(string: issue.fields.summary.trunc(length: 50))
                            .appendNewLine()
                            .appendIcon(iconName: "hash", color: NSColor.gray)
                            .appendString(string: issue.key, color: "#888888")
                            .appendSeparator()
                            .appendIcon(iconName: "project", color: NSColor.gray)
                            .appendString(string: issue.fields.assignee?.displayName ?? "Unassign", color: "#888888")
                            .appendSeparator()
                            .appendString(string: issue.fields.issuetype.name, color: "#888888")

                        
                        issueItem.attributedTitle = issueItemTitle
                        if issue.fields.summary.count > 50 {
                            issueItem.toolTip = issue.fields.summary
                        }
                        issueItem.representedObject = URL(string: "\(self.jiraHost)/browse/\(issue.key)")
                                                
                        self.jiraClient.getTransitionsByIssueKey(issueKey: issue.key) { transitions in
                            if !transitions.isEmpty {
                                let transitionsMenu = NSMenu()
                                issueItem.submenu = transitionsMenu

                                for transition in transitions {
                                    let transitionItem = NSMenuItem(title: transition.name, action: #selector(self.transitionIssue), keyEquivalent: "")
                                    transitionItem.representedObject = [issue.key, transition.id]
                                    transitionsMenu.addItem(transitionItem)
                                }
                            }
                        }
                        
                        self.menu.addItem(issueItem)
                    }
                }
            }
            else {
                self.statusBarItem.button?.title = String(0)
            }
            
            self.menu.addItem(.separator())
            let refreshItem = NSMenuItem(title: "Refresh", action: #selector(self.refreshMenu), keyEquivalent: "")
            refreshItem.image = NSImage(systemSymbolName: "arrow.clockwise", accessibilityDescription: nil)
            self.menu.addItem(refreshItem)
            
            let openSearchResultsItem = NSMenuItem(title: "Open Search results", action: #selector(self.openSearchResults), keyEquivalent: "")
            openSearchResultsItem.image = NSImage(systemSymbolName: "magnifyingglass", accessibilityDescription: nil)
            self.menu.addItem(openSearchResultsItem)
            
            let createNewItem = NSMenuItem(title: "Create issue", action: #selector(self.openCreateNewIssue), keyEquivalent: "")
            createNewItem.image = NSImage(systemSymbolName: "plus", accessibilityDescription: nil)
            self.menu.addItem(createNewItem)

            self.menu.addItem(.separator())
            self.menu.addItem(withTitle: "Preferences...", action: #selector(self.openPrefecencesWindow), keyEquivalent: "")
            self.menu.addItem(withTitle: "About JiraBar", action: #selector(self.openAboutWindow), keyEquivalent: "")
            self.menu.addItem(withTitle: "Quit", action: #selector(self.quit), keyEquivalent: "")
        }
    }
    
    
    @objc
    func transitionIssue(_ sender: NSMenuItem) {
        let issueKeyAndTo = sender.representedObject as! [String]
        
        jiraClient.transitionIssue(issueKey: issueKeyAndTo[0], to: issueKeyAndTo[1]) {
            print("refreshing")
            self.refreshMenu()
        }
    }

    @objc
    func openSearchResults() {
        let encodedPath = jql.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        NSWorkspace.shared.open(URL(string: jiraHost + "/issues?jql=" + encodedPath!)!)
    }
    
    @objc
    func openCreateNewIssue() {
        NSWorkspace.shared.open(URL(string: jiraHost + "/secure/CreateIssue!default.jspa")!)
    }
    
    @objc
    func openLink(_ sender: NSMenuItem) {
        NSWorkspace.shared.open(sender.representedObject as! URL)
    }
    
    @objc
    func openPrefecencesWindow(_: NSStatusBarButton?) {
        NSLog("Open preferences window")
        let contentView = PreferencesView()
        if preferencesWindow != nil {
            preferencesWindow.close()
        }
        preferencesWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 100, height: 100),
            styleMask: [.closable, .titled],
            backing: .buffered,
            defer: false
        )
        
        preferencesWindow.title = "Preferences"
        preferencesWindow.contentView = NSHostingView(rootView: contentView)
        preferencesWindow.makeKeyAndOrderFront(nil)
        preferencesWindow.styleMask.remove(.resizable)

        // allow the preference window can be focused automatically when opened
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        let controller = NSWindowController(window: preferencesWindow)
        controller.showWindow(self)
        
        preferencesWindow.center()
        preferencesWindow.orderFrontRegardless()
    }
    
    @objc
    func openAboutWindow(_: NSStatusBarButton?) {
        NSLog("Open about window")
        let contentView = AboutView()
        if aboutWindow != nil {
            aboutWindow.close()
        }
        aboutWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 240, height: 340),
            styleMask: [.closable, .titled],
            backing: .buffered,
            defer: false
        )
        
        aboutWindow.title = "About"
        aboutWindow.contentView = NSHostingView(rootView: contentView)
        aboutWindow.makeKeyAndOrderFront(nil)
        aboutWindow.styleMask.remove(.resizable)

        // allow the preference window can be focused automatically when opened
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        let controller = NSWindowController(window: aboutWindow)
        controller.showWindow(self)
        
        aboutWindow.center()
        aboutWindow.orderFrontRegardless()
    }
    
    @objc
    func quit(_: NSStatusBarButton) {
        NSLog("User click Quit")
        NSApplication.shared.terminate(self)
    }
    
    @objc
    func windowClosed(notification: NSNotification) {
        let window = notification.object as? NSWindow
        if let windowTitle = window?.title {
            if (windowTitle == "Preferences") {
                timer?.invalidate()
                timer = Timer.scheduledTimer(
                    timeInterval: Double(refreshRate * 60),
                    target: self,
                    selector: #selector(refreshMenu),
                    userInfo: nil,
                    repeats: true
                )
                timer?.fire()
            }
        }
    }
}

