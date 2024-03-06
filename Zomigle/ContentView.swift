//
//  ContentView.swift
//  Zomigle
//
//  Created by HAHALOSAH on 3/1/24.
//

import SwiftUI

enum ZomigleStatus {
    case waiting;
    case ready;
    case done;
    case unavailable;
    case failed;
}

struct ContentView: View {
    @State var status: ZomigleStatus = .waiting
    var body: some View {
        VStack {
            Text("Welcome to Zomigle!")
                .font(.largeTitle)
            Text("release 0.1.0 beta 2")
            Spacer()
            if status == .waiting {
                Text("Loading...")
                    .font(.title)
            } else if status == .ready {
                Button(action: {
                    install()
                }) {
                    HStack {
                        Image(systemName: "hammer")
                        Text("Install Pairing Support")
                    }
                }
                .font(.title)
            } else if status == .done {
                Button(action: {
                    uninstall()
                }) {
                    HStack {
                        Image(systemName: "hammer.fill")
                        Text("Remove Pairing Support")
                    }
                }
                .font(.title)
                Button(action: {
                    respring()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Respring")
                    }
                }
                .font(.title)
            } else if status == .unavailable {
                Text("Unavailable - ensure app was installed through TrollStore or a jailbroken package manager.")
                    .font(.title)
                    .multilineTextAlignment(.center)
            } else {
                Text("Failed - please contact @HAHALOSAH or reopen the app and try again")
                    .font(.title)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            Button("Thanks to @34306 for watched") {
                UIApplication.shared.open(URL(string: "https://github.com/34306/watched")!)
            }
            Button("Zomigle app by HAHALOSAH") {
                UIApplication.shared.open(URL(string: "https://github.com/HAHALOSAH/Zomigle")!)
            }
            Text("I do not take credit for any code I did not write.")
        }
        .padding()
        .onAppear {
            check()
        }
    }
    
    func check() {
        do {
            try FileManager.default.moveItem(atPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist.backup", toPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist")
        } catch {
            NSLog("%@", error as NSError)
        }
        if !FileManager.default.isReadableFile(atPath: "/var/mobile/Library/Preferences") {
            status = .unavailable
            return
        }
        if FileManager.default.fileExists(atPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist.backup") {
            status = .done
            return
        }
        status = .ready
    }
    
    func install() {
        do {
            try FileManager.default.moveItem(atPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist", toPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist.backup")
            try FileManager.default.moveItem(atPath: "/var/mobile/Library/Preferences/com.apple.pairedsync.plist", toPath: "/var/mobile/Library/Preferences/com.apple.pairedsync.plist.backup")
            var currentContents = NSMutableDictionary(contentsOf: URL(fileURLWithPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist.backup"))
            if currentContents == nil {
                status = .failed
                return
            }
            // ty 34306
            currentContents!.setObject(1, forKey: "minPairingCompatibilityVersion" as NSCopying)
            currentContents!.setObject(99, forKey: "maxPairingCompatibilityVersion" as NSCopying)
            currentContents!.setObject("", forKey: "IOS_PAIRING_EOL_MIN_PAIRING_COMPATIBILITY_VERSION_CHIPIDS" as NSCopying)
            currentContents!.setObject(1, forKey: "minPairingCompatibilityVersionWithChipID" as NSCopying)
            
            try currentContents?.write(to: URL(fileURLWithPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist"))
            currentContents = NSMutableDictionary(contentsOf: URL(fileURLWithPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist.backup"))
            if currentContents == nil {
                status = .failed
                return
            }
            currentContents!.setObject(99, forKey: "activityTimeout" as NSCopying)
            check()
        } catch {
            status = .failed
        }
    }
    
    func uninstall() {
        if !FileManager.default.isWritableFile(atPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist.backup") {
            status = .failed
            return
        }
        do {
            if FileManager.default.isWritableFile(atPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist") && FileManager.default.isWritableFile(atPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist.backup") {
                try FileManager.default.removeItem(atPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist")
                try FileManager.default.moveItem(atPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist.backup", toPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist")
            }
            if FileManager.default.isWritableFile(atPath: "/var/mobile/Library/Preferences/com.apple.pairedsync.plist") && FileManager.default.isWritableFile(atPath: "/var/mobile/Library/Preferences/com.apple.pairedsync.plist.backup") {
                try FileManager.default.removeItem(atPath: "/var/mobile/Library/Preferences/com.apple.pairedsync.plist")
                try FileManager.default.moveItem(atPath: "/var/mobile/Library/Preferences/com.apple.pairedsync.plist.backup", toPath: "/var/mobile/Library/Preferences/com.apple.pairedsync.plist")
            }
            check()
        } catch {
            status = .failed
        }
    }
}

#Preview {
    ContentView()
}
