#!/usr/bin/env python3
import os

# Patch the firmware files for the different teams

TEAMS = [
    "handout",
    "about_blankets",
    "cheriPI",
    "DiceGang",
    "fibonhack",
    "flagbot",
    "FluxFingers",
    "ISITDTU",
    "thehackerscrew",
    "Zer0Line",
    "Phreaks_2600",
]

TEAMS = [str(i) for i in range(11)]

PWDS = [
    b"86e1ae97e58b4cc3",
    b"535e1974af863ee1",
    b"ad2167401fece98f",
    b"9d1dc19a345d0a4d",
    b"ee32d5533ce544bd",
    b"4f0ba3ea86f5ef5c",
    b"11020d5f62b74e61",
    b"527e6be2bb32e322",
    b"a4ed7b39fd614816",
    b"913002c46de4cf6c",
    b"dc781d6f48985312",
]

SSID = b"Internet of Shit"
PASSWD = b"S0S3cur3"
FLAG = b"EPFL{th3_'S'_1n_IoT_5t4nd5_f0r_53cur1ty}"
FAKE_FLAG = b"EPFL{test_flag}"

assert(len(TEAMS) == 11)
assert(len(PWDS) == 11)

os.makedirs("./handout", exist_ok=True)
with open("./src/build/lakectf-ios.elf", "rb") as orig_elf, open("./src/build/lakectf-ios.bin", "rb") as orig_bin:
    elf_bytes_orig = bytearray(orig_elf.read())
    bin_bytes_orig = bytearray(orig_bin.read())
    for team, passwd in zip(TEAMS, PWDS):
        with open(f"./handout/lakectf-ios-{team}.elf", "wb") as team_elf, open(f"./handout/lakectf-ios-{team}.bin", "wb") as team_bin:
            elf_bytes = elf_bytes_orig.copy()
            bin_bytes = bin_bytes_orig.copy()
            tmp = f"IoS-{team}"
            print(f"Team: {team}, SSID: {tmp}, password: {passwd}")
            ssid = tmp.encode()
            
            # Patch the ELF
            while (ssid_idx := elf_bytes.find(SSID)) != -1:
                patch_len = max(len(SSID), len(ssid))
                elf_bytes[ssid_idx:ssid_idx + patch_len] = b"\0" * patch_len
                elf_bytes[ssid_idx:ssid_idx + len(ssid)] = ssid
            while (passwd_idx := elf_bytes.find(PASSWD)) != -1:
                patch_len = max(len(PASSWD), len(passwd))
                elf_bytes[passwd_idx:passwd_idx + patch_len] = b"\0" * patch_len
                elf_bytes[passwd_idx:passwd_idx + len(passwd)] = passwd
            while (flag_idx := elf_bytes.find(FLAG)) != -1:
                patch_len = max(len(FLAG), len(FAKE_FLAG))
                elf_bytes[flag_idx:flag_idx + patch_len] = b"\0" * patch_len
                elf_bytes[flag_idx:flag_idx + len(FAKE_FLAG)] = FAKE_FLAG
            team_elf.write(elf_bytes)

            # Patch the bin
            while (ssid_idx := bin_bytes.find(SSID)) != -1:
                patch_len = max(len(SSID), len(ssid))
                bin_bytes[ssid_idx:ssid_idx + patch_len] = b"\0" * patch_len
                bin_bytes[ssid_idx:ssid_idx + len(ssid)] = ssid
            while (passwd_idx := bin_bytes.find(PASSWD)) != -1:
                patch_len = max(len(PASSWD), len(passwd))
                bin_bytes[passwd_idx:passwd_idx + patch_len] = b"\0" * patch_len
                bin_bytes[passwd_idx:passwd_idx + len(passwd)] = passwd
            while (flag_idx := bin_bytes.find(FLAG)) != -1:
                patch_len = max(len(FLAG), len(FAKE_FLAG))
                bin_bytes[flag_idx:flag_idx + patch_len] = b"\0" * patch_len
                bin_bytes[flag_idx:flag_idx + len(FAKE_FLAG)] = FAKE_FLAG
            team_bin.write(bin_bytes)
