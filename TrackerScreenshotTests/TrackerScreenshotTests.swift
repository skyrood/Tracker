//
//  TrackerScreenshotTests.swift
//  TrackerScreenshotTests
//
//  Created by Rodion Kim on 2025/07/17.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerScreenshotTests: XCTestCase {
    func testTrackersViewController() throws {
        let trackersViewController = TrackersViewController()
        trackersViewController.loadViewIfNeeded()
        trackersViewController.setTestData()
        
        assertSnapshots(matching: trackersViewController, as: [.image])
    }
}
