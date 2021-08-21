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
    case rgb(red: Float, green: Float, blue: Float, alpha: Float, path: URL)
    case grayGamma(white: Float, alpha: Float, path: URL)
    case string(_ value: String, path: URL)
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
        analyzeProjectColors()
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
        
        analyze()
    }
    
    fileprivate func analyzeProjectColors() {
        var dublicatedColorsCount = 0
        var singleUsageColorsCount = 0
        var notAddedColorsToAssetCount = 0
        
        projectColors.forEach { color in
            if let names = color.names, names.count > 1 {
                dublicatedColorsCount += 1
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
        print("Unique colors in projects:".bold, projectColors.count)
        if dublicatedColorsCount > 0 {
            print("🤨 Duplicated colors:".bold.red, dublicatedColorsCount)
        }
        if singleUsageColorsCount > 0 {
            print("🤨 Single use color:".bold.red, singleUsageColorsCount)
        }
        if notAddedColorsToAssetCount > 0 {
            print("🤨 Color not added to asset:".bold.red, notAddedColorsToAssetCount)
        }
    }
    
    private func analyze() {
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
                print("Init color by name".blink, "\(pattern)".green)
            
            case .rswift(let identifier, let url):
                setColor(identifier, path: url)
                print("R.swift:".blink, "\(identifier)".green)
            
            case .string(let value, let url):
                setColor(value, path: url)
                print("Value: ".blink, value)
                
            case .xib(let color):
                setXibColor(color)
                print("Xib: ".blink, "\(color.name)".lightRed)
                
            case .rgb(let r, let g, let b,let a, let path):
                let color = ProjectColor(
                    colorRepresentation: .custom(color: .rgb(red: r, green: g, blue: b, alpha: a)),
                    names: nil,
                    usedInFiles: [Path(path.absoluteString)]
                )
                setProjectColor(color)
                print("UIColor or Color rgb args: ".blink, "\(r), \(g), \(b), \(a)".red)
                
            case .grayGamma(let w, let a, let path):
                let color = ProjectColor(
                    colorRepresentation: .custom(color: .grayGamma(white: w, alpha: a)),
                    names: nil,
                    usedInFiles: [Path(path.absoluteString)]
                )
                setProjectColor(color)
                print("UIColor or Color gray gamma args: ".blink, "\(w), \(a)".red)
                
            case .system(let name, let alpha, let path):
                let color = ProjectColor(
                    colorRepresentation: .system(name: name, alpha: alpha),
                    names: nil,
                    usedInFiles: [Path(path.absoluteString)]
                )
                setProjectColor(color)
                print("System: ".blink, name.green)
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
            existColor.merge(dublicate: newColor)
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
        else if case .named(let name) = xibColor.color, let resource = findAssetColor(for: name) {
            var asset = resource.asset
            asset.path = xibColor.path
            setAsset(asset)
        }
        else {
            print("Color from xib", xibColor.name, "not set to project colors collection")
        }
    }
    
    private func setColor(_ id: String, path: URL) {
        if let resource = findAssetColor(for: id) {
            var asset = resource.asset
            asset.path = Path(path.absoluteString)
            setAsset(asset)
        }
        else {
            print("Color as rcolor", id, "not set to project colors collection (\(path.absoluteString))")
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
        try? resultHtml.write(ProjectColorsPage(colors: projectColors.sorted(by: { $0.sortRelation(color: $1) })).render())
        print("colors.html:\n", resultHtml.absolute().string)
    }
}
