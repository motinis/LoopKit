//
//  RemoteActionDelegate.swift
//  LoopKit
//
//  Created by Bill Gestrich on 3/19/23.
//  Copyright © 2023 LoopKit Authors. All rights reserved.
//

import Foundation

public protocol RemoteActionDelegate: AnyObject {
    func enactRemoteOverride(name: String, durationTime: TimeInterval?, remoteAddress: String) async throws
    func cancelRemoteOverride() async throws
    func deliverRemoteCarbs(amountInGrams: Double, absorptionTime: TimeInterval?, foodType: String?, startDate: Date?,
                            bolusType: BolusType?) async throws
    func deliverRemoteBolus(amountInUnits: Double) async throws
}

public enum BolusType : Codable {
    case recommended, nonCorrecting
    
    public func amount(_ recommendation: ManualBolusRecommendation) -> Double {
        switch self {
        case .recommended: return recommendation.amount
        case .nonCorrecting: return Swift.min(recommendation.amount, recommendation.carbsAmount ?? 0)
        }
    }
}
