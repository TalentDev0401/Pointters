//
//  RegisterViewController.swift
//  Pointters
//
//  Created by Mac on 2/14/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import AWSS3
import AWSCore
import CoreLocation
import FirebaseAnalytics

class RegisterViewController: UIViewController {
    
    @IBOutlet var consNavBarTop: NSLayoutConstraint!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imgPic: UIImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var tfFirst: UITextField!
    @IBOutlet var tfLast: UITextField!
    @IBOutlet var tfLocation: UITextField!
    @IBOutlet var btnSignUp: UIButton!
    
    var locationManager = CLLocationManager()
    
    let imagePickerController = UIImagePickerController()
    var selectedImgData: Data!
    
    var imageURL = ""
    var txtFirst = ""
    var txtLast = ""
    var dictLocation = [String:Any]()

    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initUI()
        setupLocationManager()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    //*******************************************************//
    //              MARK: - Private Method                   //
    //*******************************************************//
    
    func initUI() {
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavBarTop.constant = 85.0
        } else {
            consNavBarTop.constant = 64.0
        }
        
        imgPic.layer.cornerRadius = imgPic.frame.size.height/2
        imgPic.layer.masksToBounds = true
        
        btnSignUp.layer.cornerRadius = 5.0
        btnSignUp.layer.masksToBounds = true
    }
    
    func initData(){
        if let userDict = UserCache.sharedInstance.getUserCredentials() {
            if let val = userDict[kUserCredentials.kLoginType] as? String {
                if val == "F" {
                    let user = UserCache.sharedInstance.getAccountData()
                    if user.firstName != "" {
                        txtFirst = user.firstName
                        tfFirst.text = user.firstName
                    }
                    if user.lastName != "" {
                        txtLast = user.lastName
                        tfLast.text = user.lastName
                    }
                    setUserName()
                    if user.profilePic != "" {
                        imageURL = user.profilePic
                        imgPic.sd_imageTransition = .fade
                        imgPic.sd_setImage(with: URL(string: imageURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"user_avatar_placeholder"))
                    }
                }
            }
        }
    }
    
    func setUserName() {
        var strName = ""
        
        if txtFirst != "" {
            strName = txtFirst + " "
        }
        if txtLast != "" {
            strName += txtLast
        }
        
        lblName.text = strName
    }
    
    func allowSignUp() {
        if txtFirst != "" && txtLast != "" && tfLocation.text != "" {
            btnSignUp.backgroundColor = UIColor.getCustomBlueColor()
            btnSignUp.isUserInteractionEnabled = true
        } else {
            btnSignUp.backgroundColor = UIColor.lightGray
            btnSignUp.isUserInteractionEnabled = false
        }
    }
    
    func uploadImageOnAWS() {
        let accessKey = kAWSCredentials.kAccessKey
        let secretKey = kAWSCredentials.kSecretKey
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        let remoteName = "profile_pic_" + txtFirst + UIDevice.current.identifierForVendor!.uuidString
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(remoteName)
        do {
            try selectedImgData?.write(to: fileURL)
        }
        catch {}
        let uploadRequest = AWSS3TransferManagerUploadRequest()!
        uploadRequest.body = fileURL
        uploadRequest.key = remoteName
        uploadRequest.bucket = kAWSCredentials.kS3BucketName
        uploadRequest.contentType = "image/jpeg"
        uploadRequest.acl = .publicRead
        
        let url = AWSS3.default().configuration.endpoint.url
        let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!)
        imageURL = (publicURL?.absoluteString)!

        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest).continueWith { (task: AWSTask<AnyObject>) -> Any? in
            if let error = task.error {
                print("Upload failed with error: (\(error.localizedDescription))")
            }
            
            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!)
                print("Uploaded to:\(String(describing: publicURL))")
            }
            return nil
        }
        
    }
    
    func deleteImageOnAWS(){
        let s3 = AWSS3.default()
        let deleteObjectRequest = AWSS3DeleteObjectRequest()
        deleteObjectRequest?.bucket = kAWSCredentials.kS3BucketName
        deleteObjectRequest?.key = "profile_pic " + txtFirst + UIDevice.current.identifierForVendor!.uuidString
        s3.deleteObject(deleteObjectRequest!).continueWith { (task:AWSTask) -> AnyObject? in
            if let error = task.error {
                print("Error occurred: \(error)")
                return nil
            }
            print("Deleted successfully.")
            return nil
        }
    }
    
    func getUserLocationDict() {
        let lat:Double = UserCache.sharedInstance.getUserLatitude()!
        let lng:Double = UserCache.sharedInstance.getUserLongitude()!
        let location = CLLocation(latitude: lat, longitude: lng)
        var dictLatLng = [String:Any]()
        dictLatLng["type"] = "Point"
        dictLatLng["coordinates"] = [location.coordinate.longitude, location.coordinate.latitude]
        self.dictLocation["geoJson"] = dictLatLng
        
        let geocoder = CLGeocoder()
        PointtersHelper.sharedInstance.startLoader(view: self.view)
        geocoder.reverseGeocodeLocation(location, completionHandler: {
            placemarks, error in
            PointtersHelper.sharedInstance.stopLoader()
            
            if let err = error {
                print(err.localizedDescription)
                self.tfLocation.text = "Unknown address"
            } else if let placemarkArray = placemarks {
                if let placemark = placemarkArray.first {
                    print(placemark)
                    self.dictLocation["city"] = placemark.locality
                    self.dictLocation["country"] = placemark.country
                    self.dictLocation["postalCode"] = placemark.postalCode
                    self.dictLocation["province"] = placemark.subAdministrativeArea
                    self.dictLocation["state"] = placemark.administrativeArea
                    self.showLocation(code: placemark.postalCode, city: placemark.locality, state: placemark.administrativeArea, country: placemark.country)
                } else {
                    print("Placemark was nil")
                    self.tfLocation.text = "Unknown address"
                }
            } else {
                print("Unknown error")
                self.tfLocation.text = "Unknown address"
            }
        })
    }
    
    func showLocation(code:String?, city:String?, state:String?, country:String?) {
        var strLocation = ""
        
        if city != nil && city != "" {
            strLocation = strLocation + city! + " "
        }
        if state != nil && state != "" {
            strLocation = strLocation + state! + ", "
        }
        if code != nil && code != "" {
            strLocation = strLocation + code! + ", "
        }
        if country != nil && country != "" {
            strLocation = strLocation + country!
        }
        
        if strLocation != "" {
            tfLocation.text = strLocation
        } else {
            tfLocation.text = "Unknown address"
        }
        
        allowSignUp()
    }
    
    func parseAPIResponse(userDict:[String:Any]) {
        let user = User()
        
        if let val = userDict["_id"] {
            user.id = val as! String
        }
        if let val = userDict["firstName"] {
            user.firstName = val as! String
        }
        if let val = userDict["lastName"] {
            user.lastName = val as! String
        }
        if let val = userDict["birthday"] {
            user.birthday = val as! String
        }
        if let val = userDict["profilePic"] {
            user.profilePic = val as! String
        }
        if let val = userDict["profileBackgroundMedia"] {
            user.profileMedia = val as! [[String : String]]
        }
        
        if let val = userDict["email"] {
            user.email = val as! String
        }
        if let val = userDict["phone"] {
            user.phone = val as! String
        }
        if let val = userDict["verified"] {
            user.verified = val as! Bool
        }
        if let val = userDict["description"] {
            user.desc = val as! String
        }
        if let val = userDict["companyName"] {
            user.companyName = val as! String
        }
        
        if let val = userDict["education"] {
            user.education = val as! String
        }
        if let val = userDict["license"] {
            user.license = val as! String
        }
        if let val = userDict["insurance"] {
            user.insurance = val as! String
        }
        if let val = userDict["awards"] {
            user.awards = val as! String
        }
        
        if let val = userDict["isAdmin"] {
            user.isAdmin = val as! Bool
        }
        if let val = userDict["isActive"] {
            user.isActive = val as! Bool
        }
        
        UserCache.sharedInstance.setAccountData(userData: user)
    }
    
    //*******************************************************//
    //              MARK: - IBAction Method                  //
    //*******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func btnPicTapped(_ sender: Any) {
        tfFirst.resignFirstResponder()
        tfLast.resignFirstResponder()
        
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = ["public.image"]
        present(imagePickerController, animated: false, completion: nil)
    }
    
    @IBAction func btnTermsTapped(_ sender: Any) {
        let termsVC = storyboard?.instantiateViewController(withIdentifier: "TermsVC") as! TermsViewController
        navigationController?.pushViewController(termsVC, animated: true)
    }
    
    @IBAction func btnPolicyTapped(_ sender: Any) {
        let privacyVC = storyboard?.instantiateViewController(withIdentifier: "PrivacyVC") as! PrivacyViewController
        navigationController?.pushViewController(privacyVC, animated: true)
    }
    
    @IBAction func btnSignUpTapped(_ sender: Any) {
        if imageURL == "" {
            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Please upload your profile picture to complete the signup.", buttonTitles: ["OK"], viewController: self, completion: nil)
            return
        }
        var userDict = [String:Any]()
        userDict["firstName"] = txtFirst
        userDict["lastName"] = txtLast
        userDict["profilePic"] = imageURL
        userDict["location"] = dictLocation
        userDict["completedRegistration"] = true
        userDict["completedRegistrationDate"] = PointtersHelper.sharedInstance.getCurrentDateTime()
        callUpdateUserApi(dict: userDict)
    }
    
    @IBAction func btnLocationTapped(_ sender: Any) {
        tfFirst.resignFirstResponder()
        tfLast.resignFirstResponder()
        getUserLocationDict()
    }
    
    //*******************************************************//
    //              MARK: - Call API Method                  //
    //*******************************************************//
    
    func callUpdateUserApi(dict:[String:Any]) {
        locationManager.stopUpdatingLocation()
        PointtersHelper.sharedInstance.startLoader(view: view)
        ApiHandler.callUpdateUser(userParam: dict, withCompletionHandler: { (result,statusCode,response, error) in
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    self.callGetUserDetailApi()
                } else {
                    PointtersHelper.sharedInstance.stopLoader()
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: responseDict["message"] as! String, buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                PointtersHelper.sharedInstance.stopLoader()
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: error, buttonTitles: ["OK"], viewController: self, completion: nil)
            }
        })
    }
    
    func callGetUserDetailApi() {
        ApiHandler.callGetUserDetails(withCompletionHandler: { (result,statusCode,response) in
            PointtersHelper.sharedInstance.stopLoader()
            
            if result == true {
                let responseDict = response.value as! [String:Any]
                if statusCode == 200 {
                    let userDict = responseDict["user"] as! [String:Any]
                    self.parseAPIResponse(userDict : userDict)
                    var dict = UserCache.sharedInstance.getUserCredentials()
                    dict![kUserCredentials.kCompletedRegistration] = userDict["completedRegistration"]
                    UserCache.sharedInstance.setUserCredentials(userDict:dict!)
                    
                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                    let containerNavVC = storyBoard.instantiateViewController(withIdentifier: "ContainerTabsNavVC") as! UINavigationController
                    let containerVC = storyBoard.instantiateViewController(withIdentifier: "ContainerTabVC") as! ContainerTabViewController
                    containerNavVC.viewControllers = [containerVC]
                    
                    let window: UIWindow = PointtersHelper.sharedInstance.mainWindow()
                    UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                        window.rootViewController = containerNavVC
                    }, completion: { completed in
                        window.makeKeyAndVisible()
                    })
                    PointtersHelper.sharedInstance.sendAnalyticsToFirebase(event: kFirebaseEvents.userRegisterComplete)
                } else {
                    PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "connection failed", buttonTitles: ["OK"], viewController: self, completion: nil)
                }
            } else {
                PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "connection failed", buttonTitles: ["OK"], viewController: self, completion: nil)
            }
        })
    }
}

//*******************************************************//
//                  MARK: - Extensions                   //
//*******************************************************//

// UITextFieldDelegate
extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typeCasteToStringFirst = textField.text as NSString?
        let newString = typeCasteToStringFirst?.replacingCharacters(in: range, with: string)
        
        if textField == tfFirst {
            txtFirst = newString!
            setUserName()
        } else if textField == tfLast {
            txtLast = newString!
            setUserName()
        }
        
        allowSignUp()
        
        return true
    }
}

// UIImagePickerControllerDelegate
extension RegisterViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        PointtersHelper.sharedInstance.startLoader(view: view)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage?

        if selectedImgData != nil {
            selectedImgData = UIImageJPEGRepresentation(image!, 0.9)
            
            DispatchQueue.global(qos: .background).async {
                self.deleteImageOnAWS()
                self.uploadImageOnAWS()
                
                DispatchQueue.main.async {
                    self.imgPic.image = image
                    self.allowSignUp()
                    PointtersHelper.sharedInstance.stopLoader()
                }
            }
        }
        else {
            selectedImgData = UIImageJPEGRepresentation(image!, 0.9)
            
            DispatchQueue.global(qos: .background).async {
                self.uploadImageOnAWS()
                
                DispatchQueue.main.async {
                    self.imgPic.image = image
                    self.allowSignUp()
                    PointtersHelper.sharedInstance.stopLoader()
                }
            }
        }
        
        imagePickerController.dismiss(animated: true, completion: nil)
    }
}

extension RegisterViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0] as CLLocation
        UserCache.sharedInstance.setUserLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        getAddressFromLatLon(pdblLatitude: userLocation.coordinate.latitude, withLongitude: userLocation.coordinate.longitude)
    }
}
