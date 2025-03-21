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
    @State private var useNewChildInsulinModel: Bool
    @State private var useRapidActingChildInsulinModel: Bool
    @State private var useFastLyumjevInsulinModel: Bool

    private var initialUseNewChildInsulinModel: Bool {
        viewModel.useNewChildInsulinModel
    }
    private var initialUseRapidActingChildInsulinModel: Bool {
        viewModel.useRapidActingChildInsulinModel
    }
    private var initialUseFastLyumjevInsulinModel: Bool {
        viewModel.useFastLyumjevInsulinModel
    }

    public init(preferencesViewModel: PreferencesViewModel, didSave: (() -> Void)? = nil) {
        self.viewModel = preferencesViewModel
        self.didSave = didSave
        _useNewChildInsulinModel = State(initialValue: preferencesViewModel.useNewChildInsulinModel)
        _useRapidActingChildInsulinModel = State(initialValue: preferencesViewModel.useRapidActingChildInsulinModel)
        _useFastLyumjevInsulinModel = State(initialValue: preferencesViewModel.useFastLyumjevInsulinModel)
    }

    public var body: some View {
        contentWithCancel
            .navigationBarTitle("", displayMode: .inline)
    }
    
    private var settingsChanged: Bool {
        useNewChildInsulinModel != initialUseNewChildInsulinModel
            || useRapidActingChildInsulinModel != initialUseRapidActingChildInsulinModel
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
                    Toggle("🚧 Use New Child Models", isOn: $useNewChildInsulinModel)
                        .disabled(useRapidActingChildInsulinModel || useFastLyumjevInsulinModel)
                    Toggle("Use Rapid Acting Child", isOn: $useRapidActingChildInsulinModel)
                        .disabled(useNewChildInsulinModel)
                    Toggle("Use Fast Lyumjev", isOn: $useFastLyumjevInsulinModel)
                        .disabled(useNewChildInsulinModel)
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

    private var description: any View {
        VStack {
            Text(
                LocalizedString(
                    "Insulin Model Options allow you to customize the insulin model for different insulin types. These choices override any other changes made (e.g., via feature flag or hard-coding).",
                    comment: "Description for Insulin Model Options Preference Editor"
                )
            ).font(.callout)

            HStack(alignment: .top) {
                Text("•")
                Text(LocalizedString("New Child: models tuned for ages 6-11. Faster for Fiasp. Much faster for Novolog, Humalog, and Lyumjev. Apidra behaves similarly in children and adults, so it is not applicable. May not be used with the other options", comment: "description of new child models"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }.font(.subheadline)
            HStack(alignment: .top) {
                Text("•")
                Text(LocalizedString("Rapid Acting Child: slightly faster model for all rapid-acting insulins (Novolog, Humalog, and Apidra). This was previously configurable via a feature flag", comment: "description of rapid child model"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }.font(.subheadline)
            HStack(alignment: .top) {
                Text("•")
                Text(LocalizedString("Fast Lyumjev: slightly faster acting model than the default which matches Fiasp", comment: "description of fast lyumjev model"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }.font(.subheadline)

        }
        .foregroundColor(Color(.secondaryLabel))
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
        viewModel.updateUseNewChildInsulinModel(useNewChildInsulinModel)
        viewModel.updateUseRapidActingChildInsulinModel(useRapidActingChildInsulinModel)
        viewModel.updateUseFastLyumjevInsulinModel(useFastLyumjevInsulinModel)
        didSave?()
        dismiss()
    }
}

