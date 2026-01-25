import UserNotifications

final class NotificationService {
    
    func postNotification(title: String, message: String) {
        
        Task {
        
            let granted = await requestPermissionIfNeeded()
            
            guard granted else {
                return
            }

            let settings = await UNUserNotificationCenter.current().notificationSettings()
            
            guard settings.alertSetting == .enabled else {
                return
            }

            let content = UNMutableNotificationContent()
            
            content.title = title
            
            content.body = message

            let request = UNNotificationRequest(
            
                identifier: UUID().uuidString,
                
                content: content,
                
                trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            
            )

            try? await UNUserNotificationCenter.current().add(request)
        }
    }

    private func requestPermissionIfNeeded() async -> Bool {
        let center = UNUserNotificationCenter.current()
        
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        @unknown default:
            return false
        }
    }
}
