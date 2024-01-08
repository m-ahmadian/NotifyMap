//
//  NotificationManager.swift
//  NotifyMap
//
//  Created by Mehrdad Behrouz Ahmadian on 2024-01-08.
//

import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            // Handle Authorization
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleArrival), name: .userDidArriveAtDestination, object: nil)
    }
    
    @objc private func handleArrival() {
        let content = UNMutableNotificationContent()
        content.title = "Arrival Alert"
        content.body = "You have arrived at your destination."
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: "arrivalNotification", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
