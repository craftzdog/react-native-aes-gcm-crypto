import { NativeModules } from 'react-native';

export type EncryptedData = {
  iv: string;
  tag: string;
  content: string;
};

type AesGcmCryptoType = {
  decrypt(
    base64Ciphertext: string,
    key: string,
    iv: string,
    tag: string,
    isBinary: boolean
  ): Promise<string>;
  encrypt(
    plainText: string,
    inBinary: boolean,
    key: string
  ): Promise<EncryptedData>;
};

const { AesGcmCrypto } = NativeModules;

export default AesGcmCrypto as AesGcmCryptoType;
