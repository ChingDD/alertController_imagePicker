//
//  ViewController.swift
//  點選alert產生拍照或選照片功能
//
//  Created by JeffApp on 2023/5/15.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var outerScrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var pageControl: UIPageControl!
    var leftScrollView:UIScrollView!
    var arrScroview:[UIScrollView] = []
    var leftImageView:UIImageView!
    var arrImageView:[UIImageView] = []
    var index = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        outerScrollView.delegate = self
        messageTextField.delegate = self
        outerScrollView.showsHorizontalScrollIndicator = false
        //用迴圈將innerScrollView與imageView加在outerScrollView上
        for _ in 0...4{
            //增加innerScrollView
            switch leftScrollView{
            case nil:
                let innerScrollView = UIScrollView()
                innerScrollView.frame = CGRect(x: 0, y: 0, width: outerScrollView.frame.width, height: outerScrollView.frame.height)
                innerScrollView.maximumZoomScale = 5
                innerScrollView.minimumZoomScale = 1
                innerScrollView.bouncesZoom = false
                innerScrollView.delegate = self
                leftScrollView = innerScrollView
                arrScroview.append(innerScrollView)
                outerScrollView.addSubview(innerScrollView)
            default:
                let innerScrollView = UIScrollView()
                innerScrollView.frame = leftScrollView.frame.offsetBy(dx: outerScrollView.frame.width, dy: 0)
                innerScrollView.maximumZoomScale = 5
                innerScrollView.minimumZoomScale = 1
                innerScrollView.bouncesZoom = false
                innerScrollView.delegate = self
                leftScrollView = innerScrollView
                arrScroview.append(innerScrollView)
                outerScrollView.addSubview(innerScrollView)
            }
            //增加imageView
            switch leftImageView{
            case nil:
                leftImageView = imageView
                arrImageView.append(imageView)
                leftScrollView.addSubview(imageView)
            default:
                let photoImageView = UIImageView()
                photoImageView.frame = CGRect(x: 0, y: 0, width: leftScrollView.frame.width, height: leftScrollView.frame.height)
                arrImageView.append(photoImageView)
                leftScrollView.addSubview(photoImageView)
            }
        }
    }

    @IBAction func pageMove(_ sender: UIPageControl) {
        //設定scrollView捲動
        let contentPoint = CGPoint(x: arrScroview[pageControl.currentPage].frame.origin.x, y: 0)
        outerScrollView.setContentOffset(contentPoint, animated: true)
    }
    
    
    
    @IBAction func choosePhoto(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let alertAction = UIAlertAction(title: "從相簿", style: .default){_ in
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = .photoLibrary
            self.present(controller, animated: true)
        }
        let alerActionCamera = UIAlertAction(title: "從相機", style: .default){_ in
            if !UIImagePickerController.isCameraDeviceAvailable(.rear){return}
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = .camera
            self.present(controller, animated: true)
        }
        let alerActionCencel = UIAlertAction(title: "取消", style: .default){_ in
            let controller = UIImagePickerController()
            controller.delegate = self
            self.dismiss(animated: true)
        }
        alertController.addAction(alertAction)
        alertController.addAction(alerActionCamera)
        alertController.addAction(alerActionCencel)
        present(alertController, animated: true)
        
    }
    
    
    
    @IBAction func sendImage(_ sender: UIButton) {
        guard let image = arrImageView[pageControl.currentPage].image,
        let text = messageTextField.text else{return}
        let controller = UIActivityViewController(activityItems: [image,text], applicationActivities: nil)
        present(controller, animated: true)
        
    }
    
    
    
    
}

extension ViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //print("選照片的keys有：\(info.keys)")
        let image = info[.originalImage] as! UIImage
        arrImageView[pageControl.currentPage].image = image
        print("pick work")
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancel work")
        dismiss(animated: true)
    }
}



//可將照片放大縮小
extension ViewController:UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return arrImageView[pageControl.currentPage]
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == outerScrollView{
            let index = Int(scrollView.contentOffset.x/scrollView.frame.width)
            pageControl.currentPage = index
            
        }
    }
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView == outerScrollView{
            arrScroview[pageControl.currentPage].zoomScale = 1
        }
    }
    
}

extension ViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        messageTextField.resignFirstResponder()
    }
}
