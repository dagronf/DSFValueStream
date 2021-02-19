//
//  DSFValueStream.swift
//  DSFValueStream
//
//  Created by Darren Ford on 19/2/21.
//  Copyright © 2021 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation

/// A value source that releases a new value at a regular interval
public class DSFTimedValueStream<ValueSourceType> {
	private var timer: Timer?

	// The generator to used
	private let generator: DSFValueSource<ValueSourceType>

	/// Create a random value publisher using the provided random value generator
	public init(generator: DSFValueSource<ValueSourceType>) {
		self.generator = generator
	}

	/// Start the generator, calling the callback every `interval` seconds with a new random value
	public func start(interval: Swift.Double,
							callback: @escaping (ValueSourceType) -> Void) {
		self.stop()
		self.timer = Timer.scheduledTimer(
			withTimeInterval: interval,
			repeats: true,
			block: { [weak self] _ in
				if let me = self {
					callback(me.generator.generate())
				}
			}
		)
	}

	/// Stop the random value source
	public func stop() {
		self.timer?.invalidate()
		self.timer = nil
	}
}

/// A value source that releases a new value when gated.
public class DSFGatedValueStream<ValueSourceType>: DSFValueSource<ValueSourceType> {

	let generator: DSFValueSource<ValueSourceType>

	public init(_ generator: DSFValueSource<ValueSourceType>, action: ((ValueSourceType) -> Void)? = nil) {
		self.actionBlock = action
		self.generator = generator
		super.init()
	}

	/// The block to call when a new value is available
	public var actionBlock: ((ValueSourceType) -> Void)?

	/// Allow a new value out of the source
	/// - Parameter count: The number of values to release
	public func trigger(count: Int = 1) {
		guard let block = self.actionBlock else {
			return
		}

		(0 ..< count).forEach { _ in
			block(self.generator.generate())
		}
	}
}
