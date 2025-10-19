//
//  HomeView.swift
//  SnoozeIsland
//
//  Created by jose Yun on 1/31/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var snoozeViewModel: SnoozeIslandViewModel
    @State var startMenu = false
    @State var recordMenu = false
    @State var sleepLogMenu = false
    @State var setupMenu = false
    @State var warningAlert = false
    @State var hasRecordAlert = false
    
    @State private var currentTime: String = ""
    
    var body: some View {
        ZStack {
            backgroundView
            mainContentView
            overlayViews
        }
    }
    
    // MARK: - Background View
    private var backgroundView: some View {
        Image(snoozeViewModel.isNight ? "bkg_night" : "bkg_day")
            .resizable()
            .ignoresSafeArea()
            .scaledToFill()
            .overlay {
                islandOverlay
            }
    }
    
    private var islandOverlay: some View {
        IslandGridView()
            .padding()
            .overlay {
                gifOverlay
            }
    }
    
    private var gifOverlay: some View {
        Group {
            if snoozeViewModel.isNight {
                GIFView(gifName: "danzam-night")
                    .offset(y: -100)
                    .scaleEffect(0.2)
            } else {
                dayGifView
            }
        }
    }
    
    private var dayGifView: some View {
        Group {
            if snoozeViewModel.lastSuccess > 0 {
                GIFView(gifName: "dazam-pleased")
                    .offset(y: -100)
                    .scaleEffect(0.4)
            } else if snoozeViewModel.lastSuccess == 0 {
                GIFView(gifName: "danzam-normal")
                    .offset(y: -200)
                    .scaleEffect(0.2)
            } else {
                GIFView(gifName: "danzam-tired")
                    .offset(y: -200)
                    .scaleEffect(0.1)
            }
        }
    }
    
    // MARK: - Main Content View
    private var mainContentView: some View {
        VStack {
            topSection
            Spacer()
            bottomButtons
        }
    }
    
    private var topSection: some View {
        HStack {
            sunMoonButton
            Spacer()
        }
    }
    
    private var sunMoonButton: some View {
        Image(snoozeViewModel.isNight ? "moon" : "sun")
            .onTapGesture {
                handleSunMoonTap()
            }
            .padding(.horizontal)
    }
    
    private var bottomButtons: some View {
        HStack(spacing: 30) {
            startButton
            recordButton
            sleepLogButton
            setupButton
        }
        .padding(.bottom, 56)
        .padding(.horizontal, 16)
    }
    
    private var startButton: some View {
        Button(action: {
            withAnimation {
                startMenu.toggle()
            }
        }) {
            if snoozeViewModel.onProcess {
                Image(snoozeViewModel.isNight ? "button1-1x" : "button1x")
            } else {
                Image(snoozeViewModel.isNight ? "button1-1" : "button1")
            }
        }
    }
    
    private var recordButton: some View {
        Button(action: { recordMenu.toggle() }) {
            Image(snoozeViewModel.isNight ? "button2-1" : "button2")
        }
        .fullScreenCover(isPresented: $recordMenu) {
            ChallengeRecordView(recordMenu: $recordMenu)
        }
    }
    
    private var sleepLogButton: some View {
        Button(action: { sleepLogMenu.toggle() }) {
            Image(snoozeViewModel.isNight ? "button3-1" : "button3")
        }
        .fullScreenCover(isPresented: $sleepLogMenu) {
            SleepLogView(sleepLogMenu: $sleepLogMenu)
        }
    }
    
    private var setupButton: some View {
        Button(action: {
            withAnimation {
                setupMenu.toggle()
            }
        }) {
            Image(snoozeViewModel.isNight ? "button4-1" : "button4")
        }
    }
    
    // MARK: - Overlay Views
    private var overlayViews: some View {
        Group {
            challengeOverlay
            setupOverlay
            warningAlertOverlay
            hasRecordAlertOverlay
        }
    }
    
    private var challengeOverlay: some View {
        VStack {
            Spacer()
            challengeView
                .padding()
                .mask {
                    RoundedRectangle(cornerRadius: 32)
                        .padding()
                }
                .offset(y: startMenu ? 0 : 1300)
        }
    }
    
    private var challengeView: some View {
        Group {
            if snoozeViewModel.onProcess {
                ChallengeWrapView(startMenu: $startMenu)
            } else {
                ChallengeStartView(startMenu: $startMenu)
            }
        }
    }
    
    private var setupOverlay: some View {
        VStack {
            Spacer()
            SetupView(snoozeViewModel: snoozeViewModel, setupMenu: $setupMenu)
                .padding()
                .mask {
                    RoundedRectangle(cornerRadius: 32)
                        .padding()
                }
                .offset(y: setupMenu ? 0 : 1300)
        }
    }
    
    private var warningAlertOverlay: some View {
        WarningAlertView(warningAlert: $warningAlert)
            .padding()
            .mask {
                RoundedRectangle(cornerRadius: 32)
                    .padding()
            }
            .offset(y: warningAlert ? 0 : 1300)
    }
    
    private var hasRecordAlertOverlay: some View {
        HasRecordAlertView(hasRecordAlert: $hasRecordAlert)
            .padding()
            .mask {
                RoundedRectangle(cornerRadius: 32)
                    .padding()
            }
            .offset(y: hasRecordAlert ? 0 : 1300)
    }
    
    // MARK: - Event Handlers
    private func handleSunMoonTap() {
        if snoozeViewModel.onProcess {
            if snoozeViewModel.hasTodayRecord {
                withAnimation {
                    hasRecordAlert.toggle()
                }
            } else {
                withAnimation {
                    snoozeViewModel.recordSleep()
                    if snoozeViewModel.isNight {
                        setAlarm(time: snoozeViewModel.wakeTime)
                    }
                }
            }
        } else {
            withAnimation {
                warningAlert.toggle()
                
                if startMenu {
                    startMenu.toggle()
                }
                
                if setupMenu {
                    setupMenu.toggle()
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    func startTimer() {
        // 타이머 시작: 1초마다 실행
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss" // 원하는 시간 형식 설정
            let timeString = dateFormatter.string(from: Date())
            currentTime = timeString
        }
    }
    
    private func setAlarm(time: Date) {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)
        
        scheduleNotification(hour: hour, minute: minute)
        print("🕰 \(hour)시 \(minute)분에 알람 설정됨")
    }
}

#Preview {
    @Previewable @StateObject var snoozeViewModel = SnoozeIslandViewModel.snoozeViewModel
        
    HomeView()
        .environmentObject(snoozeViewModel)
}
