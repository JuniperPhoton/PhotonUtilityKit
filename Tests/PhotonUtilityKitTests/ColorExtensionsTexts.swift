import XCTest
import SwiftUI
import CoreGraphics
@testable import PhotonUtility

final class ColorExtensionsTexts: XCTestCase {
    func testCreateFromHex() throws {
        var hex = "#ffffff"
        XCTAssertNotNil(CGColor.create(hexString: hex))
        XCTAssertNotNil(Color(hexString: hex))
        
        hex = "#00ffffff"
        XCTAssertNotNil(CGColor.create(hexString: hex))
        XCTAssertNotNil(Color(hexString: hex))
        
        hex = "00ffffff"
        XCTAssertNil(CGColor.create(hexString: hex))
        XCTAssertNil(Color(hexString: hex))
    }
    
    func testToHexString() throws {
        var hex = "#FF2425"
        let cgColor = CGColor.create(hexString: hex)
        XCTAssertEqual(cgColor!.toHexString(), "#FF2425")
        XCTAssertEqual(cgColor!.toHexString(withAlpha: true), "#FFFF2425")
    }
}
