import XCTest
@testable import MyShakeRage

final class ShakeIntensityClassifierTests: XCTestCase {
    private let classifier = ShakeIntensityClassifier()

    func testReturnsNilBelowWeakThresholdAtDefaultSensitivity() {
        XCTAssertNil(classifier.classify(magnitude: 1.49, sensitivity: 1.0))
    }

    func testClassifiesEachDefaultThresholdBand() {
        XCTAssertEqual(classifier.classify(magnitude: 1.5, sensitivity: 1.0), .weak)
        XCTAssertEqual(classifier.classify(magnitude: 2.5, sensitivity: 1.0), .medium)
        XCTAssertEqual(classifier.classify(magnitude: 4.0, sensitivity: 1.0), .strong)
        XCTAssertEqual(classifier.classify(magnitude: 6.0, sensitivity: 1.0), .extreme)
    }

    func testHigherSensitivityLowersEffectiveThresholds() {
        XCTAssertEqual(classifier.classify(magnitude: 1.2, sensitivity: 1.5), .weak)
    }

    func testLowerSensitivityRaisesEffectiveThresholds() {
        XCTAssertNil(classifier.classify(magnitude: 1.5, sensitivity: 0.8))
        XCTAssertEqual(classifier.classify(magnitude: 2.0, sensitivity: 0.8), .weak)
    }
}
