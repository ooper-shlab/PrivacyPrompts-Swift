/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Tableview controller that displays all the privacy data classes in the system.
 */

@import UIKit;
@import CoreBluetooth;
@import CoreLocation;

#define kDataClassAdvertising NSLocalizedString(@"ADVERTISING_SERVICE", @"")
#define kDataClassAppleMusic NSLocalizedString(@"APPLE_MUSIC_SERVICE", @"")
#define kDataClassBluetooth NSLocalizedString(@"BLUETOOTH_SERVICE", @"")
#define kDataClassCalendars NSLocalizedString(@"CALENDARS_SERVICE", @"")
#define kDataClassCamera NSLocalizedString(@"CAMERA_SERVICE", @"")
#define kDataClassContacts NSLocalizedString(@"CONTACTS_SERVICE", @"")
#define kDataClassFacebook NSLocalizedString(@"FACEBOOK_SERVICE", @"")
#define kDataClassHealth NSLocalizedString(@"HEALTH_SERVICE", @"")
#define kDataClassHome NSLocalizedString(@"HOME_SERVICE", @"")
#define kDataClassLocation NSLocalizedString(@"LOCATION_SERVICE", @"")
#define kDataClassMicrophone NSLocalizedString(@"MICROPHONE_SERVICE", @"")
#define kDataClassMotion NSLocalizedString(@"MOTION_SERVICE", @"")
#define kDataClassPhotosImagePicker NSLocalizedString(@"PHOTOS_IMAGE_PICKER_SERVICE", @"")
#define kDataClassPhotosLibrary NSLocalizedString(@"PHOTOS_LIBRARY_SERVICE", @"")
#define kDataClassReminders NSLocalizedString(@"REMINDERS_SERVICE", @"")
#define kDataClassSiri NSLocalizedString(@"SIRI_SERVICE", @"")
#define kDataClassSinaWeibo NSLocalizedString(@"SINA_WEIBO_SERVICE", @"")
#define kDataClassSpeechRecognition NSLocalizedString(@"SPEECH_RECOGNITION_SERVICE", @"")
#define kDataClassTencentWeibo NSLocalizedString(@"TENCENT_WEIBO_SERVICE", @"")
#define kDataClassTwitter NSLocalizedString(@"TWITTER_SERVICE", @"")

typedef NS_ENUM(NSInteger, DataClass) {
    Advertising,
    AppleMusic,
    Bluetooth,
    Calendars,
    Camera,
    Contacts,
    Facebook,
    Health,
    Home,
    Location,
    Microphone,
    Motion,
    PhotosImagePicker,
    PhotosLibrary,
    Reminders,
    Siri,
    SinaWeibo,
    SpeechRecognition,
    TencentWeibo,
    Twitter
};

@interface APLPrivacyClassesTableViewController : UITableViewController <UINavigationControllerDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, CBCentralManagerDelegate, HMHomeManagerDelegate>
@end
