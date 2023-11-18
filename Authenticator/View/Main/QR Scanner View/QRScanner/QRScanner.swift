//
//  QRScanner.swift
//  Authenticator
//
//  Created by PRO 14 on 17.11.23.
//

import AVFoundation
import OneTimePassword

enum QRScannerEffect {
    case saveNewToken(Token)
    case showErrorMessage(String)
}

protocol QRScannerDelegate: AnyObject {
    func handleDecodedText(_ text: String)
    
}

class QRScanner: NSObject {
    
    weak var delegate: QRScannerDelegate?
    private let serialQueue = DispatchQueue(label: "QRScanner serial queue")
    private var captureSession: AVCaptureSession?
    
    func start(success: @escaping (AVCaptureSession) -> Void, failure: @escaping (Error) -> Void) {
        serialQueue.async {
            do {
                let captureSession = try self.captureSession ?? QRScanner.createCaptureSession(withDelegate: self)
                captureSession.startRunning()
                
                self.captureSession = captureSession
                DispatchQueue.main.async {
                    success(captureSession)
                }
            } catch {
                self.captureSession = nil
                DispatchQueue.main.async {
                    failure(error)
                }
            }
        }
    }
    
    
    func stop() {
        serialQueue.async {
            self.captureSession?.stopRunning()
        }
    }

    // MARK: Capture

    enum CaptureSessionError: Error {
        case noCaptureDevice
        case noQRCodeMetadataType
    }
    
    private class func createCaptureSession(withDelegate delegate: AVCaptureMetadataOutputObjectsDelegate) throws -> AVCaptureSession {
        let captureSession = AVCaptureSession()

        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            throw CaptureSessionError.noCaptureDevice
        }
        let captureInput = try AVCaptureDeviceInput(device: captureDevice)
        captureSession.addInput(captureInput)

        let captureOutput = AVCaptureMetadataOutput()
        // The output must be added to the session before it can be checked for metadata types
        captureSession.addOutput(captureOutput)
        guard captureOutput.availableMetadataObjectTypes.contains(.qr) else {
            throw CaptureSessionError.noQRCodeMetadataType
        }
        captureOutput.metadataObjectTypes = [.qr]
        captureOutput.setMetadataObjectsDelegate(delegate, queue: .main)

        return captureSession
    }
    
    class var deviceCanScan: Bool {
        return (AVCaptureDevice.default(for: .video) != nil)
    }

    class var authorizationStatus: AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .video)
    }

    class func requestAccess(_ completionHandler: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { accessGranted in
            DispatchQueue.main.async {
                completionHandler(accessGranted)
            }
        }
    }
}

extension QRScanner: AVCaptureMetadataOutputObjectsDelegate {
    // MARK: AVCaptureMetadataOutputObjectsDelegate

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metadata in metadataObjects {
            if let metadata = metadata as? AVMetadataMachineReadableCodeObject,
                metadata.type == .qr,
                let string = metadata.stringValue {
                    // Dispatch to the main queue because setMetadataObjectsDelegate doesn't
                    main {
                        self.delegate?.handleDecodedText(string)
                    }
            }
        }
    }
}
