@echo off
SvcAgent.exe /install /silent
sc config SearchFileAgent start= auto
sc start SearchFileAgent
