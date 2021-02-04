/* global performance, Buffer */
import * as React from 'react';
import { useState } from 'react';
import { StyleSheet, View, Text, Pressable } from 'react-native';
import AesGcmCrypto from 'react-native-aes-gcm-crypto';
import jsCrypto from './js-crypto';
import { data } from './image.json';

const key = 'Yzg1MDhmNDYzZjRlMWExOGJkNTk5MmVmNzFkOGQyNzk=';
const plainKey = 'c8508f463f4e1a18bd5992ef71d8d279';

const wait = () => new Promise((resolve) => setTimeout(resolve, 0));

export default function App() {
  const [processingJSCrypto, setProcessingJSCrypto] = useState<number>(0);
  const [jsCryptoResult, setJSCryptoResult] = useState<number>(0);
  const [processingNativeCrypto, setProcessingNativeCrypto] = useState<number>(
    0
  );
  const [nativeCryptoResult, setNativeCryptoResult] = useState<number>(0);

  const handleNativeCryptoPress = async () => {
    setProcessingNativeCrypto(0);
    const startTime = performance.now();
    let dataToProcess = data;

    for (let iter = 0; iter < 1000; iter++) {
      console.log('iter:', iter);
      setProcessingNativeCrypto(iter);
      const res = await AesGcmCrypto.encrypt(dataToProcess, true, key);
      dataToProcess = await AesGcmCrypto.decrypt(
        res.content,
        key,
        res.iv,
        res.tag,
        true
      );
    }
    const finishedTime = performance.now();
    console.log('done! took', finishedTime - startTime, 'milliseconds');
    setNativeCryptoResult(finishedTime - startTime);
    setProcessingNativeCrypto(0);
  };

  const handleJSCryptoPress = async () => {
    setProcessingJSCrypto(0);
    const startTime = performance.now();
    let dataToProcess = data;
    await wait();

    for (let iter = 0; iter < 1000; iter++) {
      console.log('iter:', iter);
      setProcessingJSCrypto(iter);
      await wait();
      const buf = Buffer.from(dataToProcess, 'base64');
      const res = jsCrypto.encrypt(plainKey, buf, {
        inputEncoding: 'binary',
        outputEncoding: 'base64',
      });
      dataToProcess = jsCrypto.decrypt(plainKey, res, {
        inputEncoding: 'base64',
        outputEncoding: 'base64',
      });
    }
    const finishedTime = performance.now();
    setJSCryptoResult(finishedTime - startTime);
    setProcessingJSCrypto(0);

    console.log('done! took', finishedTime - startTime, 'milliseconds');
  };

  return (
    <View style={styles.container}>
      <Text style={styles.heading}>Native implementatin of AES-GCM</Text>
      <Text style={styles.result}>
        {nativeCryptoResult > 0 ? `${nativeCryptoResult} milliseconds` : ''}
      </Text>
      <Pressable onPress={handleNativeCryptoPress} style={styles.button}>
        <Text>
          {processingNativeCrypto > 0
            ? `Processing.. ${processingNativeCrypto}`
            : 'Perform a benchmark test'}
        </Text>
      </Pressable>

      <Text style={styles.heading}>JavaScript implementatin of AES-GCM</Text>
      <Text style={styles.result}>
        {jsCryptoResult > 0 ? `${jsCryptoResult} milliseconds` : ''}
      </Text>
      <Pressable onPress={handleJSCryptoPress} style={styles.button}>
        <Text>
          {processingJSCrypto > 0
            ? `Processing.. ${processingJSCrypto}`
            : 'Perform a benchmark test'}
        </Text>
      </Pressable>
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
  heading: {
    fontSize: 20,
    marginTop: 10,
    marginBottom: 10,
  },
  result: {
    marginTop: 10,
    marginBottom: 10,
  },
  button: { backgroundColor: 'skyblue', padding: 12 },
});
