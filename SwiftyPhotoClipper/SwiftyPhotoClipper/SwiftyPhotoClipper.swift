//
//  SwiftyPhotoClipper.swift
//  SwiftyPhotoClipper
//
//  Created by lip on 17/4/4.
//  Copyright © 2017年 lip. All rights reserved.
//

import UIKit

//
//  UIClipController.swift
//  Temple
//
//  Created by lip on 17/4/4.
//  Copyright © 2017年 lip. All rights reserved.
//

import UIKit

protocol SwiftyPhotoClipperDelegate {
    
    func didFinishClippingPhoto(image:UIImage)
}

class SwiftyPhotoClipper: UIViewController {
    
    // 代理
    var delegate:SwiftyPhotoClipperDelegate?
    
    var imgView:UIImageView?
    
    var img:UIImage?
    let scrollview = UIScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    
    var maxScale:CGFloat = 3.0
    var minScale:CGFloat = 1.0
    
    // 屏幕
    let HEIGHT = UIScreen.main.bounds.height
    let WIDTH = UIScreen.main.bounds.width
    
    // 截图大小
    var selectWidth:CGFloat = UIScreen.main.bounds.width
    var selectHeight:CGFloat = 200.0
    
    // 框框线的宽度
    let lineWidth:CGFloat = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
        drawTheRect()
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// 设置图片
    func setImageView(image:UIImage){
        imgView = UIImageView(image: image)
    }
    
    /// 设置裁切区域
    func setClipSize(width:CGFloat,height:CGFloat){
        
        self.selectHeight = height
        self.selectWidth = width
    }
    
    
    
}

// MARK: - UI
extension SwiftyPhotoClipper{
    
    fileprivate func setupUI(){
        
        scrollview.backgroundColor = UIColor.black
        
        imgView = UIImageView(image: img)
        
        guard let imgView = imgView else {
            return
        }
        view.backgroundColor = UIColor.white
        imgView.contentMode = .scaleToFill
        scrollview.delegate = self
        imgView.center = scrollview.center
        
        if imgView.bounds.width > WIDTH {
            imgView.frame.size = CGSize(width: WIDTH, height: imgView.bounds.height / imgView.bounds.width * WIDTH)
            imgView.center = scrollview.center
        }
        if imgView.bounds.height > HEIGHT{
            imgView.frame.size = CGSize(width: HEIGHT, height: imgView.bounds.width / imgView.bounds.height * HEIGHT)
            imgView.center = scrollview.center
        }
        
        view.addSubview(scrollview)
        scrollview.addSubview(imgView)
        
        let topInsert = (imgView.frame.size.height - selectHeight)/2
        let bottomInsert = (HEIGHT - imgView.frame.size.height)/2
        
        scrollview.contentSize = CGSize(width: WIDTH, height: HEIGHT + imgView.frame.height / 2)
        scrollview.contentInset = UIEdgeInsets(top: topInsert, left: 0, bottom: -bottomInsert, right: 0)
        
        // 隐藏导航条
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.showsVerticalScrollIndicator = false
        
        // 设置缩放属性
        scrollview.maximumZoomScale = maxScale
        scrollview.minimumZoomScale = minScale
        
        // 设置按钮
        
        let cancelBtn = UIButton(frame: CGRect(x: 10, y: HEIGHT - 50, width: 100, height: 40))
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.addTarget(nil, action: #selector(cancelBtnIsClicked), for: .touchUpInside)
        view.addSubview(cancelBtn)
        
        let okBtn = UIButton(frame: CGRect(x: WIDTH - 110, y: HEIGHT - 50, width: 100, height: 40))
        okBtn.contentMode = .right
        okBtn.setTitle("选取", for: .normal)
        okBtn.addTarget(nil, action: #selector(okBtnIsClicked), for: .touchUpInside)
        view.addSubview(okBtn)
        
        
        
    }
    
    fileprivate func clipImage()->UIImage?{
        
        let rect  = UIScreen.main.bounds
        
        // 记录屏幕缩放比
        let scal = UIScreen.main.scale
        
        // 上下文
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        
        let context = UIGraphicsGetCurrentContext()
        
        UIApplication.shared.keyWindow?.layer.render(in: context!)
        
        // 截全屏
        guard let img = UIGraphicsGetImageFromCurrentImageContext()?.cgImage,
            let result = img.cropping(to: CGRect(x: scal * lineWidth, y: (HEIGHT - selectHeight)/2 * scal, width: (self.WIDTH - 2*lineWidth) * scal, height: selectHeight * scal))   else{
                return nil
        }
        // 关闭上下文
        UIGraphicsEndImageContext()
        
        return UIImage(cgImage: result, scale: scal, orientation: .up)
        
    }
    
    
    /// 绘制选择框
    fileprivate func drawTheRect(){
        
        
        // 获取上下文 size表示图片大小 false表示透明 0表示自动适配屏幕大小
        UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, false, 0)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor)
        context?.fill(UIScreen.main.bounds)
        context?.addRect(CGRect(x: 0, y: (HEIGHT - selectHeight)/2, width: WIDTH , height: selectHeight))
        context?.setBlendMode(.clear)
        context?.fillPath()
        
        // 绘制框框
        context?.setBlendMode(.color)
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.setLineWidth(1.0)
        context?.stroke(CGRect(x: 0, y: (HEIGHT - selectHeight)/2 - lineWidth , width: WIDTH , height: selectHeight + 2*lineWidth))
        context?.strokePath()
        
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let selectarea = UIImageView(image: img)
        selectarea.frame.origin = CGPoint(x: 0, y: 0)
        view.addSubview(selectarea)
        
        
    }
    
}

// MARK: - 代理方法
extension SwiftyPhotoClipper:UIScrollViewDelegate{
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        //当捏或移动时，需要对center重新定义以达到正确显示位置
        var centerX = scrollView.center.x
        var centerY = scrollView.center.y
        centerX = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width / 2 : centerX
        centerY = scrollView.contentSize.height > scrollView.frame.size.height ?scrollView.contentSize.height / 2 : centerY
        self.imgView?.center = CGPoint(x: centerX, y: centerY)
        
        guard let imgView = imgView else {
            return
        }
        
        let topInsert = (imgView.frame.size.height - selectHeight)/2
        let bottomInsert = (HEIGHT - imgView.frame.size.height)/2
        scrollview.contentSize = CGSize(width: imgView.frame.width, height: HEIGHT + imgView.frame.height / 2)
        scrollview.contentInset = UIEdgeInsets(top: topInsert, left: 0, bottom: -bottomInsert, right: 0)
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imgView
    }
    
}

// MARK: - 监听
extension SwiftyPhotoClipper{
    
    @objc fileprivate func cancelBtnIsClicked(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func okBtnIsClicked(){
        let result = clipImage() ?? UIImage()
        delegate?.didFinishClippingPhoto(image: result)
        dismiss(animated: true, completion: nil)
        
    }
    
}
