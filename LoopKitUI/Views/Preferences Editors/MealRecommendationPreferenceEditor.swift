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

public struct MealRecommendationPreferenceEditor: View {
    @Environment(\.dismissAction) private var dismiss
    @Environment(\.authenticate) private var authenticate
    @Environment(\.appName) private var appName

    let viewModel: PreferencesViewModel
    let didSave: (() -> Void)?

    @State private var isCarbExcluded: Bool
    @State private var isCOBExcluded: Bool
    @State private var isBGCorrectionExcluded: Bool

    private var initialCarbExcluded: Bool {
        viewModel.isCarbEntryExcluded
    }
    private var initialCobExcluded: Bool {
        viewModel.isCobCorrectionExcluded
    }
    private var initialBgExcluded: Bool {
        viewModel.isBgCorrectionExcluded
    }

    public init(preferencesViewModel: PreferencesViewModel, didSave: (() -> Void)? = nil) {
        self.viewModel = preferencesViewModel
        self.didSave = didSave
        _isCarbExcluded = State(initialValue: preferencesViewModel.isCarbEntryExcluded)
        _isCOBExcluded = State(initialValue: preferencesViewModel.isCobCorrectionExcluded)
        _isBGCorrectionExcluded = State(initialValue: preferencesViewModel.isBgCorrectionExcluded)
    }

    public var body: some View {
        contentWithCancel
            .navigationBarTitle("", displayMode: .inline)
    }

    private var contentWithCancel: some View {
        content
            .navigationBarBackButtonHidden(
                isCarbExcluded != initialCarbExcluded
                || isCOBExcluded != initialCobExcluded
                || isBGCorrectionExcluded != initialBgExcluded
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    leadingNavigationBarItem
                }
            }
    }

    @ViewBuilder
    private var leadingNavigationBarItem: some View {
        if isCarbExcluded != initialCarbExcluded
            || isCOBExcluded != initialCobExcluded
            || isBGCorrectionExcluded != initialBgExcluded {
            Button(action: { dismiss() }) {
                Text(LocalizedString("Cancel", comment: "Cancel editing settings button title"))
            }
        } else {
            EmptyView()
        }
    }

    private var content: some View {
        ConfigurationPage(
            title: Text(LocalizedString("Meal Bolus Options", comment: "Title for Meal Bolus Options editor")),
            actionButtonTitle: Text(LocalizedString("Save", comment: "Save button title")),
            actionButtonState: saveButtonState,
            cards: {
                Card {
                    description
                        .font(.callout)
                        .foregroundColor(Color(.secondaryLabel))
                        .fixedSize(horizontal: false, vertical: true)

                    Toggle("Exclude Carb Entry by Default", isOn: $isCarbExcluded)
                    Toggle("Exclude COB Correction by Default", isOn: $isCOBExcluded)
                    Toggle("Exclude Glucose Correction by Default", isOn: $isBGCorrectionExcluded)
                }
            },
            actionAreaContent: {
            },
            action: {
                startSaving()
            }
        )
    }

    private var saveButtonState: ConfigurationPageActionButtonState {
        if isCarbExcluded != initialCarbExcluded
            || isCOBExcluded != initialCobExcluded
            || isBGCorrectionExcluded != initialBgExcluded {
            return .enabled
        }
        return .disabled
    }

    private var description: Text {
        Text(
            LocalizedString(
                "Meal Bolus Options allow you to choose which effects are included by default for bolus recommendations.",
                comment: "Description for Meal Recommendation Preference Editor"
            )
        )
    }

    private func startSaving() {
        authenticate(LocalizedString("Authentication is required to save these settings.", comment: "Authentication challenge description for meal preferences")) {
            switch $0 {
            case .success:
                continueSaving()
            case .failure:
                break
            }
        }
    }

    private func continueSaving() {
        viewModel.updateCarbEntryExcluded(isCarbExcluded)
        viewModel.updateCobCorrectionExcluded(isCOBExcluded)
        viewModel.updateBgCorrectionExcluded(isBGCorrectionExcluded)
        didSave?()
        dismiss()
    }
}
