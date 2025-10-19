//
//  UserNotification.swift
//  DanjamRenew
//
//  Created by jose Yun on 12/12/23.
//


import UserNotifications
import SwiftUI


func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if granted {
            print("✅ 알림 권한 허용됨")
        } else {
            print("🚫 알림 권한 거부됨")
        }
    }
}


func scheduleNotification(hour: Int, minute: Int) {
    let content = UNMutableNotificationContent()
    content.title = "⏰ 일어나욧"
    content.body = "아침입니다~"
    content.sound = .default
    
    var dateComponents = DateComponents()
    dateComponents.hour = hour
    dateComponents.minute = minute
    
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("🚨 알람 등록 실패: \(error.localizedDescription)")
        } else {
            print("✅ \(hour)시 \(minute)분 알람 등록 완료")
        }
    }
}


func scheduleDailyNotification(hour: Int, minute: Int) {
    let center = UNUserNotificationCenter.current()
    
    let content = UNMutableNotificationContent()
    content.title = "자러갈 시간!"
    content.body = "단잠의 섬에 놀러오세요!"
    content.sound = UNNotificationSound.default
    
    // 특정 시간 설정
    var dateComponents = DateComponents()
    dateComponents.hour = hour
    dateComponents.minute = minute
    
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    let request = UNNotificationRequest(identifier: "dailyNotification", content: content, trigger: trigger)
    
    center.add(request) { error in
        if let error = error {
            print("알림 등록 실패:", error)
        } else {
            print("알림이 매일 \(hour):\(minute)에 등록됨")
        }
    }
}
