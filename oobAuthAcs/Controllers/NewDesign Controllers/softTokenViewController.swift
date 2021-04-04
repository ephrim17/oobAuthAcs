//
//  softTokenViewController.swift
//  oobAuthAcs
//
//  Created by LOB4 on 19/10/19.
//  Copyright © 2019 fss. All rights reserved.
//

import UIKit
import SwiftOTP


class softTokenViewController: UIViewController {

    
    //timer Variables
    var timer = Timer()
    var timeLeft: TimeInterval = 30
    var sec : TimeInterval = 30
    
    @IBOutlet weak var genCode: UILabel!
    @IBOutlet weak var copyBtn: UIButton!
    @IBOutlet weak var expiresIn: UILabel!
    
    @IBOutlet weak var testLabel: UILabel!
    
    let timeLeftShapeLayer = CAShapeLayer()
    let bgShapeLayer = CAShapeLayer()
    var timerLabel =  UILabel()
    let strokeIt = CABasicAnimation(keyPath: "strokeEnd")
    var endTime: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        genCode.text = ""
        
        expiresIn.text = ""
        testLabel.text = ""
        
        //To_Check_AppMoved_To_Background_Or_Not
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        //notificationCenter.addObserver(self, selector: #selector(appCameToForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appCameToEnterActive), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
    
    }
    
  
    
    override func viewDidAppear(_ animated: Bool) {
        view.addObserver(self, forKeyPath: #keyPath(UIView.bounds), options: .new, context: nil)
        
        configureUI()
        hideLayers()
        self.title = "TOTP"
        timerLabel = UILabel(frame: CGRect(x: view.bounds.midX-45 ,y: view.bounds.midY+80, width: 100, height: 50))
        
        //CircularAnimation
        strokeIt.fromValue = 0
        strokeIt.toValue = 1
        strokeIt.duration = timeLeft
        endTime = Date().addingTimeInterval(timeLeft)
        generateCode()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("closed ---totp")
        timerLabel.textColor = UIColor.black
        sec = 30
        strokeIt.fromValue = 0
        strokeIt.toValue = 1
        strokeIt.duration = 30
        hideLayers()
        timer.invalidate()
        print("timer over")
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func appMovedToBackground() {
        print("App moved to background!")
        timerLabel.textColor = UIColor.black
        sec = 30
        strokeIt.fromValue = 0
        strokeIt.toValue = 1
        strokeIt.duration = 30
        hideLayers()
        timer.invalidate()
        print("timer over")
    }
    
    
    @objc func appCameToEnterActive(){
        print("appCameToEnterActive")
        print("app enters foreground")
        configureUI()
        hideLayers()
        self.title = "TOTP"
        
        //CircularAnimation
        strokeIt.fromValue = 0
        strokeIt.toValue = 1
        strokeIt.duration = timeLeft
        endTime = Date().addingTimeInterval(timeLeft)
        
        generateCode()
    }
    
    @objc func appCameToForeground() {
//        print("app enters foreground")
//        configureUI()
//        hideLayers()
//        self.title = "TOTP"
//
//        //CircularAnimation
//        strokeIt.fromValue = 0
//        strokeIt.toValue = 1
//        strokeIt.duration = timeLeft
//        endTime = Date().addingTimeInterval(timeLeft)
//
//        generateCode()
    }
    
    
    
    // MARK: - Selectors
    
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helper Functions
    func configureUI() {
        view.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = UIColor(red:0.84, green:0.11, blue:0.14, alpha:0.1)
        navigationItem.title = "Soft Token"
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    
    func generateCode(){
        generateTotp()
        enableLayers()
        drawBgShape()
        drawTimeLeftShape()
        timeLeftShapeLayer.add(strokeIt, forKey: nil)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(softTokenViewController.clock), userInfo: nil, repeats: true)
    }
    
    func stopGenCode(){
        print("timer over")
        timerLabel.text = ""
        timerLabel.textColor = UIColor.black
        sec = 30
        timerLabel.stopBlink()
        hideLayers()
        strokeIt.fromValue = 0
        strokeIt.toValue = 1
        strokeIt.duration = 30
        timer.invalidate()
    }
    
    @objc func clock(){
        
        sec = sec - 1
        let fullTime : [String] = "\(sec)".components(separatedBy: ".")
        
        let secs : String = fullTime[0]
        timerLabel.text = "\(secs)"
        
        if (sec < 5){
            timerLabel.textColor = UIColor.red
            timerLabel.startBlink()
        }
        
        if (sec==0){
            print("timer over")
            timerLabel.text = ""
            timerLabel.textColor = UIColor.black
            sec = 30
            timerLabel.stopBlink()
            hideLayers()
            strokeIt.fromValue = 0
            strokeIt.toValue = 1
            strokeIt.duration = 30
            timer.invalidate()
            generateCode()
        }
    }
    
    func generateTotp(){
        saveTotpFlag() //to check whether he has entered totp controller
        addTimeLabel()
        
        //Taking_SecretKey_from_Local_Storage
        let userDefaults = UserDefaults.standard
        let softKey = userDefaults.string(forKey: "totpKey")
        print("Received soft key-----\(String(describing: softKey))")
        
        //*****WORKING******//
//        guard let data = base32DecodeToData("HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ") else { return }
//        print("base32DecodeToData----\(data)")
        
        let currentDateTime = Date()
        print("Time \(currentDateTime)")
        expiresIn.text = "UTC" + " " + "\(currentDateTime)"
        
        guard let data = base32DecodeToData("HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ") else { return }
        print("base32DecodeToData----\(data)")
        
        
        //testFunc
//        var localTimeZoneIdentifier: String { return TimeZone.current.identifier }
//        print ("localTimeZoneIdentifier----\(localTimeZoneIdentifier)")
//        let dateFormatter = DateFormatter()
//        let timeZone = TimeZone(identifier: "\(localTimeZoneIdentifier)")
//        dateFormatter.timeZone = timeZone
//        dateFormatter.timeStyle = .long
//        //dateFormatter.timeZone = TimeZone(abbreviation: "UTC+5:30")
//        //dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
//        print("testFunc time-------- \(dateFormatter.string(from: Date()))")
//        testLabel.text = "\(dateFormatter.string(from: Date()))"
//        let date = dateFormatter.date(from: "\(dateFormatter.string(from: Date()))")
        

        
        
        //let calendar = Calendar.current
        //let CurrentTimePlusThirtySec = calendar.date(byAdding: .second, value: 30, to: currentDateTime)
        
        if let totp = TOTP(secret: data, digits: 6, timeInterval: 1, algorithm: .sha1) {
            
            let otpString = totp.generate(time: currentDateTime)
            print("TOTP-----\(String(describing: otpString))")
            genCode.text = otpString!
        }
    }
    
    @IBAction func copybtnAction(_ sender: Any) {
        UIPasteboard.general.string = genCode.text
        showToast(message: "OTP copied successfully")
    }
    
    func addTimeLabel() {
        //timerLabel = UILabel(frame: CGRect(x: 185-50 ,y: 525-25, width: 100, height: 50))
        timerLabel.textAlignment = .center
        timerLabel.text = "30"
        timerLabel.font = timerLabel.font.withSize(65)
        view.addSubview(timerLabel)
        
        let margins = self.view.layoutMarginsGuide
        timerLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        timerLabel.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        timerLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        timerLabel.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
    }
    
    func hideLayers(){
        //timeLabel.alpha = 0
        genCode.alpha = 0
        copyBtn.alpha = 0
        expiresIn.alpha = 0
        timeLeftShapeLayer.isHidden = true
        bgShapeLayer.isHidden = true
    }
    
    func enableLayers(){
        //timeLabel.alpha = 1
        genCode.alpha = 1
        copyBtn.alpha = 1
        expiresIn.alpha = 1
        timeLeftShapeLayer.isHidden = false
        bgShapeLayer.isHidden = false
    }
    
    func drawBgShape() {
        bgShapeLayer.path = UIBezierPath(arcCenter: CGPoint(x: view.bounds.midX , y: view.bounds.midY+100), radius:
            100, startAngle: -90.degreesToRadians, endAngle: 270.degreesToRadians, clockwise: true).cgPath
        bgShapeLayer.strokeColor = UIColor.white.cgColor
        bgShapeLayer.fillColor = UIColor.clear.cgColor
        bgShapeLayer.lineWidth = 15
        view.layer.addSublayer(bgShapeLayer)
        bgShapeLayer.frame = view.bounds
    }
    
    func drawTimeLeftShape() {
        timeLeftShapeLayer.path = UIBezierPath(arcCenter: CGPoint(x: view.bounds.midX , y: view.bounds.midY+100), radius:
            100, startAngle: -90.degreesToRadians, endAngle: 270.degreesToRadians, clockwise: true).cgPath
        //timeLeftShapeLayer.strokeColor = UIColor.red.cgColor
        timeLeftShapeLayer.strokeColor = UIColor(red:0.27, green:0.65, blue:1.00, alpha:1.0).cgColor
        timeLeftShapeLayer.fillColor = UIColor.clear.cgColor
        timeLeftShapeLayer.lineWidth = 15
        view.layer.addSublayer(timeLeftShapeLayer)
        timeLeftShapeLayer.frame = view.bounds
    }
    
}

//Showing--Toast--Message
extension UIViewController {
    
    func showToast(message : String) {
        
        let alert = UIAlertController(title: "Success", message: "Code copied Successfully", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "okay", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
//        let toastLabel = UILabel(frame: CGRect(x: 16, y: 465, width: 343, height: 50))
//        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
//        toastLabel.textColor = UIColor.white
//        toastLabel.font = UIFont(name: "Avenir-Light", size: 19.0)
//        toastLabel.textAlignment = .center;
//        toastLabel.text = message
//        toastLabel.alpha = 1.0
//        toastLabel.layer.cornerRadius = 10;
//        toastLabel.clipsToBounds  =  true
//        self.view.addSubview(toastLabel)
//        UIView.animate(withDuration: 4.0, delay: 1, options: .curveEaseOut, animations: {
//            toastLabel.alpha = 0.0
//        }, completion: {(isCompleted) in
//            toastLabel.removeFromSuperview()
//        })
    }
    
}

extension Int {
    var degreesToRadians : CGFloat {
        return CGFloat(self) * .pi / 180
    }
}

//UILabel---blinking
extension UILabel {
    func startBlink() {
        UIView.animate(withDuration: 0.5,
                       delay:0.0,
                       options:[.allowUserInteraction, .curveEaseInOut, .autoreverse, .repeat],
                       animations: { self.alpha = 0 },
                       completion: nil)
    }
    
    func stopBlink() {
        layer.removeAllAnimations()
        alpha = 1
    }
}


extension softTokenViewController{
    func saveTotpFlag(){
         Storage.myStorage(totpFlagVal: "yes")
    }
}
