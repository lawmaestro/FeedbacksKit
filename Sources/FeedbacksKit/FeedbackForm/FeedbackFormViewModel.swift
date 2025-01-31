import Foundation
import UIKit
import Combine

class FeedbackFormViewModel: ObservableObject {
    let haptics = UINotificationFeedbackGenerator()

    enum FeedbackFormResult {
        case success, failure

        var message: String {
            switch self {
            case .success: return "_feedback_successfully_sent".localized
            case .failure: return "_oups_error_occured".localized
            }
        }
    }

    private let service: SubmitService

    @Published var email = ""
    @Published var message = ""

    @Published var isLoading = false
    @Published var result: FeedbackFormResult?

    init(service: SubmitService) {
        self.service = service
        haptics.prepare()
    }

    var isSubmitDisabled: Bool {
        message.isEmpty
    }

    var isFormDisabled: Bool {
        isLoading
    }

    func submit() {
        isLoading = true

        Task {
            do {
                try await service.submit(formData: makeFormData())
                await handleSuccess()
            } catch {
                await handleFailure()
            }
        }
    }

    private func makeFormData() -> FeedbackFormData {
        FeedbackFormData(
            email: email,
            message: message
        )
    }

    @MainActor
    private func handleSuccess() {
        haptics.notificationOccurred(.success)
        isLoading = false
        result = .success
        email = ""
        message = ""
    }

    @MainActor
    private func handleFailure() {
        haptics.notificationOccurred(.error)
        isLoading = false
        result = .failure
    }
}
