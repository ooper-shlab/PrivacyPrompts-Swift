//
//  APLPrivacyClassesTableViewController.swift
//  PrivacyPrompts
//
//  Translated by OOPer in cooperation with shlab.jp, on 2016/1/23.
//
//
/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 Tableview controller that displays all the privacy data classes in the system.
 */

import UIKit
import CoreBluetooth
import CoreLocation

let kDataClassAdvertising = NSLocalizedString("ADVERTISING_SERVICE", comment: "")
let kDataClassAppleMusic = NSLocalizedString("APPLE_MUSIC_SERVICE", comment: "")
let kDataClassBluetooth = NSLocalizedString("BLUETOOTH_SERVICE", comment: "")
let kDataClassCalendars = NSLocalizedString("CALENDARS_SERVICE", comment: "")
let kDataClassCamera = NSLocalizedString("CAMERA_SERVICE", comment: "")
let kDataClassContacts = NSLocalizedString("CONTACTS_SERVICE", comment: "")
let kDataClassFacebook = NSLocalizedString("FACEBOOK_SERVICE", comment: "")
let kDataClassHealth = NSLocalizedString("HEALTH_SERVICE", comment: "")
let kDataClassHome = NSLocalizedString("HOME_SERVICE", comment: "")
let kDataClassLocation = NSLocalizedString("LOCATION_SERVICE", comment: "")
let kDataClassMicrophone = NSLocalizedString("MICROPHONE_SERVICE", comment: "")
let kDataClassMotion = NSLocalizedString("MOTION_SERVICE", comment: "")
let kDataClassPhotosImagePicker = NSLocalizedString("PHOTOS_IMAGE_PICKER_SERVICE",comment: "")
let kDataClassPhotosLibrary = NSLocalizedString("PHOTOS_LIBRARY_SERVICE",comment: "")
let kDataClassReminders = NSLocalizedString("REMINDERS_SERVICE",comment: "")
let kDataClassSiri = NSLocalizedString("SIRI_SERVICE", comment: "")
let kDataClassSinaWeibo = NSLocalizedString("SINA_WEIBO_SERVICE",comment: "")
let kDataClassSpeechRecognition = NSLocalizedString("SPEECH_RECOGNITION_SERVICE", comment: "")
let kDataClassTencentWeibo = NSLocalizedString("TENCENT_WEIBO_SERVICE",comment: "")
let kDataClassTwitter = NSLocalizedString("TWITTER_SERVICE", comment: "")

enum DataClass: Int {
    case
    advertising,
    appleMusic,
    bluetooth,
    calendars,
    camera,
    contacts,
    facebook,
    health,
    home,
    location,
    microphone,
    motion,
    photosImagePicker,
    photosLibrary,
    reminders,
    siri,
    sinaWeibo,
    speechRecognition,
    tencentWeibo,
    twitter
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
import Intents
import Speech
import StoreKit


@objc(APLPrivacyClassesTableViewController)
class APLPrivacyClassesTableViewController: UITableViewController, UINavigationControllerDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, CBCentralManagerDelegate, HMHomeManagerDelegate {
    // Create an array with all our services.
    private var serviceArray: [String] = [kDataClassAdvertising, kDataClassAppleMusic, kDataClassBluetooth, kDataClassCalendars,
    kDataClassCamera, kDataClassContacts, kDataClassFacebook, kDataClassHealth, kDataClassHome,
    kDataClassLocation, kDataClassMicrophone, kDataClassMotion, kDataClassPhotosLibrary,
    kDataClassPhotosImagePicker, kDataClassReminders, kDataClassSinaWeibo, kDataClassSiri,
    kDataClassSpeechRecognition, kDataClassTencentWeibo, kDataClassTwitter]
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
        case kDataClassAdvertising:
            viewController.checkBlock = {[weak self] in
                self?.advertisingIdentifierStatus()
            }
            viewController.requestBlock = nil
        case kDataClassAppleMusic:
            viewController.checkBlock = {[weak self] in
                self?.checkAppleMusicAccess()
            }
            viewController.requestBlock = {[weak self] in
                self?.requestAppleMusicAccess()
            }
        case kDataClassBluetooth:
            viewController.checkBlock = {[weak self] in
                self?.checkBluetoothAccess()
            }
            viewController.requestBlock = {[weak self] in
                self?.requestBluetoothAccess()
            }
        case kDataClassCalendars:
            viewController.checkBlock = {[weak self] in
                self?.checkEventStoreAccessForType(.event)
            }
            viewController.requestBlock = {[weak self] in
                self?.requestEventStoreAccessWithType(.event)
            }
        case kDataClassCamera:
            viewController.requestBlock = {[weak self] in
                self?.requestCameraAccess()
            }
        case kDataClassContacts:
            viewController.checkBlock = {[weak self] in
                self?.checkContactStoreAccess()
            }
            viewController.requestBlock = {[weak self] in
                self?.requestContactStoreAccess()
            }
        case kDataClassFacebook:
            viewController.checkBlock = {[weak self] in
                self?.checkSocialAccountAuthorizationStatus(ACAccountTypeIdentifierFacebook)
            }
            viewController.requestBlock = {[weak self] in
                self?.requestFacebookAccess()
            }
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
        case kDataClassLocation:
            viewController.checkBlock = {[weak self] in
                self?.checkLocationServicesAuthorizationStatus()
            }
            viewController.requestBlock = {[weak self] in
                self?.requestLocationServicesAuthorization()
            }
        case kDataClassMicrophone:
            viewController.checkBlock = {[weak self] in
                self?.checkMicrophoneAccess()
            }
        
            viewController.requestBlock = {[weak self] in
                self?.requestMicrophoneAccess()
            }
        case kDataClassMotion:
            viewController.checkBlock = nil
            viewController.requestBlock = {[weak self] in
                self?.requestMotionAccessData()
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
        case kDataClassReminders:
            viewController.checkBlock = {[weak self] in
                self?.checkEventStoreAccessForType(.reminder)
            }
            viewController.requestBlock = {[weak self] in
                self?.requestEventStoreAccessWithType(.reminder)
            }
        case kDataClassSiri:
            viewController.checkBlock = {[weak self] in
                self?.checkSiriAccess()
            }
            viewController.requestBlock = {[weak self] in
                self?.requestSiriAccess()
            }
        case kDataClassSinaWeibo:
            viewController.checkBlock = {[weak self] in
                self?.checkSocialAccountAuthorizationStatus(ACAccountTypeIdentifierSinaWeibo)
            }
            viewController.requestBlock = {[weak self] in
                self?.requestSinaWeiboAccess()
            }
        case kDataClassSpeechRecognition:
            viewController.checkBlock = {[weak self] in
                self?.checkSpeechRecognitionAccess()
            }
            viewController.requestBlock = {[weak self] in
                self?.requestSpeechRecognitionAccess()
            }
        case kDataClassTencentWeibo:
            viewController.checkBlock = {[weak self] in
                self?.checkSocialAccountAuthorizationStatus(ACAccountTypeIdentifierTencentWeibo)
            }
            viewController.requestBlock = {[weak self] in
                self?.requestTencentWeiboAccess()
            }
        case kDataClassTwitter:
            viewController.checkBlock = {[weak self] in
                self?.checkSocialAccountAuthorizationStatus(ACAccountTypeIdentifierTwitter)
            }
            viewController.requestBlock = {[weak self] in
                self?.requestTwitterAccess()
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
    
    //MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.serviceArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell")!
        cell.textLabel?.text = self.serviceArray[(indexPath as NSIndexPath).row]
        return cell
    }
    
    //MARK: - Advertising
    //
    //- (void)advertisingIdentifierStatus {
    private func advertisingIdentifierStatus() {
    //    /*
    //        It is required to check the value of the property
    //        isAdvertisingTrackingEnabled before using the advertising identifier. if
    //        the value is NO, then identifier can only be used for the purposes
    //        enumerated in the program license agreement note that the advertising ID
    //        can be controlled by restrictions just like the rest of the privacy data
    //        classes.
    //        Applications should not cache the advertising ID as it can be changed
    //        via the reset button in Settings.
    //    */
    //    [self alertViewWithDataClass:Advertising status:([ASIdentifierManager sharedManager].advertisingTrackingEnabled) ? NSLocalizedString(@"ALLOWED", @"") : NSLocalizedString(@"DENIED", @"")];
        self.alertViewWithDataClass(.advertising, status: ASIdentifierManager.shared().isAdvertisingTrackingEnabled ? NSLocalizedString("ALLOWED", comment: "") : NSLocalizedString("DENIED", comment: ""))
    //}
    }
    //
    //MARK: - Apple Music
    //
    //- (void)checkAppleMusicAccess {
    private func checkAppleMusicAccess() {
    //    SKCloudServiceAuthorizationStatus status = [SKCloudServiceController authorizationStatus];
        let status = SKCloudServiceController.authorizationStatus()
    //    if (status == SKCloudServiceAuthorizationStatusNotDetermined) {
        switch status {
        case .notDetermined:
    //        [self alertViewWithDataClass:AppleMusic status:NSLocalizedString(@"UNDETERMINED", @"")];
            self.alertViewWithDataClass(.appleMusic, status: NSLocalizedString("UNDETERMINED", comment: ""))
    //    }
    //    else if (status == SKCloudServiceAuthorizationStatusRestricted) {
        case .restricted:
    //        [self alertViewWithDataClass:AppleMusic status:NSLocalizedString(@"RESTRICTED", @"")];
            self.alertViewWithDataClass(.appleMusic, status: NSLocalizedString("RESTRICTED", comment: ""))
    //    }
    //    else if (status == SKCloudServiceAuthorizationStatusDenied) {
        case .denied:
    //        [self alertViewWithDataClass:AppleMusic status:NSLocalizedString(@"DENIED", @"")];
            self.alertViewWithDataClass(.appleMusic, status: NSLocalizedString("DENIED", comment: ""))
    //    }
    //    else if (status == SKCloudServiceAuthorizationStatusAuthorized) {
        case .authorized:
    //        [self alertViewWithDataClass:AppleMusic status:NSLocalizedString(@"GRANTED", @"")];
            self.alertViewWithDataClass(.appleMusic, status: NSLocalizedString("GRANTED", comment: ""))
    //    }
        }
    //}
    }
    //
    //- (void)requestAppleMusicAccess {
    private func requestAppleMusicAccess() {
    //    [SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status){
        SKCloudServiceController.requestAuthorization {status in
    //        dispatch_async(dispatch_get_main_queue(), ^{
            DispatchQueue.main.async {
    //            [self checkAppleMusicAccess];
                self.checkAppleMusicAccess()
    //        });
            }
    //    }];
        }
    //}
    }
    //
    //MARK: - Bluetooth
    //
    //- (void)checkBluetoothAccess {
    private func checkBluetoothAccess() {
    //    if(!self.cbManager) {
        if self.cbManager == nil {
    //        self.cbManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
            self.cbManager = CBCentralManager(delegate: self, queue: nil)
    //    }
        }
    //
    //    /*
    //        We can ask the bluetooth manager ahead of time what the authorization
    //        status is for our bundle and take the appropriate action.
    //    */
    //    CBManagerState state = (self.cbManager).state;
        let state = self.cbManager!.state
    //    if(state == CBManagerStateUnknown) {
        switch state {
        case .unknown:
    //        [self alertViewWithDataClass:Bluetooth status:NSLocalizedString(@"UNKNOWN", @"")];
            self.alertViewWithDataClass(.bluetooth, status: NSLocalizedString("UNKNOWN", comment: ""))
    //    }
    //    else if(state == CBManagerStateUnauthorized) {
        case .unauthorized:
    //        [self alertViewWithDataClass:Bluetooth status:NSLocalizedString(@"DENIED", @"")];
            self.alertViewWithDataClass(.bluetooth, status: NSLocalizedString("DENIED", comment: ""))
    //    }
    //    else {
//        case .unsupported:
//            self.alertViewWithDataClass(.bluetooth, status: NSLocalizedString("UNAVAILABLE", comment: ""))
        default:
    //        [self alertViewWithDataClass:Bluetooth status:NSLocalizedString(@"GRANTED", @"")];
            self.alertViewWithDataClass(.bluetooth, status: NSLocalizedString("GRANTED", comment: ""))
    //    }
        }
    //}
    }
    //
    //- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
    //    /*
    //        The delegate method will be called when the permission status changes
    //        the application should then attempt to handle the change appropriately
    //        by changing UI or setting up or tearing down data structures.
    //    */
    //}
    }
    //
    //- (void)requestBluetoothAccess {
    private func requestBluetoothAccess() {
    //    if(!self.cbManager) {
        if self.cbManager == nil {
    //        self.cbManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
            self.cbManager = CBCentralManager(delegate: self, queue: nil)
    //    }
        }
    //
    //    /*
    //        When the application requests to start scanning for bluetooth devices
    //        that is when the user is presented with a consent dialog.
    //    */
    //    [self.cbManager scanForPeripheralsWithServices:nil options:nil];
        self.cbManager!.scanForPeripherals(withServices: nil, options: nil)
    //}
    }
    //
    //- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    //    // Handle the discovered bluetooth devices...
    //}
    }
    //
    //MARK: - Calendars And Reminders
    //
    //- (void)checkEventStoreAccessForType:(EKEntityType)type {
    private func checkEventStoreAccessForType(_ type: EKEntityType) {
    //    /*
    //     We can ask the event store ahead of time what the authorization status
    //     is for our bundle and take the appropriate action.
    //     */
    //    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:type];
        let status = EKEventStore.authorizationStatus(for: type)
    //    if(status == EKAuthorizationStatusNotDetermined) {
        switch status {
        case .notDetermined:
    //        [self alertViewWithDataClass:((type == EKEntityTypeEvent) ? Calendars : Reminders) status:NSLocalizedString(@"UNDETERMINED", @"")];
            self.alertViewWithDataClass((type == .event) ? .calendars : .reminders, status: NSLocalizedString("UNDETERMINED", comment: ""))
    //    }
    //    else if(status == EKAuthorizationStatusRestricted) {
        case .restricted:
    //        [self alertViewWithDataClass:((type == EKEntityTypeEvent) ? Calendars : Reminders) status:NSLocalizedString(@"RESTRICTED", @"")];
            self.alertViewWithDataClass((type == .event) ? .calendars : .reminders, status: NSLocalizedString("RESTRICTED", comment: ""))
    //    }
    //    else if(status == EKAuthorizationStatusDenied) {
        case .denied:
    //        [self alertViewWithDataClass:((type == EKEntityTypeEvent) ? Calendars : Reminders) status:NSLocalizedString(@"DENIED", @"")];
            self.alertViewWithDataClass((type == .event) ? .calendars : .reminders, status: NSLocalizedString("DENIED", comment: ""))
    //    }
    //    else if(status == EKAuthorizationStatusAuthorized) {
        case .authorized:
    //        [self alertViewWithDataClass:((type == EKEntityTypeEvent) ? Calendars : Reminders) status:NSLocalizedString(@"GRANTED", @"")];
            self.alertViewWithDataClass((type == .event) ? .calendars : .reminders, status: NSLocalizedString("GRANTED", comment: ""))
    //    }
        }
    //}
    }
    //
    //- (void)requestEventStoreAccessWithType:(EKEntityType)type {
    private func requestEventStoreAccessWithType(_ type: EKEntityType) {
    //    if(!self.eventStore) {
        if self.eventStore == nil {
    //        self.eventStore = [[EKEventStore alloc] init];
            self.eventStore = EKEventStore()
    //    }
        }
    //
    //    /*
    //     When the application requests to receive event store data that is when
    //     the user is presented with a consent dialog.
    //     */
    //    [self.eventStore requestAccessToEntityType:type completion:^(BOOL granted, NSError *error) {
        self.eventStore!.requestAccess(to: type) {granted, error in
    //        dispatch_async(dispatch_get_main_queue(), ^{
            DispatchQueue.main.async {
    //            [self alertViewWithDataClass:((type == EKEntityTypeEvent) ? Calendars : Reminders) status:(granted) ? NSLocalizedString(@"GRANTED", @"") : NSLocalizedString(@"DENIED", @"")];
                self.alertViewWithDataClass((type == .event) ? .calendars : .reminders, status: (granted) ? NSLocalizedString("GRANTED", comment: "") : NSLocalizedString("DENIED", comment: ""))
    //            // Do something with the access to eventstore...
    //        });
            }
    //    }];
        }
    //}
    }
    //
    //MARK: - Camera
    //
    //- (void)requestCameraAccess {
    private func requestCameraAccess() {
    //    NSError *error = nil;
        do {
    //
    //    // Find a video capture device.
    //    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
            let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    //
    //    // Attempt to create a device input.
    //    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
            _ = try AVCaptureDeviceInput(device: device)
    //
    //    if (input) {
    //        [self alertViewWithMessage:[NSString stringWithFormat:NSLocalizedString(@"CAMERA_SUCCESS", @"")]];
            self.alertViewWithMessage(NSLocalizedString("CAMERA_SUCCESS", comment: ""))
    //    }
    //    else {
        } catch let error as NSError {
    //       [self alertViewWithMessage:[NSString stringWithFormat:NSLocalizedString(@"CAMERA_ERROR", @""), error.code, error.localizedDescription]];
            self.alertViewWithMessage(String(format: NSLocalizedString("CAMERA_ERROR", comment: ""), error.code))
    //    }
        }
    //}
    }
    //
    //MARK: - Contacts
    //
    //- (void)checkContactStoreAccess {
    private func checkContactStoreAccess() {
    //    /*
    //        We can ask the contact store ahead of time what the authorization status
    //        is for our bundle and take the appropriate action.
    //    */
    //    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        let status = CNContactStore.authorizationStatus(for: .contacts)
    //    if(status == CNAuthorizationStatusNotDetermined) {
        switch status {
        case .notDetermined:
    //        [self alertViewWithDataClass:Contacts status:NSLocalizedString(@"UNDETERMINED", @"")];
            self.alertViewWithDataClass(.contacts, status: NSLocalizedString("UNDETERMINED", comment: ""))
    //    }
    //    else if(status == CNAuthorizationStatusRestricted) {
        case .restricted:
    //        [self alertViewWithDataClass:Contacts status:NSLocalizedString(@"RESTRICTED", @"")];
            self.alertViewWithDataClass(.contacts, status: NSLocalizedString("UNDETERMINED", comment: ""))
    //    }
    //    else if(status == CNAuthorizationStatusDenied) {
        case .denied:
    //        [self alertViewWithDataClass:Contacts status:NSLocalizedString(@"DENIED", @"")];
            self.alertViewWithDataClass(.contacts, status: NSLocalizedString("UNDETERMINED", comment: ""))
    //    }
    //    else if(status == CNAuthorizationStatusAuthorized) {
        case .authorized:
    //        [self alertViewWithDataClass:Contacts status:NSLocalizedString(@"GRANTED", @"")];
            self.alertViewWithDataClass(.contacts, status: NSLocalizedString("UNDETERMINED", comment: ""))
    //    }
        }
    //}
    }
    //
    //- (void)requestContactStoreAccess {
    private func requestContactStoreAccess() {
    //    if(!self.contactStore) {
        if self.contactStore == nil {
    //        self.contactStore = [[CNContactStore alloc] init];
            self.contactStore = CNContactStore()
    //    }
        }
    //
    //    [self.contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        self.contactStore!.requestAccess(for: .contacts) {granted, error in
    //        dispatch_async(dispatch_get_main_queue(), ^{
            DispatchQueue.main.async {
    //            [self alertViewWithDataClass:Contacts status:(granted) ? NSLocalizedString(@"GRANTED", @"") : NSLocalizedString(@"DENIED", @"")];
                self.alertViewWithDataClass(.contacts, status: (granted) ? NSLocalizedString("GRANTED", comment: "") : NSLocalizedString("DENIED", comment: ""))
    //            // Do something with the access to the contact store...
    //        });
            }
    //    }];
        }
    //}
    }
    //
    //
    //MARK: - Facebook
    //
    //- (void)requestFacebookAccess {
    private func requestFacebookAccess() {
    //    if(!self.accountStore) {
        if self.accountStore == nil {
    //        self.accountStore = [[ACAccountStore alloc] init];
            self.accountStore = ACAccountStore()
    //    }
        }
    //    ACAccountType *facebookAccount = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        let facebookAccount = self.accountStore!.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierFacebook)
    //
    //    /*
    //        When requesting access to the account, the user will be prompted
    //        for consent.
    //    */
    //    NSDictionary *options = @{ ACFacebookAppIdKey: @"MY_CODE",
        let options: [String: Any] = [ACFacebookAppIdKey: "MY_CODE",
    //                               ACFacebookPermissionsKey: @[@"email", @"user_about_me"],
            ACFacebookPermissionsKey: ["email", "user_about_me"],
    //                               ACFacebookAudienceKey: ACFacebookAudienceFriends };
            ACFacebookAudienceKey: ACFacebookAudienceFriends]
    //
    //    [self.accountStore requestAccessToAccountsWithType:facebookAccount options:options completion:^(BOOL granted, NSError *error) {
        self.accountStore!.requestAccessToAccounts(with: facebookAccount, options: options) {granted, error in
    //        dispatch_async(dispatch_get_main_queue(), ^{
            DispatchQueue.main.async {
    //            [self alertViewWithDataClass:Facebook status:(granted) ? NSLocalizedString(@"GRANTED", @"") : NSLocalizedString(@"DENIED", @"")];
                self.alertViewWithDataClass(.facebook, status: (granted) ? NSLocalizedString("GRANTED", comment: "") : NSLocalizedString("DENIED", comment: ""))
    //            // Do something with account access...
    //        });
            }
    //    }];
        }
    //}
    }
    //
    //MARK: - Health
    //
    //- (void)checkHealthAccess {
    private func checkHealthAccess() {
    //    if ([HKHealthStore isHealthDataAvailable]) {
        if HKHealthStore.isHealthDataAvailable() {
    //        if (!self.healthStore) {
            if self.healthStore == nil {
    //            self.healthStore = [[HKHealthStore alloc] init];
                self.healthStore = HKHealthStore()
    //        }
            }
    //
    //        HKQuantityType *heartRateType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
            let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
    //        HKAuthorizationStatus status = [self.healthStore authorizationStatusForType:heartRateType];
            let status = self.healthStore!.authorizationStatus(for: heartRateType)
    //
    //        if (status == HKAuthorizationStatusNotDetermined) {
            switch status {
            case .notDetermined:
    //            [self alertViewWithDataClass:Health status:NSLocalizedString(@"UNKNOWN", @"")];
                self.alertViewWithDataClass(.health, status: NSLocalizedString("UNKNOWN", comment: ""))
    //        }
    //        else if (status == HKAuthorizationStatusSharingAuthorized) {
            case .sharingAuthorized:
    //            [self alertViewWithDataClass:Health status:NSLocalizedString(@"GRANTED", @"")];
                self.alertViewWithDataClass(.health, status: NSLocalizedString("GRANTED", comment: ""))
    //        }
    //        else if (status == HKAuthorizationStatusSharingDenied) {
            case .sharingDenied:
    //            [self alertViewWithDataClass:Health status:NSLocalizedString(@"DENIED", @"")];
                self.alertViewWithDataClass(.health, status: NSLocalizedString("DENIED", comment: ""))
    //        }
            }
    //    }
    //    else {
        } else {
    //        // Health data is not available on all devices.
    //        [self alertViewWithDataClass:Health status:NSLocalizedString(@"UNAVAILABLE", @"")];
            self.alertViewWithDataClass(.health, status: NSLocalizedString("UNAVAILABLE", comment: ""))
    //    }
        }
    //}
    }
    //
    //- (void)requestHealthAccess {
    private func requestHealthAccess() {
    //    if ([HKHealthStore isHealthDataAvailable]) {
        if HKHealthStore.isHealthDataAvailable() {
    //        if (!self.healthStore) {
            if self.healthStore == nil {
    //            self.healthStore = [[HKHealthStore alloc] init];
                self.healthStore = HKHealthStore()
    //        }
            }
    //
    //        HKQuantityType *heartRateType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
            let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
    //        NSSet *typeSet = [NSSet setWithObject:heartRateType];
            let typeSet: Set<HKQuantityType> = [heartRateType]
    //
    //        /*
    //            Requests consent from the user to read and write heart rate data
    //            from the health store.
    //        */
    //        [self.healthStore requestAuthorizationToShareTypes:typeSet
            self.healthStore?.requestAuthorization(toShare: typeSet, read: typeSet) {success, error in
    //                                                 readTypes:typeSet
    //                                                completion:^(BOOL success, NSError *error) {
    //                                                    dispatch_async(dispatch_get_main_queue(), ^{
                DispatchQueue.main.async {
    //                                                        [self checkHealthAccess];
                    self.checkHealthAccess()
    //                                                    });
                }
    //                                                }];
            }
    //    }
    //    else {
        } else {
    //        // Health data is not available on all devices
    //        [self alertViewWithDataClass:Health status:NSLocalizedString(@"UNAVAILABLE", @"")];
            self.alertViewWithDataClass(.health, status: NSLocalizedString("UNAVAILABLE", comment: ""))
    //    }
        }
    //}
    }
    //
    //#pragma mark - Home
    //
    //- (void)requestHomeAccess {
    private func requestHomeAccess() {
    //    self.homeManager = [[HMHomeManager alloc] init];
        self.homeManager = HMHomeManager()
    //
    //    /*
    //        HMHomeManager will notify the delegate when it's ready to vend home data.
    //        It will ask for user permission first, if needed.
    //    */
    //    self.homeManager.delegate = self;
        self.homeManager?.delegate = self
    //}
    }
    //
    //- (void)homeManagerDidUpdateHomes:(HMHomeManager *)manager {
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
    //    if (manager.homes.count > 0) {
        if manager.homes.count > 0 {
    //        // A home exists, so we have access.
    //        [self alertViewWithDataClass:Home status:NSLocalizedString(@"GRANTED", @"")];
    //    }
    //    else {
        } else {
    //        /*
    //            No homes are available. Is that because no home is set in
    //            HMHomeManager, or because the user denied access?
    //        */
    //        __weak HMHomeManager *weakHomeManager = manager; // Prevent memory leak.
    //        [manager addHomeWithName:@"Test Home" completionHandler:^(HMHome *home, NSError *error) {
            manager.addHome(withName: "Test Home") {[weak manager] home, error in
    //
    //            if (!error) {
                if error == nil {
    //                [self alertViewWithDataClass:Home status:NSLocalizedString(@"GRANTED", @"")];
    //            }
    //            else {
                } else {
                    let error = error! as NSError
    //                if (error.code == HMErrorCodeHomeAccessNotAuthorized) {
                    if error.code == HMError.Code.homeAccessNotAuthorized.rawValue {
    //                    // User denied permission.
    //                    [self alertViewWithDataClass:Home status:NSLocalizedString(@"DENIED", @"")];
                        self.alertViewWithDataClass(.home, status: NSLocalizedString("DENIED", comment: ""))
    //                }
    //                else {
                    } else {
    //                    // Handle other errors cleanly.
    //                    [self alertViewWithMessage:[NSString stringWithFormat:NSLocalizedString(@"HOME_ERROR", @""), error.code, error.localizedDescription]];
                        self.alertViewWithMessage(String(format: NSLocalizedString("HOME_ERROR", comment: ""), error.code, error.localizedDescription))
    //                }
                    }
    //            }
                }
    //
    //            if (home) {
                if let home = home {
    //                /*
    //                    Clean up after ourselves, don't leave the Test Home in the
    //                    HMHomeManager array.
    //                */
    //                [weakHomeManager removeHome:home completionHandler:^(NSError * _Nullable error) {
                    manager?.removeHome(home) {error in
    //                    // ... do something with the result of removing the home ...
    //                }];
                    }
    //            }
                }
    //        }];
            }
    //    }
        }
    //}
    }
    //
    //MARK: - Location
    //
    //- (void)checkLocationServicesAuthorizationStatus {
    private func checkLocationServicesAuthorizationStatus() {
    //    /*
    //        We can ask the location services manager ahead of time what the
    //        authorization status is for our bundle and take the appropriate action.
    //    */
    //    [self reportLocationServicesAuthorizationStatus:[CLLocationManager authorizationStatus]];
        self.reportLocationServicesAuthorizationStatus(CLLocationManager.authorizationStatus())
    //}
    }
    //
    //- (void)reportLocationServicesAuthorizationStatus:(CLAuthorizationStatus)status {
    private func reportLocationServicesAuthorizationStatus(_ status: CLAuthorizationStatus) {
    //    NSString *statusText = nil;
        var statusText: String
    //
        switch status {
    //    if(status == kCLAuthorizationStatusNotDetermined) {
        case .notDetermined:
    //        statusText = NSLocalizedString(@"UNDETERMINED", @"");
            statusText = NSLocalizedString("UNDETERMINED", comment: "")
    //    }
    //    else if(status == kCLAuthorizationStatusRestricted) {
        case .restricted:
    //        statusText = NSLocalizedString(@"RESTRICTED", @"");
            statusText = NSLocalizedString("RESTRICTED", comment: "")
    //    }
    //    else if(status == kCLAuthorizationStatusDenied) {
        case .denied:
    //        statusText = NSLocalizedString(@"DENIED", @"");
            statusText = NSLocalizedString("DENIED", comment: "")
    //    }
    //    else if(status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        case .authorizedWhenInUse:
    //        statusText = NSLocalizedString(@"LOCATION_WHEN_IN_USE", @"");
            statusText = NSLocalizedString("LOCATION_WHEN_IN_USE", comment: "")
    //    }
    //    else if(status == kCLAuthorizationStatusAuthorizedAlways) {
        case .authorizedAlways:
    //        statusText = NSLocalizedString(@"LOCATION_ALWAYS", @"");
            statusText = NSLocalizedString("LOCATION_ALWAYS", comment: "")
    //    }
        }
    //
    //    [self alertViewWithDataClass:Location status:statusText];
        self.alertViewWithDataClass(.location, status: statusText)
    //}
    }
    //
    //- (void)requestLocationServicesAuthorization {
    private func requestLocationServicesAuthorization() {
    //    if (!self.locationManager) {
        if self.locationManager == nil {
    //        self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager = CLLocationManager()
    //        self.locationManager.delegate = self;
            self.locationManager!.delegate = self
    //    }
        }
    //
    //    /*
    //        Gets user permission to get their location while the app is in the
    //        foreground.
    //
    //        To monitor the user's location even when the app is in the background:
    //        1. Replace [self.locationManager requestWhenInUseAuthorization] with
    //           [self.locationManager requestAlwaysAuthorization]
    //        2. Change NSLocationWhenInUseUsageDescription to
    //           NSLocationAlwaysUsageDescription in PrivacyPrompts-Info.plist.
    //    */
    //    [self.locationManager requestWhenInUseAuthorization];
        self.locationManager!.requestWhenInUseAuthorization()
    //
    //    /*
    //        Requests a single location after the user is presented with a consent
    //        dialog.
    //    */
    //    [self.locationManager startUpdatingLocation];
        self.locationManager!.startUpdatingLocation()
    //}
    }
    //
    //MARK: - CLLocationMangerDelegate
    //
    //- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    //    // Handle the failure...
    //    [self.locationManager stopUpdatingLocation];
        self.locationManager?.stopUpdatingLocation()
    //}
    }
    //
    //- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //    // Do something with the new location the application just received...
    //    [self.locationManager stopUpdatingLocation];
        self.locationManager?.stopUpdatingLocation()
    //}
    }
    //
    //- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    //    /*
    //        The delegate function will be called when the permission status changes
    //        the application should then attempt to handle the change appropriately
    //        by changing the UI or setting up or tearing down data structures.
    //    */
    //    [self reportLocationServicesAuthorizationStatus:status];
        self.reportLocationServicesAuthorizationStatus(status)
    //}
    }
    //
    //MARK: - Microphone
    //- (void)requestMicrophoneAccess {
    private func requestMicrophoneAccess() {
    //    AVAudioSession *session = [AVAudioSession sharedInstance];
        let session = AVAudioSession.sharedInstance()
    //    [session requestRecordPermission:^(BOOL granted) {
        session.requestRecordPermission {granted in
    //        if(granted) {
            if granted {
    //            NSError *error;
    //            // Setting the category will also request access from the user.
    //            [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
                _ = try? session.setCategory(AVAudioSessionCategoryPlayAndRecord)
    //            // Do something with the audio session.
    //        }
    //        else {
            } else {
    //            // Handle failure.
    //        }
            }
    //
    //        dispatch_async(dispatch_get_main_queue(), ^{
            DispatchQueue.main.async {
    //            [self alertViewWithDataClass:Microphone status:(granted) ? NSLocalizedString(@"GRANTED", @"") : NSLocalizedString(@"DENIED", @"")];
                self.alertViewWithDataClass(.microphone, status: (granted) ? NSLocalizedString("GRANTED", comment: "") : NSLocalizedString("DENIED", comment: ""))
    //        });
            }
    //    }];
        }
    //}
    }
    //
    //-(void)checkMicrophoneAccess {
    private func checkMicrophoneAccess() {
    //    AVAudioSessionRecordPermission status = [[AVAudioSession sharedInstance] recordPermission];
        let status = AVAudioSession.sharedInstance().recordPermission()
        //### Why `AVAudioSessionRecordPermission` is `OptionSet`?
        switch status {
    //    if (status == AVAudioSessionRecordPermissionUndetermined) {
        case AVAudioSessionRecordPermission.undetermined:
    //        [self alertViewWithDataClass:Microphone status:NSLocalizedString(@"UNDETERMINED", @"")];
            self.alertViewWithDataClass(.microphone, status: NSLocalizedString("UNDETERMINED", comment: ""))
    //    }
    //    else if (status == AVAudioSessionRecordPermissionDenied) {
        case AVAudioSessionRecordPermission.denied:
    //        [self alertViewWithDataClass:Microphone status:NSLocalizedString(@"DENIED", @"")];
            self.alertViewWithDataClass(.microphone, status: NSLocalizedString("DENIED", comment: ""))
    //    }
    //    else if (status == AVAudioSessionRecordPermissionGranted) {
        case AVAudioSessionRecordPermission.granted:
    //        [self alertViewWithDataClass:Microphone status:NSLocalizedString(@"GRANTED", @"")];
            self.alertViewWithDataClass(.microphone, status: NSLocalizedString("GRANTED", comment: ""))
    //    }
        default:
            break
        }
    //}
    }
    //
    //MARK: - Motion
    //
    //- (void)requestMotionAccessData {
    private func requestMotionAccessData() {
    //    self.cmManager = [[CMMotionActivityManager alloc] init];
        self.cmManager = CMMotionActivityManager()
    //    self.motionActivityQueue = [[NSOperationQueue alloc] init];
        self.motionActivityQueue = OperationQueue()
    //    [self.cmManager startActivityUpdatesToQueue:self.motionActivityQueue withHandler:^(CMMotionActivity *activity) {
        self.cmManager!.startActivityUpdates(to: self.motionActivityQueue!) {activity in
    //        // Do something with the activity reported.
    //        [self alertViewWithDataClass:Motion status:NSLocalizedString(@"ALLOWED", @"")];
            self.alertViewWithDataClass(.motion, status: NSLocalizedString("ALLOWED", comment: ""))
    //        [self.cmManager stopActivityUpdates];
            self.cmManager!.stopActivityUpdates()
    //    }];
        }
    //}
    }
    //
    //MARK: - Photos
    //
    //- (void)reportPhotosAuthorizationStatus {
    private func reportPhotosAuthorizationStatus() {
    //    /*
    //        We can ask the photo library ahead of time what the authorization status
    //        is for our bundle and take the appropriate action.
    //    */
    //    NSString *statusText = nil;
        var statusText: String
        switch PHPhotoLibrary.authorizationStatus() {
    //    if([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
        case .notDetermined:
    //        statusText = NSLocalizedString(@"UNDETERMINED", @"");
            statusText = NSLocalizedString("UNDETERMINED", comment: "")
    //    }
    //    else if([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusRestricted) {
        case .restricted:
    //        statusText = NSLocalizedString(@"RESTRICTED", @"");
            statusText = NSLocalizedString("RESTRICTED", comment: "")
    //    }
    //    else if([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied) {
        case .denied:
    //        statusText = NSLocalizedString(@"DENIED", @"");
            statusText = NSLocalizedString("DENIED", comment: "")
    //    }
    //    else if([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        case .authorized:
    //        statusText = NSLocalizedString(@"GRANTED", @"");
            statusText = NSLocalizedString("GRANTED", comment: "")
    //    }
        }
    //
    //    [self alertViewWithMessage:[NSString stringWithFormat:NSLocalizedString(@"PHOTOS_ACCESS_LEVEL", @""), statusText]];
        self.alertViewWithMessage(String(format: NSLocalizedString("PHOTOS_ACCESS_LEVEL", comment: ""), statusText))
    //}
    }
    //
    //- (void)requestPhotosAccessUsingImagePicker {
    private func requestPhotosAccessUsingImagePicker() {
    //    /*
    //        There are two ways to prompt the user for permission to access photos.
    //        This one will display the photo picker UI. See the PHPhotoLibrary
    //        example in this file for the other way to request photo access.
    //    */
    //    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        let picker = UIImagePickerController()
    //    picker.delegate = self;
        picker.delegate = self
    //
    //    /*
    //        Upon presenting the picker, consent will be required from the user if
    //        the user previously denied access to the photo library, an
    //        "access denied" lock screen will be presented to the user to remind them
    //        of this choice.
    //    */
    //    [self.navigationController presentViewController:picker animated:YES completion:nil];
        self.navigationController?.present(picker, animated: true, completion: nil)
    //}
    }
    //
    //- (void)requestPhotosAccessUsingPhotoLibrary {
    private func requestPhotosAccessUsingPhotoLibrary() {
    //    /*
    //        There are two ways to prompt the user for permission to access photos.
    //        This one will not display the photo picker UI. See the
    //        UIImagePickerController example in this file for the other way to
    //        request photo access.
    //    */
    //    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        PHPhotoLibrary.requestAuthorization {status in
    //        dispatch_async(dispatch_get_main_queue(), ^{
            DispatchQueue.main.async {
    //            [self reportPhotosAuthorizationStatus];
                self.reportPhotosAuthorizationStatus()
    //        });
            }
    //    }];
        }
    //}
    }
    //
    //#pragma mark - SinaWeibo
    //
    //- (void)requestSinaWeiboAccess {
    private func requestSinaWeiboAccess() {
    //    if(!self.accountStore) {
        if self.accountStore == nil {
    //        self.accountStore = [[ACAccountStore alloc] init];
            self.accountStore = ACAccountStore()
    //    }
        }
    //
    //    ACAccountType *sinaWeiboAccount = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierSinaWeibo];
        let sinaWeiboAccount = self.accountStore!.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierSinaWeibo)
    //
    //    /*
    //        When requesting access to the account is when the user will be prompted
    //        for consent.
    //    */
    //    [self.accountStore requestAccessToAccountsWithType:sinaWeiboAccount options:nil completion:^(BOOL granted, NSError *error) {
        self.accountStore!.requestAccessToAccounts(with: sinaWeiboAccount, options: nil) {granted, error in
    //        dispatch_async(dispatch_get_main_queue(), ^{
            DispatchQueue.main.async {
    //            [self alertViewWithDataClass:SinaWeibo status:(granted) ? NSLocalizedString(@"GRANTED", @"") : NSLocalizedString(@"DENIED", @"")];
                self.alertViewWithDataClass(.sinaWeibo, status: (granted) ? NSLocalizedString("GRANTED", comment: "") : NSLocalizedString("DENIED", comment: ""))
    //            // Do something with account access...
    //        });
            }
    //    }];
        }
    //}
    }
    //
    //#pragma mark - Siri methods
    //
    //- (void)checkSiriAccess {
    private func checkSiriAccess() {
    //    INSiriAuthorizationStatus status = [INPreferences siriAuthorizationStatus];
        let status = INPreferences.siriAuthorizationStatus()
    //    if (status == INSiriAuthorizationStatusNotDetermined) {
        switch status {
    //        [self alertViewWithDataClass:Siri status:NSLocalizedString(@"UNDETERMINED", @"")];
        case .notDetermined:
            self.alertViewWithDataClass(.siri, status: NSLocalizedString("UNDETERMINED", comment: ""))
    //    }
    //    else if (status == INSiriAuthorizationStatusRestricted) {
        case .restricted:
    //        [self alertViewWithDataClass:Siri status:NSLocalizedString(@"RESTRICTED", @"")];
            self.alertViewWithDataClass(.siri, status: NSLocalizedString("RESTRICTED", comment: ""))
    //    }
    //    else if (status == INSiriAuthorizationStatusDenied) {
        case .denied:
    //        [self alertViewWithDataClass:Siri status:NSLocalizedString(@"DENIED", @"")];
            self.alertViewWithDataClass(.siri, status: NSLocalizedString("DENIED", comment: ""))
    //    }
    //    else if (status == INSiriAuthorizationStatusAuthorized) {
        case .authorized:
    //        [self alertViewWithDataClass:Siri status:NSLocalizedString(@"GRANTED", @"")];
            self.alertViewWithDataClass(.siri, status: NSLocalizedString("GRANTED", comment: ""))
    //    }
        }
    //}
    }
    //
    //- (void)requestSiriAccess {
    private func requestSiriAccess() {
    //    [INPreferences requestSiriAuthorization:^(INSiriAuthorizationStatus status){
        INPreferences.requestSiriAuthorization {status in
    //        dispatch_async(dispatch_get_main_queue(), ^{
            DispatchQueue.main.async {
    //            [self checkSiriAccess];
                self.checkSiriAccess()
    //        });
            }
    //    }];
        }
    //}
    }
    //
    //#pragma mark - Speech Recognition
    //
    //- (void)checkSpeechRecognitionAccess {
    private func checkSpeechRecognitionAccess() {
    //    SFSpeechRecognizerAuthorizationStatus status = [SFSpeechRecognizer authorizationStatus];
        let status = SFSpeechRecognizer.authorizationStatus()
    //    if (status == SFSpeechRecognizerAuthorizationStatusNotDetermined) {
        switch status {
    //        [self alertViewWithDataClass:SpeechRecognition status:NSLocalizedString(@"UNDETERMINED", @"")];
        case .notDetermined:
            self.alertViewWithDataClass(.speechRecognition, status: NSLocalizedString("UNDETERMINED", comment: ""))
    //    }
    //    else if (status == SFSpeechRecognizerAuthorizationStatusRestricted) {
        case .restricted:
    //        [self alertViewWithDataClass:SpeechRecognition status:NSLocalizedString(@"RESTRICTED", @"")];
            self.alertViewWithDataClass(.speechRecognition, status: NSLocalizedString("RESTRICTED", comment: ""))
    //    }
    //    else if (status == SFSpeechRecognizerAuthorizationStatusDenied) {
        case .denied:
    //        [self alertViewWithDataClass:SpeechRecognition status:NSLocalizedString(@"DENIED", @"")];
            self.alertViewWithDataClass(.speechRecognition, status: NSLocalizedString("DENIED", comment: ""))
    //    }
    //    else if (status == SFSpeechRecognizerAuthorizationStatusAuthorized) {
        case .authorized:
    //        [self alertViewWithDataClass:SpeechRecognition status:NSLocalizedString(@"GRANTED", @"")];
            self.alertViewWithDataClass(.speechRecognition, status: NSLocalizedString("GRANTED", comment: ""))
    //    }
        }
    //}
    }
    //
    //- (void)requestSpeechRecognitionAccess {
    private func requestSpeechRecognitionAccess() {
    //    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status){
        SFSpeechRecognizer.requestAuthorization {status in
    //        dispatch_async(dispatch_get_main_queue(), ^{
            DispatchQueue.main.async {
    //            [self checkSpeechRecognitionAccess];
                self.checkSpeechRecognitionAccess()
    //        });
            }
    //    }];
        }
    //}
    }
    //
    //#pragma mark - Social Methods
    //
    //- (void)checkSocialAccountAuthorizationStatus:(NSString *)accountTypeIndentifier {
    private func checkSocialAccountAuthorizationStatus(_ accountTypeIndentifier: String) {
    //    if(!self.accountStore) {
        if self.accountStore == nil {
    //        self.accountStore = [[ACAccountStore alloc] init];
            self.accountStore = ACAccountStore()
    //    }
        }
    //
    //    /*
    //        We can ask each social account type ahead of time what the authorization
    //        status is for our bundle and take the appropriate action.
    //    */
    //    ACAccountType *socialAccount = [self.accountStore accountTypeWithAccountTypeIdentifier:accountTypeIndentifier];
        let socialAccount = self.accountStore!.accountType(withAccountTypeIdentifier: accountTypeIndentifier)!
    //
    //    DataClass class;
        var cls: DataClass
        switch accountTypeIndentifier {
    //    if([accountTypeIndentifier isEqualToString:ACAccountTypeIdentifierFacebook]) {
        case ACAccountTypeIdentifierFacebook:
    //        class = Facebook;
            cls = .facebook
    //    }
    //    else if([accountTypeIndentifier isEqualToString:ACAccountTypeIdentifierTwitter]) {
        case ACAccountTypeIdentifierTwitter:
    //        class = Twitter;
            cls = .twitter
    //    }
    //    else if([accountTypeIndentifier isEqualToString:ACAccountTypeIdentifierSinaWeibo]) {
        case ACAccountTypeIdentifierSinaWeibo:
    //        class = SinaWeibo;
            cls = .sinaWeibo
    //    }
    //    else {
        default:
    //        class = TencentWeibo;
            cls = .tencentWeibo
    //    }
        }
    //    [self alertViewWithDataClass:class status:(socialAccount.accessGranted) ? NSLocalizedString(@"GRANTED", @"") : NSLocalizedString(@"DENIED", @"")];
        self.alertViewWithDataClass(cls, status: (socialAccount.accessGranted) ? NSLocalizedString("GRANTED", comment: "") : NSLocalizedString("DENIED", comment: ""))
    //}
    }
    //
    //MARK: - TencentWeibo
    //
    //- (void)requestTencentWeiboAccess {
    private func requestTencentWeiboAccess() {
    //    if(!self.accountStore) {
        if self.accountStore == nil {
    //        self.accountStore = [[ACAccountStore alloc] init];
            self.accountStore = ACAccountStore()
    //    }
        }
    //
    //    ACAccountType *tencentWeiboAccount = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTencentWeibo];
        let tencentWeiboAccount = self.accountStore!.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTencentWeibo)
    //    // Your Tencent Weibo App ID, as it appears on the Tencent Weibo website.
    //    NSDictionary *options = @{ACTencentWeiboAppIdKey: @"MY_CODE"};
        let options = [ACTencentWeiboAppIdKey: "MY_CODE"]
    //    /*
    //        When requesting access to the account is when the user will be prompted
    //        for consent.
    //     */
    //    [self.accountStore requestAccessToAccountsWithType:tencentWeiboAccount options:options completion:^(BOOL granted, NSError *error) {
        self.accountStore?.requestAccessToAccounts(with: tencentWeiboAccount, options: options) {granted, error in
    //        dispatch_async(dispatch_get_main_queue(), ^{
            DispatchQueue.main.async {
    //            [self alertViewWithDataClass:TencentWeibo status:(granted) ? NSLocalizedString(@"GRANTED", @"") : NSLocalizedString(@"DENIED", @"")];
                self.alertViewWithDataClass(.tencentWeibo, status: (granted) ? NSLocalizedString("GRANTED", comment: "") : NSLocalizedString("DENIED", comment: ""))
    //            // Do something with account access...
    //        });
            }
    //    }];
        }
    //}
    }
    //
    //
    //#pragma mark - Twitter
    //
    //- (void)requestTwitterAccess {
    private func requestTwitterAccess() {
    //    if(!self.accountStore) {
        if self.accountStore == nil {
    //        self.accountStore = [[ACAccountStore alloc] init];
            self.accountStore = ACAccountStore()
    //    }
        }
    //
    //    ACAccountType *twitterAccount = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        let twitterAccount = self.accountStore!.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
    //    
    //    /*
    //        When requesting access to the account, the user will be prompted for 
    //        consent.
    //    */
    //    [self.accountStore requestAccessToAccountsWithType:twitterAccount options:nil completion:^(BOOL granted, NSError *error) {
        self.accountStore?.requestAccessToAccounts(with: twitterAccount, options: nil) {granted, error in
    //        dispatch_async(dispatch_get_main_queue(), ^{
            DispatchQueue.main.async {
    //            [self alertViewWithDataClass:Twitter status:(granted) ? NSLocalizedString(@"GRANTED", @"") : NSLocalizedString(@"DENIED", @"")];
                self.alertViewWithDataClass(.twitter, status: (granted) ? NSLocalizedString("GRANTED", comment: "") : NSLocalizedString("DENIED", comment: ""))
    //             // Do something with account access...
    //        });
            }
    //    }];
        }
    //}
    }
    //
    //MARK: - Helper Methods
    //
    //- (void)alertViewWithDataClass:(DataClass)class status:(NSString *)status {
    private func alertViewWithDataClass(_ cls: DataClass, status: String) {
    //    NSString *formatString = NSLocalizedString(@"ACCESS_LEVEL", @"");
        let formatString = NSLocalizedString("ACCESS_LEVEL", comment: "")
    //    [self alertViewWithMessage:[NSString stringWithFormat:formatString, [self stringForDataClass:class], status]];
        self.alertViewWithMessage(String(format: formatString, cls.asString, status))
    //}
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
        case .advertising:
            return kDataClassAdvertising
        case .appleMusic:
            return  kDataClassAppleMusic
        case .bluetooth:
            return kDataClassBluetooth
        case .calendars:
            return kDataClassCalendars
        case .camera:
            return kDataClassCamera
        case .contacts:
            return kDataClassContacts
        case .facebook:
            return kDataClassFacebook
        case .health:
            return kDataClassHealth
        case .home:
            return kDataClassHome
        case .location:
            return kDataClassLocation
        case .microphone:
            return kDataClassMicrophone
        case .motion:
            return kDataClassMotion
        case .photosImagePicker:
            return kDataClassPhotosImagePicker
        case .photosLibrary:
            return kDataClassPhotosLibrary
        case .reminders:
            return kDataClassReminders
        case .siri:
            return kDataClassSiri
        case .sinaWeibo:
            return kDataClassSinaWeibo
        case .speechRecognition:
            return  kDataClassSpeechRecognition
        case .tencentWeibo:
            return kDataClassTencentWeibo
        case .twitter:
            return kDataClassTwitter
        }
    }
}

