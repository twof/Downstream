import XCTest

import DownstreamTests

var tests = [XCTestCaseEntry]()
tests += DownstreamTests.allTests()
XCTMain(tests)
