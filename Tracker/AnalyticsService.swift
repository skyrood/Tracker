//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Rodion Kim on 2025/07/21.
//

import Foundation
import AppMetricaCore

final class AnalyticsService {
    static let shared = AnalyticsService()
    
    private init() {}
    
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "f77df71b-28f0-4060-a59f-ea54bd402db6") else {
            return
        }
        
        AppMetrica.activate(with: configuration)
    }
    
    func reportEvent(event: String, params : [AnyHashable : Any]) {
        AppMetrica.reportEvent(name: event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
