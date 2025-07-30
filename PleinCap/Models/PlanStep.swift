//
//  PlanStep.swift
//  PFE_APP
//
//  Created by chaabani achref on 23/7/2025.
//

import Foundation
import SwiftUICore
struct PlanStep {
    var title: String
    var description: String
    var dateRange: String
    var isDone: Bool = false
    var viewBuilder: (_ onComplete: @escaping () -> Void) -> AnyView
}
