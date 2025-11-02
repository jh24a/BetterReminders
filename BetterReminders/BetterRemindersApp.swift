//
//  BetterRemindersApp.swift
//  BetterReminders
//
//  Created by Jose H on 8/15/25.
//

import SwiftUI
import UserNotifications
import AppKit

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show banner + sound even when app is active
        completionHandler([.banner, .sound])
    }
}



@main
struct BetterRemindersApp: App {
    
    @State private var notificationDelegate = NotificationDelegate()
    @State private var customMessage: String = ""
    @State private var selectedInterval: Int = 30 // minutes
    @State private var repeatContinuously: Bool = false

    init() {
        let center = UNUserNotificationCenter.current()
        center.delegate = notificationDelegate
        registerNotificationCategories()
        requestNotificationAuthorization()
    }
    
    var body: some Scene {
        MenuBarExtra("BetterReminders", systemImage: "asterisk") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Create Reminder")
                    .font(.headline)
                
                TextField("Reminder purpose (optional)", text: $customMessage)
                    .textFieldStyle(.plain)
                    .frame(minWidth: 260) // ensure visible width
                
                Picker("Interval", selection: $selectedInterval) {
                    Text("10 min").tag(10)
                    Text("15 min").tag(15)
                    Text("30 min").tag(30)
                    Text("60 min").tag(60)
                }
                .pickerStyle(.menu)
                
                Toggle("Repeat continuously", isOn: $repeatContinuously)
                
                HStack {
                    Button("Create") {
                        let seconds = TimeInterval(selectedInterval * 60)
                        scheduleNextReminder(in: seconds, message: customMessage)
                    }
                    Button("Test Now") {
                        sendNotificationNow()
                    }
                }
                
                Divider()
                
                Button("Quit") { NSApplication.shared.terminate(nil) }
            }
            .padding(14)
            .frame(minWidth: 300) 
        }.menuBarExtraStyle(.window)
    }
    
    func registerNotificationCategories(){
        UNUserNotificationCenter.current().setNotificationCategories([])
    }
    
    func scheduleNextReminder(in seconds: TimeInterval = 1800) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "This is your 30-minute reminder!"
        content.sound = .default
        // We’ll tie in categoryIdentifier later for actions.
        // content.categoryIdentifier = "REMINDER_CATEGORY"

        // Schedule for the future; do not repeat at the trigger level.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: "com.yourcompany.betterreminders.next", content: content, trigger: trigger)

        // Remove any previous “next” request so you only ever have one pending.
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["com.yourcompany.betterreminders.next"])
        center.add(request) { error in
            if let error = error {
                print("Error scheduling next reminder: \(error)")
            } else {
                print("Next reminder scheduled in \(Int(seconds)) seconds")
            }
        }
    }
    
    func scheduleNextReminder(in seconds: TimeInterval = 1800, message: String? = nil) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = (message?.isEmpty == false) ? message! : "This is your 30-minute reminder!"
        content.sound = .default
        // We’ll tie in categoryIdentifier later for actions.
        // content.categoryIdentifier = "REMINDER_CATEGORY"
        
        // Schedule for the future; do not repeat at the trigger level.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: "com.yourcompany.betterreminders.next", content: content, trigger: trigger)

        // Remove any previous “next” request so you only ever have one pending.
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["com.yourcompany.betterreminders.next"])
        center.add(request) { error in
            if let error = error {
                print("Error scheduling next reminder: \(error)")
            } else {
                print("Next reminder scheduled in \(Int(seconds)) seconds with message: \(content.body)")
                if self.repeatContinuously {
                    // Chain schedule the next reminder after the same interval
                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                        self.scheduleNextReminder(in: seconds, message: message)
                    }
                }
            }
        }
    }
    
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    let seconds = TimeInterval(self.selectedInterval * 60)
                    self.scheduleNextReminder(in: seconds, message: self.customMessage)
                } else {
                    print("Permission not granted: \(String(describing: error))")
                }
            }
        }
    }
    
    func sendNotificationNow() {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "This is your reminder!"
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification: \(error)")
            }
        }
    }
 
}
