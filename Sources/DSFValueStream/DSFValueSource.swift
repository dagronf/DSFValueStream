//
//  DSFValueSource.swift
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

/// A source of values
public class DSFValueSource<ValueSourceType> {
	/// Overriden by subclasses to return a random value
	public func generate() -> ValueSourceType {
		fatalError()
	}
}

public class DSFValueSourceType {
	
	/// A Double random value source
	public class DoubleSource: DSFValueSource<Double> {
		let range: ClosedRange<Double>

		/// Create a Double random source that returns values within the specified range
		public init(_ range: ClosedRange<Double> = 0.0 ... 1.0) {
			self.range = range
		}

		override public func generate() -> Double {
			return Double.random(in: self.range)
		}
	}

	/// A Int random value source
	public class IntSource: DSFValueSource<Int> {
		let range: ClosedRange<Int>

		/// Create an Int random source that returns values within the specified range
		public init(_ range: ClosedRange<Int> = 0 ... 100) {
			self.range = range
		}

		override public func generate() -> Int {
			return Int.random(in: self.range)
		}
	}

	/// A Bool random value source
	public class BoolSource: DSFValueSource<Bool> {
		override public func generate() -> Bool {
			return Bool.random()
		}
	}

	/// A source that returns an element of a provided array
	public class ArraySource<ValueType>: DSFValueSource<ValueType> {
		public enum SourceType {
			case random
			case increment
		}

		private var position: Int = 0
		private let type: SourceType
		private let values: [ValueType]

		/// Create a string random source that returns random string from within the `strings` parameter
		public init(values: [ValueType], type: SourceType = .random) {
			self.type = type
			self.values = values
		}

		override public func generate() -> ValueType {
			switch self.type {
			case .random:
				return self.values[Int.random(in: 0 ..< self.values.count)]
			case .increment:
				let newVal = self.position
				self.position = (newVal + 1) % self.values.count
				return self.values[newVal]
			}
		}
	}

	/// A String random value source
	public typealias StringsSource = ArraySource<String>
}

#if canImport(CoreGraphics)

import CoreGraphics

public extension DSFValueSourceType {
	/// A CGFloat random value source
	class CGFloatSource: DSFValueSource<CGFloat> {
		let range: ClosedRange<CGFloat>
		init(_ range: ClosedRange<CGFloat> = 0.0 ... 1.0) {
			self.range = range
		}

		override public func generate() -> CGFloat {
			return CGFloat.random(in: self.range)
		}
	}
}

#endif

public extension DSFValueSourceType {
	/// A value source that returns a sine wave
	class SineWaveSource: DSFValueSource<CGFloat> {
		var sinusoid: CGFloat = 0.00
		public var increment: CGFloat

		public init(increment: CGFloat = 0.1) {
			self.increment = increment
		}

		override public func generate() -> CGFloat {
			self.sinusoid += self.increment
			return sin(self.sinusoid)
		}
	}
}
