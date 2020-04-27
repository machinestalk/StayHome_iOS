//
//  BluetoothManager.swift
//  lockDown
//
//  Created by Aymen HECHMI on 11/04/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import Foundation
import CoreBluetooth

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

    // MARK: - Public methods
    func startAdvertising(with name: String) {
        self.name = name
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    func startScanning() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // MARK: - Private properties
    private var peripheralManager: CBPeripheralManager?
    private var centralManager: CBCentralManager?
    private var name: String?
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
            self.peripheralManager?.startAdvertising(advertisingData)
        } else {
            //TO DO
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

