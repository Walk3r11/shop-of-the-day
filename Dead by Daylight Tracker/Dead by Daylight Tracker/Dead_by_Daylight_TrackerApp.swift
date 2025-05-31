import SwiftUI
import Clerk

@main
struct Dead_by_Daylight_TrackerApp: App {
    @State private var clerk = Clerk.shared
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if clerk.isLoaded {
                    ContentView()
                } else {
                    ProgressView("Loading...")
                }
            }
            .environment(clerk) // ✅ this injects Clerk into your whole app
            .task {
                // ⚠️ Replace with your actual publishable key if needed
                clerk.configure(publishableKey: "pk_test_d29uZHJvdXMtaG9uZXliZWUtNzAuY2xlcmsuYWNjb3VudHMuZGV2JA")
                try? await clerk.load()
            }
        }
    }
}
