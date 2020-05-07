//
//  BarcodeScanViewController.swift
//  BookShelf
//
//  Created by 西田 on 19/12/23.
//  Copyright © 2019 Nishida. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON
import SDWebImage

class BarcodeScanViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate{
        
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    let detectionArea = UIView()

    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    
    var coredataAction = CoredataAtion()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = false
        
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do{
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch{
            return
        }
        
        if (captureSession.canAddInput(videoInput)){
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)){
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8,.ean13]
        } else {
            failed()
            return
        }
        
        let x:CGFloat = 0.1
        let y:CGFloat = 0.3
        let width:CGFloat = 0.8
        let height:CGFloat = 0.2
        
        detectionArea.frame = CGRect(x: view.frame.size.width * 0.1, y: view.frame.size.height * 0.2, width: view.frame.size.width * 0.8, height: view.frame.size.height * height)
        detectionArea.layer.borderColor = UIColor.red.cgColor
        detectionArea.layer.borderWidth  = 3
        detectionArea.layer.zPosition = 1
        view.addSubview(detectionArea)
         // 画面の横、縦に対して、左が5%、上が30%のところに、横幅80%、縦幅20%を読み取りエリアに設定
        metadataOutput.rectOfInterest = CGRect(x: y, y: 1 - x - width, width: height, height: width)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(x: 0, y: view.frame.size.height * 0.1, width: view.frame.size.width, height: view.frame.size.height * 0.4)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.zPosition = -1
        view.layer.addSublayer(previewLayer)
        captureSession.startRunning()
        saveBtn.isEnabled = false
    }
    
    func failed(){
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device doesn't supprort scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        
        if (captureSession?.isRunning == false){
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true){
            captureSession.stopRunning()
        }
    }
    
//    func convartISBN(value: String) -> String? {
//        let v = NSString(string: value).longLongValue
//        let prefix: Int64 = Int64(v / 10000000000)
//        guard prefix == 978 || prefix == 979 else { return nil }
//        let isbn9: Int64 = (v % 10000000000) / 10
//        var sum: Int64 = 0
//        var tmpISBN = isbn9
//    /*
//    for var i = 10; i > 0 && tmpISBN > 0; i -= 1 {
//        let divisor: Int64 = Int64(pow(10, Double(i - 2)))
//        sum += (tmpISBN / divisor) * Int64(i)
//        tmpISBN %= divisor
//    }
//    */
//
//        var i = 10
//        while i > 0 && tmpISBN > 0 {
//            let divisor: Int64 = Int64(pow(10, Double(i - 2)))
//            sum += (tmpISBN / divisor) * Int64(i)
//            tmpISBN %= divisor
//            i -= 1
//        }
//        let checkdigit = 11 - (sum % 11)
//        return String(format: "%lld%@", isbn9, (checkdigit == 10) ? "X" : String(format: "%lld", checkdigit % 11))
//    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if let metadataObject = metadataObjects.first{
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
//            guard let isbn = convartISBN(value: stringValue)  else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

            found(code: stringValue)
            captureSession.stopRunning()
            saveBtn.isEnabled = true
            
        }
    }
    
    func found(code: String){
        
        let url = "https://api.openbd.jp/v1/get?isbn=\(code)"

        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { (response) in
                
            switch response.result{
            case.success:
                let json:JSON = JSON(response.data as Any)
                let title = json[0]["summary"]["title"].string
                let author = json[0]["summary"]["author"].string
                let content = json[0]["onix"]["CollateralDetail"]["TextContent"][0]["Text"].string
                let imageURL = json[0]["summary"]["cover"].string
                
                self.label.text = title
                self.author.text = author
                self.content.text = content
                self.bookImage.sd_setImage(with: URL(string: imageURL!), completed: nil)
                break
                
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait
    }
    
    @IBAction func save(_ sender: Any) {
        
        coredataAction.sortAction()
        coredataAction.saveAction(title: label.text!, author: author.text!, content: content.text, url: bookImage.sd_imageURL!)
        self.navigationController?.popViewController(animated: true)

    }
}

