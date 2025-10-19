//
//  SleepDataModel.swift
//  SnoozeIsland
//
//  Created by jose Yun on 2/2/25.
//

import Foundation
import Charts

struct SleepLog: Identifiable, Codable {
    
    var id = UUID()
    var day: Date // 수면의 날짜
    var startTime: Date // 수면 시작 시간
    var endTime: Date // 수면 종료 시간
    var sleepDuration: Double? // 수면 길이 단위 h.
    var success: Bool? // 수면 습관 성공 여부
    
    init(startTime: Date, endTime: Date, success: Bool = false) {
        self.day = endTime
        self.startTime = startTime
        self.endTime = endTime
        self.success = success
        let calendar = Calendar.current
        self.sleepDuration = Double(calendar.dateComponents([.hour, .minute, .second], from: startTime, to: endTime).hour!)
    }

}
