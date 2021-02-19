# DSFValueStream

Generate a stream of values

<p align="center">
    <img src="https://img.shields.io/github/v/tag/dagronf/DSFValueStream" />
    <img src="https://img.shields.io/badge/macOS-10.12+-red" />
    <img src="https://img.shields.io/badge/iOS-12.0+-blue" />
    <img src="https://img.shields.io/badge/tvOS-12.0+-orange" />
    <img src="https://img.shields.io/badge/SwiftUI-1.0+-green" />
    <img src="https://img.shields.io/badge/macCatalyst-1.0+-purple" />
</p>

<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.0-orange.svg" />
    <img src="https://img.shields.io/badge/License-MIT-lightgrey" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
</p>

## Why

I had some tests and some demo projects that needed controllable streams of 'random' values of different types.

I wrote these class to try to abstract and centralize the generation logic.  I was also keen to spend some more time playing with Combine.

## TL;DR Show me something!

```swift

// Create a timed generator that emits a random Int value in the range 0 ... 100 every 10 seconds
var intValueGenerator = DSFTimedValueGenerator(
   generator: DSFValueSourceType.Int(0 ... 100))
)

// Start the int timer and do something with the stream
self.intValueGenerator.start(interval: 10) { (value) in
   Swift.print("new integer value is \(value)")
}

/////

// Create a gated generator that emits a random word whenever it is triggered
let wordStream = DSFGatedValueStream(
   DSFValueSourceType.ArraySource(values: ["Sphinx","of","black","quartz","judge","my","vow"],
                                  type: .random)
)
wordStream.actionBlock = { value in
   Swift.print(value)
}
...

// Trigger the stream's action block with a new value
wordStream.trigger()


```


## Overview

This library has two main concepts

###A source generates a value

A source generates a single value in response to a call.  This value is entirely dependent on the source - it might be purely random, or maybe iterative over an array of stored values.

There are a number of built-in source types

* A random source generates a random value within a specified range.
* An incremental source increments its internal value every time it emits a value.

1. Random Double value (`DSFValueSourceType.DoubleSource`)
2. Random Int value (`DSFValueSourceType.IntSource`)
3. Random Bool value (`DSFValueSourceType.BoolSource`)
4. Random CGFloat value (`DSFValueSourceType.CGFloatSource`)
5. Random Array member value (`DSFValueSourceType.ArraySource<SOME_TYPE>`)
6. Incremental Array member value (`DSFValueSourceType.ArraySource<SOME_TYPE>`)
7. Incremental CGFloat values along a sine wave (`DSFValueSourceType.SineWaveSource`)

It is quite straight forward to write your own source if needed.

###A generator or publisher uses a source to generate a stream of values

The generator is provided a source which is then used to generate a stream of values. Currently there are two types of generator.

1. A timed generator which emits a new value on a scheduled interval.
2. A gated generator which emits a new value when the generator is triggered.

## Generators

### Timed

A value generator that emits a new value on a time interval

#### DSFTimedValueGenerator

```swift
var doubleValueGenerator = DSFTimedValueGenerator(
   generator: DSFValueSourceType.DoubleSource(-100 ... 100)
)

var intValueGenerator = DSFTimedValueGenerator(
   generator: DSFValueSourceType.Int(0 ... 100)
)

func startGenerating() {
   // Print a random value between -100 and 100 every second
   self.doubleValueGenerator.start(interval: 1) { (value) in
      Swift.print("new double value is \(value)")
   }

   self.intValueGenerator.start(interval: 10) { (value) in
      Swift.print("new integer value is \(value)")
   }
}
```

#### DSFTimedValuePublisher (Combine)

```swift
let randomIntegerPublisher = DSFTimedValuePublisher(DSFValueSourceType.IntSource())

// Start the publisher generating values
randomIntegerPublisher.start(interval: 0.2)

// Hook a subscriber up to the publisher
cancellable = randomIntegerPublisher.publisher
   .sink { value in
      Swift.print("Combine = \(value)")
   }
```

### Gated

A gated generator emits a new value from the generated whenever it is triggered.

#### DSFGatedValueGenerator

```swift
let generator = DSFGatedValueGenerator(
   DSFValueSourceType.ArraySource(values: values, type: .increment))
   
generator.actionBlock = { value in
   Swift.print("newValue is \(value)")
}

...

generator.gate()           // generate a single value
generator.gate(count: 10)  // generate 10 values
```

### DSFGatedValuePublisher (Combine)

```swift
let randomIntegerPublisher = DSFGatedValuePublisher(DSFValueSourceType.IntSource())

// Hook a subscriber up to the publisher
cancellable = randomIntegerPublisher.publisher
   .sink { value in
      Swift.print("Combine = \(value)")
   }
   
   ...
   
randomIntegerPublisher.gate()
```
## License

```
MIT License

Copyright (c) 2021 Darren Ford

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
