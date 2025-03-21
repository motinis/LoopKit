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
    case insulinModelPreferences
    case sleepSchedule
}

extension PreferencesSetting: Equatable { }

public extension PreferencesSetting {
    var title: String {
        switch self {
        case .basalLock:
            return LocalizedString("Basal Lock", comment: "Title text for basal lock setting")
        case .mealRecommendationPreferences:
            return LocalizedString("Meal Bolus Defaults", comment: "Title text for Meal Bolus Defaults")
        case .insulinModelPreferences:
            return LocalizedString("Insulin Model Options", comment: "Title text for Insulin Model Options")
        case .sleepSchedule:
            return LocalizedString("Sleep Schedule", comment: "Title text for Sleep Schedule")
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
            return String(format: LocalizedString("Allows user to choose whether to include these effects for initial Bolus recommendation at meal entry. By default, Loop includes these carbohydrate and glucose effects.", comment: "Descriptive text for Meal Bolus Defaults for (1: app name)"), appName)
        case .insulinModelPreferences:
            return String(format: LocalizedString("Allows user to choose alternative insulin model behaviors", comment: "Descriptive text for Insulin Model Preferences for (1: app name)"), appName)
        case .sleepSchedule:
            return String(format: LocalizedString("Insulin absorption is modeled to be slower while sleeping.", comment: "Descriptive text for Sleep Schedule Preferences for (1: app name)"), appName)
        }
    }
}

// MARK: Guardrails
public extension PreferencesSetting {
    var guardrailCaptionForLowValue: String {
        switch self {
        case .basalLock:
            return LocalizedString("The value you have entered is lower than what is typically recommended.", comment: "Descriptive text for guardrail low value warning for basal lock")
        default:
            return LocalizedString("", comment: "")
        }
    }
    
    var guardrailCaptionForHighValue: String {
        switch self {
        case .basalLock:
            return LocalizedString("The value you have entered is higher than what is typically recommended.", comment: "Descriptive text for guardrail high value warning for basal lock")
        default:
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
