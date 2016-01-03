//
//  ViewController.m
//  testDES
//
//  Created by 陈金 on 15/12/28.
//  Copyright © 2015年 Art. All rights reserved.
//

#import "ViewController.h"
#import"GTMBase64.h"
#import<CommonCrypto/CommonCryptor.h>
#import "OpenUDID.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "SSDiskInfo.h"
#import "SystemServices.h"
#import <dlfcn.h>
#import <AdSupport/AdSupport.h>

@interface ViewController ()
@property(strong, nonatomic) NSString *bs;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self testDes];
    
    
    
    NSDictionary* dic = [self fetchSSIDInfo];
    
    SystemServices* info = [SystemServices sharedServices];
    
    NSLog(@"SSID is %@",[dic objectForKey:@"SSID"]);
    NSLog(@"BSSID is %@",[dic objectForKey:@"BSSID"]);
    NSLog(@"OpenUDID value is %@",[OpenUDID value]);
    
    NSLog(@"longDiskSpace is %lld",info.longDiskSpace);
    
    NSLog(@"systemDeviceTypeNotFormatted is %@",info.systemDeviceTypeNotFormatted);
    
    NSLog(@"systemsUptime is %@",info.systemsUptime);
    
    NSLog(@"jailbroken is %d",info.jailbroken);
    
    NSLog(@"systemVersion is %@",info.systemsVersion);
    
//    NSLog(@"serialNumber is %@",[self serialNumber]);
    
    //[self fetchBattery];
//    initWithUUIDString
    NSUUID* udid = [[NSUUID alloc] initWithUUIDString:@"E621E1F8-C36C-495A-93FC-0C247A3E6E5F"];
    
    NSLog(@"udid is %@",udid.UUIDString);
    NSString *adid = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSLog(@"adId is %@ idfv is %@",adid,idfv);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setBs:(NSString *)bs
{
    _bs = bs;
}


- (id)fetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@", ifnam, info);
        if (info && [info count]) { break; }
    }
    return info;
}

- (void)fetchBattery
{
    ELLIOKitDumper *dumper = [ELLIOKitDumper new];
    ELLIOKitNodeInfo *root = [dumper dumpIOKitTree];
    ELLIOKitNodeInfo *children = [[root children] firstObject];
    
    [[children children] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        ELLIOKitNodeInfo *info = obj;
        
        if([info.name isEqualToString:@"AppleARMPE"]){
            
            
            
            [[info children] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                ELLIOKitNodeInfo *info1 = obj;
                
                if([info1.name isEqualToString:@"charger"]){
                    
                    NSArray* propertyArray = info1.properties;
                    
                    NSLog(@"propertyArray is %@",propertyArray.firstObject);
                    
                    
                    [propertyArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        //                        battery-id
                        
                        NSString* tempString = obj;
                        
                        if([obj rangeOfString:@"battery-id"].location != NSNotFound){
                            
                            NSLog(@"battery-id is %@",tempString);
                            
                            *stop = YES;
                            
                        }
                        
                        
                    }];
                    
                }
                
                
                
                [[info1 children] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    ELLIOKitNodeInfo *info2 = obj;
                    if([info2.name isEqualToString:@"AppleARMPMUCharger"]){
                        
                        NSArray* propertyArray = info2.properties;
                        
                        [propertyArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            
                            //                        battery-id
                            
                            NSString* tempString = obj;
                            
                            if([obj rangeOfString:@"CycleCount"].location != NSNotFound){
                                
                                NSLog(@"CycleCount is %@",tempString);
                                
                                *stop = YES;
                                
                            }
                            
                            
                        }];
                        
                    }
                    
                    
                }];
                
                //                *stop = YES;
                
            }];
            
            
            
            
            
            *stop = YES;
        }
        
        
    }];
}


- (void)testDes
{
    NSString* test1 = @"LHn0y+BOAjtK3Bj6fs3FOmkP131GiODuiq4nmILaf/amh2q6uKvgIuVubXVAHZX97EX7JKSbHbtAIWiGJE/2GRPe+DpPGCvVnASzVD7AEKsPJgihvjSNzQ+K7fP+B8DwFNyC6ku2+ZAaqrWaMV7kg2D8riE8+0SljShOjFYA4bJMFfFeC4kh7NB1XPfbtojqVDNDmLHj/vEQS8m3GcS9QizrhbQp7FCitOv03MFkcFXCAa9I50/5wOT6CpGhgXm/T7NG3vQBRxC5FtMjI13TSwBk0TzXlJrux4m9ajQYGrtofbE6XsRzBfRwQA/D6pY+BqcvhfD4tpiYCoDlClcSwif1bAZ7cG05+TqSBU1+Ty4HdCEvJw3twNOthvHXVTHZDw5e1bWVEdapygelfuDBnhiUKV+O1lJ4qtiiBVQWKmz2gLCvM4pzvKl+OGXwlvnhzTcb6mQazQUyTmi5q8Le6506wtTKTSPlMvATMpdhb/cOnPVGswrnDNeQg9EUve6Da34NQj51YuB70YqoKe/yFRNE+0gigqm0UQh4ONcDxBU=";
    
    test1 = [self decryptUseDES:test1 key:@"0dxwLxO8"];
    
    NSLog(@"test1 is %@",test1);
    
    //    NSString* test2 = @"user_id=16610763&oid_md5=FAAED18B5663C338630D5D557514F8A9&binding=26_1&idfa=1E3AC62A-A5AE-445F-BDEC-90801FADA0A7&idfv=98B576FE-1341-4288-9695-7FE25624D133&uid=211843dde181e94d9ac033470cae65e858fc7208&sn=870260YRA4S&bs=ST2203212403SW1420&cc=-2&dm=iPhone3,1&sv=7.1.2&mac=&rm=ac:29:3a:96:8e:3d&ri=192.168.2.3&dt=(null)&ut=1250&ls=14510596096&pn=38&ver=1.19&rn=dk_MAC";
    //    2858EE5C-5F5F-4876-9878-96E522F6A566
    NSString* test2 = @"user_id=15626600&oid_md5=F4C6E3528B8C507B5F168AF92190D342&binding=26_1";
    //    http://wx.itry.com/itry/xb_verify?param=&idfa=2858EE5C-5F5F-4876-9878-96E522F6A566&msg=101&ver=1.19&binding=26_1&unionid=o3eBLuJKWuf2XwrOLrz4IQyVTl1w
    test2 = [self encryptUseDES:test2 key:@"0dxwLxO8"];
    NSLog(@"test2 is %@",test2);
    
    NSURL* url = [NSURL URLWithString:@"http://www.baidu.com/s?paramet=LHn0y+BOAjtLxVC8eYfsR0pItMl1PSGXudTBtuPrvKYBBkkQPdfS9dD8CbKO10e8Op1gEdJOzs0zezzP2a809c+TVsWgtRZe"];
    
    NSLog(@"url is %@",[url query]);
}

- (NSString *) encryptUseDES:(NSString *)plainText key:(NSString *)key
{
    NSString *ciphertext = nil;
    const char *textBytes = [plainText UTF8String];
    NSUInteger dataLength = [plainText length];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    Byte iv[] = {1,2,3,4,5,6,7,8};
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [key UTF8String], kCCKeySizeDES,
                                          iv,
                                          textBytes, dataLength,
                                          buffer, 1024,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        
        ciphertext = [[NSString alloc] initWithData:[GTMBase64 encodeData:data] encoding:NSUTF8StringEncoding];
    }
    return ciphertext;
}

//解密
- (NSString *) decryptUseDES:(NSString*)cipherText key:(NSString*)key
{
    NSData* cipherData = [GTMBase64 decodeString:cipherText];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesDecrypted = 0;
    Byte iv[] = {1,2,3,4,5,6,7,8};
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [key UTF8String],
                                          kCCKeySizeDES,
                                          iv,
                                          [cipherData bytes],
                                          [cipherData length],
                                          buffer,
                                          1024,
                                          &numBytesDecrypted);
    NSString* plainText = nil;
    if (cryptStatus == kCCSuccess) {
        NSData* data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesDecrypted];
        plainText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return plainText;
}

- (NSString *)serialNumber
{
    NSString *serialNumber = nil;
    void *IOKit = dlopen("/System/Library/Frameworks/IOKit.framework/IOKit", RTLD_NOW);
    
    if (IOKit)
        
    {
        
        mach_port_t *kIOMasterPortDefault = dlsym(IOKit, "kIOMasterPortDefault");
        
        CFMutableDictionaryRef (*IOServiceMatching)(const char *name) = dlsym(IOKit, "IOServiceMatching");
        
        mach_port_t (*IOServiceGetMatchingService)(mach_port_t masterPort, CFDictionaryRef matching) = dlsym(IOKit, "IOServiceGetMatchingService");
        
        CFTypeRef (*IORegistryEntryCreateCFProperty)(mach_port_t entry, CFStringRef key, CFAllocatorRef allocator, uint32_t options) = dlsym(IOKit, "IORegistryEntryCreateCFProperty");
        
        kern_return_t (*IOObjectRelease)(mach_port_t object) = dlsym(IOKit, "IOObjectRelease");
        
        
        
        if (kIOMasterPortDefault && IOServiceGetMatchingService && IORegistryEntryCreateCFProperty && IOObjectRelease)
            
        {
            
            mach_port_t platformExpertDevice = IOServiceGetMatchingService(*kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"));
            
            if (platformExpertDevice)
                
            {
                
                CFTypeRef platformSerialNumber = IORegistryEntryCreateCFProperty(platformExpertDevice, CFSTR("IOPlatformSerialNumber"), kCFAllocatorDefault, 0);
                
                if (CFGetTypeID(platformSerialNumber) == CFStringGetTypeID())
                    
                {
                    
                    serialNumber = [NSString stringWithString:(__bridge NSString*)platformSerialNumber];
                    
                    CFRelease(platformSerialNumber);
                    
                }
                
                IOObjectRelease(platformExpertDevice);
                
            }
            
        }
        
        dlclose(IOKit);
        
    }
    
    
    
    return serialNumber;
    
}

@end
