# react-native-aes-gcm-crypto

AES-GCM encryption/decryption for React Native

## Requirements

- iOS >= 13.0
- Android >= 26

## Installation

```sh
npm install react-native-aes-gcm-crypto
```

## Usage

```js
import AesGcmCrypto from 'react-native-aes-gcm-crypto';

const key = 'Yzg1MDhmNDYzZjRlMWExOGJkNTk5MmVmNzFkOGQyNzk=';

AesGcmCrypto.decrypt(
  'LzpSalRKfL47H5rUhqvA',
  key,
  '131348c0987c7eece60fc0bc',
  '5baa85ff3e7eda3204744ec74b71d523',
  false
).then((decryptedData) => {
  console.log(decryptedData);
});

AesGcmCrypto.encrypt('{"name":"Hoge"}', false, key).then((result) => {
  console.log(result);
});
```

### Encrypt data

```ts
type EncryptedData = {
  iv: string;
  tag: string;
  content: string;
};

function encrypt(
  plainText: string,
  inBinary: boolean,
  key: string
): Promise<EncryptedData>;
```

- **plainText**: A string data to encrypt. If `inBinary` is `true`, it should be encoded in Base64.
- **inBinary**: `true` to encrypt binary data encoded with Base64
- **key**: AES key in Base64

### Encrypt file

```ts
function encryptFile(
  inputFilePath: string,
  outputFilePath: string,
  key: string
): Promise<{
  iv: string;
  tag: string;
}>;
```

- **inputFilePath**: A file path to encrypt
- **outputFilePath**: An output file path
- **key**: AES key in Base64

### Decrypt data

```ts
function decrypt(
  base64Ciphertext: string,
  key: string,
  iv: string,
  tag: string,
  isBinary: boolean
): Promise<string>;
```

- **base64Ciphertext**: A base64 data to decrypt.
- **key**: AES key in Base64
- **iv**: An initialization vector
- **tag**: An auth tag
- **isBinary**: `true` to return decrypted data in Base64

### Decrypt file

```ts
function decrypt(
  inputFilePath: string,
  outputFilePath: string,
  key: string,
  iv: string,
  tag: string
): Promise<boolean>;
```

- **inputFilePath**: A file path to decrypt
- **outputFilePath**: An output file path
- **key**: AES key in Base64
- **iv**: An initialization vector
- **tag**: An auth tag
- **isBinary**: `true` to return decrypted data in Base64

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## Author

Takuya Matsuyama | [@inkdrop_app](https://twitter.com/inkdrop_app)

Made for my app called [Inkdrop - A Markdown note-taking app](https://www.inkdrop.app/)

## License

MIT
