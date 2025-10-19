//
//  UserModel.swift
//  SnoozeIsland
//
//  Created by jose Yun on 2/2/25.
//

import Foundation

class UserProfile: Codable, Equatable {
    var registerDate: Date
    var userID: UUID
    var cycle: (Date, Date)? // Storing start and end Date as Date objects
    
    
    init(registerDate: Date = Date(), userID: UUID = UUID()) {
        self.registerDate = registerDate
        self.userID = userID
    }
    
    enum CodingKeys: String, CodingKey {
        case registerDate, userID, cycle
    }
    
    public func setCycle(cycle: (Date, Date)) {
        self.cycle = cycle
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        registerDate = try container.decode(Date.self, forKey: .registerDate)
        userID = try container.decode(UUID.self, forKey: .userID)
        
        // Decode cycle components
        let cycleDict = try container.decode([String: Int].self, forKey: .cycle)
        
        let calendar = Calendar.current
        
        // Create start and end Date using the stored hour and minute
        let startHour = cycleDict["startHour"] ?? 0
        let startMinute = cycleDict["startMinute"] ?? 0
        let endHour = cycleDict["endHour"] ?? 0
        let endMinute = cycleDict["endMinute"] ?? 0
        
        // Use current date to set the time for both start and end cycle
        let startDate = calendar.date(bySettingHour: startHour, minute: startMinute, second: 0, of: Date()) ?? Date()
        let endDate = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: Date()) ?? Date()
        
        cycle = (startDate, endDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(registerDate, forKey: .registerDate)
        try container.encode(userID, forKey: .userID)
        
        // Extract hour and minute components from the start and end Date
        let calendar = Calendar.current
        
        let startHour = calendar.component(.hour, from: cycle?.0 ?? Date())
        let startMinute = calendar.component(.minute, from: cycle?.0 ?? Date())
        let endHour = calendar.component(.hour, from: cycle?.1 ?? Date())
        let endMinute = calendar.component(.minute, from: cycle?.1 ?? Date())
        
        // Create dictionary with cycle components
        let cycleDict: [String: Int] = [
            "startHour": startHour,
            "startMinute": startMinute,
            "endHour": endHour,
            "endMinute": endMinute
        ]
        
        try container.encode(cycleDict, forKey: .cycle)
    }
    
    static func == (lhs: UserProfile, rhs: UserProfile) -> Bool {
        return lhs.userID == rhs.userID
    }
}
