import Combine

@MainActor
final class NotificationViewModel: ObservableObject {
    private let notificationService: NotificationService

    init(notificationService: NotificationService) {
        self.notificationService = notificationService
    }

    func notify(title:String, message:String) {
        notificationService.postNotification(
            title:title,
            message: message
        )
    }
}
