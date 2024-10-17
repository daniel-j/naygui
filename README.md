# Naygui

Welcome to this repository! Here you'll find a Nim wrapper for raygui, an auxiliar module for raylib to create simple GUI interfaces.

## Documentation

Please refer to the raygui readme and examples writen in C:
https://github.com/raysan5/raygui/tree/4.0

## Installation

```
git clone https://github.com/planetis-m/naygui.git --recurse-submodules
cd naygui/src/raygui/
git apply ../../mangle_names.patch
```

## Examples

Example code located in tests dir:
https://github.com/planetis-m/naygui/blob/master/tests/controls_test_suite.nim
```
nim compile -r tests/controls_test_suite.nim
```

### Development Status

Currently some features are missing.