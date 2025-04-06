//
//  PreferencesProvider.swift
//  LoopKit
//
//  Created by Jonas Björkert on 2024-02-25.
//  Copyright © 2024 LoopKit Authors. All rights reserved.
//

import Foundation
import HealthKit

public protocol PreferencesProvider {
    var basalLockThreshold: HKQuantity { get set }
    var isBasalLockEnabled: Bool { get set }
    var isCarbEntryExcluded: Bool { get set }
    var isCobCorrectionExcluded: Bool { get set }
    var isBgCorrectionExcluded: Bool { get set }
    var isDetectMealDuplicatesEnabled: Bool { get set }
    var useNewChildInsulinModel: Bool { get set }
    var useRapidActingChildInsulinModel: Bool { get set }
    var useFastLyumjevInsulinModel: Bool { get set }
    var isSleepScheduleEnabled: Bool { get set }
    var sleepSchedule: SleepSchedule? { get set }
}
