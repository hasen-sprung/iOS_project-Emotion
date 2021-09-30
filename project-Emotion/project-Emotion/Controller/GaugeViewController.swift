
import UIKit
import Macaw

class GaugeViewController: UIViewController {

    let gaugeView = GaugeWaveAnimationView(frame: UIScreen.main.bounds)
    let floatingAreaView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    var floatingSVGViews = [FloatingSVGView]()

    override func viewDidLoad() {
        super.viewDidLoad()
        gaugeView.delegate = self
        
        view.backgroundColor = .white
        
        // MARK: - [start] gaugeWaveAnimation에서 정보 수신
        NotificationCenter.default.addObserver(self, selector: #selector(setFloatingAreaView(_:)), name: Notification.Name(rawValue: "figureIsChanged"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appearTextField(_:)), name: Notification.Name(rawValue: "figureIsSettled"), object: nil)
        // [end] gaugeWaveAnimation에서 정보 수신
        
        // MARK: - [start] svg view 생성
        floatingSVGViews.append(FloatingSVGView(frame: CGRect(x: 0, y: 0, width: 0, height: 0)))
        floatingSVGViews.append(FloatingSVGView(frame: CGRect(x: 0, y: 0, width: 0, height: 0)))
        floatingSVGViews.append(FloatingSVGView(frame: CGRect(x: 0, y: 0, width: 0, height: 0)))
        // [end] svg view 생성
        
        view.addSubview(gaugeView)
        view.addSubview(floatingAreaView)
        
        for idx in 1...floatingSVGViews.count {
        
            floatingAreaView.addSubview(floatingSVGViews[idx - 1])
        }
        
        
        setFloatingAreaView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // MARK: - [start] gaugeView 애니메이션 실행
        gaugeView.startWaveAnimation()
        
        // MARK: - [start] navigationBar 투명
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        // [End] navigationBar 투명
        
        // MARK: - [start] SVG 초기화 후, 애니메이션 시작
        floatingSVGViews[0].startSVGanimation(width: 60,
                                           height: 60,
                                           rangeX: 5,
                                           rangeY: -30,
                                           centerX: 0,
                                           centerY: 15,
                                           duration: 0.9,
                                           delay: 0.2)
        
        floatingSVGViews[1].startSVGanimation(width: 40,
                                           height: 40,
                                           rangeX: 14,
                                           rangeY: -40,
                                           centerX: 150,
                                           centerY: 23,
                                           duration: 0.7,
                                           delay: 0)
        
        floatingSVGViews[2].startSVGanimation(width: 50,
                                           height: 50,
                                           rangeX: -5,
                                           rangeY: -50,
                                           centerX: -130,
                                           centerY: 33,
                                           duration: 1.1,
                                           delay: 0.1)
        // [end] SVG 초기화 후, 애니메이션 시작
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        gaugeView.setGradientLayer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        gaugeView.stopWaveAnimation()
    }

    // MARK: - [start] floating base View setting and moving
    func setFloatingAreaView() {
        
        floatingAreaView.frame.size = CGSize(width: view.frame.width, height: view.frame.height * 0.2)
        floatingAreaView.center = CGPoint(x: view.frame.width / 2, y: view.frame.height * 0.5)
        floatingAreaView.backgroundColor = .clear
        floatingAreaView.isUserInteractionEnabled = false
    }

    @objc func setFloatingAreaView(_ notification: NSNotification) {
        
        // 0.12초 후에 실행 (wave속도와 sync 조절용도)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
               
            if let figure = notification.userInfo?["figure"] as? Float {
                self.floatingAreaView.frame.size = CGSize(width: self.view.frame.width, height: self.view.frame.height * 0.2)
                self.floatingAreaView.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height * CGFloat(figure))
                self.floatingAreaView.backgroundColor = .clear
                self.floatingAreaView.isUserInteractionEnabled = false
                
                for idx in 1...self.floatingSVGViews.count {
                    self.floatingSVGViews[idx - 1].changeSVGShape(figure: figure)
                }
            }
        }
    }
    // [end] floating object base View setting and moving
    
    // MARK: - [start] appear textField (when figure settled)
    @objc func appearTextField(_ notification: NSNotification) {
        
        if let figure = notification.userInfo?["figure"] as? Float {
            
            print(figure)
            floatingSVGViews[0].zoomSVGShape()
        }
    }
    // [end] appear textField (when figure settled)
}

//MARK: - GaugeWaveAnimationViewDelegate

extension GaugeViewController: GaugeWaveAnimationViewDelegate {
    
    func sendFigureToGaugeViewController() {
        
        let newFigure = gaugeView.getGaugeValue()
        let figureDict: [String : Float] = ["figure" : newFigure]
        NotificationCenter.default.post(name: Notification.Name(rawValue: "figureIsChanged"), object: nil, userInfo: figureDict)
    }
    
    func actionTouchedUpOutside() {
        
        let settledFigure = gaugeView.getGaugeValue()
        let figureDict: [String : Float] = ["figure" : settledFigure]
        NotificationCenter.default.post(name: Notification.Name(rawValue: "figureIsSettled"), object: nil, userInfo: figureDict)
    }
    
    func actionTouchedUpOutsideInSafeArea() {
        print("in safe area touched out")
    }
    
}
