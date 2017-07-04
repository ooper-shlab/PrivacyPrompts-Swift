//
//  APLPrivacyClassesTableViewController.swift
//  PrivacyPrompts
//
//  Translated by OOPer in cooperation with shlab.jp, on 2016/1/23.
//
//
/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 Tableview controller that displays all the privacy data classes in the system.
 */

import UIKit
import CoreBluetooth
import CoreLocation

let kDataClassLocation = NSLocalizedString("LOCATION_SERVICE", comment: "")
let kDataClassCalendars = NSLocalizedString("CALENDARS_SERVICE",comment: "")
let kDataClassContacts = NSLocalizedString("CONTACTS_SERVICE",comment: "")
let kDataClassPhotosImagePicker = NSLocalizedString("PHOTOS_IMAGE_PICKER_SERVICE",comment: "")
let kDataClassPhotosLibrary = NSLocalizedString("PHOTOS_LIBRARY_SERVICE",comment: "")
let kDataClassReminders = NSLocalizedString("REMINDERS_SERVICE",comment: "")
let kDataClassMicrophone = NSLocalizedString("MICROPHONE_SERVICE",comment: "")
let kDataClassMotion = NSLocalizedString("MOTION_SERVICE",comment: "")
let kDataClassBluetooth = NSLocalizedString("BLUETOOTH_SERVICE",comment: "")
let kDataClassFacebook = NSLocalizedString("FACEBOOK_SERVICE",comment: "")
let kDataClassTwitter = NSLocalizedString("TWITTER_SERVICE",comment: "")
let kDataClassSinaWeibo = NSLocalizedString("SINA_WEIBO_SERVICE",comment: "")
let kDataClassTencentWeibo = NSLocalizedString("TENCENT_WEIBO_SERVICE",comment: "")
let kDataClassAdvertising = NSLocalizedString("ADVERTISING_SERVICE",comment: "")
let kDataClassHealth = NSLocalizedString("HEALTH_SERVICE",comment: "")
let kDataClassHome = NSLocalizedString("HOME_SERVICE",comment: "")

enum DataClass: Int {
    case
    location,
    calendars,
    contacts,
    photosImagePicker,
    photosLibrary,
    reminders,
    microphone,
    motion,
    bluetooth,
    facebook,
    twitter,
    sinaWeibo,
    tencentWeibo,
    advertising,
    health,
    home
}

import EventKit
import Contacts
import Accounts
import AdSupport
import Photos
import AVFoundation
import CoreMotion
import HealthKit
import HomeKit


@objc(APLPrivacyClassesTableViewController)
class APLPrivacyClassesTableViewController: UITableViewController, UINavigationControllerDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, CBCentralManagerDelegate, HMHomeManagerDelegate {
    
    /*
    Create an array with all our services.
    */
    private var serviceArray: [String] = [kDataClassLocation, kDataClassCalendars, kDataClassContacts, kDataClassPhotosImagePicker, kDataClassPhotosLibrary, kDataClassReminders, kDataClassMicrophone, kDataClassMotion, kDataClassBluetooth, kDataClassFacebook, kDataClassTwitter, kDataClassSinaWeibo, kDataClassTencentWeibo, kDataClassAdvertising, kDataClassHealth, kDataClassHome]
    private var locationManager: CLLocationManager?
    private var accountStore: ACAccountStore?
    private var eventStore: EKEventStore?
    private var cbManager: CBCentralManager?
    private var cmManager: CMMotionActivityManager?
    private var motionActivityQueue: OperationQueue?
    private var contactStore: CNContactStore?
    private var healthStore: HKHealthStore?
    private var homeManager: HMHomeManager?
    
    
    //MARK: - View lifecycle management
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! APLPrivacyDetailViewController
        
        let serviceString = self.serviceArray[(self.tableView.indexPathForSelectedRow as NSIndexPath?)?.row ?? 0]
        
        viewController.title = serviceString
        
        switch serviceString {
        case kDataClassLocation:
            viewController.checkBlock = {[weak self] in
                self?.checkLocationServicesAuthorizationStatus()
            }
            viewController.requestBlock = {[weak self] in
                self?.requestLocationServicesAuthorization()
            }
        case kDataClassContacts:
            viewController.checkBlock = {[weak self] in
                self?.checkContactStoreAccess()
            }
            viewController.requestBlock = {[weak self] in
                self?.requestContactStoreAccess()
            }
        case kDataClassCalendars:
            viewController.checkBlock = {[weak self] in
                self?.checkEventStoreAccessForType(.event)
            }
            viewController.requestBlock = {[weak self] in
                self?.requestEventStoreAccessWithType(.event)
            }
        case kDataClassReminders:
            viewController.checkBlock = {[weak self] in
                self?.checkEventStoreAccessForType(.reminder)
            }
            viewController.requestBlock = {[weak self] in
                self?.requestEventStoreAccessWithType(.reminder)
            }
        case kDataClassPhotosImagePicker:
            viewController.checkBlock = {[weak self] in
                self?.reportPhotosAuthorizationStatus()
            }
            viewController.requestBlock = {[weak self] in
                self?.requestPhotosAccessUsingImagePicker()
            }
        case kDataClassPhotosLibrary:
            viewController.checkBlock = {[weak self] in
                self?.reportPhotosAuthorizationStatus()
            }
            viewController.requestBlock = {[weak self] in
                self?.requestPhotosAccessUsingPhotoLibrary()
            }
        case kDataClassMicrophone:
            viewController.checkBlock = nil
            viewController.requestBlock = {
                self.requestMicrophoneAccess()
            }
        case kDataClassMotion:
            viewController.checkBlock = nil
            viewController.requestBlock = {[weak self] in
                
                self?.requestMotionAccessData()
            }
        case kDataClassBluetooth:
            viewController.checkBlock = {[weak self] in
                self?.checkBluetoothAccess()
            }
            viewController.requestBlock = {[weak self] in
                self?.requestBluetoothAccess()
            }
        case kDataClassFacebook:
            viewController.checkBlock = {[weak self] in
                self?.checkSocialAccountAuthorizationStatus(ACAccountTypeIdentifierFacebook)
            }
            viewController.requestBlock = {[weak self] in
                self?.requestFacebookAccess()
            }
        case kDataClassTwitter:
            viewController.checkBlock = {[weak self] in
                self?.checkSocialAccountAuthorizationStatus(ACAccountTypeIdentifierTwitter)
            }
            viewController.requestBlock = {[weak self] in
                self?.requestTwitterAccess()
            }
        case kDataClassSinaWeibo:
            viewController.checkBlock = {[weak self] in
                self?.checkSocialAccountAuthorizationStatus(ACAccountTypeIdentifierSinaWeibo)
            }
            viewController.requestBlock = {[weak self] in
                self?.requestSinaWeiboAccess()
            }
        case kDataClassTencentWeibo:
            viewController.checkBlock = {[weak self] in
                self?.checkSocialAccountAuthorizationStatus(ACAccountTypeIdentifierTencentWeibo)
            }
            viewController.requestBlock = {[weak self] in
                self?.requestTencentWeiboAccess()
            }
        case kDataClassAdvertising:
            viewController.checkBlock = {[weak self] in
                self?.advertisingIdentifierStatus()
            }
            viewController.requestBlock = nil
        case kDataClassHealth:
            viewController.checkBlock = {[weak self] in
                self?.checkHealthAccess()
            }
            viewController.requestBlock = {[weak self] in
                self?.requestHealthAccess()
            }
        case kDataClassHome:
            viewController.requestBlock = {[weak self] in
                self?.requestHomeAccess()
            }
        default:
            break
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let serviceString = self.serviceArray[(self.tableView.indexPathForSelectedRow as NSIndexPath?)?.row ?? 0]
        if serviceString == kDataClassMotion && !CMMotionActivityManager.isActivityAvailable() {
            self.alertViewWithDataClass(.motion, status: NSLocalizedString("UNAVAILABLE", comment: ""))
            return false
        }
        
        return true
    }
    
    //MARK: - UITableViewDataSource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.serviceArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell")!
        cell.textLabel?.text = self.serviceArray[(indexPath as NSIndexPath).row]
        return cell
    }
    
    //MARK: - Location methods
    
    private func checkLocationServicesAuthorizationStatus() {
        /*
        We can ask the location services manager ahead of time what the authorization status is for our bundle and take the appropriate action.
        */
        self.reportLocationServicesAuthorizationStatus(CLLocationManager.authorizationStatus())
    }
    
    private func reportLocationServicesAuthorizationStatus(_ status: CLAuthorizationStatus) {
        let statusText: String
        switch status {
        case CLAuthorizationStatus.notDetermined:
            statusText = NSLocalizedString("UNDETERMINED", comment: "")
        case .restricted:
            statusText = NSLocalizedString("RESTRICTED", comment: "")
        case .denied:
            statusText = NSLocalizedString("DENIED", comment: "")
        case .authorizedWhenInUse:
            statusText = NSLocalizedString("LOCATION_WHEN_IN_USE", comment: "")
        case .authorizedAlways:
            statusText = NSLocalizedString("LOCATION_ALWAYS", comment: "")
        }
        
        self.alertViewWithDataClass(.location, status: statusText)
    }
    
    private func requestLocationServicesAuthorization() {
        if self.locationManager == nil {
            self.locationManager = CLLocationManager()
            self.locationManager!.delegate = self
        }
        
        /*
        Gets user permission to get their location while the app is in the foreground.
        
        To monitor the user's location even when the app is in the background:
        1. Replace [self.locationManager requestWhenInUseAuthorization] with [self.locationManager requestAlwaysAuthorization]
        2. Change NSLocationWhenInUseUsageDescription to NSLocationAlwaysUsageDescription in InfoPlist.strings
        */
        self.locationManager!.requestWhenInUseAuthorization()
        
        /*
        Requests a single location after the user is presented with a consent dialog.
        */
        self.locationManager!.startUpdatingLocation()
    }
    
    //MARK: - CLLocationMangerDelegate methods
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        /*
        Handle the failure...
        */
        self.locationManager?.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        /*
        Do something with the new location the application just received...
        */
        self.locationManager?.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        /*
        The delegate function will be called when the permission status changes the application should then attempt to handle the change appropriately by changing UI or setting up or tearing down data structures.
        */
        self.reportLocationServicesAuthorizationStatus(status)
    }
    
    //MARK: - Contacts methods
    
    private func checkContactStoreAccess() {
        /*
        We can ask the contact store ahead of time what the authorization status is for our bundle and take the appropriate action.
        */
        let status = CNContactStore.authorizationStatus(for: .contacts)
        switch status {
        case .notDetermined:
            self.alertViewWithDataClass(.contacts, status: NSLocalizedString("UNDETERMINED", comment: ""))
        case .restricted:
            self.alertViewWithDataClass(.contacts, status: NSLocalizedString("RESTRICTED", comment: ""))
        case .denied:
            self.alertViewWithDataClass(.contacts, status: NSLocalizedString("DENIED", comment: ""))
        case .authorized:
            self.alertViewWithDataClass(.contacts, status: NSLocalizedString("GRANTED", comment: ""))
        }
    }
    
    private func requestContactStoreAccess() {
        if self.contactStore == nil {
            self.contactStore = CNContactStore()
        }
        
        self.contactStore!.requestAccess(for: .contacts) {granted, error in
            DispatchQueue.main.async {
                self.alertViewWithDataClass(.contacts, status: granted ? NSLocalizedString("GRANTED", comment: "") : NSLocalizedString("DENIED", comment: ""))
                
                /*
                Do something with the access to the contact store...
                */
            }
        }
    }
    
    //MARK: - EventStore methods
    
    private func checkEventStoreAccessForType(_ type: EKEntityType) {
        /*
        We can ask the event store ahead of time what the authorization status is for our bundle and take the appropriate action.
        */
        let status = EKEventStore.authorizationStatus(for: type)
        let dClass: DataClass = type == .event ? .calendars : .reminders
        switch status {
        case .notDetermined:
            self.alertViewWithDataClass(dClass, status: NSLocalizedString("UNDETERMINED", comment: ""))
        case .restricted:
            self.alertViewWithDataClass(dClass, status: NSLocalizedString("RESTRICTED", comment: ""))
        case .denied:
            self.alertViewWithDataClass(dClass, status: NSLocalizedString("DENIED", comment: ""))
        case .authorized:
            self.alertViewWithDataClass(dClass, status: NSLocalizedString("GRANTED", comment: ""))
        }
    }
    
    private func requestEventStoreAccessWithType(_ type: EKEntityType) {
        if self.eventStore == nil {
            self.eventStore = EKEventStore()
        }
        
        /*
        When the application requests to receive event store data that is when the user is presented with a consent dialog.
        */
        self.eventStore!.requestAccess(to: type) {granted, error in
            DispatchQueue.main.async {
                self.alertViewWithDataClass((type == .event) ? .calendars : .reminders, status: granted ? NSLocalizedString("GRANTED", comment: "") : NSLocalizedString("DENIED", comment: ""))
                
                /*
                Do something with the access to eventstore...
                */
            }
        }
    }
    
    //MARK: - Photos methods
    
    private func reportPhotosAuthorizationStatus() {
        /*
        We can ask the photo library ahead of time what the authorization status is for our bundle and take the appropriate action.
        */
        let statusText: String
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            statusText = NSLocalizedString("UNDETERMINED", comment: "")
        case .restricted:
            statusText = NSLocalizedString("RESTRICTED", comment: "")
        case .denied:
            statusText = NSLocalizedString("DENIED", comment: "")
        case .authorized:
            statusText = NSLocalizedString("GRANTED", comment: "")
        }
        
        let message = String(format: NSLocalizedString("PHOTOS_ACCESS_LEVEL", comment: ""), statusText)
        self.alertViewWithMessage(message)
    }
    
    private func requestPhotosAccessUsingImagePicker() {
        /*
        There are two ways to prompt the user for permission to access photos. This one will display the photo picker UI.  See the PHPhotoLibrary example in this file for the other way to request photo access.
        */
        
        let picker = UIImagePickerController()
        picker.delegate = self
        
        /*
        Upon presenting the picker, consent will be required from the user if the user previously denied access to the photo library, an "access denied" lock screen will be presented to the user to remind them of this choice.
        */
        self.navigationController?.present(picker, animated: true, completion: nil)
    }
    
    private func requestPhotosAccessUsingPhotoLibrary() {
        /*
        There are two ways to prompt the user for permission to access photos. This one will not display the photo picker UI.  See the UIImagePickerController example in this file for the other way to request photo access.
        */
        PHPhotoLibrary.requestAuthorization {status in
            DispatchQueue.main.async {
                self.reportPhotosAuthorizationStatus()
            }
        }
    }
    
    //MARK: - Microphone methods
    
    private func requestMicrophoneAccess() {
        let session = AVAudioSession()
        session.requestRecordPermission {granted in
            if granted {
                do {
                    /*
                    Setting the category will also request access from the user
                    */
                    try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
                } catch _ {
                    //###ignored
                }
                
                /*
                Do something with the audio session
                */
            } else {
                /*
                Handle failure
                */
            }
            
            DispatchQueue.main.async {
                self.alertViewWithDataClass(.microphone, status: granted ? NSLocalizedString("GRANTED", comment: "") : NSLocalizedString("DENIED", comment: ""))
            }
        }
    }
    
    //MARK: - Motion methods
    
    private func requestMotionAccessData() {
        self.cmManager = CMMotionActivityManager()
        self.motionActivityQueue = OperationQueue()
        self.cmManager!.startActivityUpdates(to: self.motionActivityQueue!) {activity in
            /*
            * Do something with the activity reported
            */
            self.alertViewWithDataClass(.motion, status: NSLocalizedString("ALLOWED", comment: ""))
            self.cmManager?.stopActivityUpdates()
        }
    }
    
    //MARK: - Bluetooth methods
    
    private func checkBluetoothAccess() {
        if self.cbManager == nil {
            self.cbManager = CBCentralManager(delegate: self, queue: nil)
        }
        
        /*
        We can ask the bluetooth manager ahead of time what the authorization status is for our bundle and take the appropriate action.
        */
        let state = self.cbManager!.state
        switch state {
        case .unknown:
            self.alertViewWithDataClass(.bluetooth, status: NSLocalizedString("UNKNOWN", comment: ""))
        case .unauthorized:
            self.alertViewWithDataClass(.bluetooth, status: NSLocalizedString("DENIED", comment: ""))
        default:
            self.alertViewWithDataClass(.bluetooth, status: NSLocalizedString("GRANTED", comment: ""))
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        /*
        The delegate method will be called when the permission status changes the application should then attempt to handle the change appropriately by changing UI or setting up or tearing down data structures.
        */
    }
    
    private func requestBluetoothAccess() {
        if self.cbManager == nil {
            self.cbManager = CBCentralManager(delegate: self, queue: nil)
        }
        
        /*
        When the application requests to start scanning for bluetooth devices that is when the user is presented with a consent dialog.
        */
        self.cbManager!.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        /*
        Handle the discovered bluetooth devices...
        */
    }
    
    //MARK: - Social methods
    
    private func checkSocialAccountAuthorizationStatus(_ accountTypeIndentifier: String) {
        if self.accountStore == nil {
            self.accountStore = ACAccountStore()
        }
        
        /*
        We can ask each social account type ahead of time what the authorization status is for our bundle and take the appropriate action.
        */
        let socialAccount = self.accountStore!.accountType(withAccountTypeIdentifier: accountTypeIndentifier)
        
        let dClass: DataClass
        switch accountTypeIndentifier {
        case ACAccountTypeIdentifierFacebook:
            dClass = .facebook
        case ACAccountTypeIdentifierTwitter:
            dClass = .twitter
        case ACAccountTypeIdentifierSinaWeibo:
            dClass = .sinaWeibo
        default:
            dClass = .tencentWeibo
        }
        self.alertViewWithDataClass(dClass, status: (socialAccount?.accessGranted)! ? NSLocalizedString("GRANTED", comment: "") : NSLocalizedString("DENIED", comment: ""))
    }
    
    //MARK: - Facebook
    
    private func requestFacebookAccess() {
        if self.accountStore == nil {
            self.accountStore = ACAccountStore()
        }
        let facebookAccount = self.accountStore!.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierFacebook)
        
        /*
        When requesting access to the account is when the user will be prompted for consent.
        */
        let options: [AnyHashable: Any] = [ACFacebookAppIdKey: "MY_CODE",
            ACFacebookPermissionsKey: ["email", "user_about_me"],
            ACFacebookAudienceKey: ACFacebookAudienceFriends]
        self.accountStore!.requestAccessToAccounts(with: facebookAccount, options: options) {granted, error in
            DispatchQueue.main.async {
                self.alertViewWithDataClass(.facebook, status: (granted) ? NSLocalizedString("GRANTED", comment: "") : NSLocalizedString("DENIED", comment: ""))
                /*
                Do something with account access...
                */
            }
        }
    }
    
    //MARK: - Twitter
    
    private func requestTwitterAccess() {
        if self.accountStore == nil {
            self.accountStore = ACAccountStore()
        }
        
        let twitterAccount = self.accountStore!.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
        
        /*
        When requesting access to the account is when the user will be prompted for consent.
        */
        self.accountStore!.requestAccessToAccounts(with: twitterAccount, options: nil) {granted, error in
            DispatchQueue.main.async {
                self.alertViewWithDataClass(.twitter, status: (granted) ? NSLocalizedString("GRANTED", comment: "") : NSLocalizedString("DENIED", comment: ""))
                /*
                Do something with account access...
                */
            }
        }
    }
    
    //MARK: - SinaWeibo methods
    
    private func requestSinaWeiboAccess() {
        if self.accountStore == nil {
            self.accountStore = ACAccountStore()
        }
        
        let sinaWeiboAccount = self.accountStore!.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierSinaWeibo)
        
        /*
        When requesting access to the account is when the user will be prompted for consent.
        */
        self.accountStore!.requestAccessToAccounts(with: sinaWeiboAccount, options: nil) {granted, error in
            DispatchQueue.main.async {
                self.alertViewWithDataClass(.sinaWeibo, status: (granted) ? NSLocalizedString("GRANTED", comment: "") : NSLocalizedString("DENIED", comment: ""))
                /*
                Do something with account access...
                */
            }
        }
    }
    
    //MARK: - TencentWeibo methods
    
    private func requestTencentWeiboAccess() {
        if self.accountStore == nil {
            self.accountStore = ACAccountStore()
        }
        
        let tencentWeiboAccount = self.accountStore!.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTencentWeibo)
        
        /*
        When requesting access to the account is when the user will be prompted for consent.
        */
        let options = [ACTencentWeiboAppIdKey: "replace this string to your TencentWeibo AppId"]
        self.accountStore!.requestAccessToAccounts(with: tencentWeiboAccount, options: options) {granted, error in
            DispatchQueue.main.async {
                self.alertViewWithDataClass(.tencentWeibo, status: granted ? NSLocalizedString("GRANTED", comment: "") : NSLocalizedString("DENIED", comment: ""))
                /*
                Do something with account access...
                */
            }
        }
    }
    
    //MARK: - Advertising
    
    private func advertisingIdentifierStatus() {
        /*
        It is required to check the value of the property isAdvertisingTrackingEnabled before using the advertising identifier.  if the value is NO, then identifier can only be used for the purposes enumerated in the program license agreement note that the advertising ID can be controlled by restrictions just like the rest of the privacy data classes.
        Applications should not cache the advertising ID as it can be changed via the reset button in Settings.
        */
        self.alertViewWithDataClass(.advertising, status: ASIdentifierManager.shared().isAdvertisingTrackingEnabled ? NSLocalizedString("ALLOWED", comment: "") : NSLocalizedString("DENIED", comment: ""))
    }
    
    //MARK: - Health methods
    
    private func checkHealthAccess() {
        if HKHealthStore.isHealthDataAvailable() {
            if self.healthStore == nil {
                self.healthStore = HKHealthStore()
            }
            
            let heartRateType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
            let status = self.healthStore!.authorizationStatus(for: heartRateType)
            
            switch status {
            case .notDetermined:
                self.alertViewWithDataClass(.health, status: NSLocalizedString("UNKNOWN", comment: ""))
            case .sharingAuthorized:
                self.alertViewWithDataClass(.health, status: NSLocalizedString("GRANTED", comment: ""))
            case .sharingDenied:
                self.alertViewWithDataClass(.health, status: NSLocalizedString("DENIED", comment: ""))
            }
        } else {
            // Health data is not available on all devices
            self.alertViewWithDataClass(.health, status: NSLocalizedString("UNAVAILABLE", comment: ""))
        }
    }
    
    private func requestHealthAccess() {
        if HKHealthStore.isHealthDataAvailable() {
            if self.healthStore == nil {
                self.healthStore = HKHealthStore()
            }
            
            let heartRateType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
            let typeSet: Set<HKSampleType> = [heartRateType]
            
            /*
            Requests consent from the user to read and write heart rate data from the health store
            */
            self.healthStore!.requestAuthorization(toShare: typeSet, read: typeSet) {success, error in
                DispatchQueue.main.async {
                    self.checkHealthAccess()
                }
            }
        } else {
            // Health data is not available on all devices
            self.alertViewWithDataClass(.health, status: NSLocalizedString("UNAVAILABLE", comment: ""))
        }
    }
    
    //MARK: - Home methods
    
    private func requestHomeAccess() {
        self.homeManager = HMHomeManager()
        
        // HMHomeManager will notify the delegate when it's ready to vend home data. It will ask for user permission first, if needed.
        self.homeManager!.delegate = self
    }
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        if !manager.homes.isEmpty {
            // A home exists, so we have access
            self.alertViewWithDataClass(.home, status: NSLocalizedString("GRANTED", comment: ""))
        } else {
            // No homes are available.  Is that because no home is set in HMHomeManager, or because the user denied access?
            manager.addHome(withName: "Test Home") {[weak manager]/* Prevent memory leak */ home, error in
                
                if let error = error as NSError? {
                    if error.code == HMError.homeAccessNotAuthorized.rawValue {
                        // User denied permission
                        self.alertViewWithDataClass(.home, status: NSLocalizedString("DENIED", comment: ""))
                    } else {
                        // Handle other errors cleanly
                        let message = String(format: NSLocalizedString("HOME_ERROR", comment: ""), error.code, error.localizedDescription)
                        self.alertViewWithMessage(message)
                    }
                } else {
                    self.alertViewWithDataClass(.home, status: NSLocalizedString("GRANTED", comment: ""))
                }
                
                if let home = home {
                    // Clean up after ourselves, don't leave the Test Home in the HMHomeManager array
                    manager?.removeHome(home) {error in
                        // ... do something with the result of removing the home ...
                    }
                }
            }
        }
    }
    
    //MARK: - Helper methods
    
    private func alertViewWithDataClass(_ dClass: DataClass, status: String) {
        let formatString = NSLocalizedString("ACCESS_LEVEL", comment: "")
        let message = String(format: formatString, dClass.asString, status)
        self.alertViewWithMessage(message)
    }
    
    private func alertViewWithMessage(_ message: String) {
        let alert = UIAlertController(title: NSLocalizedString("REQUEST_STATUS", comment: ""), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default) {action in
            self.navigationController?.dismiss(animated: true, completion: nil)
            })
        
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
}

extension DataClass {
    var asString: String {
        switch self {
        case .location:
            return kDataClassLocation
        case .contacts:
            return kDataClassContacts
        case .calendars:
            return kDataClassCalendars
        case .photosImagePicker:
            return kDataClassPhotosImagePicker
        case .photosLibrary:
            return kDataClassPhotosLibrary
        case .reminders:
            return kDataClassReminders
        case .bluetooth:
            return kDataClassBluetooth
        case .microphone:
            return kDataClassMicrophone
        case .motion:
            return kDataClassMotion
        case .facebook:
            return kDataClassFacebook
        case .twitter:
            return kDataClassTwitter
        case .sinaWeibo:
            return kDataClassSinaWeibo
        case .tencentWeibo:
            return kDataClassTencentWeibo
        case .advertising:
            return kDataClassAdvertising
        case .health:
            return kDataClassHealth
        case .home:
            return kDataClassHome
            
        }
    }
}

