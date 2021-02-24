import Foundation
import CryptoKit

enum CryptoError: Error {
    case runtimeError(String)
}

@objc(AesGcmCrypto)
class AesGcmCrypto: NSObject {
    @objc static func requiresMainQueueSetup() -> Bool {
        return false
    }

    @objc(decryptData:withKey:iv:tag:error:)
    func decryptData(cipherData: Data, key: Data, iv: String, tag: String) throws -> Data {
        guard let ivData = Data(hexString: iv) else {
            throw CryptoError.runtimeError("Invalid iv")
        }
        guard let tagData = Data(hexString: tag) else {
            throw CryptoError.runtimeError("Invalid tag")
        }
        
        let skey = SymmetricKey(data: key)
        let sealedBox = try AES.GCM.SealedBox(nonce: AES.GCM.Nonce(data: ivData),
                                               ciphertext: cipherData,
                                               tag: tagData)
        let decryptedData = try AES.GCM.open(sealedBox, using: skey)
        return decryptedData
    }

    func encryptData(plainData: Data, key: Data) throws -> AES.GCM.SealedBox {
        let skey = SymmetricKey(data: key)
        return try AES.GCM.seal(plainData, using: skey)
    }

    @objc(decrypt:withKey:iv:tag:isBinary:withResolver:withRejecter:)
    func decrypt(base64CipherText: String, key: String, iv: String, tag: String, isBinary: Bool, resolve:RCTPromiseResolveBlock, reject:RCTPromiseRejectBlock) -> Void {
        do {
            let keyData = Data(base64Encoded: key)!
            let decryptedData = try self.decryptData(cipherData: Data(base64Encoded: base64CipherText)!, key: keyData, iv: iv, tag: tag)
            
            if isBinary {
                resolve(decryptedData.base64EncodedString())
            } else {
                resolve(String(decoding: decryptedData, as: UTF8.self))
            }
        } catch CryptoError.runtimeError(let errorMessage) {
            reject("InvalidArgumentError", errorMessage, nil)
        } catch {
            reject("DecryptionError", "Failed to decrypt", error)
        }
    }

    @objc(decryptFile:outputFilePath:withKey:iv:tag:withResolver:withRejecter:)
    func decryptFile(inputFilePath: String, outputFilePath: String, key: String, iv: String, tag: String,  resolve:RCTPromiseResolveBlock, reject:RCTPromiseRejectBlock) -> Void {
        do {
            let keyData: Data = Data(base64Encoded: key)!
            let file = FileHandle.init(forReadingAtPath: inputFilePath)
            if (file == nil) {
                return reject("IOError", "IOError: Could not open file for reading: \(inputFilePath)", nil)
            }
            let sealedData: Data = file!.readDataToEndOfFile()
            file!.closeFile()

            let decryptedData: Data = try self.decryptData(cipherData: sealedData, key: keyData, iv: iv, tag: tag)

            if let wfile = FileHandle.init(forWritingAtPath: outputFilePath) {
                wfile.write(decryptedData)
                wfile.closeFile()
            } else {
                return reject("IOError", "IOError: Could not open file for writing: \(outputFilePath)", nil)
            }

            resolve(true)
        } catch CryptoError.runtimeError(let errorMessage) {
            reject("InvalidArgumentError", errorMessage, nil)
        } catch {
            reject("DecryptionError", "Failed to decrypt", error)
        }
    }

    @objc(encrypt:inBase64:withKey:withResolver:withRejecter:)
    func encrypt(plainText: String, inBase64: Bool, key: String, resolve:RCTPromiseResolveBlock, reject:RCTPromiseRejectBlock) -> Void {
        do {
            let keyData = Data(base64Encoded: key)!
            let plainData = inBase64 ? Data(base64Encoded: plainText)! : plainText.data(using: .utf8)!
            let sealedBox = try self.encryptData(plainData: plainData, key: keyData)

            let iv = sealedBox.nonce.withUnsafeBytes {
                Data(Array($0)).hexadecimal
            }
            let tag = sealedBox.tag.hexadecimal
            let payload = sealedBox.ciphertext.base64EncodedString()

            let response: [String: String] = [
                "iv": iv,
                "tag": tag,
                "content": payload
            ]
            resolve(response)
        } catch CryptoError.runtimeError(let errorMessage) {
            reject("InvalidArgumentError", errorMessage, nil)
        } catch {
            reject("EncryptionError", "Failed to encrypt", error)
        }
    }

    @objc(encryptFile:outputFilePath:withKey:withResolver:withRejecter:)
    func encryptFile(inputFilePath: String, outputFilePath: String, key: String, resolve:RCTPromiseResolveBlock, reject:RCTPromiseRejectBlock) -> Void {
        do {
            let keyData = Data(base64Encoded: key)!
            let file = FileHandle.init(forReadingAtPath: inputFilePath)
            if (file == nil) {
                return reject("IOError", "IOError: Could not open file for reading: \(inputFilePath)", nil)
            }
            let plainData = file!.readDataToEndOfFile()

            let sealedBox = try self.encryptData(plainData: plainData, key: keyData)

            let iv = sealedBox.nonce.withUnsafeBytes {
                Data(Array($0)).hexadecimal
            }
            let tag = sealedBox.tag.hexadecimal
            let payload = sealedBox.ciphertext

            if let wfile = FileHandle.init(forWritingAtPath: outputFilePath) {
                wfile.write(payload)
                wfile.closeFile()
            } else {
                return reject("IOError", "IOError: Could not open file for writing: \(outputFilePath)", nil)
            }

            let response: [String: String] = [
                "iv": iv,
                "tag": tag
            ]
            resolve(response)
        } catch CryptoError.runtimeError(let errorMessage) {
            reject("InvalidArgumentError", errorMessage, nil)
        } catch {
            reject("EncryptionError", "Failed to encrypt", error)
        }
    }
}
