//
//  LocalNotificationManager.swift
//  Bachelor Night in America
//
//  Created by TJ Carney on 9/28/20.
//  Copyright © 2020 TJ Carney. All rights reserved.
//

import Foundation
import UserNotifications

class LocalNotificationManager {
    var notifications = [LocalNotification]()
    
    func listScheduledNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notifications) in
            for notification in notifications {
                print("NOTIFICATION: \(notification)")
            }
            if notifications.count == 0 {
                print("NO NOTIFICATIONS SCHEDULED")
            }
        }
    }
    
    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted == true && error == nil {
                self.scheduleNotifications()
            }
        }
    }
    
    func schedule(status: SurvivorStatus) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization()
            case .authorized, .provisional:
                if status == .active {
                    self.scheduleNotifications()
                } else if status == .eliminated {
                    self.removeNotifications()
                }
            default:
                break
            }
        }
    }
    
    private func scheduleNotifications() {
        for notification in self.notifications {
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.body = notification.body
            content.sound = .default
            
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: notification.datetime, repeats: true)
            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { (error) in
                guard error == nil else {return}
                print("Notification Scheduled! -- ID: \(notification.id)")
            }
        }
        self.listScheduledNotifications()
    }
    
    private func removeNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        self.listScheduledNotifications()
    }
}
