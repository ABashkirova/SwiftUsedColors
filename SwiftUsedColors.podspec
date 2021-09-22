Pod::Spec.new do |spec|
  spec.name                         = 'SwiftUsedColors'
  spec.summary                      = 'SUC is commandline tool that helps you to keep color resources of Xcode project on track'
  spec.homepage                     = 'https://github.com/ABashkirova/SwiftUsedColors'
  spec.version                      = '0.0.5'
  spec.license                      = 'MIT'
  spec.authors                      = { 'ABashkirova' => 'sbshkrva@gmail.com' }
  spec.preserve_paths               = 'suc', 'lib_InternalSwiftSyntaxParser.dylib'
  spec.source                       = { :http => "https://github.com/ABashkirova/SwiftUsedColors/releases/download/v#{spec.version}/suc-v#{spec.version}.zip" }
end

