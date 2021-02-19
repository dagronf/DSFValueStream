import XCTest
@testable import DSFValueStream

final class DSFValueStreamTests: XCTestCase {

	func testGatedIncrement() {

		let values = [0, 1, 2, 3, 4]
		let generator = DSFGatedValueStream(
			DSFValueSourceType.ArraySource(values: values, type: .increment))


		var current = -1

		generator.actionBlock = { value in
			current = value
		}

		generator.trigger()
		XCTAssertEqual(0, current)
		generator.trigger()
		XCTAssertEqual(1, current)
		generator.trigger()
		XCTAssertEqual(2, current)
		generator.trigger()
		XCTAssertEqual(3, current)
		generator.trigger()
		XCTAssertEqual(4, current)
		generator.trigger()
		XCTAssertEqual(0, current)
		generator.trigger()
		XCTAssertEqual(1, current)
		generator.trigger()
		XCTAssertEqual(2, current)
	}

	func testRandomWords() {
		let words: [String] = {
			let phrase = "Sphinx of black quartz judge my vow"
			let words = phrase.split(separator: " ").map { String($0) }
			return words
		}()

		let generator = DSFGatedValueStream(
			DSFValueSourceType.ArraySource(values: words, type: .random))

		var current = ""

		generator.actionBlock = { value in
			current = value
		}

		generator.trigger()
		XCTAssert(words.contains(current))
		generator.trigger()
		XCTAssert(words.contains(current))
	}

	static var allTests = [
		("testGatedIncrement", testGatedIncrement),
		("testRandomWords", testRandomWords),
	]
}
