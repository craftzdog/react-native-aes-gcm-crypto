import Foundation
import CryptoKit

enum CryptoError: Error {
    case runtimeError(String)
}

@objc(AesGcmCrypto)
class AesGcmCrypto: NSObject {
    private func decrypt(cipherData: Data, key: Data, iv: String, tag: String) throws -> Data {
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

    private func encrypt(plainData: Data, key: Data) throws -> AES.GCM.SealedBox {
        
        let skey = SymmetricKey(data: key)
        return try AES.GCM.seal(plainData, using: skey)
    }

    @objc(decrypt:withKey:iv:tag:isBinary:withResolver:withRejecter:)
    func decrypt(base64CipherText: String, key: String, iv: String, tag: String, isBinary: Bool, resolve:RCTPromiseResolveBlock, reject:RCTPromiseRejectBlock) -> Void {
        do {
            let keyData = Data(base64Encoded: key)!
            let decryptedData = try self.decrypt(cipherData: Data(base64Encoded: base64CipherText)!, key: keyData, iv: iv, tag: tag)
            
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
    
    @objc(encrypt:inBase64:withKey:withResolver:withRejecter:)
    func encrypt(plainText: String, inBase64: Bool, key: String, resolve:RCTPromiseResolveBlock, reject:RCTPromiseRejectBlock) -> Void {
        do {
            let keyData = Data(base64Encoded: key)!
            let plainData = inBase64 ? Data(base64Encoded: plainText)! : plainText.data(using: .utf8)!
            let sealedBox = try self.encrypt(plainData: plainData, key: keyData)

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

}
