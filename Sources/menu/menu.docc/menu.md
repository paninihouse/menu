# ``menu``

Dynamic menu for the Mac.

## Overview

*menu* reads a list of newline-separated items from stdin and presents them to the user.
When the user selects an item and presses Return, their choice is printed to stdout and the menu terminated.
Entering text will narrow the items to those matching the tokens in the input.

### Usage

```sh
echo "Apple\nBanana\nMango\nPeach" | menu
```

## Topics

### Before you start

- <doc:how-it-works>

### Getting started

- <doc:installation>
- <doc:usage>

### Customisation

- <doc:customisation>
- <doc:patches>
- ``Config``
- ``HEX``

### CLI

- ``Menu``

### Models

- ``KeyMonitor``
- ``KeyMonitorDelegate``

### Views

- ``AppDelegate``
- ``Screen``
- ``MenuState``
- ``MenuWindow``
- ``MenuView``
- ``InputView``
- ``ListView``
- ``PageIndicatorView``
- ``TextView``
