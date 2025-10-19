//
//  ContentView.swift
//  SnoozeIsland
//
//  Created by jose Yun on 1/31/25.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    @EnvironmentObject var snoozeViewModel: SnoozeIslandViewModel
    
    @State private var isUserInitialized: Bool = false

    var body: some View {
           VStack {
               if isUserInitialized {
                   HomeView()
               } else {
                   TutorialView()
               }
           }
           .onChange(of: snoozeViewModel.userProfile) { newValue in
                   isUserInitialized = (newValue != nil)
           }
           .onAppear {
               isUserInitialized = (snoozeViewModel.userProfile != nil)
               print("isUserinitialized", isUserInitialized)
               requestNotificationPermission()
                   
           }
           .padding()
       }
}

#Preview {
    @Previewable @StateObject var snoozeViewModel = SnoozeIslandViewModel.snoozeViewModel
    
    ContentView()
        .environmentObject(snoozeViewModel)
}
