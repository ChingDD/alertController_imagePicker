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
    var arrScrollview:[UIScrollView] = []
    var leftImageView:UIImageView!
    var arrImageView:[UIImageView] = []
    var index = 0
    var currentObjBottonYPosition = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        outerScrollView.delegate = self
        messageTextField.delegate = self
        outerScrollView.showsHorizontalScrollIndicator = false
        //註冊通知中心
        let notificationCenter = NotificationCenter.default
        //通知中心觀察的事件觸發時，要做的事情(鍵盤開啟時)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        //通知中心觀察的事件觸發時，要做的事情(鍵盤收起時)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        //用迴圈將innerScrollView與imageView加在outerScrollView上
        for _ in 0...4 {
            // 增加內層滾動視圖
            switch leftScrollView {
            case nil:
                let innerScrollView = UIScrollView() // 建立內層滾動視圖
                innerScrollView.frame = CGRect(x: 0, y: 0, width: outerScrollView.frame.width, height: outerScrollView.frame.height) // 設置內層滾動視圖的框架
                innerScrollView.maximumZoomScale = 5 // 設置最大縮放比例
                innerScrollView.minimumZoomScale = 1 // 設置最小縮放比例
                innerScrollView.bouncesZoom = false // 禁止彈跳縮放
                innerScrollView.delegate = self // 設置內層滾動視圖的委派為自身
                leftScrollView = innerScrollView // 將左側滾動視圖設置為當前內層滾動視圖
                arrScrollview.append(innerScrollView) // 將內層滾動視圖添加到滾動視圖陣列中
                outerScrollView.addSubview(innerScrollView) // 將內層滾動視圖添加到外層滾動視圖中
            default:
                let innerScrollView = UIScrollView() // 建立內層滾動視圖
                innerScrollView.frame = leftScrollView.frame.offsetBy(dx: outerScrollView.frame.width, dy: 0) // 根據左側滾動視圖的框架在 x 軸上進行偏移
                innerScrollView.maximumZoomScale = 5 // 設置最大縮放比例
                innerScrollView.minimumZoomScale = 1 // 設置最小縮放比例
                innerScrollView.bouncesZoom = false // 禁止彈跳縮放
                innerScrollView.delegate = self // 設置內層滾動視圖的委派為自身
                leftScrollView = innerScrollView // 將左側滾動視圖設置為當前內層滾動視圖
                arrScrollview.append(innerScrollView) // 將內層滾動視圖添加到滾動視圖陣列中
                outerScrollView.addSubview(innerScrollView) // 將內層滾動視圖添加到外層滾動視圖中
            }

            // 增加圖像視圖
            switch leftImageView {
            case nil:
                leftImageView = imageView // 將左側圖像視圖設置為當前圖像視圖
                arrImageView.append(imageView) // 將圖像視圖添加到圖像視圖陣列中
                leftScrollView.addSubview(imageView) // 將圖像視圖添加到左側滾動視圖中
            default:
                let photoImageView = UIImageView() // 建立新的圖像視圖
                photoImageView.frame = CGRect(x: 0, y: 0, width: leftScrollView.frame.width, height: leftScrollView.frame.height) // 設置圖像視圖的框架
                arrImageView.append(photoImageView) // 將圖像視圖添加到圖像視圖陣列中
                leftScrollView.addSubview(photoImageView) // 將圖像視圖添加到左側滾動視圖中
            }
        }
    }


    @objc func keyboardWillShow(_ notification:Notification){
        print(notification.userInfo!)
        if let keyboardFrame =
            notification.userInfo?[AnyHashable("UIKeyboardBoundsUserInfoKey")] as? NSValue{
            print("註冊成功")
            let visibleField = view.frame.size.height - keyboardFrame.cgRectValue.height
            print(visibleField)
            if currentObjBottonYPosition > visibleField{
                view.frame.origin.y = view.frame.origin.y - (currentObjBottonYPosition - visibleField)
            }
        }
    }
    
    @objc func keyboardWillHide(){
        view.frame.origin.y = 0
    }
    
    @IBAction func pageMove(_ sender: UIPageControl) {
        //設定scrollView捲動
        let contentPoint = CGPoint(x: arrScrollview[pageControl.currentPage].frame.origin.x, y: 0)
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
    
    
    // 滾動視圖已結束滑動時調用的方法
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            if scrollView == outerScrollView { // 如果是外層滾動視圖
                let index = Int(scrollView.contentOffset.x / scrollView.frame.width) // 根據滾動視圖的偏移量計算當前頁面的索引
                pageControl.currentPage = index // 設定頁面控制器的當前頁數
            }
        }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView == outerScrollView{
            arrScrollview[pageControl.currentPage].zoomScale = 1
        }
    }
}


extension ViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        messageTextField.resignFirstResponder()
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentObjBottonYPosition = textField.frame.origin.y+textField.frame.height
        print(currentObjBottonYPosition)
    }
}
