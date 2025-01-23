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
    @Published var basalLockThreshold: HKQuantity
    @Published var isBasalLockEnabled: Bool
    @Published var isCarbEntryExcluded: Bool
    @Published var isCobCorrectionExcluded: Bool
    @Published var isBgCorrectionExcluded: Bool

    private var preferencesProvider: PreferencesProvider
    
    public init(preferencesProvider: PreferencesProvider) {
        self.preferencesProvider = preferencesProvider
        self.basalLockThreshold = preferencesProvider.basalLockThreshold
        self.isBasalLockEnabled = preferencesProvider.isBasalLockEnabled
        self.isCarbEntryExcluded = preferencesProvider.isCarbEntryExcluded
        self.isCobCorrectionExcluded = preferencesProvider.isCobCorrectionExcluded
        self.isBgCorrectionExcluded = preferencesProvider.isBgCorrectionExcluded
    }
    
    func updateBasalLockThreshold(_ newValue: HKQuantity) {
        preferencesProvider.basalLockThreshold = newValue
        self.basalLockThreshold = newValue
    }
    
    func updateBasalLockEnabled(_ newValue: Bool) {
        preferencesProvider.isBasalLockEnabled = newValue
        self.isBasalLockEnabled = newValue
    }
    
    func updateCarbEntryExcluded(_ newValue: Bool) {
        preferencesProvider.isCarbEntryExcluded = newValue
        self.isCarbEntryExcluded = newValue
    }
    
    func updateCobCorrectionExcluded(_ newValue: Bool) {
        preferencesProvider.isCobCorrectionExcluded = newValue
        self.isCobCorrectionExcluded = newValue
    }

    func updateBgCorrectionExcluded(_ newValue: Bool) {
        preferencesProvider.isBgCorrectionExcluded = newValue
        self.isBgCorrectionExcluded = newValue
    }
}
