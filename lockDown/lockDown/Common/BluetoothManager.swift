//
//  BluetoothManager.swift
//  lockDown
//
//  Created by Aymen HECHMI on 11/04/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import Foundation
import CoreBluetooth
import CoreLocation

enum Constants: String {
    //case SERVICE_UUID = "4DF91029-B356-463E-9F48-BAB077BF3EF5"
    case SERVICE_UUID =  "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"
}

protocol BluetoothManagerDelegate: AnyObject {
    func peripheralsDidUpdate(peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber)
    func centralStateOn()
    func centralStateOff()
}

protocol BluetoothManager {
    var peripherals: Dictionary<UUID, CBPeripheral> { get }
    var delegate: BluetoothManagerDelegate? { get set }
    func startAdvertising(with name: String)
    func startScanning()
}

class CoreBluetoothManager: NSObject, BluetoothManager {
    // MARK: - Public properties
    weak var delegate: BluetoothManagerDelegate?
    private(set) var peripherals = Dictionary<UUID, CBPeripheral>() {
        didSet {
            //delegate?.peripheralsDidUpdate()
        }
    }
    // MARK: - Private properties
    private var peripheralManager: CBPeripheralManager?
    private var centralManager: CBCentralManager?
    private var name: String?
    
    // Objects used in the creation of iBeacons
    var beaconPeripheralManager: CBPeripheralManager?
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    
    let localBeaconUUID = "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"
    let localBeaconMajor: CLBeaconMajorValue = 123
    let localBeaconMinor: CLBeaconMinorValue = 789
    let identifier = UserDefaults.standard.string(forKey: "deviceId")

    // MARK: - Public methods
    
    func initLocalBeacon() {
        if localBeacon != nil {
            stopLocalBeacon()
        }
        let uuid = UUID(uuidString: localBeaconUUID)!
        localBeacon = CLBeaconRegion(proximityUUID: uuid, major: localBeaconMajor, minor: localBeaconMinor, identifier: identifier!)
        beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
        beaconPeripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    func stopLocalBeacon() {
        
        peripheralManager?.stopAdvertising()
        peripheralManager = nil
        beaconPeripheralData = nil
        localBeacon = nil
    }
    
    func startAdvertising(with name: String) {
        self.name = name
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    func startScanning() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension CoreBluetoothManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            if peripheral.isAdvertising {
                peripheral.stopAdvertising()
            }

            let uuid = CBUUID(string: Constants.SERVICE_UUID.rawValue)
            var advertisingData: [String : Any] = [CBAdvertisementDataServiceUUIDsKey: [uuid]]

            if let name = self.name {
                advertisingData[CBAdvertisementDataLocalNameKey] = name
            }
//            let deviceId = UserDefaults.standard.string(forKey: "deviceId")
//            let deviceIdData = deviceId!.data(using: .utf8)
//            advertisingData[CBAdvertisementDataServiceDataKey] = ["\(uuid)":deviceIdData]
            self.peripheralManager?.startAdvertising(advertisingData)
            //beaconPeripheralManager?.startAdvertising(beaconPeripheralData as? [String: Any])
        } else if peripheral.state == .poweredOff {
            beaconPeripheralManager?.stopAdvertising()
        }
    }
}

extension CoreBluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {

            if central.isScanning {
                central.stopScan()
            }

            let uuid = CBUUID(string: Constants.SERVICE_UUID.rawValue)
            central.scanForPeripherals(withServices: [uuid], options: [CBCentralManagerScanOptionAllowDuplicatesKey : false])
            delegate?.centralStateOn()
        } else {
            delegate?.centralStateOff()
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        peripherals[peripheral.identifier] = peripheral
        delegate?.peripheralsDidUpdate(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI)
    }
}

