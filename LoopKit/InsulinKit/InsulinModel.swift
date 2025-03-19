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

public typealias SleepSchedule = DateInterval

public extension InsulinModel {
    
    var slowdownFactor: Double { 0.3 }
    
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
        
        let doseStart = sleepSchedule.start.dateFlooredToTimeInterval(.hours(24)).addingTimeInterval(           doseDate.timeIntervalSince(doseDate.dateFlooredToTimeInterval(.hours(24))))
        
        // slowdown does not impact delay
        let interval = DateInterval(start: doseStart + delay, duration: time - delay)
        let slowdownPeriod = sleepSchedule.intersection(with: interval)?.duration ?? 0
        
        return percentEffectRemaining(at: time - slowdownFactor * slowdownPeriod)
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
        let slowdownPeriod = sleepSchedule.intersection(with: interval)?.duration ?? 0
        
        return effectDuration - slowdownPeriod + slowdownPeriod / (1 - slowdownFactor)
    }

    var maxPossibleEffectDuration: TimeInterval {
        return effectDuration(at: Date(), sleepSchedule: SleepSchedule(start: .distantPast, end: .distantFuture))
    }
}


