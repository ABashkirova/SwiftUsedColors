## SwiftUsedColors

`suc` is commandline tool that helps you to keep color resources of Xcode project on track.

### Installation

#### Compile from source

```bash
> git clone https://github.com/ABashkirova/SwiftUsedColors.git
> cd SwiftUsedColors
> swift build -c release
> cp .build/release/suc /usr/local/bin/suc
```

#### Cocoapods

```
pod 'SwiftUsedColors'
```

`suc` will be installed at `${PODS_ROOT}/SwiftUsedColors/suc`

### Usage

Just type `suc` under your project's path
```shell
> suc
```

or use with options

```shell
> suc -p <PATH OF XCODEPROJECT> -t <TARGET> -r <DIRECTORY FOR REPORT>
```

or

### Xcode integration

Add a "Run Script" phase to each target.

```
"${PODS_ROOT}/SwiftUsedColors/suc"
```

On every project build `suc` will throw warnings about unused colors and used colors on xibs but missed in `xcassets`.

## How it works

`suc` finds colors included in the target, and then detects if they are used by the xibs, storyboards, and swift files.
`suc` collects project's colors in the `colors.html` in the directory for report specified in option `--report`.
