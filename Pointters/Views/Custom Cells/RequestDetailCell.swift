//
//  RequestDetailCell.swift
//  Pointters
//
//  Created by super on 4/30/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
import AWSS3
import AWSCore

protocol RequestDetailCellDelegate {
    func edittedPhotos(snapShots: [Media])
}


class RequestDetailCell: UITableViewCell {
    
    // category cell
    @IBOutlet weak var lblCategory: UILabel!
    
    // description cell
    @IBOutlet weak var tvDescription: UITextView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var imgClose: UIImageView!
    
    // schedule cell
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var tfDate: UITextField!

    // snap cell
    @IBOutlet weak var collectionView: UICollectionView!
    
    // price cell
    @IBOutlet weak var tfMinPrice: UITextField!
    @IBOutlet weak var tfMaxPrice: UITextField!
    
    // location cell
    @IBOutlet weak var lblLocation: UILabel!
    
    // online cell
    @IBOutlet weak var imgCheck: UIImageView!
    
    var photoEditDelegate : RequestDetailCellDelegate?

    var arrSnapPhotos = [Media]()
    var pageFlag = 0
    var viewController = UIViewController()
    var mediaIndex = 0
    var isJobOffer = false
    
    let imagePicker = UIImagePickerController()

    override func awakeFromNib() {
        super.awakeFromNib()
        if collectionView != nil {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCollectionView(snapPhotos: [Media], pageFlag: Int, rootViewController: UIViewController) {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.arrSnapPhotos.removeAll()
        self.arrSnapPhotos = snapPhotos
        self.pageFlag = pageFlag
        self.viewController = rootViewController
        self.collectionView.reloadData()
    }
    
    @objc func tappedDeleteButton(sender: UIButton) {
        
        let photoIndex = sender.tag - 100
        self.arrSnapPhotos.remove(at: photoIndex)
        collectionView.reloadData()
    
        if photoEditDelegate != nil {
            photoEditDelegate?.edittedPhotos(snapShots: self.arrSnapPhotos)
        }
    }
    @IBAction func onClickDeleteDescription(_ sender: Any) {
        self.tvDescription.text = ""
        self.tvDescription.insertText("")
    }
    
    func checkMediaAccess(type:Int) -> Bool {
        var flag = false
        
        if type == 0 {
            if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
                flag = true
            } else {
                PHPhotoLibrary.requestAuthorization { (status) in
                    if status == PHAuthorizationStatus.authorized {
                        flag = true
                    } else {
                        DispatchQueue.main.async {
                            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "Turn on photo library usage permission in the app Settings", buttonTitles: ["Go to app settings"], viewController: self.viewController, completion: { (completion) in
                                if let url = URL(string:UIApplicationOpenSettingsURLString) {
                                    if UIApplication.shared.canOpenURL(url) {
                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    }
                                }
                            })
                        }
                    }
                }
            }
            
        }
        
        return flag
    }
    
    func uploadImageOnAWS(imgData: Data,image: UIImage,withCompletionHandler:@escaping (_ result:Bool) -> Void){
        PointtersHelper.sharedInstance.startLoader(view: viewController.view)
        
        let accessKey = kAWSCredentials.kAccessKey
        let secretKey = kAWSCredentials.kSecretKey
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
                
        let remoteName = "post_pic_\(mediaIndex)_\(NSDate().timeIntervalSince1970)"
        
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(remoteName)
        do {
            try imgData.write(to: fileURL)
        }
        catch {}
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()!
        uploadRequest.body = fileURL
        uploadRequest.key = remoteName
        uploadRequest.bucket = kAWSCredentials.kS3BucketName
        uploadRequest.contentType = "image/jpeg"
        uploadRequest.acl = .publicRead
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest).continueWith { (task: AWSTask<AnyObject>) -> Any? in
            
            if let error = task.error {
                print("Upload failed with error: (\(error.localizedDescription))")
                withCompletionHandler(false)
            }
            
            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!)
                print("Uploaded to:\(String(describing: publicURL))")
                
                self.arrSnapPhotos.insert(Media.init(type:"image", path:(publicURL?.absoluteString)!), at: self.arrSnapPhotos.count)
                
                DispatchQueue.main.async {
                    withCompletionHandler(true)
                }
            }
            
            return nil
        }
    }
    //MARK:- Image Picker
    
    func showPhotoLibrary() {
        if checkMediaAccess(type: 0) {
//            let imagePickerController = UIImagePickerController()
//            imagePickerController.sourceType = .photoLibrary
//            imagePickerController.delegate = self
//            imagePickerController.mediaTypes = ["public.image"]
//            viewController.present(imagePickerController, animated: true, completion: nil)
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default) { (alert) in
                self.openCamera()
            }
            let galleryAction = UIAlertAction(title: "From gallery", style: .default) { (alert) in
                let photos = PHPhotoLibrary.authorizationStatus()
                if photos == .notDetermined {
                    PHPhotoLibrary.requestAuthorization({status in
                        if status == .authorized{
                            self.openGallery()
                        } else {}
                    })
                }else{
                    self.openGallery()
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(takePhotoAction)
            alert.addAction(galleryAction)
            alert.addAction(cancelAction)
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    // open camera
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            imagePicker.modalPresentationStyle = .fullScreen
            imagePicker.delegate = self
            viewController.present(imagePicker, animated: true, completion: nil)
        }else{
            PointtersHelper.sharedInstance.showAlertViewWithTitle("", message: "You can't access the camera.", buttonTitles: ["OK"], viewController: viewController, completion: nil)
        }
    }
    // open photo library
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = true
            self.imagePicker.modalPresentationStyle = .fullScreen
            self.imagePicker.delegate = self
            viewController.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
}

extension RequestDetailCell : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if pageFlag == 0 {
            return self.arrSnapPhotos.count
        } else {
            return self.arrSnapPhotos.count + 1
        }        
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SnapCell = collectionView.dequeueReusableCell(withReuseIdentifier: "snapCell", for: indexPath) as! SnapCell
        
        if pageFlag == 0 {
            let cellItem = self.arrSnapPhotos[self.arrSnapPhotos.count - indexPath.item - 1]
            cell.ivSnap.sd_imageTransition = .fade
            cell.ivSnap.sd_setImage(with: URL(string: cellItem.fileName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"photo_placeholder"))
            cell.btnClose.isHidden = true
        } else {
            if indexPath.item == 0 {
                cell.ivSnap.image = UIImage(named:"photo_placeholder")
                cell.btnClose.isHidden = true
                if isJobOffer {
                    cell.isUserInteractionEnabled = false
                }
            } else {
                let cellItem = self.arrSnapPhotos[self.arrSnapPhotos.count - indexPath.item]
                cell.ivSnap.sd_imageTransition = .fade
                cell.ivSnap.sd_setImage(with: URL(string: cellItem.fileName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), placeholderImage: UIImage(named:"photo_placeholder"))
                
                cell.isUserInteractionEnabled = true
                if isJobOffer {
                    cell.btnClose.isHidden = true
                } else {
                    cell.btnClose.isHidden = false
                }
                
                cell.btnClose.tag = 100 + self.arrSnapPhotos.count - indexPath.item
                cell.btnClose.addTarget(self, action: #selector(tappedDeleteButton(sender:)), for: .touchUpInside)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if pageFlag != 0 {
            if indexPath.item == 0 {
                showPhotoLibrary()
            }
        }
        self.openMedia(indexPath: indexPath)
    }
    
    func openMedia(indexPath: IndexPath) {
        if self.arrSnapPhotos.count < 1 || (indexPath.item == 0 && pageFlag != 0) {
            return
        }
        let media = (pageFlag == 0) ? self.arrSnapPhotos[self.arrSnapPhotos.count - indexPath.item - 1] : self.arrSnapPhotos[self.arrSnapPhotos.count - indexPath.item]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        switch media.mediaType {
        case "image":
            let fullScreenImageVC =  storyboard.instantiateViewController(withIdentifier: "FullScreenImageVC") as! FullScreenImageViewController
            fullScreenImageVC.imageUrl = media.fileName
            self.viewController.navigationController?.pushViewController(fullScreenImageVC, animated:false)
        case "video":
            let fullScreenVC = storyboard.instantiateViewController(withIdentifier: "FullScreenVC") as! FullScreenViewController
            fullScreenVC.videoURL = media.fileName
            self.viewController.navigationController?.pushViewController(fullScreenVC, animated: false)
        default:
            break
        }
    }
}



class SnapCell : UICollectionViewCell {
    @IBOutlet weak var ivSnap: UIImageView!
    @IBOutlet weak var btnClose: UIButton!
    
}


// MARK: - UIImagePickerControllerDelegate

extension RequestDetailCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        if mediaType == "public.image" {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage?
            let data : Data = UIImageJPEGRepresentation(image!, 0.4)!
            
            self.uploadImageOnAWS(imgData: data,image: image!, withCompletionHandler : { (result) in
                
                DispatchQueue.main.async {
                    PointtersHelper.sharedInstance.stopLoader()
                }
                
                if result == true {
                    self.mediaIndex = self.mediaIndex + 1
                    
                    if self.photoEditDelegate != nil {
                        self.photoEditDelegate?.edittedPhotos(snapShots: self.arrSnapPhotos)
                    }
                    self.collectionView.reloadData()
                }
            })
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}
