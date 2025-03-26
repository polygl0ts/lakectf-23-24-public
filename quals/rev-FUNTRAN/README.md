# FUNTRAN

## solve

```sh
echo '8.3066238629' | FUNTRAN/funtran
echo '8.30662386291' | FUNTRAN/funtran
```

## compile

compile in a `ubuntu:22.04` container to generate `FUNTRAN.zip`:

```sh
podman run --rm -v "$PWD":/chal:z ubuntu:22.04 /bin/bash -c 'apt update && apt install gfortran build-essential zip -y && cd /chal && ./makechal.sh'
```
