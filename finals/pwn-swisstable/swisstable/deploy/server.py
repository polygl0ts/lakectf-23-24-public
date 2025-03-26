import tempfile
import base64
import binascii
import os
import sys


def main():
    try:
        b64 = input("Base64 encoded file: ").strip()
    except EOFError:
        return

    try:
        js = base64.b64decode(b64)
    except binascii.Error:
        print("Invalid input", flush=True)
        return

    if len(js) >= 50000:
        print("Invalid input", flush=True)
        return

    with tempfile.NamedTemporaryFile() as f:
        f.write(js)
        f.seek(0)

        try:
            os.execve("./d8", ["d8", f.name], {})
        except Exception as e:
            print(e, flush=True)


if __name__ == "__main__":
    main()
