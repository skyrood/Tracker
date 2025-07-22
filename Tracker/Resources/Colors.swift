//
//  Colors.swift
//  Tracker
//
//  Created by Rodion Kim on 2025/07/17.
//

import UIKit

struct Colors {
    static let primary = requireColor("YPPrimaryColor")
    static let secondary = requireColor("YPSecondaryColor")
    static let inputBackground = requireColor("YPInputBackground")
    static let blue = requireColor("YPBlue")
    static let gray = requireColor("YPGray")
    static let lightGray = requireColor("YPLightGray")
    static let red = requireColor("YPRed")
    static let shadow = requireColor("YPShadow")

    static let selection: [String: UIColor] = [
        "Selection 1": requireColor("Selection 1"),
        "Selection 2": requireColor("Selection 2"),
        "Selection 3": requireColor("Selection 3"),
        "Selection 4": requireColor("Selection 4"),
        "Selection 5": requireColor("Selection 5"),
        "Selection 6": requireColor("Selection 6"),
        "Selection 7": requireColor("Selection 7"),
        "Selection 8": requireColor("Selection 8"),
        "Selection 9": requireColor("Selection 9"),
        "Selection 10": requireColor("Selection 10"),
        "Selection 11": requireColor("Selection 11"),
        "Selection 12": requireColor("Selection 12"),
        "Selection 13": requireColor("Selection 13"),
        "Selection 14": requireColor("Selection 14"),
        "Selection 15": requireColor("Selection 15"),
        "Selection 16": requireColor("Selection 16"),
        "Selection 17": requireColor("Selection 17"),
        "Selection 18": requireColor("Selection 18")
    ]
    
    static let sortedKeys = Colors.selection.keys.sorted {
        extractNumber(from: $0) < extractNumber(from: $1)
    }
    
    static private func extractNumber(from key: String) -> Int {
        let number = key.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return Int(number) ?? 0
    }
    
    static private func requireColor(_ name: String) -> UIColor {
        guard let color = UIColor(named: name) else {
            fatalError("Missing expected color \(name)")
        }
        return color
    }
}
