#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(AesGcmCrypto, NSObject)

RCT_EXTERN_METHOD(multiply:(float)a withB:(float)b
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(decrypt:(NSString *)base64CipherText
                  withKey:(NSString *)key
                  iv:(NSString *)iv
                  tag:(NSString *)tag
                  isBinary:(BOOL)isBinary
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(encrypt:(NSString *)plainData
                  inBase64:(BOOL)inBase64
                  withKey:(NSString *)key
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

@end
