#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(AesGcmCrypto, NSObject)

  RCT_EXTERN_METHOD(decrypt:(NSString *)base64CipherText
                    withKey:(NSString *)key
                         iv:(NSString *)iv
                        tag:(NSString *)tag
                   isBinary:(BOOL)isBinary
               withResolver:(RCTPromiseResolveBlock)resolve
               withRejecter:(RCTPromiseRejectBlock)reject)
 RCT_EXTERN_METHOD(decryptFile:(NSString *)inputFilePath
                outputFilePath:(NSString *)outputFilePath
                       withKey:(NSString *)key
                            iv:(NSString *)iv
                           tag:(NSString *)tag
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)
     RCT_EXTERN_METHOD(encrypt:(NSString *)plainData
                      inBase64:(BOOL)inBase64
                       withKey:(NSString *)key
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)
 RCT_EXTERN_METHOD(encryptFile:(NSString *)inputPath
                outputFilePath:(NSString *)outputFilePath
                       withKey:(NSString *)key
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

@end
