//
//  PreferencesView.swift
//  LoopKitUI
//
//  Created by Jonas Björkert on 2024-02-25.
//  Copyright © 2024 LoopKit Authors. All rights reserved.
//

import SwiftUI
import LoopKit
import HealthKit

public struct PreferencesView: View {
    @Environment(\.dismissAction) private var dismiss
    @Environment(\.appName) private var appName
    @EnvironmentObject var displayGlucosePreference: DisplayGlucosePreference
    
    @ObservedObject var viewModel: PreferencesViewModel
    
    private let timeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short

        return dateFormatter
    }()

    
    public init(viewModel: PreferencesViewModel) {
        self.viewModel = viewModel
    }
    
    private static func createFormatter(for unit: HKUnit) -> NumberFormatter {
        let quantityFormatter = QuantityFormatter(for: unit)
        return quantityFormatter.numberFormatter
    }
    
    public var body: some View {
        navigationViewWrappedContent
    }
    
    private var formatter: NumberFormatter {
        let quantityFormatter = QuantityFormatter(for: displayGlucosePreference.unit)
        return quantityFormatter.numberFormatter
    }
}

extension PreferencesView {
    private var navigationViewWrappedContent: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                content
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            dismissButton
                        }
                    }
                    .navigationBarTitle(preferencesTitle, displayMode: .large)
            }
        }
    }
    
    private var dismissButton: some View {
        Button(action: dismiss) {
            Text("Done")
        }
    }
    
    private var preferencesTitle: String {
        return "Preferences"
    }
    
    private var content: some View {
        CardList(title: nil, style: .sectioned(cardListSections)) //, trailer: cardListTrailer
    }
    
    private var cardListSections: [CardListSection] {
        var cardListSections: [CardListSection] = []
        
        cardListSections.append(preferencesCardListSection)
        
        return cardListSections
    }
    
    private var preferencesCardListSection: CardListSection {
        CardListSection {
            preferencesCardStack
                .spacing(20)
        }
    }
    
    private var preferencesCardStack: CardStack {
        var cards: [Card] = []
        
        cards.append(basalLockSection)
        cards.append(mealBolusPreferenceSection)
        cards.append(insulinModelPreferenceSection)
        cards.append(sleepSchedulePreferencesSection)

        return CardStack(cards: cards)
    }
    
    @ViewBuilder
    func screen(for setting: PreferencesSetting, dismiss: @escaping () -> Void) -> some View {
        switch setting {
        case .basalLock:
            BasalLockEditor(preferencesViewModel: viewModel, didSave: dismiss)
        case .mealBolusPreferences:
            MealBolusPreferenceEditor(preferencesViewModel: viewModel, didSave: dismiss)
        case .insulinModelPreferences:
            InsulinModelPreferenceEditor(preferencesViewModel: viewModel, didSave: dismiss)
        case .sleepSchedule:
            SleepSchedulePreferenceEditor(preferencesViewModel: viewModel, didSave: dismiss)
        }
    }
    
    private func card<Content>(for preferencesSetting: PreferencesSetting, @ViewBuilder content: @escaping () -> Content) -> Card where Content: View {
        Card {
            SectionWithTapToEdit(
                isEnabled: true,
                title: preferencesSetting.title,
                descriptiveText: preferencesSetting.descriptiveText(appName: appName),
                destination: { dismiss in
                    screen(for: preferencesSetting, dismiss: dismiss)
                        .environment(\.dismissAction, dismiss)
                },
                content: content
            )
        }
    }
    
    private var basalLockSection: Card {
        card(for: .basalLock) {
            SectionDivider()
            HStack {
                Spacer()
                if viewModel.isBasalLockEnabled {
                    HStack(alignment: .firstTextBaseline) {
                        Text(formatter.string(for: viewModel.basalLockThreshold.doubleValue(for: displayGlucosePreference.unit)) ?? "")
                        Text(displayGlucosePreference.unit.shortLocalizedUnitString())
                            .foregroundColor(Color(.secondaryLabel))
                    }
                } else {
                    Text("Off")
                        .foregroundColor(Color(.secondaryLabel))
                }
            }
        }
    }

    private var mealBolusPreferenceSection: Card {
        card(for: .mealBolusPreferences) {
            SectionDivider()
            VStack(alignment: .leading, spacing: 8) {
                checkmarkRow(title: "Carb Entry", included: !viewModel.isCarbEntryExcluded)
                checkmarkRow(title: "COB Correction", included: !viewModel.isCobCorrectionExcluded)
                checkmarkRow(title: "Glucose Correction", included: !viewModel.isBgCorrectionExcluded)
                checkmarkRow(title: "Detect Duplicate Meals", included: viewModel.isDetectMealDuplicatesEnabled)
            }
            .padding(.vertical, 8)
        }
    }
    
    private var insulinModelPreferenceSection: Card {
        card(for: .insulinModelPreferences) {
            SectionDivider()
            VStack(alignment: .leading, spacing: 8) {
                checkmarkRow(title: "Child Models", included: viewModel.useRapidActingChildInsulinModel || viewModel.useNewChildInsulinModel)
                checkmarkRow(title: "Fast Lyumjev", included: viewModel.useFastLyumjevInsulinModel)
            }
            .padding(.vertical, 8)
        }
    }

    private func checkmarkRow(title: String, included: Bool) -> some View {
        HStack {
            Text(title)
            Spacer()
            if included {
                Image(systemName: "checkmark")
                    .foregroundColor(.gray)
            }
        }
    }
        
    private var sleepSchedulePreferencesSection: Card {
        let fixedMidnight = Calendar.current.startOfDay(for: Date(timeIntervalSinceReferenceDate: 0))

        return card(for: .sleepSchedule) {
            SectionDivider()
            HStack(alignment: .firstTextBaseline) {
                Text(LocalizedString("Sleep Schedule:", comment: "sleep schedule title"))
                Spacer()
                if viewModel.isSleepScheduleEnabled, let sleepSchedule = viewModel.sleepSchedule {
                    Text(timeFormatter.string(from: fixedMidnight.addingTimeInterval(sleepSchedule.start)))
                    Text(" - ")
                    Text(timeFormatter.string(from: fixedMidnight.addingTimeInterval(sleepSchedule.start + sleepSchedule.duration)))
                } else {
                    Text("Off")
                }
            }.foregroundColor(Color(.secondaryLabel))
        }
    }
}

fileprivate struct SectionDivider: View {
    var body: some View {
        Divider()
            .padding(.trailing, -16)
    }
}

