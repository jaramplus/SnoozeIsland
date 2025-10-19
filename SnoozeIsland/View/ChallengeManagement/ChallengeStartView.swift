//
//  StartHabbitView.swift
//  SnoozeIsland
//
//  Created by jose Yun on 1/31/25.
//

import SwiftUI

struct ChallengeStartView: View {
    @EnvironmentObject var snoozeViewModel: SnoozeIslandViewModel
    @State var sleepTime: Date = Date()
    @State var wakeTime: Date = Date()
    @Binding var startMenu: Bool
    @State var control = true
    
    var body: some View {
        if control {
            ChallengeSetupView(startMenu: $startMenu, sleepTime: $sleepTime, wakeTime: $wakeTime, control: $control)
        } else {
            ChallengeIntroView(startMenu: $startMenu, sleepTime: $sleepTime, wakeTime: $wakeTime, control: $control)
        }
    }
}

#Preview {
    @Previewable @StateObject var snoozeViewModel = SnoozeIslandViewModel.snoozeViewModel
    
    HomeView()
        .environmentObject(snoozeViewModel)
}
