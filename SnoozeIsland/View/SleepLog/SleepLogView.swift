//
//  SleepLogView.swift
//  SnoozeIsland
//
//  Created by jose Yun on 1/31/25.
//

import SwiftUI
import Charts

enum LogTheme: String, CaseIterable, Identifiable {
    case week = "주", month = "달"
    var id: Self { self }
    
    func localizedString(language: Language) -> String {
        switch self {
        case .week:
            return language == .korean ? "주" : "Week"
        case .month:
            return language == .korean ? "달" : "Month"
        }
    }
}

struct SleepLogView: View {
    @EnvironmentObject var snoozeViewModel: SnoozeIslandViewModel
    @Binding var sleepLogMenu: Bool
    
    let formatter = DateFormatter()
    @State private var visibleStartDate: Date = Date().addingTimeInterval(-86400 * 5)
    @State private var visibleEndDate: Date = Date()
    
    var body: some View {
        ZStack {
            Image(snoozeViewModel.isNight ? "bkg_night" : "bkg_day")
                .resizable()
                .ignoresSafeArea()
                .scaledToFill()
            
            VStack(spacing: 0) {
                
                HStack {
                    Spacer()
                    Text(snoozeViewModel.currentLanguage == .korean ? "수면기록" : "Sleep Record")
                    Spacer()
                }
                .overlay {
                    HStack {
                        Button(action: { withAnimation {sleepLogMenu.toggle() }} ) {
                            Image(systemName: "chevron.down")
                        }
                        .padding()
                        Spacer()
                    }
                }
                .padding(.top, 36)
                .padding(.bottom, 8)
                Divider()
                
                if let sleepLogs = snoozeViewModel.sleepLogs {
                    ChartView(sleepLogs: sleepLogs, logTheme: .week)
                        .cornerRadius(8.0)
                }
                
            }
            .padding()
            .cornerRadius(8)
            .padding()
        }
        .foregroundStyle(snoozeViewModel.isNight ? .white : .black)
    }
}

#Preview {
    @Previewable @StateObject var snoozeViewModel = SnoozeIslandViewModel.snoozeViewModel
        
    SleepLogView(sleepLogMenu: .constant(false))
        .environmentObject(snoozeViewModel)
}
