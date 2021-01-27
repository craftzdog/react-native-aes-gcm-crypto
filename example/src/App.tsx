import * as React from 'react';

import { StyleSheet, View, Text } from 'react-native';
import AesGcmCrypto, { EncryptedData } from 'react-native-aes-gcm-crypto';

const key = 'c8508f463f4e1a18bd5992ef71d8d279';

export default function App() {
  const [decryptedData, setDecryptedData] = React.useState<
    string | undefined
  >();
  const [encryptedData, setEncryptedData] = React.useState<
    EncryptedData | undefined
  >();

  React.useEffect(() => {
    AesGcmCrypto.decrypt(
      'LzpSalRKfL47H5rUhqvA',
      key,
      '131348c0987c7eece60fc0bc',
      '5baa85ff3e7eda3204744ec74b71d523',
      false
    ).then(setDecryptedData);
    AesGcmCrypto.encrypt('{"name":"Hoge"}', false, key)
      .then((result) => {
        setEncryptedData(result);
        return AesGcmCrypto.decrypt(
          result.content,
          key,
          result.iv,
          result.tag,
          false
        );
      })
      .then(setDecryptedData);
  }, []);

  return (
    <View style={styles.container}>
      <Text>
        Encrypted data: {JSON.stringify(encryptedData || {}, null, 4)}
      </Text>
      <Text>Decrypted data: {decryptedData}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
