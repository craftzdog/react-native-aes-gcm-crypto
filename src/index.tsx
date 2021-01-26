import { NativeModules } from 'react-native';

type AesGcmCryptoType = {
  multiply(a: number, b: number): Promise<number>;
};

const { AesGcmCrypto } = NativeModules;

export default AesGcmCrypto as AesGcmCryptoType;
