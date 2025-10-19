//
//  MonthsView.swift
//  SnoozeIsland
//
//  Created by jose Yun on 2/5/25.
//

import SwiftUI

struct IndexView: View {
    @EnvironmentObject var snoozeViewModel: SnoozeIslandViewModel

    var body: some View {
        
        VStack(alignment: .center) {
            Text("")
                .foregroundStyle(.clear)
                .font(.system(size: 13))
                .padding(.bottom, 5)
            
            VStack(spacing: 2) {

                ForEach((1...31), id: \.self) { day in
                    if day % 5 == 0 || day == 1 {
                        Text("\(day)")
                            .frame(width: 16, height: 16)
                            .foregroundStyle(snoozeViewModel.isNight ? .white : .black)
                            .font(.system(size: 12))
                        
                    } else {
                        Text("•")
                            .frame(width: 16, height: 16)
                            .foregroundStyle(snoozeViewModel.isNight ? .white : .black)
                            .font(.system(size: 12))
                    }
                }
            }
        }
    }
}

struct MonthView: View {
    @EnvironmentObject var snoozeViewModel: SnoozeIslandViewModel
    let month: String
    let days: [Int]
    
    @State var isDisabled: Bool = false
    @State var isAlert = false
    @Binding var selectedDate: Date? // Track the selected date for alert

    let columns = [GridItem(.flexible(), spacing: 4)] // Single column layout for days
    
    
    var body: some View {
        VStack(alignment: .center) {
            Text(month)
                .font(.system(size: 13))
                .padding(.bottom, 3)
                .foregroundStyle(snoozeViewModel.isNight ? .white : .black)
                
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(days, id: \.self) { day in
                        let madenDate = makeDate(year: 2025, month: month, date: day)!
                        let currentDateLocal = Calendar.current.startOfDay(for: Date())
                        let isDisabled = shouldDisable(date: madenDate, currentDate: currentDateLocal)
                        let hasRecord = hasRecord(madenDate: madenDate)
                        let isSuccess = isCurSuccess(madenDate: madenDate)
                        let isToday = Calendar.current.isDate(madenDate, inSameDayAs: currentDateLocal)
                        
                        let isPastDate = (snoozeViewModel.userProfile != nil) ?  madenDate < snoozeViewModel.userProfile!.registerDate : madenDate < currentDateLocal
                        let isSelected = selectedDate == madenDate

                        Button(action : {
                            if selectedDate == madenDate {
                                selectedDate = nil
                            }
                            else {
                                selectedDate = madenDate
                            }
                            
                            
                        } ) {
                            HStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .foregroundStyle(getFillColor(isDisabled: isDisabled, hasRecord: hasRecord, isSuccess: isSuccess, isToday: isToday, isPastDate: isPastDate))
                                    .frame(width: 16, height: 16)
                                    .shadow(color: .white.opacity(0.2), radius: 2.0)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 4)
                                            .strokeBorder(getBorderColor(isDisabled: isDisabled, hasRecord: hasRecord, isSuccess: isSuccess, isToday: isToday, isPastDate: isPastDate, isSelected: isSelected), lineWidth: isSelected ? 2.5 : 1.5)
                                    }
                                    .scaleEffect(isSelected ? 1.1 : 1.0)
                                    .animation(.easeInOut(duration: 0.2), value: isSelected)
                            }
                        }
                        .disabled(isDisabled)
                    }
                }
            }
    
    }
    
    // 색상 로직을 위한 함수들
    func getFillColor(isDisabled: Bool, hasRecord: Bool, isSuccess: Bool, isToday: Bool, isPastDate: Bool) -> Color {
        if isDisabled {
            return .white.opacity(0.4)
        }
        
        if isToday {
            if hasRecord {
                if isSuccess {
                    // 오늘 날짜 + 성공한 기록이 있는 경우
                    return snoozeViewModel.isNight ? .white : .darkPurple
                } else {
                    // 오늘 날짜 + 실패한 기록이 있는 경우
                    return .clear
                }
            } else {
                // 오늘 날짜 + 기록이 없는 경우 - 진한 보라색
                return snoozeViewModel.isNight ? .white : .darkPurple
            }
        }
        
        if hasRecord {
            if isSuccess {
                // 기록이 있고 성공한 날 - 보라색 fill (과거 날짜는 30% 투명도)
                return isPastDate ? .lightPurple.opacity(0.4) : .lightPurple
            } else {
                // 기록이 있지만 실패한 날 - 투명 fill
                return .clear
            }
        } else {
            // 기록이 없는 날 - 흰색 (과거 날짜는 30% 투명도, 기본은 70%)
            return isPastDate ? .white.opacity(0.4) : .white.opacity(0.4)
        }
    }
    
    func getBorderColor(isDisabled: Bool, hasRecord: Bool, isSuccess: Bool, isToday: Bool, isPastDate: Bool, isSelected: Bool) -> Color {
        if isDisabled {
            return snoozeViewModel.isNight ? .white.opacity(0.4) : .white
        }
        
        // 선택된 날짜는 특별한 테두리 색상
        if isSelected {
            return .clickPurple
        }
        
        if isToday {
            if hasRecord {
                if isSuccess {
                    // 오늘 날짜 + 성공한 기록이 있는 경우
                    return .clear
                } else {
                    // 오늘 날짜 + 실패한 기록이 있는 경우 - 보라색 테두리
                    return snoozeViewModel.isNight ? .white : .lightPurple
                }
            } else {
                // 오늘 날짜 + 기록이 없는 경우 - 진한 보라색 테두리
                return snoozeViewModel.isNight ? .white : .darkPurple
            }
        }
        
        if hasRecord {
            return .lightPurple
        } else {
            return .white.opacity(0.7)
        }
    }
    
    func shouldDisable(date: Date, currentDate: Date) -> Bool {
        guard let registerDateUTC = snoozeViewModel.userProfile?.registerDate else { return false }
        
        // registerDate를 현지 시간의 하루 시작 시간으로 변환
        let registerDateLocal = Calendar.current.startOfDay(for: registerDateUTC)
        let targetDateLocal = Calendar.current.startOfDay(for: date)
        let todayLocal = Calendar.current.startOfDay(for: currentDate)
        
        print("registerDateLocal: \(registerDateLocal)")
        print("targetDateLocal: \(targetDateLocal)")
        print("todayLocal: \(todayLocal)")
        print("target > today: \(targetDateLocal > todayLocal)")
        
        // 미래 날짜이거나 등록일 이전 날짜인 경우 비활성화
        return targetDateLocal > todayLocal || targetDateLocal < registerDateLocal
    }

    
    func makeDate(year: Int, month: String, date: Int) -> Date? {
        let monthToNumber: [String: Int] = [
            "Jan": 1, "Feb": 2, "Mar": 3,
            "Apr": 4, "May": 5, "Jun": 6,
            "Jul": 7, "Aug": 8, "Sep": 9,
            "Oct": 10, "Nov": 11, "Dec": 12
        ]
        
        guard let numericMonth = monthToNumber[month] else { return nil }
        
        var components = DateComponents()
        components.year = year
        components.month = numericMonth
        components.day = date
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        let calendar = Calendar.current
        return calendar.date(from: components)
    }
    
    // 기록이 있는지 확인하는 함수
    func hasRecord(madenDate: Date) -> Bool {
        if let sleepLog = snoozeViewModel.sleepLogs {
            let curLog = sleepLog.filter { Calendar.current.isDate($0.day, inSameDayAs: madenDate) }
            return !curLog.isEmpty
        }
        return false
    }
    
    func isCurSuccess(madenDate: Date) -> Bool {
        guard let sleepLog = snoozeViewModel.sleepLogs else { return false }
        
        // 해당 날짜의 기록 확인
        let curLog = sleepLog.filter { Calendar.current.isDate($0.day, inSameDayAs: madenDate) }
        
        // 해당 날짜에 기록이 없으면 false
        guard !curLog.isEmpty else { return false }
        
        // 해당 날짜에 성공 기록이 있는지 확인
        let hasSuccessRecord = curLog.contains { $0.success == true }
        
        return hasSuccessRecord
    }
    
    // compare the first date user registered with days.
    func compareDates(_ date1: Date, _ date2: Date) -> Int {
        let calendar = Calendar.current
        // Check if the two dates are the same (ignoring time)
        if calendar.isDate(date1, inSameDayAs: date2) {
            return 0 // same
        } else if date1 < date2 {
            return -1 // date 1 < date 2
        } else {
            return 1 // date 1 > date 2
        }
    }
}


#Preview {
    @Previewable @StateObject var snoozeViewModel = SnoozeIslandViewModel.snoozeViewModel
    MonthView(month: "Feb", days: Array(1...28), selectedDate: .constant(Date()))
        .environmentObject(snoozeViewModel)
    
//    IndexView()

}
