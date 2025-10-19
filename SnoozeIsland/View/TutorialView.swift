//
//  TutorialView.swift
//  SnoozeIsland
//
//  Created by jose Yun on 2/2/25.
//

import SwiftUI

struct TutorialView: View {
    @EnvironmentObject var snoozeViewModel: SnoozeIslandViewModel
    var body: some View {
        VStack {
            Text("단잠의 섬")
            Button(action: {
                snoozeViewModel.makeUserProfile()
            }) {
                Text("시작하기")
            }
        }
    }
}

#Preview {
    @Previewable @StateObject var snoozeViewModel = SnoozeIslandViewModel.snoozeViewModel
    
    TutorialView()
        .environmentObject(snoozeViewModel)
}
