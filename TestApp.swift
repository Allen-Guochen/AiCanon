import SwiftUI
import AVFoundation
import Photos
import Vision
import CoreML

@main
struct TestApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var showingCamera = false
    @State private var showingResults = false
    @State private var capturedImage: UIImage?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // 应用标题
                VStack(spacing: 10) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 60))
                        .foregroundColor(Color(red: 0.12, green: 0.25, blue: 0.67)) // 深蓝色
                    
                    Text("智能摄影助手")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("AI分析环境，推荐最佳拍摄参数")
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.37, green: 0.45, blue: 0.63)) // 深灰蓝色
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 50)
                
                Spacer()
                
                // 主要功能按钮
                Button(action: {
                    showingCamera = true
                    print("拍摄环境照片按钮被点击")
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("拍摄环境照片")
                    }
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(15)
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // 底部说明
                Text("拍摄一张环境照片，AI将为您分析并推荐最佳相机参数")
                    .font(.caption)
                    .foregroundColor(Color(red: 0.37, green: 0.45, blue: 0.63)) // 深灰蓝色
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showingCamera) {
            CameraView(onImageCaptured: { image in
                capturedImage = image
                showingCamera = false
                showingResults = true
            })
        }
        .sheet(isPresented: $showingResults) {
            ResultsView(originalImage: capturedImage)
        }
    }
}

struct CameraView: View {
    let onImageCaptured: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    @StateObject private var cameraManager = CameraManager()
    
    var body: some View {
        ZStack {
            // 相机预览
            CameraPreviewView(session: cameraManager.session)
                .ignoresSafeArea()
            
            VStack {
                // 顶部控制栏
                HStack {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(20)
                    
                    Spacer()
                    
                    // 切换摄像头按钮
                    Button(action: {
                        cameraManager.switchCamera()
                    }) {
                        Image(systemName: "camera.rotate")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(20)
                    }
                }
                .padding()
                
                Spacer()
                
                // 底部控制栏
                HStack(spacing: 50) {
                    // 相册按钮
                    Button(action: {
                        cameraManager.showImagePicker = true
                    }) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(20)
                    }
                    
                    // 拍摄按钮
                    Button(action: {
                        cameraManager.capturePhoto { image in
                            if let image = image {
                                onImageCaptured(image)
                            }
                        }
                    }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .stroke(Color.black.opacity(0.3), lineWidth: 3)
                                    .frame(width: 70, height: 70)
                            )
                    }
                    
                    // 占位按钮（保持对称）
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            cameraManager.startSession()
        }
        .onDisappear {
            cameraManager.stopSession()
        }
        .sheet(isPresented: $cameraManager.showImagePicker) {
            ImagePicker { image in
                if let image = image {
                    onImageCaptured(image)
                }
            }
        }
        .alert("相机权限", isPresented: $cameraManager.showPermissionAlert) {
            Button("设置") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("取消", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("请在设置中允许访问相机以使用拍照功能")
        }
    }
}

// MARK: - 分析状态枚举
enum AnalysisStep: String, CaseIterable {
    case analyzingSubject = "分析主体"
    case analyzingLight = "分析光线"
    case analyzingColor = "分析色彩"
    case analyzingComposition = "分析空间"
    case completed = "分析完成"
}

// MARK: - AI分析结果数据结构
struct ImageAnalysisResult {
    var subject: String = "风景摄影"
    var lighting: String = "自然光，光线充足"
    var color: String = "色彩平衡"
    var composition: String = "三分法构图，层次分明"
    var confidence: String = "85%"
    
    // 推荐的相机参数
    var recommendedAperture: String = "f/8.0"
    var recommendedShutterSpeed: String = "1/250s"
    var recommendedISO: String = "200"
    var recommendedFocusMode: String = "单点对焦"
    var recommendedMeteringMode: String = "矩阵测光"
    var recommendedWhiteBalance: String = "自动"
    var shootingAdvice: String = "根据AI分析，建议使用小光圈获得深景深，配合较快的快门速度确保画面清晰。"
    
    mutating func calculateRecommendedSettings() {
        // 根据分析结果计算推荐参数
        if subject.contains("人像") {
            recommendedAperture = "f/2.8"
            recommendedShutterSpeed = "1/125s"
            recommendedFocusMode = "人脸对焦"
            shootingAdvice = "人像摄影建议使用大光圈虚化背景，突出主体。"
        } else if subject.contains("建筑") {
            recommendedAperture = "f/11"
            recommendedShutterSpeed = "1/60s"
            shootingAdvice = "建筑摄影建议使用小光圈确保建筑细节清晰。"
        } else if subject.contains("美食") {
            recommendedAperture = "f/4.0"
            recommendedShutterSpeed = "1/100s"
            shootingAdvice = "美食摄影建议使用中等光圈，注意光线和角度。"
        }
        
        // 根据光线条件调整参数
        if lighting.contains("较暗") {
            recommendedISO = "800"
            recommendedShutterSpeed = "1/60s"
        } else if lighting.contains("过亮") {
            recommendedISO = "100"
            recommendedShutterSpeed = "1/500s"
        }
    }
}

// MARK: - AI分析加载界面
struct AnalysisLoadingView: View {
    let originalImage: UIImage?
    @State private var currentStep: AnalysisStep = .analyzingSubject
    @State private var progress: Double = 0.0
    @State private var showResults = false
    @State private var isAnalyzing = true
    @State private var analysisResult = ImageAnalysisResult()
    @Environment(\.dismiss) private var dismiss
    
    private let analysisSteps: [AnalysisStep] = [.analyzingSubject, .analyzingLight, .analyzingColor, .analyzingComposition]
    
    var body: some View {
        ZStack {
            // 主内容区域
            VStack(spacing: 30) {
                if showResults {
                    AnalysisResultsView(originalImage: originalImage, analysisResult: analysisResult)
                } else {
                    // 加载界面
                    VStack(spacing: 40) {
                        // 图片预览
                        if let image = originalImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 200)
                                .cornerRadius(15)
                                .opacity(0.8)
                        }
                        
                        // AI分析动画
                        VStack(spacing: 20) {
                            // 分析图标动画
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                                    .frame(width: 80, height: 80)
                                
                                Circle()
                                    .trim(from: 0, to: progress)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color(red: 0.12, green: 0.25, blue: 0.67), Color(red: 0.23, green: 0.51, blue: 0.96)], // 深蓝到亮蓝
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                                    )
                                    .frame(width: 80, height: 80)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.easeInOut(duration: 0.5), value: progress)
                                
                                Image(systemName: "brain.head.profile")
                                    .font(.system(size: 30))
                                    .foregroundColor(Color(red: 0.12, green: 0.25, blue: 0.67)) // 深蓝色
                                    .scaleEffect(1.0 + sin(Date().timeIntervalSince1970 * 2) * 0.1)
                                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: currentStep)
                            }
                            
                            // 当前分析步骤
                            VStack(spacing: 15) {
                                Text("AI正在分析中...")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                // 当前分析步骤文本
                                Text(getCurrentStepText())
                                    .font(.headline)
                                    .foregroundColor(Color(red: 0.12, green: 0.25, blue: 0.67)) // 深蓝色
                                    .scaleEffect(1.1)
                                    .animation(.easeInOut(duration: 0.5), value: currentStep)
                                    .transition(.asymmetric(
                                        insertion: .scale.combined(with: .opacity),
                                        removal: .scale.combined(with: .opacity)
                                    ))
                                
                                // 进度百分比
                                Text("\(Int(progress * 100))%")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 0.37, green: 0.45, blue: 0.63)) // 深灰蓝色
                            }
                        }
                        
                        // 分析步骤指示器
                        HStack(spacing: 25) {
                            ForEach(analysisSteps, id: \.self) { step in
                                Circle()
                                    .fill(step == currentStep ? Color(red: 0.12, green: 0.25, blue: 0.67) : 
                                          (analysisSteps.firstIndex(of: step)! < analysisSteps.firstIndex(of: currentStep)! ? Color(red: 0.23, green: 0.51, blue: 0.96) : Color.gray.opacity(0.3)))
                                    .frame(width: 20, height: 20)
                                    .scaleEffect(step == currentStep ? 1.4 : 1.0)
                                    .animation(.easeInOut(duration: 0.3), value: currentStep)
                            }
                        }
                        
                        // 底部取消按钮
                        Button(action: {
                            cancelAnalysis()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "stop.circle.fill")
                                    .font(.system(size: 18, weight: .medium))
                                Text("取消分析")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(25)
                            .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .opacity(isAnalyzing ? 1.0 : 0.0)
                        .scaleEffect(isAnalyzing ? 1.0 : 0.8)
                        .animation(.easeInOut(duration: 0.3), value: isAnalyzing)
                        .padding(.top, 20)
                    }
                }
            }
            
            // 右上角X图标
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        cancelAnalysis()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .opacity(isAnalyzing ? 1.0 : 0.0)
                    .scaleEffect(isAnalyzing ? 1.0 : 0.8)
                    .animation(.easeInOut(duration: 0.3), value: isAnalyzing)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                Spacer()
            }
        }
        .padding()
        .onAppear {
            startAnalysis()
        }
    }
    
    private func startAnalysis() {
        // 开始AI分析
        isAnalyzing = true
        performAIAnalysis()
    }
    
    private func cancelAnalysis() {
        // 取消分析，直接返回到主页
        isAnalyzing = false
        withAnimation(.easeInOut(duration: 0.3)) {
            dismiss()
        }
    }
    
    private func performAIAnalysis() {
        guard let image = originalImage else { return }
        
        // 开始AI分析
        analyzeImageWithVision(image) { analysisResult in
            DispatchQueue.main.async {
                guard isAnalyzing else { return }
                
                // 更新分析结果
                self.analysisResult = analysisResult
                
                // 显示结果
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.isAnalyzing = false
                    self.showResults = true
                }
            }
        }
    }
    
    // 真实的AI图像分析功能
    private func analyzeImageWithVision(_ image: UIImage, completion: @escaping (ImageAnalysisResult) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(ImageAnalysisResult())
            return
        }
        
        var analysisResult = ImageAnalysisResult()
        let group = DispatchGroup()
        
        // 1. 分析主体 (物体识别)
        group.enter()
        analyzeSubject(cgImage: cgImage) { subject in
            analysisResult.subject = subject
            group.leave()
        }
        
        // 2. 分析光线 (亮度分析)
        group.enter()
        analyzeLighting(cgImage: cgImage) { lighting in
            analysisResult.lighting = lighting
            group.leave()
        }
        
        // 3. 分析色彩 (颜色分析)
        group.enter()
        analyzeColor(cgImage: cgImage) { color in
            analysisResult.color = color
            group.leave()
        }
        
        // 4. 分析构图 (人脸检测、物体位置)
        group.enter()
        analyzeComposition(cgImage: cgImage) { composition in
            analysisResult.composition = composition
            group.leave()
        }
        
        // 所有分析完成后，计算推荐参数
        group.notify(queue: .main) {
            analysisResult.calculateRecommendedSettings()
            completion(analysisResult)
        }
    }
    
    // 分析拍摄主体
    private func analyzeSubject(cgImage: CGImage, completion: @escaping (String) -> Void) {
        let request = VNClassifyImageRequest { request, error in
            guard let observations = request.results as? [VNClassificationObservation],
                  let topObservation = observations.first else {
                completion("未知主体")
                return
            }
            
            // 根据识别结果判断拍摄主体类型
            let identifier = topObservation.identifier.lowercased()
            var subject = "风景摄影"
            
            if identifier.contains("person") || identifier.contains("people") {
                subject = "人像摄影"
            } else if identifier.contains("building") || identifier.contains("architecture") {
                subject = "建筑摄影"
            } else if identifier.contains("food") || identifier.contains("meal") {
                subject = "美食摄影"
            } else if identifier.contains("car") || identifier.contains("vehicle") {
                subject = "汽车摄影"
            } else if identifier.contains("animal") || identifier.contains("pet") {
                subject = "动物摄影"
            } else if identifier.contains("landscape") || identifier.contains("nature") {
                subject = "风景摄影"
            }
            
            completion(subject)
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage)
        try? handler.perform([request])
    }
    
    // 分析光线条件
    private func analyzeLighting(cgImage: CGImage, completion: @escaping (String) -> Void) {
        // 使用Vision框架分析图像亮度
        let request = VNGenerateAttentionBasedSaliencyImageRequest { request, error in
            // 这里可以分析图像的亮度分布
            // 简化实现：根据图像整体亮度判断
            let image = UIImage(cgImage: cgImage)
            let brightness = self.calculateBrightness(image: image)
            
            var lighting = "自然光，光线充足"
            if brightness < 0.3 {
                lighting = "光线较暗，建议增加曝光"
            } else if brightness > 0.7 {
                lighting = "光线过亮，建议减少曝光"
            }
            
            completion(lighting)
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage)
        try? handler.perform([request])
    }
    
    // 分析色彩
    private func analyzeColor(cgImage: CGImage, completion: @escaping (String) -> Void) {
        // 分析图像的主要颜色
        let image = UIImage(cgImage: cgImage)
        let dominantColor = getDominantColor(from: image)
        
        var colorDescription = "色彩平衡"
        if dominantColor.red > dominantColor.green && dominantColor.red > dominantColor.blue {
            colorDescription = "暖色调，红色为主"
        } else if dominantColor.blue > dominantColor.red && dominantColor.blue > dominantColor.green {
            colorDescription = "冷色调，蓝色为主"
        } else if dominantColor.green > dominantColor.red && dominantColor.green > dominantColor.blue {
            colorDescription = "自然色调，绿色为主"
        }
        
        completion(colorDescription)
    }
    
    // 分析构图
    private func analyzeComposition(cgImage: CGImage, completion: @escaping (String) -> Void) {
        // 检测人脸
        let request = VNDetectFaceRectanglesRequest { request, error in
            guard let observations = request.results as? [VNFaceObservation] else {
                completion("三分法构图，层次分明")
                return
            }
            
            if observations.count > 0 {
                completion("人像构图，建议使用人像模式")
            } else {
                completion("三分法构图，层次分明")
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage)
        try? handler.perform([request])
    }
    
    // 计算图像亮度
    private func calculateBrightness(image: UIImage) -> CGFloat {
        guard let cgImage = image.cgImage else { return 0.5 }
        
        let data = cgImage.dataProvider?.data
        let bytes = CFDataGetBytePtr(data)
        let length = CFDataGetLength(data)
        
        var totalBrightness: CGFloat = 0
        let pixelCount = length / 4 // RGBA
        
        for i in 0..<pixelCount {
            let pixelIndex = i * 4
            let r = CGFloat(bytes?[pixelIndex] ?? 0) / 255.0
            let g = CGFloat(bytes?[pixelIndex + 1] ?? 0) / 255.0
            let b = CGFloat(bytes?[pixelIndex + 2] ?? 0) / 255.0
            
            let brightness = (r + g + b) / 3.0
            totalBrightness += brightness
        }
        
        return totalBrightness / CGFloat(pixelCount)
    }
    
    // 获取主要颜色
    private func getDominantColor(from image: UIImage) -> (red: CGFloat, green: CGFloat, blue: CGFloat) {
        guard let cgImage = image.cgImage else { return (0.5, 0.5, 0.5) }
        
        let data = cgImage.dataProvider?.data
        let bytes = CFDataGetBytePtr(data)
        let length = CFDataGetLength(data)
        
        var totalRed: CGFloat = 0
        var totalGreen: CGFloat = 0
        var totalBlue: CGFloat = 0
        let pixelCount = length / 4
        
        for i in 0..<pixelCount {
            let pixelIndex = i * 4
            totalRed += CGFloat(bytes?[pixelIndex] ?? 0) / 255.0
            totalGreen += CGFloat(bytes?[pixelIndex + 1] ?? 0) / 255.0
            totalBlue += CGFloat(bytes?[pixelIndex + 2] ?? 0) / 255.0
        }
        
        return (
            red: totalRed / CGFloat(pixelCount),
            green: totalGreen / CGFloat(pixelCount),
            blue: totalBlue / CGFloat(pixelCount)
        )
    }
    
    private func getCurrentStepText() -> String {
        switch currentStep {
        case .analyzingSubject:
            return "分析主体"
        case .analyzingLight:
            return "分析光线"
        case .analyzingColor:
            return "分析色彩"
        case .analyzingComposition:
            return "分析空间"
        case .completed:
            return "分析完成"
        }
    }
}

// MARK: - 分析结果展示界面
struct AnalysisResultsView: View {
    let originalImage: UIImage?
    let analysisResult: ImageAnalysisResult
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // 标题
                Text("AI分析结果")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // 拍摄的图片
                if let image = originalImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 250)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
                
                // 分析结果卡片
                VStack(spacing: 20) {
                    // 分析信息
                    VStack(alignment: .leading, spacing: 15) {
                        Text("分析详情")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        AnalysisInfoRow(title: "拍摄主体", value: analysisResult.subject, icon: "target")
                        AnalysisInfoRow(title: "光线条件", value: analysisResult.lighting, icon: "sun.max")
                        AnalysisInfoRow(title: "色彩色调", value: analysisResult.color, icon: "paintpalette")
                        AnalysisInfoRow(title: "构图元素", value: analysisResult.composition, icon: "camera.depth.of.field")
                        AnalysisInfoRow(title: "分析置信度", value: analysisResult.confidence, icon: "checkmark.circle")
                    }
                    .padding()
                    .background(Color(red: 0.12, green: 0.25, blue: 0.67).opacity(0.1)) // 深蓝色背景
                    .cornerRadius(15)
                    
                    // 推荐参数
                    VStack(alignment: .leading, spacing: 15) {
                        Text("推荐相机参数")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 10) {
                            ParameterRow(parameter: "光圈", value: analysisResult.recommendedAperture)
                            ParameterRow(parameter: "快门速度", value: analysisResult.recommendedShutterSpeed)
                            ParameterRow(parameter: "ISO", value: analysisResult.recommendedISO)
                            ParameterRow(parameter: "对焦模式", value: analysisResult.recommendedFocusMode)
                            ParameterRow(parameter: "测光模式", value: analysisResult.recommendedMeteringMode)
                            ParameterRow(parameter: "白平衡", value: analysisResult.recommendedWhiteBalance)
                        }
                        
                        Divider()
                        
                        Text("拍摄建议")
                            .font(.headline)
                            .foregroundColor(Color(red: 0.12, green: 0.25, blue: 0.67)) // 深蓝色
                        
                        Text(analysisResult.shootingAdvice)
                            .font(.body)
                            .foregroundColor(Color(red: 0.37, green: 0.45, blue: 0.63)) // 深灰蓝色
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(Color(red: 0.97, green: 0.98, blue: 0.99)) // 浅灰蓝色背景
                    .cornerRadius(15)
                }
                
                // 完成按钮
                Button(action: {
                    dismiss()
                }) {
                    Text("完成")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.12, green: 0.25, blue: 0.67)) // 深蓝色
                        .cornerRadius(15)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - 分析信息行组件
struct AnalysisInfoRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.12, green: 0.25, blue: 0.67)) // 深蓝色
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color(red: 0.37, green: 0.45, blue: 0.63)) // 深灰蓝色
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color(red: 0.12, green: 0.25, blue: 0.67)) // 深蓝色
        }
    }
}

// MARK: - 参数行组件
struct ParameterRow: View {
    let parameter: String
    let value: String
    
    var body: some View {
        HStack {
            Text(parameter)
                .font(.body)
                .foregroundColor(Color(red: 0.22, green: 0.27, blue: 0.33)) // 深灰色
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.12, green: 0.25, blue: 0.67)) // 深蓝色
        }
        .padding(.vertical, 2)
    }
}

struct ResultsView: View {
    let originalImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        AnalysisLoadingView(originalImage: originalImage)
    }
}

// MARK: - 相机管理器
class CameraManager: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private var videoOutput = AVCapturePhotoOutput()
    private var currentCamera: AVCaptureDevice?
    private var frontCamera: AVCaptureDevice?
    private var backCamera: AVCaptureDevice?
    
    @Published var showImagePicker = false
    @Published var showPermissionAlert = false
    
    override init() {
        super.init()
        setupCameras()
    }
    
    private func setupCameras() {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        )
        
        for device in discoverySession.devices {
            if device.position == .back {
                backCamera = device
            } else if device.position == .front {
                frontCamera = device
            }
        }
        
        currentCamera = backCamera
    }
    
    func startSession() {
        checkCameraPermission { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.configureSession()
                } else {
                    self?.showPermissionAlert = true
                }
            }
        }
    }
    
    func stopSession() {
        DispatchQueue.global(qos: .background).async {
            self.session.stopRunning()
        }
    }
    
    private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    private func configureSession() {
        session.beginConfiguration()
        
        // 添加视频输入
        guard let camera = currentCamera,
              let input = try? AVCaptureDeviceInput(device: camera) else {
            session.commitConfiguration()
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        // 添加照片输出
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        
        session.commitConfiguration()
        
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
        }
    }
    
    func switchCamera() {
        guard let currentInput = session.inputs.first as? AVCaptureDeviceInput else { return }
        
        session.beginConfiguration()
        session.removeInput(currentInput)
        
        if currentInput.device == backCamera {
            currentCamera = frontCamera
        } else {
            currentCamera = backCamera
        }
        
        guard let newCamera = currentCamera,
              let newInput = try? AVCaptureDeviceInput(device: newCamera) else {
            session.addInput(currentInput)
            session.commitConfiguration()
            return
        }
        
        if session.canAddInput(newInput) {
            session.addInput(newInput)
        } else {
            session.addInput(currentInput)
        }
        
        session.commitConfiguration()
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        let settings = AVCapturePhotoSettings()
        videoOutput.capturePhoto(with: settings, delegate: PhotoCaptureDelegate(completion: completion))
    }
}

// MARK: - 照片捕获代理
class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (UIImage?) -> Void
    
    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            completion(nil)
            return
        }
        completion(image)
    }
}

// MARK: - 相机预览视图
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // 更新预览层大小
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.frame
        }
    }
}

// MARK: - 图片选择器
struct ImagePicker: UIViewControllerRepresentable {
    let completion: (UIImage?) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
            parent.completion(image)
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.completion(nil)
            parent.dismiss()
        }
    }
}

#Preview {
    ContentView()
}