#!/usr/bin/env python

with open("yarn.lock", "r") as f:
    text = f.read()
    paragraphs = text.split(r"\n\n")
    for p in paragraphs:
        if "file:" in p:
            print(p)
