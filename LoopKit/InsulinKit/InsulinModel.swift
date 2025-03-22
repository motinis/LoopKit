//
//  InsulinModel.swift
//  LoopKit
//
//  Created by Pete Schwamb on 7/26/17.
//  Copyright © 2017 LoopKit Authors. All rights reserved.
//

import Foundation


public protocol InsulinModel: CustomDebugStringConvertible {
    
    /// Returns the percentage of total insulin effect remaining at a specified interval after delivery; also known as Insulin On Board (IOB).
    /// Return value is within the range of 0-1
    ///
    /// - Parameters:
    ///   - time: The interval after insulin delivery
    func percentEffectRemaining(at time: TimeInterval) -> Double
    
    /// The expected duration, including any effect delay, of an insulin dose, from the time of the dose
    var effectDuration: TimeInterval { get }
    
    /// The time after the dose where the effect becomes non-zero
    var delay: TimeInterval { get }
}

public struct SleepSchedule : Equatable {
    
    /// offset since midnight
    public let start: TimeInterval
    
    /// up to 24hrs.
    public let duration: TimeInterval
    
    public init(start: TimeInterval, duration: TimeInterval) {
        self.init(start: Date(timeIntervalSince1970: start), duration: duration)
    }
    
    public init(start: Date, duration: TimeInterval) {
        self.init(DateInterval(start: start, duration: duration))
    }
    
    public init(_ interval: DateInterval) {
        self.start = interval.start.timeIntervalSince(interval.start.dateFlooredToTimeInterval(.hours(24)))
        self.duration = min(interval.duration, .hours(24))
    }
    
    public func intersection(with interval: DateInterval) -> TimeInterval {
        let intervalDays = floor(interval.duration / .hours(24))
        let offsetInterval = DateInterval(start: interval.start, duration: interval.duration - intervalDays * .hours(24))
        
        var result = intervalDays * duration
        
        let interval1 = DateInterval(start: interval.start.dateFlooredToTimeInterval(.hours(24)).addingTimeInterval(start), duration: duration)
        let interval2 = DateInterval(start: interval1.start.addingTimeInterval(.hours(24)), duration: duration)
        let interval3 = DateInterval(start: interval1.start.addingTimeInterval(.hours(-24)), duration: duration)
        
        result += offsetInterval.intersection(with: interval1)?.duration ?? 0
        result += offsetInterval.intersection(with: interval2)?.duration ?? 0
        result += offsetInterval.intersection(with: interval3)?.duration ?? 0
        
        return result
    }
    
    public func asDateInterval() -> DateInterval {
        DateInterval(start: Date().dateFlooredToTimeInterval(.hours(24)).addingTimeInterval(start), duration: duration)
    }
    
    static public func == (lhs: SleepSchedule, rhs: SleepSchedule) -> Bool {
        lhs.start == rhs.start && lhs.duration == rhs.duration
    }
    
}

public extension InsulinModel {
    
    private var slowdownFactor: Double { 0.3 }
    
    /// Returns the percentage of total insulin effect remaining at a specified date after delivery; also known as Insulin On Board (IOB).
    /// Takes into account a slowdown factor that occurs during sleep. Return value is within the range of 0-1
    ///
    /// - Parameters:
    ///   - doseDate: when the insulin was delivered
    ///   - time: The interval after insulin delivery
    ///   - sleepSchedule: during what period of time the absorption should be slowed down
    func percentEffectRemaining(doseDate: Date, at time: TimeInterval, sleepSchedule: SleepSchedule? = nil) -> Double {
        guard let sleepSchedule = sleepSchedule, time > delay else {
            return percentEffectRemaining(at: time)
        }
                
        // slowdown does not impact delay
        let interval = DateInterval(start: doseDate.addingTimeInterval(delay), duration: time - delay)
        
        return percentEffectRemaining(at: time - slowdownFactor * sleepSchedule.intersection(with: interval))
    }
    
    /// The expected duration, including any effect delay, of an insulin dose, from the time of the dose
    /// - Parameters:
    ///   - doseDate: when the insulin was delivered
    ///   - sleepSchedule: during what period of time the absorption should be slowed down
    func effectDuration(at doseDate: Date, sleepSchedule: SleepSchedule? = nil) -> TimeInterval {
        guard let sleepSchedule = sleepSchedule else {
            return effectDuration
        }
        
        let interval = DateInterval(start: doseDate.addingTimeInterval(delay), duration: effectDuration - delay)
        let slowdownPeriod = sleepSchedule.intersection(with: interval)
        
        return effectDuration - slowdownPeriod + slowdownPeriod / (1 - slowdownFactor)
    }

    var maxPossibleEffectDuration: TimeInterval {
        return effectDuration(at: Date(), sleepSchedule: SleepSchedule(start: 0, duration: .hours(24)))
    }
}


