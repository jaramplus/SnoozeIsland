//
//  ChallengeRecordView.swift
//  SnoozeIsland
//
//  Created by jose Yun on 1/31/25.
//

import SwiftUI

struct ChallengeRecordView: View {
    @Binding var recordMenu: Bool
    @EnvironmentObject var snoozeViewModel: SnoozeIslandViewModel
    
    // 월 이름을 언어에 따라 반환
    var monthsWithDays: [(name: String, days: Int)] {
        let isLeapYear = selectedYear % 4 == 0 && (selectedYear % 100 != 0 || selectedYear % 400 == 0)
        let febDays = isLeapYear ? 29 : 28
        
        switch snoozeViewModel.currentLanguage {
        case .korean:
            return [
                ("1월", 31), ("2월", febDays), ("3월", 31),
                ("4월", 30), ("5월", 31), ("6월", 30),
                ("7월", 31), ("8월", 31), ("9월", 30),
                ("10월", 31), ("11월", 30), ("12월", 31)
            ]
        case .english:
            return [
                ("Jan", 31), ("Feb", febDays), ("Mar", 31),
                ("Apr", 30), ("May", 31), ("Jun", 30),
                ("Jul", 31), ("Aug", 31), ("Sep", 30),
                ("Oct", 31), ("Nov", 30), ("Dec", 31)
            ]
        }
    }
    
    @State var startYear: Int = Calendar.current.component(.year, from: Date())
    let currentYear: Int = Calendar.current.component(.year, from: Date())
    
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedDate: Date? = nil
     
    var body: some View {
        ZStack {
            Image(snoozeViewModel.isNight ? "bkg_night" : "bkg_day")
                .resizable()
                .ignoresSafeArea()
                .scaledToFill()
            
            VStack(spacing: 0) {
                
                HStack {
                    Button(action: { withAnimation {recordMenu.toggle() }} ) {
                        Image(systemName: "chevron.down")
                            .foregroundStyle(snoozeViewModel.isNight ? .white : .black)
                    }
                    .padding()
                    
                    Spacer()
                    
                    Picker("", selection: $selectedYear) {
                        ForEach(startYear...currentYear, id: \.self) { year in
                            Text(year.description).tag(year)
                        }
                    }
                    .background(snoozeViewModel.isNight ? .clear : .white)
                    .cornerRadius(10.0)
                    .tint(snoozeViewModel.isNight ? .white : .black)
                    .overlay {
                        if snoozeViewModel.isNight {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.white, lineWidth: 1)
                        }
                    }
                    .padding(.horizontal)
                }
                .overlay {
                    Text(snoozeViewModel.currentLanguage == .korean ? "습관 기록" : "Habit Record")
                        .foregroundStyle(snoozeViewModel.isNight ? .white : .black)
                }
                .padding(.top, 56)
                
                Divider()
                    .foregroundStyle(.white)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
                HStack(alignment: .top) {
                    IndexView()
                    
                    LazyHGrid(rows: [GridItem(.flexible())], alignment: .top, spacing: 6) {
                        ForEach(monthsWithDays, id: \.name) { month in
                            MonthView(
                                month: month.name,
                                days: Array(1...month.days),
                                selectedDate: $selectedDate, selectedYear: selectedYear
                            )
                            .foregroundStyle(snoozeViewModel.isNight ? .white : .black)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 4)
                .padding(.bottom, 24)
                
                HStack {
                    if let date = selectedDate {
                        VStack(alignment: .leading, spacing: 0) {
                            if snoozeViewModel.currentLanguage == .korean {
                                Text("\(formattedDate(date)) 습관 형성 성공했습니다.\n\(snoozeViewModel.challengeNumber)번째 도전 중이었으며,\n \(snoozeViewModel.consecutiveSuccessCount)번 연속 성공했습니다.")
                            } else {
                                Text("Habit formed successfully on \(formattedDateEnglish(date)).\nThis was challenge #\(snoozeViewModel.challengeNumber),\nwith \(snoozeViewModel.consecutiveSuccessCount) consecutive successes.")
                            }
                        }
                    } else {
                        if snoozeViewModel.currentLanguage == .korean {
                            Text("성공 일자는 \(snoozeViewModel.consecutiveSuccessCount)일,\n도전 횟수는 \(snoozeViewModel.challengeNumber)번,\n최대 연속 성공 횟수는 \(snoozeViewModel.highestConsecutiveSuccessCount)번입니다.")
                        } else {
                            Text("Success days: \(snoozeViewModel.consecutiveSuccessCount),\nTotal challenges: \(snoozeViewModel.challengeNumber),\nMax consecutive: \(snoozeViewModel.highestConsecutiveSuccessCount)")
                        }
                    }
                    Spacer()
                }
                .padding()
                .background(snoozeViewModel.isNight ? .clear : .white.opacity(0.8))
                .overlay {
                    if snoozeViewModel.isNight {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 1)
                            .shadow(color: snoozeViewModel.isNight ? .white : .black, radius: 1)
                    }
                }
                .cornerRadius(10.0)
                .padding()
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            if let userProfileYear = snoozeViewModel.userProfile?.registerDate {
                self.startYear = Calendar.current.component(.year, from: userProfileYear)
            }
        }
        .foregroundStyle(snoozeViewModel.isNight ? .white : .black)
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: date)
    }
    
    func formattedDateEnglish(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    @Previewable @StateObject var snoozeViewModel = SnoozeIslandViewModel.snoozeViewModel
    ChallengeRecordView(recordMenu: .constant(false))
        .environmentObject(snoozeViewModel)
}
