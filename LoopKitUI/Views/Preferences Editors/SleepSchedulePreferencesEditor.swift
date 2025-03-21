//
//  SleepSchedulePreferencesEditor.swift
//  LoopKit
//
//  Created by Moti Nisenson-Ken on 18/03/2025.
//  Copyright © 2025 LoopKit Authors. All rights reserved.
//

import SwiftUI
import HealthKit
import LoopKit

public struct SleepSchedulePreferenceEditor: View {
    @Environment(\.dismissAction) private var dismiss
    @Environment(\.authenticate) private var authenticate
    @Environment(\.appName) private var appName

    let viewModel: PreferencesViewModel
    let didSave: (() -> Void)?

    @State private var isSleepScheduleEnabled: Bool
    @State private var start: TimeInterval
    @State private var end: TimeInterval
    
    
    private static func toTimeInterval(_ date: Date?) -> TimeInterval? {
        guard let date = date else {
            return nil
        }

        return date.timeIntervalSince(date.dateFlooredToTimeInterval(.hours(24)))
    }
    
    private var initialEnabled: Bool {
        viewModel.isSleepScheduleEnabled
    }

    private var initialStart: TimeInterval? {
        SleepSchedulePreferenceEditor.toTimeInterval(viewModel.sleepSchedule?.asDateInterval().start)
    }
    
    private var initialEnd: TimeInterval? {
        SleepSchedulePreferenceEditor.toTimeInterval(viewModel.sleepSchedule?.asDateInterval().end)
    }
    
    
    public init(preferencesViewModel: PreferencesViewModel, didSave: (() -> Void)? = nil) {
        self.viewModel = preferencesViewModel
        self.didSave = didSave
        _isSleepScheduleEnabled = State(initialValue: viewModel.isSleepScheduleEnabled)
        _start = State(initialValue: SleepSchedulePreferenceEditor.toTimeInterval(viewModel.sleepSchedule?.asDateInterval().start) ??  .hours(22))
        _end = State(initialValue:  SleepSchedulePreferenceEditor.toTimeInterval(viewModel.sleepSchedule?.asDateInterval().end) ??  .hours(6))
    }
    
    public var body: some View {
        contentWithCancel
            .navigationBarTitle("", displayMode: .inline)
    }
    
    private var settingsChanged: Bool {
        isSleepScheduleEnabled != initialEnabled
        || (isSleepScheduleEnabled && (initialStart == nil || initialEnd == nil))
        || (isSleepScheduleEnabled && (start != initialStart! || end != initialEnd!))
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
    
    private var sleepTime: TimeInterval {
        if end > start {
            return end - start
        }
        return .hours(24) + end - start
    }

    private var content: some View {
        ConfigurationPage(
            title: Text(LocalizedString("Sleep Schedule", comment: "Title for Sleep Schedule editor")),
            actionButtonTitle: Text(LocalizedString("Save", comment: "Save button title")),
            actionButtonState: saveButtonState,
            cards: {
                Card {
                    description
                        .font(.callout)
                        .foregroundColor(Color(.secondaryLabel))
                        .fixedSize(horizontal: false, vertical: true)

                    Toggle(isOn: $isSleepScheduleEnabled) {
                        Text("🚧 Enable Sleep Schedule")
                    }.animation(.default, value: isSleepScheduleEnabled)
                    
                    if (isSleepScheduleEnabled) {
                        HStack {
                            TimePicker(
                                offsetFromMidnight: $start,
                                bounds: 0...(TimeInterval(hours: 24) - .minutes(15)),
                                stride: .minutes(15)
                            )
                            .accessibility(identifier: "start_time_picker")
                            Text(" - ")
                            TimePicker(
                                offsetFromMidnight: $end,
                                bounds: 0...(TimeInterval(hours: 24) - .minutes(15)),
                                stride: .minutes(15)
                            )
                        }
                        .transition(.slide)
                    }
                }
            },
            actionAreaContent: {
                if isSleepScheduleEnabled {
                    Group {
                        if sleepTime >= .hours(24) {
                            Text(LocalizedString("⚠️ 24 hour sleep schedule selected. Only use this if you want to always use the slowed down insulin absorption model", comment: "Warning message for 24 hour sleep schedule"))
                        } else if sleepTime > .hours(12) {
                            Text(LocalizedString("⚠️ Sleep schedule is longer than 12 hours", comment: "Warning message for long sleep schedule"))
                        }
                    }.transition(.slide)
                }
            },
            action: {
                finishSaving()
            }
        )
    }
       
    private var saveButtonState: ConfigurationPageActionButtonState {
        return settingsChanged ? .enabled : .disabled
    }
    
    private var description: Text {
        Text(
            LocalizedString(
                "While sleeping, blood flow is reduced and insulin absorption is slowed. Enabling this will result in slower absorption being modeled during the scheduled sleep time.",
                comment: "Description for Sleep Schedule Preference Editor"
            )
        )
    }
    
    

    private func finishSaving() {
        viewModel.updateSleepScheduleEnabled(isSleepScheduleEnabled)
        if isSleepScheduleEnabled {
            viewModel.updateSleepSchedule(
                SleepSchedule(
                    start: Date(timeIntervalSince1970: start),
                    duration: sleepTime
                )
            )
        }
        didSave?()
        dismiss()
    }
}
