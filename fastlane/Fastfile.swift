// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//
import Foundation

/* Configuration */
protocol Configuration {
    /// file name of the certificate
    var certificate: String { get }
    
    /// file name of the provisioning profile
    var provisioningProfile: String { get }
    
    /// configuration name in xcode project
    var buildConfiguration: String { get }
    
    /// the app id for this configuration
    var appIdentifier: String { get }
    
    /// export methods, such as "ad-doc" or "appstore"
    var exportMethod: String { get }
}

struct Staging: Configuration {
    var certificate = "ios_distribution"
    var provisioningProfile = "jenkinsTest"
    var buildConfiguration = "Staging"
    var appIdentifier = "com.jenkinsSwift.*"
    var exportMethod = "ad-hoc"
}

//struct Production: Configuration {
//    var certificate = "ios_distribution"
//    var provisioningProfile = "Brewer_Production"
//    var buildConfiguration = "Production"
//    var appIdentifier = "works.sth.brewer.production"
//    var exportMethod = "ad-hoc"
//}
//
//struct Release: Configuration {
//    var certificate = "ios_distribution"
//    var provisioningProfile = "Brewer_Release"
//    var buildConfiguration = "Release"
//    var appIdentifier = "works.sth.brewer"
//    var exportMethod = "app-store"
//}
enum ProjectSetting {
    //static var workspace = "brewer.xcworkspace"
    static var project = "jenkinsSwift.xcodeproj"
    static var scheme = "jenkinsSwift"
    static var target = "jenkinsSwift"
    static var productName = "jenkinsSwift"
    static let devices: [String] = ["iPhone 8", "iPad Air"]
    
    static let codeSigningPath = environmentVariable(get: "CODESIGNING_PATH")
    static let certificatePassword = environmentVariable(get: "CERTIFICATE_PASSWORD")
    static let sdk = "iphoneos11.4"
}


/* Lanes */
class Fastfile: LaneFile {
   
    
    func package(config: Configuration) {
        
        importCertificate(
            certificatePath: "\(ProjectSetting.codeSigningPath)/\(config.certificate).p12",
            certificatePassword: ProjectSetting.certificatePassword,
            keychainName: environmentVariable(get: "KEYCHAIN_NAME"),
            keychainPassword: environmentVariable(get: "KEYCHAIN_PASSWORD")
           
        )
        
        updateProjectProvisioning(
            xcodeproj: ProjectSetting.project,
            profile: "\(ProjectSetting.codeSigningPath)/\(config.provisioningProfile).mobileprovision",
            targetFilter: "^\(ProjectSetting.target)$",
            buildConfiguration: config.buildConfiguration
        )
        
       
                
        
        buildApp(
            //workspace: ProjectSetting.workspace,
            scheme: ProjectSetting.scheme,
            clean: true,
            outputDirectory: "./",
            outputName: "\(ProjectSetting.productName).ipa",
            configuration: config.buildConfiguration,
            silent: true,
            exportMethod: config.exportMethod,
            exportOptions: [
            "signingStyle": "manual",
            "provisioningProfiles": [config.appIdentifier: config.provisioningProfile] ],
            sdk: ProjectSetting.sdk
        )
        
       
    }
    
    func developerReleaseLane() {
        desc("Create a developer release")
        package(config: Staging())
//        crashlytics(
//            ipaPath: "./\(ProjectSetting.productName).ipa",
//            apiToken: environmentVariable(get: "CRASHLYTICS_API_KEY").replacingOccurrences(of: "\"", with: ""),
//            buildSecret: environmentVariable(get: "CRASHLYTICS_BUILD_SECRET").replacingOccurrences(of: "\"", with: "")
//        )
       uploadToTestflight(username: "element42.in@gmail.com")
    }
    
//    func qaReleaseLane() {
//        desc("Create a weekly release")
//        package(config: Production())
////        crashlytics(
////            ipaPath: "./\(ProjectSetting.productName).ipa",
////            apiToken: environmentVariable(get: "CRASHLYTICS_API_KEY").replacingOccurrences(of: "\"", with: ""),
////            buildSecret: environmentVariable(get: "CRASHLYTICS_BUILD_SECRET").replacingOccurrences(of: "\"", with: "")
////        )
//    }
    
}

