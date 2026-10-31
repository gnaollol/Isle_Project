import SwiftUI

@main
struct IslandApp: App {
    
    
    
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    
    var body: some Scene {
        MenuBarExtra(
            "Cozy", systemImage: "star"){
                StatusMenu()
        }
        
        Settings { EmptyView() }
    
    }
}





