//
//  InsulinModelPreferenceEditor.swift
//  LoopKit
//
//  Created by Moti Nisenson-Ken on 13/02/2025.
//  Copyright © 2025 LoopKit Authors. All rights reserved.
//


import SwiftUI
import HealthKit
import LoopKit

public struct InsulinModelPreferenceEditor: View {
    @Environment(\.dismissAction) private var dismiss
    @Environment(\.authenticate) private var authenticate
    @Environment(\.appName) private var appName
    
    let viewModel: PreferencesViewModel
    
    let didSave: (() -> Void)?
    @State private var useRapidActingChildInsulinModel: Bool
    @State private var useFastLyumjevInsulinModel: Bool

    private var initialUseRapidActingChildInsulinModel: Bool {
        viewModel.useRapidActingChildInsulinModel
    }
    private var initialUseFastLyumjevInsulinModel: Bool {
        viewModel.useFastLyumjevInsulinModel
    }

    public init(preferencesViewModel: PreferencesViewModel, didSave: (() -> Void)? = nil) {
        self.viewModel = preferencesViewModel
        self.didSave = didSave
        _useRapidActingChildInsulinModel = State(initialValue: preferencesViewModel.useRapidActingChildInsulinModel)
        _useFastLyumjevInsulinModel = State(initialValue: preferencesViewModel.useFastLyumjevInsulinModel)
    }

    public var body: some View {
        contentWithCancel
            .navigationBarTitle("", displayMode: .inline)
    }
    
    private var settingsChanged: Bool {
        useRapidActingChildInsulinModel != initialUseRapidActingChildInsulinModel
            || useFastLyumjevInsulinModel != initialUseFastLyumjevInsulinModel
    }

    private var contentWithCancel: some View {
        content
            .navigationBarBackButtonHidden(settingsChanged)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    leadingNavigationBarItem
                }
            }
    }

    @ViewBuilder
    private var leadingNavigationBarItem: some View {
        if settingsChanged {
            Button(action: { dismiss() }) {
                Text(LocalizedString("Cancel", comment: "Cancel editing settings button title"))
            }
        } else {
            EmptyView()
        }
    }

    private var content: some View {
        ConfigurationPage(
            title: Text(LocalizedString("Insulin Model Options", comment: "Title for Insulin Model Options editor")),
            actionButtonTitle: Text(LocalizedString("Save", comment: "Save button title")),
            actionButtonState: saveButtonState,
            cards: {
                Card {
                    description
                        .font(.callout)
                        .foregroundColor(Color(.secondaryLabel))
                        .fixedSize(horizontal: false, vertical: true)

                    Toggle("Use Rapid Acting Child", isOn: $useRapidActingChildInsulinModel)
                    Toggle("Use Fast Lyumjev", isOn: $useFastLyumjevInsulinModel)
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
        if settingsChanged {
            return .enabled
        }
        return .disabled
    }

    private var description: Text {
        Text(
            LocalizedString(
                "Insulin Model Options allow you to customize the insulin model for different insulin types. Enabling the Rapid Acting Child Model will force that model to be used for rapid acting, even if you previously had set the Rapid Acting Model to Adult, when using the ADULT_CHILD_INSULIN_MODEL_SELECTION_ENABLED feature flag. Fast Lyumjev represents a slightly faster acting model for Lyumjev, then the default which matches Fiasp.",
                comment: "Description for Meal Recommendation Preference Editor"
            )
        )
    }

    private func startSaving() {
        authenticate(LocalizedString("Authentication is required to save this setting.", comment: "Authentication challenge description for insulin model preferences")) {
            switch $0 {
            case .success: self.continueSaving()
            case .failure: break
            }
        }
    }
    
    private func continueSaving() {
        viewModel.updateUseRapidActingChildInsulinModel(useRapidActingChildInsulinModel)
        viewModel.updateUseFastLyumjevInsulinModel(useFastLyumjevInsulinModel)
        didSave?()
        dismiss()
    }
}

