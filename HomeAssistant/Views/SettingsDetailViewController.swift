//
//  SecondViewController.swift
//  HomeAssistant
//
//  Created by Robbie Trencheny on 3/25/16.
//  Copyright © 2016 Robbie Trencheny. All rights reserved.
//

import UIKit
import Eureka
import PermissionScope
import PromiseKit
import Crashlytics

class SettingsDetailViewController: FormViewController {

    let prefs = UserDefaults(suiteName: "group.io.robbie.homeassistant")!

    var detailGroup: String = "display"

    // swiftlint:disable:next function_body_length
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        switch detailGroup {
        case "general":
            self.title = "General Settings"
            self.form
                +++ Section()
                <<< SwitchRow("openInChrome") {
                    $0.title = "Open links in Chrome"
                    $0.value = prefs.bool(forKey: "openInChrome")
                    }.onChange { row in
                        self.prefs.setValue(row.value, forKey: "openInChrome")
                        self.prefs.synchronize()
                }
//                <<< SwitchRow("allowAllGroups") {
//                    $0.title = "Show all groups"
//                    $0.value = prefs.bool(forKey: "allowAllGroups")
//                    }.onChange { row in
//                        self.prefs.setValue(row.value, forKey: "allowAllGroups")
//                        self.prefs.synchronize()
//                }
        case "location":
            self.title = "Location Settings"
            if let zoneEntities = HomeAssistantAPI.sharedInstance.entitiesByType["Zone"] as? [Zone] {
                for zone in zoneEntities {
                    self.form
                        +++ Section(header: zone.Name, footer: "") {
                            $0.tag = zone.ID
                        }
                        <<< SwitchRow {
                            $0.title = "Updates Enabled"
                            $0.value = zone.trackingEnabled
                            }.onChange { row in
                                // swiftlint:disable:next force_try
                                print("TODO: Implement settings!")
//                                try! realm.write { zone.trackingEnabled = row.value! }
                        }
                        <<< LocationRow {
                            $0.title = "Location"
                            $0.value = zone.location()
                        }
                        <<< LabelRow {
                            $0.title = "Radius"
                            $0.value = "\(Int(zone.Radius)) m"
                        }
                        <<< SwitchRow {
                            $0.title = "Enter Notification"
                            $0.value = zone.enterNotification
                            }.onChange { row in
                                // swiftlint:disable:next force_try
                                print("TODO: Implement settings!")
//                                try! realm.write { zone.enterNotification = row.value! }
                        }
                        <<< SwitchRow {
                            $0.title = "Exit Notification"
                            $0.value = zone.exitNotification
                            }.onChange { row in
                                // swiftlint:disable:next force_try
                                print("TODO: Implement settings!")
//                                try! realm.write { zone.exitNotification = row.value! }
                    }
                }
            }
        case "notifications":
            self.title = "Notification Settings"
            self.form
                +++ Section(header: "Push token",
                            // swiftlint:disable:next line_length
                    footer: "This is the target to use in your Home Assistant configuration. Tap to copy or share.")
                <<< TextAreaRow {
                    $0.placeholder = "PushID"
                    if let pushID = prefs.string(forKey: "pushID") {
                        $0.value = pushID
                    } else {
                        $0.value = "Not registered for remote notifications"
                    }
                    $0.disabled = true
                    $0.textAreaHeight = TextAreaHeight.dynamic(initialTextViewHeight: 40)
                    }.onCellSelection { _, row in
                        let activityViewController = UIActivityViewController(activityItems: [row.value! as String],
                                                                              applicationActivities: nil)
                        self.present(activityViewController, animated: true, completion: {})
                }

                +++ Section(header: "",
                            // swiftlint:disable:next line_length
                    footer: "Updating push settings will request the latest push actions and categories from Home Assistant.")
                <<< ButtonRow {
                    $0.title = "Update push settings"
                    }.onCellSelection {_, _ in
                        HomeAssistantAPI.sharedInstance.setupPush()
                        let alert = UIAlertController(title: "Settings Import",
                                                      message: "Push settings imported from Home Assistant.",
                                                      preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                }

                +++ Section(header: "", footer: "Custom push notification sounds can be added via iTunes.")
                <<< ButtonRow {
                    $0.title = "Import sounds from iTunes"
                    }.onCellSelection {_, _ in
                        let moved = movePushNotificationSounds()
                        var message = "0 sounds were imported."
                        if moved > 0 {
                            message = "\(moved) sounds were imported. Please restart your phone to complete the import."
                        }
                        let alert = UIAlertController(title: "Sounds Import",
                                                      message: message,
                                                      preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
            }

            //                <<< ButtonRow {
            //                    $0.title = "Import system sounds"
            //                }.onCellSelection {_,_ in
            //                    let list = getSoundList()
            //                    print("system sounds list", list)
            //                    for sound in list {
            //                        copyFileToDirectory(sound)
            //                    }
        //                }
        default:
            print("Something went wrong, no settings detail group named \(detailGroup)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
