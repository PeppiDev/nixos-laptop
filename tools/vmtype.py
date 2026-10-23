#!/usr/bin/env python3
"""Escribe texto en una VM libvirt simulando teclado (virsh send-key, layout US).

Uso: vmtype.py <dominio> <texto> [--enter]
"""
import subprocess
import sys

CONN = "qemu:///system"

PLAIN = {
    " ": "KEY_SPACE", "-": "KEY_MINUS", "=": "KEY_EQUAL", "[": "KEY_LEFTBRACE",
    "]": "KEY_RIGHTBRACE", ";": "KEY_SEMICOLON", "'": "KEY_APOSTROPHE",
    "`": "KEY_GRAVE", "\\": "KEY_BACKSLASH", ",": "KEY_COMMA", ".": "KEY_DOT",
    "/": "KEY_SLASH", "\n": "KEY_ENTER", "\t": "KEY_TAB",
}
SHIFTED = {
    "!": "KEY_1", "@": "KEY_2", "#": "KEY_3", "$": "KEY_4", "%": "KEY_5",
    "^": "KEY_6", "&": "KEY_7", "*": "KEY_8", "(": "KEY_9", ")": "KEY_0",
    "_": "KEY_MINUS", "+": "KEY_EQUAL", "{": "KEY_LEFTBRACE",
    "}": "KEY_RIGHTBRACE", ":": "KEY_SEMICOLON", '"': "KEY_APOSTROPHE",
    "~": "KEY_GRAVE", "|": "KEY_BACKSLASH", "<": "KEY_COMMA", ">": "KEY_DOT",
    "?": "KEY_SLASH",
}


def keys_for(ch):
    if ch.isalpha():
        k = f"KEY_{ch.upper()}"
        return ["KEY_LEFTSHIFT", k] if ch.isupper() else [k]
    if ch.isdigit():
        return [f"KEY_{ch}"]
    if ch in PLAIN:
        return [PLAIN[ch]]
    if ch in SHIFTED:
        return ["KEY_LEFTSHIFT", SHIFTED[ch]]
    raise ValueError(f"carácter no soportado: {ch!r}")


def main():
    dom, text = sys.argv[1], sys.argv[2]
    if "--enter" in sys.argv[3:]:
        text += "\n"
    for ch in text:
        subprocess.run(
            ["virsh", "-c", CONN, "send-key", dom, "--codeset", "linux", *keys_for(ch)],
            check=True, stdout=subprocess.DEVNULL,
        )


if __name__ == "__main__":
    main()
