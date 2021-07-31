import Foundation
import PathKit
import CommandLineKit
import Rainbow

let cli = CommandLineKit.CommandLine()

cli.formatOutput = { s, type in
    var str: String
    switch(type) {
    case .error: str = s.red.bold
    case .optionFlag: str = s.green.underline
    default: str = s
    }
    
    return cli.defaultFormat(s: str, type: type)
}

let projectPathOption = StringOption(
    shortFlag: "p",
    longFlag: "project",
    helpMessage: "Root path of your Xcode project. Default is current."
)
cli.addOption(projectPathOption)

let targetOption = StringOption(
    shortFlag: "t",
    longFlag: "target",
    helpMessage: "Project's target. Skip to process all targets."
)
cli.addOption(targetOption)

do {
    try cli.parse()
}
catch {
    cli.printUsage()
    exit(EX_USAGE)
}

let showWarnings = ProcessInfo.processInfo.environment["XCODE_PRODUCT_BUILD_VERSION"] != nil

// MARK: Option Project Path

let project: Path
let projectExtention = "xcodeproj"
if let optProject = projectPathOption.value {
    project = Path(optProject)
}
else if let envProject = ProcessInfo.processInfo.environment["PROJECT_FILE_PATH"] {
    project = Path(envProject)
}
else {
    let path = Path(".").absolute()
    if path.extension == projectExtention {
        project = path
    }
    else if let xcodeproj = path.glob("*." + projectExtention).first {
        project = xcodeproj
    }
    else {
        cli.printUsage(AppError.Project.projectFileNotSpecified.message())
        exit(EX_USAGE)
    }
}

if !project.exists || !project.isDirectory || project.extension != projectExtention {
    if !project.exists {
        cli.printUsage(AppError.Project.projectNotFound.message(project))
    }
    else if !project.isDirectory {
        cli.printUsage(AppError.Project.projectIsNotDirectory.message(project))
    }
    else if project.extension != projectExtention {
        cli.printUsage(AppError.Project.projectWrongExtension.message(project))
    }
    exit(EX_USAGE)
}

// MARK: Option Target

var target: String? = nil

if let optionTarget = targetOption.value {
    target = optionTarget
}
else if let envTarget = ProcessInfo.processInfo.environment["TARGET_NAME"] {
    target = envTarget
}

// MARK: Source Root

let sourceRoot: Path
if let envRoot = ProcessInfo.processInfo.environment["SOURCE_ROOT"] {
    sourceRoot = Path(envRoot)
}
else {
    sourceRoot = project.parent()
}

do {
    try Explorer(
        projectPath: project,
        sourceRoot: sourceRoot,
        target: target,
        showWarnings: showWarnings
    ).explore()
}
catch {
    print(AppError.processingFailed.message(error).red.bold)
    exit(EX_USAGE)
}
