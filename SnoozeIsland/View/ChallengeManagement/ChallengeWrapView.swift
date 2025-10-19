//
//  ChallengeWrapView.swift
//  SnoozeIsland
//
//  Created by jose Yun on 6/8/25.
//

import SwiftUI

struct ChallengeWrapView: View {
    @EnvironmentObject var snoozeViewModel: SnoozeIslandViewModel
    @Binding var startMenu: Bool
    @State var control = true
    
    var body: some View {
        if control {
            ChallengeCurrentView(startMenu: $startMenu, control: $control)
        } else {
            ChallengeResetView(startMenu: $startMenu, control: $control)
        }
    }
}

#Preview {
    @Previewable @StateObject var snoozeViewModel = SnoozeIslandViewModel.snoozeViewModel
    
    HomeView()
        .environmentObject(snoozeViewModel)
}
