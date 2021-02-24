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
  decryptFile(
    inputFilePath: string,
    outputFilePath: string,
    key: string,
    iv: string,
    tag: string
  ): Promise<boolean>;
  encrypt(
    plainText: string,
    inBinary: boolean,
    key: string
  ): Promise<EncryptedData>;
  encryptFile(
    inputFilePath: string,
    outputFilePath: string,
    key: string
  ): Promise<{
    iv: string;
    tag: string;
  }>;
};

const { AesGcmCrypto } = NativeModules;

export default AesGcmCrypto as AesGcmCryptoType;
