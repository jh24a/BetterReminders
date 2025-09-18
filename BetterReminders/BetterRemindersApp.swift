//
//  BetterRemindersApp.swift
//  BetterReminders
//
//  Created by Jose H on 8/15/25.
//

import SwiftUI
import UserNotifications
import AppKit

@main
struct BetterRemindersApp: App {
    
    @State private var timer: Timer?

    init() {
        requestNotificationAuthorization()
    }

    var body: some Scene {
        
        MenuBarExtra("BetterReminders", systemImage: "asterisk"){
            Button("Quit"){
                stopBackgroundTimer()
                NSApplication.shared.terminate(nil)
            }
        }
    }
    
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                scheduleNotifications()
            } else {
                print("Permission not granted: \(String(describing: error))")
            }
        }
    }
    
    func scheduleNotifications() {
        // Send the first notification immediately
        sendNotification()
        print("sent the first notification")
        
        // Start the background timer for 30-minute intervals
        startBackgroundTimer()
        
        // Set up notification observer for app lifecycle events
        setupNotificationObserver()
    }
    
    func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            // Restart timer if it's not running when app becomes active
            if self.timer == nil {
                self.startBackgroundTimer()
            }
        }
    }
    
    func startBackgroundTimer() {
        // Cancel any existing timer
        timer?.invalidate()
        
        // Create a new timer that runs every 30 minutes (1800 seconds)
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            sendNotification()
            print("30-minute reminder sent at \(Date())")
        }
        
        // Ensure the timer continues running in the background
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
        
        print("Background timer started - will send notifications every 30 minutes")
    }
    
    func stopBackgroundTimer() {
        timer?.invalidate()
        timer = nil
        print("Background timer stopped")
    }
    
    func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "This is your 30-minute reminder!"
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString, content: content, trigger: nil)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification: \(error)")
            }
        }
    }
 
}
