import crypto from 'crypto';
import createEncryptHelper from 'inkdrop-crypto';

const cipher = createEncryptHelper(crypto);

export default cipher;
