@echo off
sc stop SearchFileAgent
sc config SearchFileAgent start= disabled
SvcAgent.exe /uninstall /silent
taskkill -F -IM Agent.exe

