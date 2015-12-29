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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self testDes];
    
    NSDictionary* dic = [self fetchSSIDInfo];
    
    NSLog(@"SSID is %@",[dic objectForKey:@"SSID"]);
    NSLog(@"BSSID is %@",[dic objectForKey:@"BSSID"]);
    NSLog(@"OpenUDID value is %@",[OpenUDID value]);
    
    NSLog(@"longDiskSpace is %lld",[SSDiskInfo longDiskSpace]);
    
    NSLog(@"systemDeviceTypeNotFormatted is %@",[[SystemServices sharedServices] systemDeviceTypeNotFormatted]);
    
    NSLog(@"systemsUptime is %@",[[SystemServices sharedServices] systemsUptime]);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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



- (void)testDes
{
    NSString* test1 = @"LHn0y+BOAjuU4eUyh865aBmD6cMI8QOpUEu0gL0TLQPk4LKoW1mnLL6Ah8JsrOO0QssMgXAnBkqmkOuJOAbJ6x3SzxbqlMT4";
    
    test1 = [self decryptUseDES:test1 key:@"0dxwLxO8"];
    
    NSLog(@"test1 is %@",test1);
    
    //    NSString* test2 = @"user_id=16610763&oid_md5=FAAED18B5663C338630D5D557514F8A9&binding=26_1&idfa=1E3AC62A-A5AE-445F-BDEC-90801FADA0A7&idfv=98B576FE-1341-4288-9695-7FE25624D133&uid=211843dde181e94d9ac033470cae65e858fc7208&sn=870260YRA4S&bs=ST2203212403SW1420&cc=-2&dm=iPhone3,1&sv=7.1.2&mac=&rm=ac:29:3a:96:8e:3d&ri=192.168.2.3&dt=(null)&ut=1250&ls=14510596096&pn=38&ver=1.19&rn=dk_MAC";
    //    2858EE5C-5F5F-4876-9878-96E522F6A566
    NSString* test2 = @"user_id=16610763&oid_md5=FAAED18B5663C338630D5D557514F8A9&binding=26_1&idfa=2858EE5C-5F5F-4876-9878-96E522F6A566&idfv=08B576FE-1341-4288-9695-7FE25624D133&uid=311843dde181e94d9ac033470cae65e858fc7208&sn=970260YRA4S&bs=TT2203212403SW1420&cc=-2&dm=iPhone3,1&sv=7.1.2&mac=&rm=bc:29:3a:96:8e:3d&ri=192.168.2.3&dt=(null)&ut=1251&ls=24510596096&pn=38&ver=1.19&rn=dk_MAC";
    //    http://wx.itry.com/itry/xb_verify?param=&idfa=2858EE5C-5F5F-4876-9878-96E522F6A566&msg=101&ver=1.19&binding=26_1&unionid=o3eBLuJKWuf2XwrOLrz4IQyVTl1w
    test2 = [self encryptUseDES:test2 key:@"0dxwLxO8"];
    NSLog(@"test2 is %@",test2);
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
@end
