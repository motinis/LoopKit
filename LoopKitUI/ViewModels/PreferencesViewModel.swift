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
    @Published public var isDetectMealDuplicatesEnabled: Bool

    private var preferencesProvider: PreferencesProvider
    
    public init(preferencesProvider: PreferencesProvider) {
        self.preferencesProvider = preferencesProvider
        self.basalLockThreshold = preferencesProvider.basalLockThreshold
        self.isBasalLockEnabled = preferencesProvider.isBasalLockEnabled
        self.isCarbEntryExcluded = preferencesProvider.isCarbEntryExcluded
        self.isCobCorrectionExcluded = preferencesProvider.isCobCorrectionExcluded
        self.isBgCorrectionExcluded = preferencesProvider.isBgCorrectionExcluded
        self.isDetectMealDuplicatesEnabled = preferencesProvider.isDetectMealDuplicatesEnabled
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
    
    public func updateDetectDuplicateMealsEnabled(_ newValue: Bool) {
        preferencesProvider.isDetectMealDuplicatesEnabled = newValue
        self.isDetectMealDuplicatesEnabled = newValue
    }

}
