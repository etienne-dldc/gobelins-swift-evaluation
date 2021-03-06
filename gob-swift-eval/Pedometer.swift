//
//  Pedometer.swift
//  gob-swift-eval
//
//  Created by Quentin Tshaimanga on 22/03/2016.
//  Copyright © 2016 Etienne De Ladonchamps. All rights reserved.
//

import Foundation
import CoreMotion


class CustomPedometerData {
    var numberOfSteps: Int = 0
    var distance: Int = 0
    var currentCadence: Int = 0
    var floorsAscended: Int = 0
    var floorsDescended: Int = 0
    var startDate: NSDate
    var endDate: NSDate
    
    
    init (numberOfSteps: Int, distance: Int, currentCadence: Int, floorsAscended: Int, floorsDescended: Int, startDate: NSDate, endDate: NSDate) {
        self.numberOfSteps = numberOfSteps
        self.distance = distance
        self.currentCadence = currentCadence
        self.floorsAscended = floorsAscended
        self.floorsDescended = floorsDescended
        self.startDate = startDate
        self.endDate = endDate;
    }
}

class CustomPedometer {
    var socket = Socket.sharedInstance
    weak var delegate: ViewController?
    
    let useNatif: Bool
    var natifPedometer: CMPedometer? = nil
    
    init(useNatif: Bool){
        self.useNatif = useNatif
    }
    
    func getPedometerData (fromDate: NSDate, toDate: NSDate) -> CustomPedometerData {
        
        var numberOfSteps = 0;
        var distance = 0;
        var currentCadence = 0;
        var floorsAscended = 0;
        var floorsDescended = 0;
        var startDate : NSDate = NSDate();
        var endDate: NSDate = NSDate();
        
        if ( useNatif ) {
            self.natifPedometer = CMPedometer()
            
            if CMPedometer.isStepCountingAvailable() {
                print("valid pedometer");
            } else {
                print("invalid pedometer");
            }
            
            self.natifPedometer!.queryPedometerDataFromDate(NSDate(), toDate: NSDate(), withHandler: { (data, error) -> Void in
                
                numberOfSteps = Int(data!.numberOfSteps)
                distance = Int(data!.distance!)
                currentCadence = Int(data!.currentCadence!)
                floorsAscended = Int(data!.floorsAscended!)
                floorsDescended = Int (data!.floorsDescended!)
                //onComplete(CustomPedometerData())
            })
            
        }else {
            
            //USE Socket
            self.socket.io.on("UPDATE_PEDOMETER") { data, ack in

                let step = data[0].integerValue;
                self.delegate?.returnData(step);
            }
            
            //TODO AnyObject to NSDATA
            
            //Get DATA
            let data = NSData(contentsOfURL: NSURL(string: "http://127.0.0.1:8080/pedometerData/")!)
            
            var jsonResult : AnyObject
            
            if (data != nil){
                
                do {
                    jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    
                    if let items = jsonResult as? NSArray {
                        for item in items {
                            print(item["numberOfSteps"]!!.integerValue);
                            print(item["distance"]!!.integerValue);
                            print(item["currentCadence"]!!.integerValue);
                            print(item["floorsAscended"]!!.integerValue);
                            print(item["floorsDescended"]!!.integerValue);
                            
                            numberOfSteps = item["numberOfSteps"]!!.integerValue
                            distance = 10
                            
                            let time = 2
                            currentCadence = distance * time
                            
                            floorsAscended = 4
                            floorsDescended = 2
                            
                            startDate = fromDate
                            endDate = toDate
                            
                        }
                    }
                    
                } catch let error as NSError {
                    print(error)
                }
            }else{
                print("error connection database (php)")
            }
            //onComplete(CustomPedometerData())
        }
        
        return CustomPedometerData(numberOfSteps: numberOfSteps, distance: distance, currentCadence: currentCadence, floorsAscended: floorsAscended, floorsDescended: floorsDescended, startDate: startDate, endDate: endDate)
        
    }
    
}

    // MARK: CustomPedometerDelegate
    protocol CustomPedometerDelegate: class {
        func returnData(data:NSNumber)
        
    }



