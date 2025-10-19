//
//  MyFormatt.swift
//  SnoozeIsland
//
//  Created by jose Yun on 3/23/25.
//

import SwiftUI

let myFormat = Date.FormatStyle()
    .year(.omitted)
    .month(.omitted)
    .day(.omitted)
    .hour(.defaultDigits(amPM: .abbreviated))
    .minute(.twoDigits)
    .timeZone(.omitted)
    .era(.omitted)
    .dayOfYear(.omitted)
    .weekday(.omitted)
    .week(.omitted)
    .locale(Locale(identifier: "ko_KR"))

