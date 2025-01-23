//
//  PreferencesSetting.swift
//  LoopKit
//
//  Created by Jonas Björkert on 2024-02-25.
//  Copyright © 2024 LoopKit Authors. All rights reserved.
//

import Foundation

public enum PreferencesSetting {
    case basalLock
    case mealRecommendationPreferences
}

extension PreferencesSetting: Equatable { }

public extension PreferencesSetting {
    var title: String {
        switch self {
        case .basalLock:
            return LocalizedString("Basal Lock", comment: "Title text for basal lock setting")
        case .mealRecommendationPreferences:
            return LocalizedString("Meal Entry Preference", comment: "Title text for meal entry preferences")
        }
    

    }
    
    var smallTitle: String {
        return title
    }
    
    func descriptiveText(appName: String) -> String {
        switch self {
        case .basalLock:
            return String(format: LocalizedString("Basal Lock prevents the basal rate from being throttled if the blood glucose is above a certain level.", comment: "Descriptive text for basal lock (1: app name)"), appName)
        case .mealRecommendationPreferences:
            return String(format: LocalizedString("Meal Entry Preferences allows selective choice of what effects to include by default for bolus recommendation", comment: "Descriptive text for meal entry preferences for (1: app name)"), appName)
        }
    }
}

// MARK: Guardrails
public extension PreferencesSetting {
    var guardrailCaptionForLowValue: String {
        switch self {
        case .basalLock:
            return LocalizedString("The value you have entered is lower than what is typically recommended.", comment: "Descriptive text for guardrail low value warning for basal lock")
        case .mealRecommendationPreferences:
            return LocalizedString("", comment: "")
        }
    }
    
    var guardrailCaptionForHighValue: String {
        switch self {
        case .basalLock:
            return LocalizedString("The value you have entered is higher than what is typically recommended.", comment: "Descriptive text for guardrail high value warning for basal lock")
        case .mealRecommendationPreferences:
            return LocalizedString("", comment: "")
        }
    }
    
    var guardrailCaptionForOutsideValues: String {
        return LocalizedString("The value you have entered for Basal Lock is outside of the recommended range.", comment: "Descriptive text for guardrail outside value warning for basal lock")
    }
    
    var guardrailSaveWarningCaption: String {
        return LocalizedString("Please note that this value is outside of the recommended range.", comment: "Descriptive text for saving settings outside the recommended range for basal lock")
    }
}
