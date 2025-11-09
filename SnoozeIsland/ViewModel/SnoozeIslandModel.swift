//
//  SnoozeIslandViewModel.swift
//  SnoozeIsland
//
//  Created by jose Yun on 2/2/25.
//

//MARK: creature: [DraggableItem] 저장 안되고 있음!

import SwiftUI

final class SnoozeIslandViewModel: ObservableObject {
    static let snoozeViewModel: SnoozeIslandViewModel = SnoozeIslandViewModel()
    
    init() {
        self.onProcess = UserDefaults.standard.bool(forKey: "onProcess") // 주기를 시작함
        self.isNight = UserDefaults.standard.bool(forKey: "night") // 없으면 day, isNight == false
        self.isAlarm = UserDefaults.standard.bool(forKey: "alarm") // 알람 받는 설정, yes / no
        self.isSound = UserDefaults.standard.bool(forKey: "sound") // 배경음악 설정, yes / no
        
        self.challengeNumber = UserDefaults.standard.integer(forKey: "challengeNumber") // 챌린지 도전 숫자
        self.consecutiveSuccessCount = UserDefaults.standard.integer(forKey: "consecutiveSuccessCount") // 연속 수면 성공 횟수
        self.highestConsecutiveSuccessCount = UserDefaults.standard.integer(forKey: "highestConsecutiveSuccessCount") // 연속 수면 성공 횟수
        
        self.creatures = loadCreatures()
        
        self.userProfile = loadUserProfile()
        self.sleepLogs = loadSleepLogs()
        
        if let user = userProfile {
            if let cycle = user.cycle {
                self.sleepTime = cycle.0
                self.wakeTime = cycle.1
            }
        }
    }
//    
//    let creatures_day: [String] = ["cloud-tree", "waterdrop-grass", "waterdrop-grass", "rose-mushroom", "deer-day", "bear-day"]
//    let creatures_night: [String] = ["cloud-tree", "waterdrop-grass", "waterdrop-grass", "rose-mushroom", "deer-night", "bear-night"]
    
    let creatures_day: [String] = ["waterdrop-grass", "waterdrop-grass", "rose-mushroom", "deer-day", "bear-day", "cloud-tree"]
    let creatures_night: [String] = ["waterdrop-grass", "waterdrop-grass", "rose-mushroom", "deer-night", "bear-night", "cloud-tree", ]
    
    @Published var creatures: [DraggableItem] = []
    {
        didSet {
            saveCreatures()
        }
    }
    
    var challengeNumber: Int {
        didSet {
            UserDefaults.standard.set(challengeNumber, forKey: "challengeNumber")
        }
    }
    // 챌린지 도전 숫자.
    var consecutiveSuccessCount: Int {
        didSet {
            UserDefaults.standard.set(consecutiveSuccessCount, forKey: "consecutiveSuccessCount")
            
            if consecutiveSuccessCount > 0 {
                lastSuccess = 1 // success
                addNextItem()
                
                if consecutiveSuccessCount > highestConsecutiveSuccessCount { // 최고 기록 경신
                    highestConsecutiveSuccessCount = consecutiveSuccessCount
                }
                
            } else {
                lastSuccess = -1 // failed
                reduceItem()
            }
        }
    } // 이번 주기 연속 기록 횟수
    
    var highestConsecutiveSuccessCount: Int {
        didSet {
            UserDefaults.standard.set(highestConsecutiveSuccessCount, forKey: "highestConsecutiveSuccessCount")
        }
    }
    
    var lastSuccess: Int = 0 //어젯밤에 성공했는가? 1==성공, -1==실패. 단잠이 상태 변경 용도.
    
    var notifications = [Notification]() // 알람
    
    var currentLanguage: Language {
            // 시스템 언어가 한국어인지 확인
            let preferredLanguage = Locale.preferredLanguages.first ?? "en"
            return preferredLanguage.hasPrefix("ko") ? .korean : .english
    }
    
    @Published var onProcess: Bool {
        didSet {
            UserDefaults.standard.set(onProcess, forKey: "onProcess")
        }
    }
    
    @Published var userProfile: UserProfile? // 별도 저장
    
    @Published var sleepLogs: [SleepLog]? {
        didSet {
            saveSleepLogs()
        }
    }
    
    @Published var sleepTime: Date = Date() // 주기 수면 시작
    @Published var wakeTime: Date = Date() // 주기 수면 종료
    @Published var isNight: Bool {
        didSet {
            UserDefaults.standard.set(isNight, forKey: "night")
        }
    }
    
    
    @Published var isSound: Bool {
        didSet {
            UserDefaults.standard.set(isSound, forKey: "sound")
        }
    }
    
    @Published var isAlarm: Bool {
        didSet {
            UserDefaults.standard.set(isAlarm, forKey: "alarm")
        }
    }
    
    // MARK: - 날짜별 기록 확인 함수들
    
    /// 특정 날짜에 이미 기록이 있는지 확인
    func hasRecordForDate(_ date: Date) -> Bool {
        guard let logs = sleepLogs else { return false }
        
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: date)
        
        return logs.contains { log in
            let logDate = calendar.startOfDay(for: log.day)
            return calendar.isDate(logDate, inSameDayAs: targetDate)
        }
    }
    
    /// 오늘 날짜에 이미 기록이 있는지 확인하는 computed property
    var hasTodayRecord: Bool {
        return hasRecordForDate(Date())
    }
    
    func loadUserProfile() -> UserProfile? {
        if let savedData = UserDefaults.standard.data(forKey: "userProfile") {
            let decoder = JSONDecoder()
            if let loadedProfile = try? decoder.decode(UserProfile.self, from: savedData) {
                return loadedProfile
            }
        }
        return nil
    }
        
    func loadSleepLogs() -> [SleepLog]? {
        if let savedData = UserDefaults.standard.data(forKey: "sleepLogs") {
            print("savedData:", savedData)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601  // <-- Date 타입을 처리할 수 있도록 설정

            do {
                let loadedLog = try decoder.decode([SleepLog].self, from: savedData)
                print("loadedLog:", loadedLog)
                return loadedLog
            } catch {
                print("디코딩 오류:", error)
            }
        }
        return [SleepLog(startTime: Date(), endTime: Date().addingTimeInterval(28800)),
                SleepLog(startTime: Date().addingTimeInterval(86400), endTime: Date().addingTimeInterval(115200)),
                SleepLog(startTime: Date().addingTimeInterval(86400 * 2), endTime: Date().addingTimeInterval(115200 * 2)),
                SleepLog(startTime: Date().addingTimeInterval(86400 * 3), endTime: Date().addingTimeInterval(115200 * 3)),
                SleepLog(startTime: Date().addingTimeInterval(86400 * 4), endTime: Date().addingTimeInterval(115200 * 4)),
                SleepLog(startTime: Date().addingTimeInterval(86400 * 5), endTime: Date().addingTimeInterval(115200 * 5)),
                SleepLog(startTime: Date().addingTimeInterval(86400 * 6), endTime: Date().addingTimeInterval(115200 * 6)),
                SleepLog(startTime: Date().addingTimeInterval(86400 * 7), endTime: Date().addingTimeInterval(115200 * 7)),
                SleepLog(startTime: Date().addingTimeInterval(86400 * 8), endTime: Date().addingTimeInterval(115200 * 8))
        ]
    }
        
        func makeUserProfile() {
            let encoder = JSONEncoder()
            
            let user = UserProfile()
            self.userProfile = user
            
            if let encoded = try? encoder.encode(user) {
                UserDefaults.standard.set(encoded, forKey: "userProfile")
            }
        }
        
        func saveUserProfile() { // 제일 처음 주기 설정할 때.
            
            let encoder = JSONEncoder()
            self.userProfile?.setCycle(cycle: (sleepTime, wakeTime))
            if let encoded = try? encoder.encode(userProfile) {
                UserDefaults.standard.set(encoded, forKey: "userProfile")
                
                UserDefaults.standard.set(true, forKey: "alarm")
                UserDefaults.standard.set(true, forKey: "sound")
                
                self.isAlarm = true
                self.isSound = true
            }
        }
        
    
    private func addNextItem() {
        guard self.creatures.count < 6 else { return }

        let nextName = [creatures_day[self.creatures.count], creatures_night[self.creatures.count]] // day night order
        let randomLine = Int.random(in: 0..<4)
        let randomOffsetX = CGFloat.random(in: -150...150)

        let newItem = DraggableItem(
            names: nextName,
            offset: CGSize(width: randomOffsetX, height: 0),
            currentLineIndex: randomLine
        )

        self.creatures.append(newItem)
            print("Added \(nextName) on line \(randomLine) with X offset \(Int(randomOffsetX))")
        }
    
        private func reduceItem() {
            creatures = []
        }
        
        func startProcess() {
            self.onProcess = true
            
            let calendar = Calendar.current
            
            let hour = calendar.component(.hour, from: self.sleepTime ?? Date())
            let minute = calendar.component(.minute, from: self.sleepTime ?? Date())
            
            scheduleDailyNotification(hour: hour, minute: minute)
        }
        
        func inRoutine(newTime: Date, isNight: Bool) -> Bool {
            let calendar = Calendar.current
            var basisComponents: DateComponents
            // Extract hours and minutes for both dates
            let newComponents = calendar.dateComponents([.hour, .minute], from: newTime)
            
            print("new", newComponents)

            if let user = userProfile {
                print("user profile exits")
                if !isNight { // Day
                    if let cycle = user.cycle {
                        basisComponents = calendar.dateComponents([.hour, .minute], from: cycle.0)
                    } else {
                        return false
                    }
                } else { // night
                    if let cycle = user.cycle {
                        basisComponents = calendar.dateComponents([.hour, .minute], from: cycle.1)
                    } else {
                        return false
                    }
                }
                
                print("basis", basisComponents)
                
                // Convert hours and minutes to total minutes
                if let newHour = newComponents.hour, let newMinute = newComponents.minute,
                   let basisHour = basisComponents.hour, let basisMinute = basisComponents.minute {
                    
                    let newTotalMinutes = newHour * 60 + newMinute
                    let basisTotalMinutes = basisHour * 60 + basisMinute
                    
                    let difference = abs(newTotalMinutes - basisTotalMinutes)
                    
                    return difference <= 30
                }
            }
            return false
        }
        
        func recordSleep() {
            let today = Date()
            
            var newLog: SleepLog
            
            if !self.isNight { // day
                let lastSleepStart = Date()
                UserDefaults.standard.set(lastSleepStart, forKey: "lastSleepStart")
                withAnimation {
                    isNight.toggle()
                }
            } else {
                let lastSleepEnd = Date()

                if let lastSleepStart = UserDefaults.standard.object(forKey: "lastSleepStart") as? Date {
                    let isCurrentSuccess = inRoutine(newTime: lastSleepStart, isNight: false) && inRoutine(newTime: lastSleepEnd, isNight: true)
                    
                    if isCurrentSuccess {
                        newLog = SleepLog(startTime: lastSleepStart, endTime: lastSleepEnd, success: true)
                        consecutiveSuccessCount += 1
                    } else {
                        newLog = SleepLog(startTime: lastSleepStart, endTime: lastSleepEnd, success: false)
                        consecutiveSuccessCount = 0
                    }
                    
                    if sleepLogs?.isEmpty == true {
                        sleepLogs = [newLog]
                    } else {
                        self.sleepLogs?.append(newLog)
                    }
                }
                withAnimation {
                    isNight.toggle()
                }
            }
        }
        
        func saveSleepLogs() { // save sleepLogs
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601  // 날짜 포맷 설정
            
            if let encoded = try? encoder.encode(sleepLogs) {
                UserDefaults.standard.set(encoded, forKey: "sleepLogs")
                UserDefaults.standard.synchronize()
            }
        }
    
    
    func debug() {
        if let savedData = UserDefaults.standard.data(forKey: "sleepLogs") {
            print("UserDefaults에 저장된 데이터:", savedData)
        } else {
            print("UserDefaults에서 데이터를 찾을 수 없음")
        }
    }
        
        func reset() {
            UserDefaults.standard.set(nil, forKey: "userProfile")
            self.userProfile = nil
            
            self.onProcess = false
            self.isNight = false
            self.sleepLogs = []
            
            sleepTime = Date()
            wakeTime = Date()
            
            challengeNumber += 1
            consecutiveSuccessCount = 0
            creatures = []
        }
    
    func saveCreatures() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self.creatures)
            UserDefaults.standard.set(data, forKey: "creatures")
            print("Successfully saved \(creatures.count) creatures")
        } catch {
            print("Failed to save creatures: \(error)")
        }
    }

    // 3. 불러오기 시 - JSON에서 디코딩해서 불러오기
    func loadCreatures() -> [DraggableItem] {
        guard let data = UserDefaults.standard.data(forKey: "creatures") else {
            print("No creatures data found")
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            let creatures = try decoder.decode([DraggableItem].self, from: data)
            print("Successfully loaded \(creatures.count) creatures")
            return creatures
        } catch {
            print("Failed to decode creatures: \(error)")
            return []
        }
    }
    
}
