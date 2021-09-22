//
//  Explorer.swift
//

import Foundation
import PathKit
import XcodeProj
import Glob
import HyperSwift

enum ExploreError: Error {
    case notFound(message: String)
}

struct ExploreResource {
    var name: String
    let asset: ColorSet
    var path: Path
    var usedCount: Int = 0
}

enum ExploreUsage {
    case xib(_ value: XibColorSet)
    case rgb(red: Float, green: Float, blue: Float, alpha: Float, path: URL, key: String?)
    case grayGamma(white: Float, alpha: Float, path: URL, key: String?)
    case string(_ value: String, path: URL)
    case named(_ name: String, path: URL)
    case regexp(_ pattern: String, path: URL)
    case rswift(_ identifier: String, path: URL)
    case system(_ name: String, alpha: Float, path: URL)
}

class Explorer {
    private let projectPath: Path
    private let sourceRoot: Path
    private let reportPath: Path?
    private let target: String?
    private let showWarnings: Bool
    private var exploredResources: [ExploreResource] = []
    private var exploredUsages: [ExploreUsage] = []
    private var projectColors: [ProjectColor] = []
    
    private var duplicatedColorsCount = 0
    private var singleUsageColorsCount = 0
    private var unusedColorsCount = 0
    private var notAddedColorsToAssetCount = 0
    
    init(
        projectPath: Path,
        sourceRoot: Path,
        target: String?,
        reportPath: Path?,
        showWarnings: Bool
    ) throws {
        self.projectPath = projectPath
        self.sourceRoot = sourceRoot
        self.target = target
        self.showWarnings = showWarnings
        self.reportPath = reportPath
    }
    
    func explore() throws {
        print("🔨 Loading project \(project.lastComponent)".bold)
        let xcodeproj = try XcodeProj(path: projectPath)
        
        try xcodeproj.pbxproj.nativeTargets.forEach { target in
            if self.target == nil || (self.target != nil && target.name == self.target) {
                print("📦 Processing target \(target.name)".bold)
                try explore(target: target)
            }
        }
        analyseProjectColors()
        writeUsedColors()
        print("🦒 Complete".bold)
    }
    
    private func explore(target: PBXNativeTarget) throws {
        exploredResources = []
        exploredUsages = []
        
        if let resources = try target.resourcesBuildPhase() {
            try explore(resources: resources)
        }
        
        if let sources = try target.sourcesBuildPhase() {
            try explore(sources: sources)
        }
        
        analyse()
    }
    
    private func analyseProjectColors() {
        projectColors
            .filter { $0.isUnused }
            .forEach { unusedColor in
                guard
                    let path = unusedColor.usedInFiles?.first,
                    let name = unusedColor.assetsFiles?.first
                else {
                    return
                }
                warn(path: path.description, "Color «\(name)» from Asset is not used")
            }
        
        projectColors
            .filter { $0.isDuplicate }
            .forEach { duplicateColor in
                guard let path = duplicateColor.assetsFiles?.first else {
                    return
                }
                let assetNames = duplicateColor.assetsFiles?.compactMap {  "«\($0.lastComponent)»" }.joined(separator: ",") ?? ""
                warn(path: path.description, "Color \(assetNames) is dublicates")
            }
        
        projectColors.forEach { color in
            if color.isDuplicate {
                duplicatedColorsCount += 1
            }
            if color.isUnused {
                unusedColorsCount += 1
            }
            if let files = color.usedInFiles {
                if files.count == 1 {
                    singleUsageColorsCount += 1
                }
                if !files.compactMap({ $0.extension }).contains(where: { $0.contains("colorset") }) {
                    notAddedColorsToAssetCount += 1
                }
            }
        }
        
        print("\n--------------")
        print("Unique colors in project:".bold, projectColors.count)
        if duplicatedColorsCount > 0 {
            print("🤨 Repeating colors:".bold.red, duplicatedColorsCount)
        }
        if unusedColorsCount > 0 {
            print("🤨 Unused colors:".bold.red, unusedColorsCount)
        }
        if singleUsageColorsCount > 0 {
            print("🤨 Colors used once:".bold.red, singleUsageColorsCount)
        }
        if notAddedColorsToAssetCount > 0 {
            print("🤨 Colors not added to asset:".bold.red, notAddedColorsToAssetCount)
        }
    }
    
    private func analyse() {
        print("🎨 – Assets colors:")
        exploredResources.forEach { resource in
            let defaultColorHex: String = resource.asset.colors[.default]?.hexName ?? ""
            let darkColorHex: String = resource.asset.colors[.dark]?.hexName ?? ""
            let darkName = darkColorHex.isEmpty ? "" : "(dark #\(darkColorHex))"
            setAsset(resource.asset)
            print("🎨 ", resource.asset.name, " – #", defaultColorHex, darkName)
        }
    
        print("📲 Usaged colors:")
        exploredUsages.forEach { usage in
            switch usage {
            case .regexp(let pattern, let url):
                setColor(pattern, path: url)
                
            case .named(let pattern, let url):
                setColor(pattern, path: url)
            
            case .rswift(let identifier, let url):
                setColor(identifier, path: url)
            
            case .string(let value, let url):
                setColor(value, path: url)
                
            case .xib(let color):
                setXibColor(color)
                
            case .rgb(let r, let g, let b,let a, let path, let key):
                var keys: [String]?
                if let key = key {
                    keys = [key]
                }
                let color = ProjectColor(
                    colorRepresentation: .custom(color: .rgb(red: r, green: g, blue: b, alpha: a, raw: nil)),
                    names: nil,
                    usedInFiles: [Path(path.absoluteString)],
                    keys: keys
                )
                setProjectColor(color)
                
            case .grayGamma(let w, let a, let path, let key):
                var keys: [String]?
                if let key = key {
                    keys = [key]
                }
                let color = ProjectColor(
                    colorRepresentation: .custom(color: .grayGamma(white: w, alpha: a, raw: nil)),
                    names: nil,
                    usedInFiles: [Path(path.absoluteString)],
                    keys: keys
                )
                setProjectColor(color)
                
            case .system(let name, let alpha, let path):
                let color = ProjectColor(
                    colorRepresentation: .system(name: name, alpha: alpha),
                    names: nil,
                    usedInFiles: [Path(path.absoluteString)]
                )
                setProjectColor(color)
            }
        }
        print("Colors in assets: ".bold, exploredResources.count)
        print("Colors in sources: ".bold, exploredUsages.count)
    }
    
    private func explore(resources: PBXResourcesBuildPhase) throws {
        guard let files = resources.files else {
            throw ExploreError.notFound(message: "Resource files not found")
        }
        
        try files.forEach { file in
            guard let ffile = file.file else {
                return
            }
            
            try explore(resource: ffile)
        }
    }
    
    /// Collect project files
    private func explore(resource: PBXFileElement) throws {
        guard let fullPath = try resource.fullPath(sourceRoot: sourceRoot) else {
            throw ExploreError.notFound(
                message: "Could not get full path for resource \(resource) (uuid: \(resource.uuid))"
            )
        }
        
        let ext = fullPath.extension
        
        switch ext {
        case "xcassets":
            try explore(xcassets: resource, path: fullPath)
            
        case "xib", "storyboard":
            try explore(xib: resource, path: fullPath)
            
        default:
            break
        }
    }
    
    /// Collect .colorset files
    private func explore(xcassets: PBXFileElement, path: Path) throws {
        let files = Glob(pattern: path.string + "**/*.colorset")
        
        try files.forEach { setPath in
            let setPath = Path(setPath)
            
            try ColorInAssetsParser(setPath, { colorSet in
                let exp = ExploreResource(
                    name: setPath.lastComponentWithoutExtension,
                    asset: colorSet,
                    path: setPath.absolute()
                )
                
                self.exploredResources.append(exp)
            })
        }
    }
    
    /// Collect .xib and .storyboard files
    private func explore(xib: PBXFileElement, path: Path) throws {
        _ = try? XibParser(path, { usage in
            self.exploredUsages.append(usage)
        })
    }
    
    /// Collect .swift files
    private func explore(sources: PBXSourcesBuildPhase) throws {
        guard let files = sources.files else {
            throw ExploreError.notFound(message: "Source files not found")
        }
        
        try files.forEach { file in
            guard let fullPath = try file.file?.fullPath(sourceRoot: sourceRoot) else {
                return
            }
            
            if fullPath.extension != "swift" {
                return
            }

            if fullPath.lastComponent == "R.generated.swift" {
                return
            }
            
            try SwiftParser(fullPath, { usage in
                self.exploredUsages.append(usage)
            })
        }
    }
    
    // MARK: - Collect project colors
    
    private func setProjectColor(_ newColor: ProjectColor) {
        if let existColorIndex = projectColors.firstIndex(where: { $0.equalColors(with: newColor) }) {
            var existColor = projectColors[existColorIndex]
            existColor.merge(duplicate: newColor)
            projectColors[existColorIndex] = existColor
        }
        else {
            projectColors.append(newColor)
        }
    }
    
    private func setAsset(_ colorSet: ColorSet) {
        guard let newColor = colorSet.projectColor else {
            return
        }
        setProjectColor(newColor)
    }
    
    private func setXibColor(_ xibColor: XibColorSet) {
        if let projectColor = xibColor.projectColor {
            setProjectColor(projectColor)
        }
        else if case .named(let name, _) = xibColor.color, let resource = findAssetColor(for: name) {
            var asset = resource.asset
            asset.path = xibColor.path
            setAsset(asset)
        }
        else {
            var message: String = "The named color used is «" + xibColor.name + "»"
            if let property = xibColor.key {
                message += " in property " + property
            }
            message += ", but it is not in Asset"
            warn(path: xibColor.path.description, message)
        }
    }
    
    private func setColor(_ id: String, path: URL) {
        if let resource = findAssetColor(for: id) {
            var asset = resource.asset
            asset.path = Path(path.absoluteString)
            setAsset(asset)
        }
        else {
            warn(path: path.path, "Used R.color.\(id) not found in Assets")
        }
    }
    
    private func findAssetColor(for colorName: String) -> ExploreResource? {
        let assetName = clearifyName(for: colorName)
        return exploredResources.first(where: { clearifyName(for: $0.name) == assetName })
    }
    
    private func clearifyName(for name: String) -> String {
        return SwiftIdentifier(name: name, lowercaseStartingCharacters: true).description
    }
    
    // MARK: - Generate reports
    
    private func writeUsedColors() {
        guard let reportPath = reportPath else {
            return
        }
        let resultHtml = reportPath + Path("colors.html")
        try? resultHtml.write(
            ProjectColorsPage(
                colors: projectColors.sorted(by: { $0.sortRelation(color: $1) }),
                duplicatedColorsCount: duplicatedColorsCount,
                singleUsageColorsCount: singleUsageColorsCount,
                unusedColorsCount: unusedColorsCount,
                notAddedColorsToAssetCount: notAddedColorsToAssetCount
            )
            .render()
        )
        print("colors.html:\n", resultHtml.absolute().string)
    }
    
    private func warn(path: String, _ message: String) {
        guard showWarnings else {
            return
        }

        print("\(path.description): warning: \(message)")
    }
}
