//
//  ViewController.swift
//  SwiftyPhotoClipper
//
//  Created by lip on 17/4/4.
//  Copyright © 2017年 lip. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
  

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.darkGray
        
        let photoBtn = UIButton(frame: CGRect(x: 10, y: 100, width: 100, height: 20))
        photoBtn.setTitle("相册中选择", for: .normal)
        photoBtn.addTarget(nil, action: #selector(photoBtnIsClicked), for: .touchUpInside)
        
        let cameraBtn = UIButton(frame: CGRect(x: 10, y: 200, width: 100, height: 20))
        cameraBtn.setTitle("拍照", for: .normal)
        cameraBtn.addTarget(nil, action: #selector(camerBtnIsClicked), for: .touchUpInside)
        
        view.addSubview(photoBtn)
        view.addSubview(cameraBtn)
     
    }
    
    @objc private func photoBtnIsClicked(){
        //判断设置是否支持图片库
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary

            //弹出控制器，显示界面
            self.present(picker, animated: true, completion: nil)
        }

    }
    
    @objc private func camerBtnIsClicked(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerControllerSourceType.camera
            //弹出控制器，显示界面
            self.present(picker, animated: true, completion: nil)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate,SwiftyPhotoClipperDelegate{
    //选择图片成功后代理
    func imagePickerController(_ picker: UIImagePickerController,didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
        
            picker.dismiss(animated: false, completion: { 
                let clipper = SwiftyPhotoClipper()
                clipper.delegate = self
                clipper.img = image
                self.present(clipper, animated: true, completion: nil)
            })
            
            
        } else{
            print("Something went wrong")
        }
    }
    
    func didFinishClippingPhoto(image: UIImage) {
        
        let imgv = UIImageView(frame: CGRect(x: 0, y: 300, width: UIScreen.main.bounds.width, height: 200))
            imgv.image = image
        
        view.addSubview(imgv)
    }

}

