//
//  MealRecommendationPreferenceEditor.swift
//  LoopKit
//
//  Created by Jonas Björkert on 2025-01-27.
//  Copyright © 2025 LoopKit Authors. All rights reserved.
//

import SwiftUI
import HealthKit
import LoopKit

public struct MealBolusPreferenceEditor: View {
    @Environment(\.dismissAction) private var dismiss
    @Environment(\.authenticate) private var authenticate
    @Environment(\.appName) private var appName

    let viewModel: PreferencesViewModel
    let didSave: (() -> Void)?

    @State private var isCarbIncluded: Bool
    @State private var isCOBIncluded: Bool
    @State private var isBGCorrectionIncluded: Bool
    @State private var isDetectDuplicateMealsEnabled: Bool

    private var initialCarbIncluded: Bool {
        !viewModel.isCarbEntryExcluded
    }
    private var initialCobIncluded: Bool {
        !viewModel.isCobCorrectionExcluded
    }
    private var initialBgIncluded: Bool {
        !viewModel.isBgCorrectionExcluded
    }
    private var initialDetectDuplicateMealsEnabled: Bool {
        viewModel.isDetectMealDuplicatesEnabled
    }

    public init(preferencesViewModel: PreferencesViewModel, didSave: (() -> Void)? = nil) {
        self.viewModel = preferencesViewModel
        self.didSave = didSave
        _isCarbIncluded = State(initialValue: !preferencesViewModel.isCarbEntryExcluded)
        _isCOBIncluded = State(initialValue: !preferencesViewModel.isCobCorrectionExcluded)
        _isBGCorrectionIncluded = State(initialValue: !preferencesViewModel.isBgCorrectionExcluded)
        _isDetectDuplicateMealsEnabled = State(initialValue: preferencesViewModel.isDetectMealDuplicatesEnabled)
    }

    public var body: some View {
        contentWithCancel
            .navigationBarTitle("", displayMode: .inline)
    }

    private var contentWithCancel: some View {
        content
            .navigationBarBackButtonHidden(
                isCarbIncluded != initialCarbIncluded
                || isCOBIncluded != initialCobIncluded
                || isBGCorrectionIncluded != initialBgIncluded
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    leadingNavigationBarItem
                }
            }
    }

    @ViewBuilder
    private var leadingNavigationBarItem: some View {
        if isCarbIncluded != initialCarbIncluded
            || isCOBIncluded != initialCobIncluded
            || isBGCorrectionIncluded != initialBgIncluded {
            Button(action: { dismiss() }) {
                Text(LocalizedString("Cancel", comment: "Cancel editing settings button title"))
            }
        } else {
            EmptyView()
        }
    }

    private var content: some View {
        ConfigurationPage(
            title: Text(LocalizedString("Meal Bolus Defaults", comment: "Title for Meal Bolus Defaults editor")),
            actionButtonTitle: Text(LocalizedString("Save", comment: "Save button title")),
            actionButtonState: saveButtonState,
            cards: {
                Card {
                    description
                        .font(.callout)
                        .foregroundColor(Color(.secondaryLabel))
                        .fixedSize(horizontal: false, vertical: true)

                    Toggle("Include Carb Entry", isOn: $isCarbIncluded)
                    Toggle("Include COB Correction", isOn: $isCOBIncluded)
                    Toggle("Include Glucose Correction", isOn: $isBGCorrectionIncluded)
                    Toggle("Detect Duplicate Meals", isOn: $isDetectDuplicateMealsEnabled)
                }
            },
            actionAreaContent: {
            },
            action: {
                finishSaving()
            }
        )
    }

    private var saveButtonState: ConfigurationPageActionButtonState {
        if isCarbIncluded != initialCarbIncluded
            || isCOBIncluded != initialCobIncluded
            || isBGCorrectionIncluded != initialBgIncluded
            || isDetectDuplicateMealsEnabled != initialDetectDuplicateMealsEnabled {
            return .enabled
        }
        return .disabled
    }

    private var description: Text {
        Text(
            LocalizedString(
                "Meal Bolus Defaults allow you to choose which effects are included by default for bolus recommendations. Excluded effects are summed with the negative Max Bolus Limit and Glucose Safety Theshold values. If the sum is positive, then they are all excluded. Otherwise, the effects are already covered, and no exclusion is necessary.\n\nYou may also choose whether Loop should check for duplicate carb entries in the 15 minutes prior to the current meal.",
                comment: "Description for Meal Bolus Preference Editor"
            )
        )
    }

    private func finishSaving() {
        viewModel.updateCarbEntryExcluded(!isCarbIncluded)
        viewModel.updateCobCorrectionExcluded(!isCOBIncluded)
        viewModel.updateBgCorrectionExcluded(!isBGCorrectionIncluded)
        viewModel.updateDetectDuplicateMealsEnabled(isDetectDuplicateMealsEnabled)
        didSave?()
        dismiss()
    }
}
