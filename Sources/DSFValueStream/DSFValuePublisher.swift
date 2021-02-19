//
//  DSFValuePublisher.swift
//  DSFRandomValueGenerators
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

#if canImport(Combine)

import Combine

/// A combine publisher for a generator.
@available(macOS 10.15, iOS 13, tvOS 13, *)
class DSFTimedValuePublisher<ValueSourceType> {

	private let subject = PassthroughSubject<ValueSourceType, Never>()
	public var publisher: AnyPublisher<ValueSourceType, Never> {
		 // Here we're "erasing" the information of which type
		 // that our subject actually is, only letting our outside
		 // code know that it's a read-only publisher:
		 subject.eraseToAnyPublisher()
	}

	private let generator: DSFValueSource<ValueSourceType>
	private var cancellable: AnyCancellable? = nil

	/// Create a random value publisher using the provided random value generator
	public init(_ generator: DSFValueSource<ValueSourceType>) {
		//self.interval = interval
		self.generator = generator
	}

	/// Start the generator, emitting a new random value every `interval` seconds
	public func start(interval: Double) {
		self.stop()
		self.cancellable = Timer.publish(every: interval, on: .main, in: .default)
			.autoconnect()
			.sink { [weak self] _ in
				self?.generate()
			}
	}

	/// Stop the generator
	public func stop() {
		self.cancellable?.cancel()
		self.cancellable = nil
	}

	private func generate() {
		self.subject.send(self.generator.generate())
	}
}

/// A combine publisher for random values
@available(macOS 10.15, iOS 13, tvOS 13, *)
class DSFGatedValuePublisher<ValueSourceType> {
	private let subject = PassthroughSubject<ValueSourceType, Never>()
	public var publisher: AnyPublisher<ValueSourceType, Never> {
		 // Here we're "erasing" the information of which type
		 // that our subject actually is, only letting our outside
		 // code know that it's a read-only publisher:
		 subject.eraseToAnyPublisher()
	}

	// The generator to use when producing values
	private let generator: DSFValueSource<ValueSourceType>

	/// Create a random value publisher using the provided random value generator
	public init(_ generator: DSFValueSource<ValueSourceType>) {
		self.generator = generator
	}

	/// Allow a new value out of the source
	/// - Parameter count: The number of values to release
	public func trigger(count: Int = 1) {
		(0 ..< count).forEach { _ in
			self.subject.send(self.generator.generate())
		}
	}
}

#endif
