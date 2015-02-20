//
//  VEBleHandle.m
//  Veepoo_Health
//
//  Created by zeze on 15/2/15.
//  Copyright (c) 2015年 veepoo. All rights reserved.
//

#import "VEBleHandle.h"
#import "BLEUtility.h"
#define ConnectDevice self.connectPeripheral


@implementation VEBleHandle
{
    
}
@synthesize centralManager;
@synthesize scanTimer;
- (id)initWithDelegate:(id<VEBleDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.bleDelegate = delegate;
        centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
        
        
    }
    return self;
}

#pragma 手动操作
/**
 *  Scan
 */
- (void)startScanDevice
{
    if (centralManager.state == CBCentralManagerStatePoweredOn) {
        debugLog(@"startScanDevice");
        if (scanTimer) {
            [centralManager scanForPeripheralsWithServices:nil options:nil];
        }else{
            scanTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(startScanDevice) userInfo:nil repeats:YES];
        }
    }
}
/**
 *  stop Scan
 */
- (void)stopScanDevice
{
    if (centralManager.state == CBCentralManagerStatePoweredOn) {
        [centralManager stopScan];
    }
    [scanTimer invalidate];
    scanTimer = nil;
}
/**
 * connectDevice
 */
- (void)connectDevice:(CBPeripheral *)peripheral
{
    ConnectDevice = peripheral;
    
    [centralManager connectPeripheral:ConnectDevice options:nil];
}

/*
 disconnectDevice handle To disconn手动断开蓝牙
 */
- (void)disconnectDevice
{
    [centralManager cancelPeripheralConnection:ConnectDevice];
}
/*
 read RSSI
 */
- (void)readDevRSSI
{
    [ConnectDevice readRSSI];
}


- (void)writeCharacteristicWithService:(NSString*)sUUID cID:(NSString*)CID dID:(NSString*)DID data:(NSData*)data isNoti:(BOOL)flag
{
    [BLEUtility writeCharacteristic:self.connectPeripheral sUUID:sUUID cUUID:CID data:data];
    [BLEUtility setNotificationForCharacteristic:self.connectPeripheral sUUID:sUUID cUUID:CID enable:flag];
}

- (void)notiWithService:(NSString*)sUUID dID:(NSString*)DID isNoti:(BOOL)flag
{
     [BLEUtility setNotificationForCharacteristic:self.connectPeripheral sUUID:sUUID cUUID:DID enable:flag];
}

#pragma 代理方法

/*
 CBCentralManagerDelegate BleState
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    [self startScanDevice];
    debugLog(@"centralManagerDidUpdateState");
}

//found device
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    [self.bleDelegate alreadyFoundDevice:peripheral];
    debugLog(@"didDiscoverPeripheral :%@",peripheral);
}


//did connect peripheral
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self.bleDelegate bleStateChangeTo:connected];
    
    
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    debugLog(@"didConnectPeripheral");
}

//disconnect peripheral
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self.bleDelegate bleStateChangeTo:noConnect];
}

//fail to connect peripheral
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self.bleDelegate bleStateChangeTo:noConnect];
}

//discover services
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    debugLog(@"didDiscoverServices");
    for (CBService *s in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:s];
    }
}

//discover characteristics For Service
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    debugLog(@"didDiscoverCharacteristicsForService");
    [self.bleDelegate discoverServices:service];
}

//update Value For characteristic
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    debugLog(@"didUpdateValueForCharacteristic");
    [self.dataDelegate getTheValueWithCharcteristic:characteristic];
}

// RSSI Value
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    [self.bleDelegate getRSSI:RSSI];
}

- (void)storeDevice
{
    //    NSString *str = IOS_VERSION>=7.0? CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, DEFAULT_PERIPHER.UUID)):@"";
    NSString *str = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, ConnectDevice.UUID));
    NSMutableDictionary *dicz = [NSMutableDictionary dictionary];
    
    [dicz setObject:str forKey:@"select_uuid"];
    [dicz setObject:ConnectDevice.name forKey:@"select_name"];
    [[NSUserDefaults standardUserDefaults] setObject:dicz forKey:@"lastDevice"];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
