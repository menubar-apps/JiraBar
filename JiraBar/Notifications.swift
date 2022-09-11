//
//  Notifications.swift
//  jiraBar
//
//  Created by Pavel Makhov on 2022-09-06.
//

import Foundation
import UserNotifications

func sendNotification(body: String = "") {
  let content = UNMutableNotificationContent()
  content.title = "PullBar"

  if body.count > 0 {
    content.body = body
  }

  let uuidString = UUID().uuidString
  let request = UNNotificationRequest(
    identifier: uuidString,
    content: content, trigger: nil)

  let notificationCenter = UNUserNotificationCenter.current()
  notificationCenter.requestAuthorization(options: [.alert, .sound]) { _, _ in }
  notificationCenter.add(request)
}
