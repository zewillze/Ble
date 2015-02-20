//
//  VEBleHandle.h
//  Veepoo_Health
//
//  Created by zeze on 15/2/15.
//  Copyright (c) 2015年 veepoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef NS_ENUM(NSInteger, CentralState)
{
    noConnect = 0,
    connected = 1
};



@protocol VEBleDelegate <NSObject>

//Discover Peripherals
- (void)alreadyFoundDevice:(CBPeripheral*)peripheral;

//Discover Services
- (void)discoverServices:(CBService*)service;




@optional

//State
- (void)bleStateChangeTo:(CentralState)state;
//RSSI
- (void)getRSSI:(NSNumber*)RSSI;



//Save dev info


@end

@protocol VEBleDataDelegate <NSObject>

//get the characteristic Value
- (void)getTheValueWithCharcteristic:(CBCharacteristic*)characteristic;

@end


@interface VEBleHandle : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic, strong) id<VEBleDelegate>bleDelegate;
@property (nonatomic, strong) id<VEBleDataDelegate>dataDelegate;

@property (nonatomic, retain) CBPeripheral *connectPeripheral;
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) NSTimer *scanTimer;

//init
- (id)initWithDelegate:(id<VEBleDelegate>)delegate;

//searchDevice;
- (void)startScanDevice;

//connect device
- (void)connectDevice:(CBPeripheral*)peripheral;

//disconnect device;
- (void)disconnectDevice;

// Read RSSI
- (void)readDevRSSI;

//stop scan device
- (void)stopScanDevice;

//save dev info
- (void)storeDevice;

//write command
- (void)writeCharacteristicWithService:(NSString*)sUUID cID:(NSString*)CID dID:(NSString*)DID data:(NSData*)data isNoti:(BOOL)flag;
- (void)notiWithService:(NSString*)sUUID dID:(NSString*)DID isNoti:(BOOL)flag;
@end
