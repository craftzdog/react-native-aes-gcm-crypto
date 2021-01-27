package com.reactnativeaesgcmcrypto

import com.facebook.react.bridge.*
import java.security.GeneralSecurityException
import java.util.*
import javax.crypto.Cipher
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.SecretKeySpec

class EncryptionOutput(val iv: ByteArray,
                       val tag: ByteArray,
                       val ciphertext: ByteArray)

class AesGcmCryptoModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
  val GCM_TAG_LENGTH = 16

  override fun getName(): String {
    return "AesGcmCrypto"
  }

  private fun getSecretKeyFromString(keyStr: String): SecretKey {
    val baKey = keyStr.toByteArray()
    val key: SecretKey = SecretKeySpec(baKey, 0, baKey.size, "AES")
    return key
  }

  fun decryptData(ciphertext: ByteArray, key: String, iv: String, tag: String): ByteArray {
    val secretKey: SecretKey = getSecretKeyFromString(key)
    val ivData = iv.hexStringToByteArray()
    val tagData = tag.hexStringToByteArray()
    val cipher = Cipher.getInstance("AES/GCM/NoPadding")
    val spec = GCMParameterSpec(GCM_TAG_LENGTH * 8, ivData)
    cipher.init(Cipher.DECRYPT_MODE, secretKey, spec)
    return cipher.doFinal(ciphertext + tagData)
  }

  fun encryptData(plainData: ByteArray, key: String): EncryptionOutput {
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
      val ciphertext: ByteArray = Base64.getDecoder().decode(base64CipherText)
      val unsealed: ByteArray = decryptData(ciphertext, key, iv, tag)

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
  fun encrypt(plainText: String,
              inBinary: Boolean,
              key: String,
              promise: Promise) {
    try {
      val plainData = if (inBinary) Base64.getDecoder().decode(plainText) else plainText.toByteArray(Charsets.UTF_8)
      val sealed = encryptData(plainData, key)
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

}
