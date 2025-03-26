# Crypto-Eat

Manger attack on OAEP (timing information serves as oracle).

Implementation copy pasted from [PyCryptodome](https://github.com/pycrypto/pycrypto/blob/master/lib/Crypto/Cipher/PKCS1_OAEP.py), except that this part:

```python
# y must be 0, but we MUST NOT check it here in order not to
# allow attacks like Manger's (http://dl.acm.org/citation.cfm?id=704143)
```

is replaced by:

```python
if bord(y)!=0:
    raise ValueError("Incorrect decryption.")
time.sleep(1)
```

## TODO maybe

- Make the timing leak more subtle instead of using `time.sleep`.

- Make copy paste from the original implementation less obvious.
