//
//  BasalRateSchedule.swift
//  Naterade
//
//  Created by Nathan Racklyeft on 2/12/16.
//  Copyright © 2016 Nathan Racklyeft. All rights reserved.
//

import Foundation


public typealias BasalRateSchedule = DailyValueSchedule<Double>

public struct BasalScheduleValidationResult {
    let scheduleError: Error?
    let itemErrors: [(index: Int, error: Error)]
}


public extension DailyValueSchedule where T == Double {
    /**
     Calculates the total basal delivery for a day

     - returns: The total basal delivery
     */
    func total() -> Double {
        var total: Double = 0

        for (index, item) in items.enumerated() {
            var endTime = maxTimeInterval

            if index < items.endIndex - 1 {
                endTime = items[index + 1].startTime
            }

            total += (endTime - item.startTime).hours * item.value
        }
        
        return total
    }
}

public extension BasalRateSchedule {
    /// Gets the number of units scheduled to be delivered
    ///
    /// - Parameters:
    ///   - startDate: from when to start summing
    ///   - duration: for how long to sum the basal units
    /// - Returns: the number of units that would be deliver from date to date.addingTimeInterval(duration)
    func getBasalUnits(startDate: Date, duration: TimeInterval) -> Double {
        let endDate = startDate.addingTimeInterval(duration)
        var nextStartDate = startDate
        var basalUnits = 0.0

        for schedule in self.between(start: nextStartDate, end: endDate) {
            basalUnits += Swift.min(schedule.endDate, endDate).timeIntervalSince(nextStartDate).hours * schedule.value
            nextStartDate = schedule.endDate
        }
        
        return basalUnits
    }

}
