//
//  PreferencesViewModel.swift
//  LoopKitUI
//
//  Created by Jonas Björkert on 2024-02-25.
//  Copyright © 2024 LoopKit Authors. All rights reserved.
//

import Foundation
import LoopKit
import HealthKit

public class PreferencesViewModel: ObservableObject {
    @Published public var basalLockThreshold: HKQuantity
    @Published public var isBasalLockEnabled: Bool
    @Published public var isCarbEntryExcluded: Bool
    @Published public var isCobCorrectionExcluded: Bool
    @Published public var isBgCorrectionExcluded: Bool
    @Published public var useNewChildInsulinModel: Bool
    @Published public var useRapidActingChildInsulinModel: Bool
    @Published public var useFastLyumjevInsulinModel: Bool
    @Published public var isSleepScheduleEnabled: Bool
    @Published public var sleepSchedule: SleepSchedule?

    private var preferencesProvider: PreferencesProvider
    
    public init(preferencesProvider: PreferencesProvider) {
        self.preferencesProvider = preferencesProvider
        self.basalLockThreshold = preferencesProvider.basalLockThreshold
        self.isBasalLockEnabled = preferencesProvider.isBasalLockEnabled
        self.isCarbEntryExcluded = preferencesProvider.isCarbEntryExcluded
        self.isCobCorrectionExcluded = preferencesProvider.isCobCorrectionExcluded
        self.isBgCorrectionExcluded = preferencesProvider.isBgCorrectionExcluded
        self.useNewChildInsulinModel = preferencesProvider.useNewChildInsulinModel
        self.useRapidActingChildInsulinModel = preferencesProvider.useRapidActingChildInsulinModel
        self.useFastLyumjevInsulinModel = preferencesProvider.useFastLyumjevInsulinModel
        self.isSleepScheduleEnabled = preferencesProvider.isSleepScheduleEnabled
        self.sleepSchedule = preferencesProvider.sleepSchedule
    }
    
    public func updateBasalLockThreshold(_ newValue: HKQuantity) {
        preferencesProvider.basalLockThreshold = newValue
        self.basalLockThreshold = newValue
    }
    
    public func updateBasalLockEnabled(_ newValue: Bool) {
        preferencesProvider.isBasalLockEnabled = newValue
        self.isBasalLockEnabled = newValue
    }
    
    public func updateCarbEntryExcluded(_ newValue: Bool) {
        preferencesProvider.isCarbEntryExcluded = newValue
        self.isCarbEntryExcluded = newValue
    }
    
    public func updateCobCorrectionExcluded(_ newValue: Bool) {
        preferencesProvider.isCobCorrectionExcluded = newValue
        self.isCobCorrectionExcluded = newValue
    }

    public func updateBgCorrectionExcluded(_ newValue: Bool) {
        preferencesProvider.isBgCorrectionExcluded = newValue
        self.isBgCorrectionExcluded = newValue
    }
    
    public func updateUseNewChildInsulinModel(_ newValue: Bool) {
        preferencesProvider.useNewChildInsulinModel = newValue
        self.useNewChildInsulinModel = newValue
    }
    
    public func updateUseRapidActingChildInsulinModel(_ newValue: Bool) {
        preferencesProvider.useRapidActingChildInsulinModel = newValue
        self.useRapidActingChildInsulinModel = newValue
    }
    
    public func updateUseFastLyumjevInsulinModel(_ newValue: Bool) {
        preferencesProvider.useFastLyumjevInsulinModel = newValue
        self.useFastLyumjevInsulinModel = newValue
    }
    
    public func updateSleepScheduleEnabled(_ newValue: Bool) {
        preferencesProvider.isSleepScheduleEnabled = newValue
        self.isSleepScheduleEnabled = newValue
    }
    
    public func updateSleepSchedule(_ newValue: SleepSchedule?) {
        preferencesProvider.sleepSchedule = newValue
        self.sleepSchedule = newValue
    }
}
