#!/usr/bin/python
from libqtile.command.client import InteractiveCommandClient

c = InteractiveCommandClient()

try:
    print(c.layout.info().get("name"))
except:
    print("")
