//
//  Colors.swift
//  Tracker
//
//  Created by Rodion Kim on 2025/07/17.
//

import UIKit

struct Colors {
    static let background = UIColor(named: "Background") ?? .systemBackground
    static let black = UIColor(named: "Black") ?? .black
    static let blue = UIColor(named: "Blue") ?? .blue
    static let gray = UIColor(named: "Gray") ?? .gray
    static let inputBackground = UIColor(named: "InputBackground") ?? .darkGray
    static let lightGray = UIColor(named: "LightGray") ?? .lightGray
    static let red = UIColor(named: "Red") ?? .red
    static let shadow = UIColor(named: "Shadow") ?? .shadow
    static let white = UIColor(named: "White") ?? .white
    
    // selection colors
    static let selection: [String: UIColor] = [
        "Selection 1": UIColor(named: "Selection 1") ?? .red,
        "Selection 2": UIColor(named: "Selection 2") ?? .orange,
        "Selection 3": UIColor(named: "Selection 3") ?? .blue,
        "Selection 4": UIColor(named: "Selection 4") ?? .purple,
        "Selection 5": UIColor(named: "Selection 5") ?? .green,
        "Selection 6": UIColor(named: "Selection 6") ?? .purple,
        "Selection 7": UIColor(named: "Selection 7") ?? .systemPink,
        "Selection 8": UIColor(named: "Selection 8") ?? .blue,
        "Selection 9": UIColor(named: "Selection 9") ?? .green,
        "Selection 10": UIColor(named: "Selection 10") ?? .blue,
        "Selection 11": UIColor(named: "Selection 11") ?? .orange,
        "Selection 12": UIColor(named: "Selection 12") ?? .systemPink,
        "Selection 13": UIColor(named: "Selection 13") ?? .yellow,
        "Selection 14": UIColor(named: "Selection 14") ?? .purple,
        "Selection 15": UIColor(named: "Selection 15") ?? .purple,
        "Selection 16": UIColor(named: "Selection 16") ?? .purple,
        "Selection 17": UIColor(named: "Selection 17") ?? .purple,
        "Selection 18": UIColor(named: "Selection 18") ?? .green
    ]
}
