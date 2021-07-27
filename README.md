# Alien Scanner

A Ruby application to catch incoming aliens as per these [requirements](./assignment.md)

By Josep Egea

## Installation

Written in Ruby 3.0.1.

On first installation, run `bundle install`.

## Usage

Run the `alien_scan.rb` script.

``` bash
bundle exec alien_scan.rb scan
```

Produces something like that

``` bash
==================================================================
Found bandit at [74, 1] with 0.875 confidence
Original:
--o-----o--
---o---o---
--ooooooo--
-oo-ooo-oo-
ooooooooooo
o-ooooooo-o
o-o-----o-o
---oo-oo---

Found:
ooo-----o--
o--o-o-o---
--o-ooooo--
oo--ooo-oo-
ooooooo-ooo
oooo--ooo-o
o-o-----o-o
---oo-oo---

...
```

### Specifying a radar reading file

With no arguments, it looks for a radar reading in `data/radar01.txt`.

You can speficy a radar reading file as an argument:

``` bash
bundle exec alien_scan.rb scan path/to/reading_file
```

### Alien patterns

On launch, the script loads the following alien patterns for
recognition:

``` bash
data/alien01.txt
data/alien02.txt
```

At the moment, the executable script doesn't provide options to load a
different set of patterns, although the underlying classes support an
arbitrary number of them,

### Fuzzy matching

The scanner supports fuzzy recognition, allowing for a certain amount
of noise in the readings and still recognize the aliens.

The scanner sensitivity can be controlled by the
`--minimum-confidence-factor`, which takes values from `0.0` (total
fuzzyness) to `1.0` only exact recognition.

You can also use `-c` as a shorter alias.

``` bash
bundle exec alien_scan.rb scan data/radar01.txt -c 0.9
```

The default confidence factor is 0.85.

### Partial detection close to the edges

The scanner supports detecting partly visible aliens on the edges of
the radar readings.

In order to avoid too many false positives, it only tries to match
partial readings if at most 50% of the alien pattern is beyond each of
the edges.

This thereshold is configurable in the internal classes but not in the
CLI script.

# Running tests

You can run the test suite with

``` bash
bundle exec rspec
```

# Design decissions

I've tried to follow SOLID principles.

## TickMaps

The main model in the app is the `TickMap`. TickMaps are used to
manage both radar readings and alien patterns.

A TickMap is a bidimensional collection of ticks with a certain
size. At its barest definition, it's not even a class but an interface
with just 2 accessors (`x_size` and `y_size`) and a method to get the
value of a certain tick (`tick_at`).

``` rbs
interface _TickMap
  attr_reader x_size: Integer
  attr_reader y_size: Integer
  def tick_at: (Integer, Integer) -> Integer
end
```

Most of the rest of the code that manages TickMaps just uses these 3
methods and will be able to deal with any object that provides them.

There are 3 classes implementing this interface, one of them abstract
(`AbstractTickMap`) and two concrete ones (`TickMap` and
`TickMapClip`).

The first one stores the ticks internally in an array of arrays. The
second one provides a "virtual" TickMap as a clipping inside of
another TickMap, specified by `x_start`, `y_start` and its own
`x_size` and `y_size`.

In addition, there is a Mixin, `TickMappable`, that provides some
common functionality applicable to any TickMap, like formatting it for
the console or iterating over it. The class `AbstractTickMap` includes
this mixin, so these functionality is automatically available to all
its subclasses. But in case you need to create a new implementation of
TickMap not inheriting from that base class you'll still be able to
include this mixin and benefit from its functionality.

## Service classes

The actual scanning is performed by different service classes trying
to keep them as close to a single responsability as possible.

- `TickMapParser`: Reads TickMaps from text files.
- `Clipper`: Creates a new TickMap clipping an existing one.
- `Matcher`: Compares 2 TickMaps and provides a similarity factor.
- `Scanner`: Gets a Radar Reading (a TickMap) and a list of Alien
  patterns (also TickMaps) and finds matches.
- `Result`: Encapsulates an alien match in a radar reading, providing
  its position, confidence factor, and the rest of data.
  
All of these classes receive all its dependencies as arguments, either
on the constructor, or when performing the service, so they should be
usable with other objects that provide a compatible signature.

When possible, the dependency injection is done in 2 layers:

- By providing the needed object itself
- Or by providing its class.

That way, the customization can happen at the needed level.

## Fuzzy matching algorithm

It's not clear by the requirements if the matching must be fuzzy or
exact, although the mention of noise and the fact that no exact
matches appear in the sample reading seem to imply that some fuzziness
is expected.

In order to do the matching, the `Matcher` class compares the 2
TickMaps cell by cell, and accounts for the number of them that are
different. It then derives the confidence factor from that difference
(1.0 when all ticks match, 0.0 in case of no coincidence).

More sofisticated algorithms could be implemented by providing an
alternate Matcher that implements the `match` method.

## CLI

I've used the `thor` gem to generate the CLI interface.

## Rubocop

I've made some changes over the default Rubocop configuration to adapt
to some custom cases and my specific tastes.
