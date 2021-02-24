package com.reactnativeaesgcmcrypto

import com.facebook.react.bridge.*
import com.facebook.react.module.annotations.ReactModule
import java.io.File
import java.security.GeneralSecurityException
import java.util.*
import javax.crypto.Cipher
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.SecretKeySpec

class EncryptionOutput(val iv: ByteArray,
                       val tag: ByteArray,
                       val ciphertext: ByteArray)

@ReactModule(name = "AesGcmCrypto")
class AesGcmCryptoModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
  val GCM_TAG_LENGTH = 16

  override fun getName(): String {
    return "AesGcmCrypto"
  }

  private fun getSecretKeyFromString(key: ByteArray): SecretKey {
    return SecretKeySpec(key, 0, key.size, "AES")
  }

  @Throws(javax.crypto.AEADBadTagException::class)
  fun decryptData(ciphertext: ByteArray, key: ByteArray, iv: String, tag: String): ByteArray {
    val secretKey: SecretKey = getSecretKeyFromString(key)
    val ivData = iv.hexStringToByteArray()
    val tagData = tag.hexStringToByteArray()
    val cipher = Cipher.getInstance("AES/GCM/NoPadding")
    val spec = GCMParameterSpec(GCM_TAG_LENGTH * 8, ivData)
    cipher.init(Cipher.DECRYPT_MODE, secretKey, spec)
    return cipher.doFinal(ciphertext + tagData)
  }

  fun encryptData(plainData: ByteArray, key: ByteArray): EncryptionOutput {
    val secretKey: SecretKey = getSecretKeyFromString(key)

    val cipher = Cipher.getInstance("AES/GCM/NoPadding")
    cipher.init(Cipher.ENCRYPT_MODE, secretKey)
    val iv = cipher.iv.copyOf()
    val result = cipher.doFinal(plainData)
    val ciphertext = result.copyOfRange(0, result.size - GCM_TAG_LENGTH)
    val tag = result.copyOfRange(result.size - GCM_TAG_LENGTH, result.size)
    return EncryptionOutput(iv, tag, ciphertext)
  }

  @ReactMethod
  fun decrypt(base64CipherText: String,
              key: String,
              iv: String,
              tag: String,
              isBinary: Boolean,
              promise: Promise) {
    try {
      val keyData = Base64.getDecoder().decode(key)
      val ciphertext: ByteArray = Base64.getDecoder().decode(base64CipherText)
      val unsealed: ByteArray = decryptData(ciphertext, keyData, iv, tag)

      if (isBinary) {
        promise.resolve(Base64.getEncoder().encodeToString(unsealed))
      } else {
        promise.resolve(unsealed.toString(Charsets.UTF_8))
      }
    } catch (e: javax.crypto.AEADBadTagException) {
      promise.reject("DecryptionError", "Bad auth tag exception", e)
    } catch (e: GeneralSecurityException) {
      promise.reject("DecryptionError", "Failed to decrypt", e)
    } catch (e: Exception) {
      promise.reject("DecryptionError", "Unexpected error", e)
    }
  }

  @ReactMethod
  fun decryptFile(inputFilePath: String,
                  outputFilePath: String,
                  key: String,
                  iv: String,
                  tag: String,
                  promise: Promise) {
    try {
      val keyData = Base64.getDecoder().decode(key)
      val ciphertext = File(inputFilePath).inputStream().readBytes()
      val unsealed: ByteArray = decryptData(ciphertext, keyData, iv, tag)

      File(outputFilePath).outputStream().write(unsealed)
      promise.resolve(true)
    } catch (e: javax.crypto.AEADBadTagException) {
      promise.reject("DecryptionError", "Bad auth tag exception", e)
    } catch (e: GeneralSecurityException) {
      promise.reject("DecryptionError", "Failed to decrypt", e)
    } catch (e: Exception) {
      promise.reject("DecryptionError", "Unexpected error", e)
    }
  }

  @ReactMethod
  fun encrypt(plainText: String,
              inBinary: Boolean,
              key: String,
              promise: Promise) {
    try {
      val keyData = Base64.getDecoder().decode(key)
      val plainData = if (inBinary) Base64.getDecoder().decode(plainText) else plainText.toByteArray(Charsets.UTF_8)
      val sealed = encryptData(plainData, keyData)
      var response = WritableNativeMap()
      response.putString("iv", sealed.iv.toHex())
      response.putString("tag", sealed.tag.toHex())
      response.putString("content", Base64.getEncoder().encodeToString(sealed.ciphertext))
      promise.resolve(response)
    } catch (e: GeneralSecurityException) {
      promise.reject("EncryptionError", "Failed to encrypt", e)
    } catch (e: Exception) {
      promise.reject("EncryptionError", "Unexpected error", e)
    }
  }

  @ReactMethod
  fun encryptFile(inputFilePath: String,
                  outputFilePath: String,
                  key: String,
                  promise: Promise) {
    try {
      val keyData = Base64.getDecoder().decode(key)
      val plainData = File(inputFilePath).inputStream().readBytes()
      val sealed = encryptData(plainData, keyData)
      File(outputFilePath).outputStream().write(sealed.ciphertext)
      var response = WritableNativeMap()
      response.putString("iv", sealed.iv.toHex())
      response.putString("tag", sealed.tag.toHex())
      promise.resolve(response)
    } catch (e: GeneralSecurityException) {
      promise.reject("EncryptionError", "Failed to encrypt", e)
    } catch (e: Exception) {
      promise.reject("EncryptionError", "Unexpected error", e)
    }
  }
}
