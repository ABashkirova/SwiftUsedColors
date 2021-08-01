//
//  AppError.swift
//  
//  https://github.com/mugabe/SwiftUnusedResources
//  Created by mugabe.
//

import Foundation
import PathKit

enum AppError {
    case processingFailed
    
    enum Project {
        case projectFileNotSpecified
        case projectNotFound
        case projectIsNotDirectory
        case projectWrongExtension
    }
    
    enum Report {
        case reportIsNotDirectory
        case reportDirectoryIsNotFound
    }
}

extension AppError {
    func message(_ error: Error) -> String {
        switch self {
        case .processingFailed:
            return "❌ Processing failed: \(error)"

        }
    }
}

extension AppError.Report {
    func message(_ report: Path? = nil) -> String {
        switch self {
        case .reportDirectoryIsNotFound:
            return "Wrong report directory specified: \(String(describing: report)) not found"
        case .reportIsNotDirectory:
            return "Wrong report directory specified: \(String(describing: report)) is not directory"
        }
    }
}

extension AppError.Project {
    func message(_ project: Path? = nil) -> String {
        let projectPath = project?.string
        
        switch self {
        case .projectFileNotSpecified:
            return "Project file not specified"
            
        case .projectNotFound:
            return "Wrong project file specified: \(String(describing: projectPath)) not found"
            
        case .projectIsNotDirectory:
            return "Wrong project file specified: \(String(describing: projectPath)) is not directory"
            
        case .projectWrongExtension:
            return "Wrong project file specified: \(String(describing: projectPath)) is not .xcodeproj"
        }
    }
}
