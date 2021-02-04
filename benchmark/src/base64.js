const CHARS =
  'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';

/**
 * window.btoa
 */
export function btoa(input) {
  let map;
  let i = 0;
  let block = 0;
  let output = '';

  for (
    block = 0, i = 0, map = CHARS;
    input.charAt(i | 0) || ((map = '='), i % 1);
    output += map.charAt(63 & (block >> (8 - (i % 1) * 8)))
  ) {
    const charCode = input.charCodeAt((i += 3 / 4));

    if (charCode > 0xff) {
      throw new Error(
        "'RNFirebase.Base64.btoa' failed: The string to be encoded contains characters outside of the Latin1 range."
      );
    }

    block = (block << 8) | charCode;
  }

  return output;
}

/**
 * window.atob
 */
export function atob(input) {
  let i = 0;
  let bc = 0;
  let bs = 0;
  let buffer;
  let output = '';

  const str = input.replace(/[=]+$/, '');

  if (str.length % 4 === 1) {
    throw new Error(
      "'RNFirebase.Base64.atob' failed: The string to be decoded is not correctly encoded."
    );
  }

  for (
    bc = 0, bs = 0, i = 0;
    (buffer = str.charAt(i++));
    ~buffer && ((bs = bc % 4 ? bs * 64 + buffer : buffer), bc++ % 4)
      ? (output += String.fromCharCode(255 & (bs >> ((-2 * bc) & 6))))
      : 0
  ) {
    buffer = CHARS.indexOf(buffer);
  }

  return output;
}
