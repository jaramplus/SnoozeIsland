//
//  ChartView.swift
//  SnoozeIsland
//
//  Created by jose Yun on 8/10/25.
//

import SwiftUI
import Charts

enum Language: String, CaseIterable {
    case korean = "한국어"
    case english = "English"
}
struct ChartView: View {
    
    @EnvironmentObject var snoozeViewModel: SnoozeIslandViewModel
    var sleepLogs: [SleepLog]
    
    var timeLabels: [String] {
        switch snoozeViewModel.currentLanguage {
        case .korean:
            return ["오후 9시", "오후 11시", "오전 1시", "오전 3시", "오전 5시", "오전 7시", "오전 9시", "오전 11시"]
        case .english:
            return ["9 PM", "11 PM", "1 AM", "3 AM", "5 AM", "7 AM", "9 AM", "11 AM"]
        }
    }
    
    @State private var selectedLog: SleepLog?
    @State var logTheme: LogTheme
        
    @State private var visibleStartDate: Date = Date().addingTimeInterval(-86400 * 6)
    @State private var visibleEndDate: Date = Date()

    @State var scrollPosition: Date = Date().addingTimeInterval(-86400 * 5)
    
    // MARK: - Computed Properties
    private var chartDomainLength: TimeInterval {
        logTheme == .week ? 3600 * 24 * 7 : 3600 * 24 * 30
    }
    
    private var dateRangeOffset: Int {
        logTheme == .week ? 6 : 30
    }
    
    private var axisLabelColor: Color {
        snoozeViewModel.isNight ? .white.opacity(0.9) : .black.opacity(0.9)
    }
    
    private var axisGridColor: Color {
        snoozeViewModel.isNight ? .white.opacity(0.3) : .black.opacity(0.3)
    }
    
    var body: some View {
        VStack {
            
            VStack {
                Picker("", selection: $logTheme) {
                    ForEach(LogTheme.allCases) {
                        Text($0.localizedString(language: snoozeViewModel.currentLanguage))
                    }
                }
                .pickerStyle(.segmented)
                .background(.white.opacity(0.4))
                .cornerRadius(8)
                .padding()
                
                
                VStack {
                    Text("\(formattedDate(visibleStartDate)) - \(formattedDate(visibleEndDate))")
                        .font(.caption)
                        .opacity(0.8)
                }
                .opacity(0.7)
                
                Spacer()
                
                Chart {
                    if sleepLogs.isEmpty {
                        ForEach([SleepLog(startTime: Date(), endTime:Date().addingTimeInterval(80000))]) { log in
                            let startHour = Double(Calendar.current.component(.hour, from: log.startTime))
                            let endHour = Double(Calendar.current.component(.hour, from: log.endTime))
                            
                            BarMark(
                                x: .value("Date", log.day, unit: .day),
                                yStart: .value("StartTime", startHour),
                                yEnd: .value("EndTime", endHour)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                    } else {
                        ForEach(sleepLogs) { log in
                            let startHour = Double(Calendar.current.component(.hour, from: log.startTime))
                            let endHour = Double(Calendar.current.component(.hour, from: log.endTime))
                            
                            BarMark(
                                x: .value("Date", log.day, unit: .day),
                                yStart: .value("StartTime", startHour),
                                yEnd: .value("EndTime", endHour)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
                .chartScrollableAxes(.horizontal)
                .foregroundStyle(.lightPurple)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: logTheme == .week ? 1 : 10)) { value in
                        if let date = value.as(Date.self) {
                            
                                AxisValueLabel {
                                    Text(formatXAxisDate(date))
                                }
                                .foregroundStyle(logTheme == .week ? axisLabelColor : .clear)
                       }
                        AxisGridLine()
                        AxisTick()
                            
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: Array(0...24)) { value in
                        if let hour = value.as(Int.self), hour % 3 == 0 {
                            let timeIndex = (hour / 3) % timeLabels.count
                            AxisValueLabel(timeLabels[timeIndex])
                                .foregroundStyle(axisLabelColor)
                        }
                        AxisGridLine()
                            .foregroundStyle(axisGridColor)
                    }
                }
                .chartXVisibleDomain(length: chartDomainLength)
                .chartScrollPosition(x: $scrollPosition)
                .chartScrollTargetBehavior(
                    .valueAligned(
                        matching: DateComponents(hour: 0),
                        majorAlignment: .matching(DateComponents(day: 1))
                    )
                )
                .chartGesture { proxy in
                    SpatialTapGesture()
                        .onEnded { item in
                            if let target: (date: Date, temp: Double) = proxy.value(at: item.location, as: (Date, Double).self),
                               let closestLog = closestChartData(to: target) {
                                selectedLog = closestLog
                            }
                        }
                }
                .onChange(of: scrollPosition) { newPosition in
                    updateVisibleDates(for: newPosition)
                }
                .onChange(of: logTheme) { newTheme in
                    updateEndDateForTheme()
                }
            }
            
            buildInfoSection()
        }
    }
    
    // MARK: - Info Section
    private func buildInfoSection() -> some View {
        HStack {
            if let selected = selectedLog {
                VStack(alignment: .leading, spacing: 6) {
                    Text(getFormattedDate(for: selected))
                        .font(.headline)
                    Text("\(getFormattedStartTime(for: selected)) ~ \(getFormattedEndTime(for: selected))")
                    Text(getTotalSleepTime(for: selected))
                        .bold()
                }
            } else if sleepLogs.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    if snoozeViewModel.currentLanguage == .korean {
                        Text("아직 기록한 수면이 없습니다. 단잠의 섬에서 수면을 기록해주세요.")
                    } else {
                        Text("No sleep records yet. Please record your sleep in Snooze Island.")
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    if snoozeViewModel.currentLanguage == .korean {
                        Text("이 기간 동안")
                            .font(.system(size: 16))
                        
                        Text("평균 취침 시간은 \(averageBedtime())시")
                            .font(.system(size: 16))
                        
                        Text("평균 기상 시간은 \(averageWakeupTime())시")
                            .font(.system(size: 16))
                        
                        Text("하루 평균 수면량은 \(averageSleepDuration())시간입니다.")
                            .font(.system(size: 16))
                    } else {
                        Text("During this period")
                            .font(.system(size: 16))
                        
                        Text("Average bedtime: \(averageBedtime())")
                            .font(.system(size: 16))
                        
                        Text("Average wake time: \(averageWakeupTime())")
                            .font(.system(size: 16))
                        
                        Text("Average sleep duration: \(averageSleepDuration())")
                            .font(.system(size: 16))
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(snoozeViewModel.isNight ? .clear : .white.opacity(0.8))
        .cornerRadius(10)
        .overlay {
            if snoozeViewModel.isNight {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white, lineWidth: 2)
                    .shadow(color: .white, radius: 1)
            }
        }
    }
    
    // MARK: - Event Handlers
    private func updateVisibleDates(for newPosition: Date) {
        let startDate = newPosition
        let endDate = Calendar.current.date(byAdding: .day, value: dateRangeOffset, to: startDate) ?? startDate
        visibleStartDate = startDate
        visibleEndDate = endDate
    }
    
    private func updateEndDateForTheme() {
        let endDate = Calendar.current.date(byAdding: .day, value: dateRangeOffset, to: visibleStartDate) ?? visibleStartDate
        visibleEndDate = endDate
    }
    
    // MARK: - Helper Functions
    func closestChartData(to target: (date: Date, temp: Double)) -> SleepLog? {
        sleepLogs.min { a, b in
            abs(a.day.timeIntervalSince(target.date)) < abs(b.day.timeIntervalSince(target.date))
        }
    }
    
    // MARK: - Formatting Functions
    
    private func formatXAxisDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        
        switch snoozeViewModel.currentLanguage {
        case .korean:
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "d일"
            return formatter.string(from: date)
            
        case .english:
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "d"
            let day = formatter.string(from: date)
            return day + getOrdinalSuffix(for: Int(day) ?? 0)
        }
    }

    private func getOrdinalSuffix(for day: Int) -> String {
        // Special cases for 11th, 12th, 13th
        if day >= 11 && day <= 13 {
            return "th"
        }
        
        // Check last digit
        switch day % 10 {
        case 1:
            return "st"
        case 2:
            return "nd"
        case 3:
            return "rd"
        default:
            return "th"
        }
    }
    
    private func getFormattedDate(for log: SleepLog) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy.MM.dd"
        return formatter.string(from: log.day)
    }
    
    private func getFormattedStartTime(for log: SleepLog) -> String {
        let formatter = DateFormatter()
        
        if snoozeViewModel.currentLanguage == .korean {
            formatter.dateFormat = "a h:mm"
            formatter.amSymbol = "오전"
            formatter.pmSymbol = "오후"
        } else {
            formatter.dateFormat = "h:mm a"
        }
        
        return formatter.string(from: log.startTime)
    }
    
    private func getFormattedEndTime(for log: SleepLog) -> String {
        let formatter = DateFormatter()
        
        if snoozeViewModel.currentLanguage == .korean {
            formatter.dateFormat = "a h:mm"
            formatter.amSymbol = "오전"
            formatter.pmSymbol = "오후"
        } else {
            formatter.dateFormat = "h:mm a"
        }
        
        return formatter.string(from: log.endTime)
    }
    
    private func getTotalSleepTime(for log: SleepLog) -> String {
        let interval = log.endTime.timeIntervalSince(log.startTime)
        let totalMinutes = Int(interval / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if snoozeViewModel.currentLanguage == .korean {
            return "총 \(hours)시간 \(minutes)분 수면"
        } else {
            return "Total: \(hours)h \(minutes)m sleep"
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "YYYY.MM.dd"
        return formatter.string(from: date)
    }
    
    // MARK: - Legacy computed properties (keeping for compatibility)
    var formattedDate: String {
        guard let log = selectedLog else { return "" }
        return getFormattedDate(for: log)
    }

    var formattedStartTime: String {
        guard let log = selectedLog else { return "" }
        return getFormattedStartTime(for: log)
    }

    var formattedEndTime: String {
        guard let log = selectedLog else { return "" }
        return getFormattedEndTime(for: log)
    }

    var totalSleepTime: String {
        guard let log = selectedLog else { return "" }
        return getTotalSleepTime(for: log)
    }
    
// 평균 취침 시간 계산 (24시간 형식)
    func averageBedtime() -> String {
        let calendar = Calendar.current
        var totalMinutes = 0
        
        for log in sleepLogs {
            let components = calendar.dateComponents([.hour, .minute], from: log.startTime)
            let hour = components.hour ?? 0
            let minute = components.minute ?? 0
            
            // 24시간을 분으로 변환하여 계산 (밤 시간 처리)
            var minutesFromMidnight = hour * 60 + minute
            if hour < 12 {
                // 자정 이후의 시간은 다음날로 계산
                minutesFromMidnight += 24 * 60
            }
            totalMinutes += minutesFromMidnight
        }
        
        let averageMinutes = totalMinutes / sleepLogs.count
        var averageHour = (averageMinutes / 60) % 24
        let averageMinute = averageMinutes % 60
        
        return String(format: "%02d:%02d", averageHour, averageMinute)
    }
    
    // 평균 기상 시간 계산 (24시간 형식)
    func averageWakeupTime() -> String {
        let calendar = Calendar.current
        var totalMinutes = 0
        
        for log in sleepLogs {
            let components = calendar.dateComponents([.hour, .minute], from: log.endTime)
            let hour = components.hour ?? 0
            let minute = components.minute ?? 0
            totalMinutes += hour * 60 + minute
        }
        
        let averageMinutes = totalMinutes / sleepLogs.count
        let averageHour = averageMinutes / 60
        let averageMinute = averageMinutes % 60
        
        return String(format: "%02d:%02d", averageHour, averageMinute)
    }
    
    // 평균 수면 시간 계산
    func averageSleepDuration() -> String {
        var totalDuration: TimeInterval = 0
        
        for log in sleepLogs {
            totalDuration += log.endTime.timeIntervalSince(log.startTime)
        }
        
        let averageDuration = totalDuration / Double(sleepLogs.count)
        let hours = Int(averageDuration / 3600)
        let minutes = Int((averageDuration.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if snoozeViewModel.currentLanguage == .korean {
            return String(format: "%d시간 %d분", hours, minutes)
        } else {
            return String(format: "%dh %dm", hours, minutes)
        }
    }
}

#Preview {
    @Previewable @StateObject var snoozeViewModel = SnoozeIslandViewModel.snoozeViewModel
        
    SleepLogView(sleepLogMenu: .constant(false))
        .environmentObject(snoozeViewModel)
}
