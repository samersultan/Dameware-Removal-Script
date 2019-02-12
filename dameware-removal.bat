net stop “Dameware Mini Remote Control”
net stop DWMRCS

regsvr32 /u %systemroot%\DWRCS\DWRCSh.dll
regsvr32 /u %systemroot%\DWRCS\DWRCSE.dll
regsvr32 /u %systemroot%\DWRCS\DWRCSET.dll
regsvr32 /u %systemroot%\DWRCS\DWRCSI.dll
regsvr32 /u %systemroot%\DWRCSDWRCRSS.dll
regsvr32 /u %systemroot%\DWRCS\DWRCK.dll
regsvr32 /u %systemroot%\DWRCS\DWRCWXL.dll

%systemroot%\DWRCS\dwrcs.exe -remove

rd %systemroot%\DWRCS\ /s /q
