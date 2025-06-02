import Testing
import Foundation
import CoreFoundation
import CoreVideo
@testable import PhotonUtility

private let cases: [(input: OSType, output: String)] = [
    (kCVPixelFormatType_32BGRA, "BGRA"),
    (kCVPixelFormatType_422YpCbCr10BiPlanarVideoRange, "x422")
]

@Test(arguments: cases)
func testOSTypeToString(testCase: (input: OSType, output: String)) {
    #expect(testCase.input.ostypeToString() == testCase.output)
}

@Test(arguments: cases)
func testStringToOsType(testCase: (input: OSType, output: String)) async throws {
    #expect(testCase.output.stringToOSType() == testCase.input)
}
