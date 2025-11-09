//
//  TutorialView.swift
//  SnoozeIsland
//
//  Created by jose Yun on 2/2/25.
//

import SwiftUI

struct SprintView: View {
    @EnvironmentObject var snoozeViewModel: SnoozeIslandViewModel
    var body: some View {
        VStack {
            Spacer()
            Text("단잠의 섬")
                .foregroundStyle(.white)
            Spacer()
        }
        .foregroundStyle(.darkPurple)
        .onAppear() {
            snoozeViewModel.makeUserProfile()
        }
    }
}

#Preview {
    @Previewable @StateObject var snoozeViewModel = SnoozeIslandViewModel.snoozeViewModel
    
    SprintView()
        .environmentObject(snoozeViewModel)
}
