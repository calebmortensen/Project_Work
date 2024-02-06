@ECHO off
cls
title CareFusion - SQELAB Computer Imaging Solution - Built January 2010 - Version 1
:start
ECHO You are at the Home Menu - You may eject the CareFusion Imaging CD. (0) 1ST.
ECHO (1-8) Maps to Image Repository. (d-z) Applies OS Image followed by a Restart.
ECHO Total of 3 Steps to Image Computer. Imaging Servers (172.16.10.10 and .11)
ECHO.
ECHO 0.  Format Drive            (1ST STEP-ALWAYS) [Formats Hard Drive to C:]
ECHO 1.  Asus P1                 (2nd Step-Option) [Maps to Image Repository] (.10)
ECHO 2.  Compaq Evo D51s         (2nd Step-Option) [Maps to Image Repository] (.11)
ECHO 3.  Dell D830 Laptop        (2nd Step-Option) [Maps to Image Repository] (.11)
ECHO 4.  Dell Precision T5400    (2nd Step-Option) [Maps to Image Repository] (.10)
ECHO 5.  HP Vectra VL420 DT      (2nd Step-Option) [Maps to Image Repository] (.11)
ECHO 6.  HP XW4000               (2nd Step-Option) [Maps to Image Repository] (.11)
ECHO 7.  IBM ThinkCentre         (2nd Step-Option) [Maps to Image Repository] (.11)
ECHO 8.  IBM T41 Laptop          (2nd Step-Option) [Maps to Image Repository] (.11)
ECHO.
ECHO (3rd Step-Options) [Applies OS Image] (d)2000PROsp4 (e)2000SRVsp4 (f)XPsp2
ECHO (g)XPsp3 (y)2003SRV (i)2003SRVsp1 (j)2003SRVsp2 (o)2003SRVENTsp1
ECHO (v)2003SRVENTsp2 (k)VB (m)VBsp1 (n)VBsp2 (l)VE (p)VEsp1 (q)VEsp2 (u)VU (b)VUsp1
ECHO (x)VUsp2 (s)2008SRV (t)2008SRVsp2 (w)Win7ENT (z)Win7PRO (h)Win7Ult
ECHO.
ECHO ADMIN USE ONLY     (c)-Clear Mapping (r)-Restart Computer
ECHO                    (a)-Command Line [To return to the Home Menu, type: Home]
ECHO.
ECHO Upon Reboot: Navigate to Properties of "My Computer" - Change name to SQE-##               
set choice=
set /p choice= Select Step-Options (0 through z) [CaSe-SeNsItIvE] and Press ENTER:
ECHO.
if not '%choice%'=='' set choice=%choice:~0,1%
if '%choice%'=='0' goto format
if '%choice%'=='1' goto Asus
if '%choice%'=='2' goto CompaqEvo
if '%choice%'=='3' goto D830
if '%choice%'=='4' goto T5400
if '%choice%'=='5' goto HPVectra
if '%choice%'=='6' goto HPXW4000
if '%choice%'=='7' goto IBMThinkCentre
if '%choice%'=='8' goto IBMT41
if '%choice%'=='a' goto cmd
if '%choice%'=='c' goto clearmapping
if '%choice%'=='d' goto 2000sp4
if '%choice%'=='e' goto 2000srvsp4
if '%choice%'=='f' goto xpsp2
if '%choice%'=='g' goto xpsp3
if '%choice%'=='y' goto 2003
if '%choice%'=='i' goto 2003sp1
if '%choice%'=='j' goto 2003sp2
if '%choice%'=='k' goto vb
if '%choice%'=='l' goto ve
if '%choice%'=='m' goto vbsp1
if '%choice%'=='n' goto vbsp2
if '%choice%'=='p' goto vesp1
if '%choice%'=='q' goto vesp2
if '%choice%'=='r' goto restart
if '%choice%'=='s' goto 2008
if '%choice%'=='t' goto 2008sp2
if '%choice%'=='v' goto 2003entsp2
if '%choice%'=='w' goto win7ent
if '%choice%'=='z' goto win7pro
if '%choice%'=='u' goto vu
if '%choice%'=='b' goto vusp1
if '%choice%'=='x' goto vusp2
if '%choice%'=='o' goto 2003entsp1
if '%choice%'=='h' goto win7ult
ECHO "%choice%" is not valid please try again
ECHO.
goto start
:format
Diskpart /s clean.txt && pause && Home
goto end
:Asus
net use Z: \\172.16.10.10\AsusImages /user:sqeuser P@$$W0rd
Pause
Home
goto end
:CompaqEvo
net use Z: \\172.16.10.11\CompaqEvoImages /user:sqeuser P@$$W0rd
Pause
Home
goto end
:D830
net use Z: \\172.16.10.11\D830Images /user:sqeuser P@$$W0rd
Pause
Home
goto end
:T5400
net use Z: \\172.16.10.10\T5400Images /user:sqeuser P@$$W0rd
Pause
Home
goto end
:HPVectra
net use Z: \\172.16.10.11\HPVectraImages /user:sqeuser P@$$W0rd
Pause
Home
goto end
:HPXW4000
net use Z: \\172.16.10.11\HPXw4000Images /user:sqeuser P@$$W0rd
Pause
Home
goto end
:IBMThinkCentre
net use Z: \\172.16.10.11\IBMThinkCentreImages /user:sqeuser P@$$W0rd
Pause
Home
goto end
:IBMT41
net use Z: \\172.16.10.11\IBMT41Images /user:sqeuser P@$$W0rd
Pause
Home
goto end
:cmd
cmd
goto end
:clearmapping
net use * /delete /yes && Pause && Home
goto end
:restart
shutdown -r -f -t 3
goto end
:2000sp4
imagex /apply Z:\2000sp4.wim 1 C:
shutdown -r -f -t 3
goto end
:2000srvsp4
imagex /apply Z:\2000srvsp4.wim 1 C:
shutdown -r -f -t 3
goto end
:xpsp2
imagex /apply Z:\xpsp2.wim 1 C:
shutdown -r -f -t 3
goto end
:xpsp3
imagex /apply Z:\xpsp3.wim 1 C:
shutdown -r -f -t 3
goto end
:2003
imagex /apply Z:\2003.wim 1 C:
shutdown -r -f -t 3
goto end
:2003sp1
imagex /apply Z:\2003sp1.wim 1 C:
shutdown -r -f -t 3
goto end
:2003sp2
imagex /apply Z:\2003sp2.wim 1 C:
shutdown -r -f -t 3
goto end
:2003entsp2
imagex /apply Z:\2003entsp2.wim 1 C:
shutdown -r -f -t 3
goto end
:2003entsp1
imagex /apply Z:\2003entsp1.wim 1 C:
shutdown -r -f -t 3
goto end
:vb
imagex /apply Z:\vb.wim 1 C:
bcdedit /enum /store c:\Boot\BCD
bcdedit /set {default} device partition=c:
bcdedit /set {default} osdevice partition=c:
bcdedit /set {bootmgr} device partition=c:
shutdown -r -f -t 3
goto end
:ve
imagex /apply Z:\ve.wim 1 C:
bcdedit /enum /store c:\Boot\BCD
bcdedit /set {default} device partition=c:
bcdedit /set {default} osdevice partition=c:
bcdedit /set {bootmgr} device partition=c:
shutdown -r -f -t 3
goto end
:vbsp1
imagex /apply Z:\vbsp1.wim 1 C:
bcdedit /enum /store c:\Boot\BCD
bcdedit /set {default} device partition=c:
bcdedit /set {default} osdevice partition=c:
bcdedit /set {bootmgr} device partition=c:
shutdown -r -f -t 3
goto end
:vbsp2
imagex /apply Z:\vbsp2.wim 1 C:
bcdedit /enum /store c:\Boot\BCD
bcdedit /set {default} device partition=c:
bcdedit /set {default} osdevice partition=c:
bcdedit /set {bootmgr} device partition=c:
shutdown -r -f -t 3
goto end
:vesp1
imagex /apply Z:\vesp1.wim 1 C:
bcdedit /enum /store c:\Boot\BCD
bcdedit /set {default} device partition=c:
bcdedit /set {default} osdevice partition=c:
bcdedit /set {bootmgr} device partition=c:
shutdown -r -f -t 3
goto end
:vesp2
imagex /apply Z:\vesp2.wim 1 C:
bcdedit /enum /store c:\Boot\BCD
bcdedit /set {default} device partition=c:
bcdedit /set {default} osdevice partition=c:
bcdedit /set {bootmgr} device partition=c:
shutdown -r -f -t 3
goto end
:vu
imagex /apply Z:\vu.wim 1 C:
bcdedit /enum /store c:\Boot\BCD
bcdedit /set {default} device partition=c:
bcdedit /set {default} osdevice partition=c:
bcdedit /set {bootmgr} device partition=c:
shutdown -r -f -t 3
goto end
:vusp1
imagex /apply Z:\vusp1.wim 1 C:
bcdedit /enum /store c:\Boot\BCD
bcdedit /set {default} device partition=c:
bcdedit /set {default} osdevice partition=c:
bcdedit /set {bootmgr} device partition=c:
shutdown -r -f -t 3
goto end
:vusp2
imagex /apply Z:\vusp2.wim 1 C:
bcdedit /enum /store c:\Boot\BCD
bcdedit /set {default} device partition=c:
bcdedit /set {default} osdevice partition=c:
bcdedit /set {bootmgr} device partition=c:
shutdown -r -f -t 3
goto end
:2008
imagex /apply Z:\2008.wim 1 C:
bcdedit /enum /store c:\Boot\BCD
bcdedit /set {default} device partition=c:
bcdedit /set {default} osdevice partition=c:
bcdedit /set {bootmgr} device partition=c: 
shutdown -r -f -t 3
goto end
:2008sp2
imagex /apply Z:\2008sp2.wim 1 C:
bcdedit /enum /store c:\Boot\BCD
bcdedit /set {default} device partition=c:
bcdedit /set {default} osdevice partition=c:
bcdedit /set {bootmgr} device partition=c:
shutdown -r -f -t 3
goto end
:win7ent
imagex /apply Z:\win7ent.wim 1 C:
bcdedit /enum /store c:\Boot\BCD
bcdedit /set {default} device partition=c:
bcdedit /set {default} osdevice partition=c:
bcdedit /set {bootmgr} device partition=c:
shutdown -r -f -t 3
goto end
:win7pro
imagex /apply Z:\win7pro.wim 1 C:
bcdedit /enum /store c:\Boot\BCD
bcdedit /set {default} device partition=c:
bcdedit /set {default} osdevice partition=c:
bcdedit /set {bootmgr} device partition=c:
shutdown -r -f -t 3
goto end
:win7ult
imagex /apply Z:\win7ult.wim 1 C:
bcdedit /enum /store c:\Boot\BCD
bcdedit /set {default} device partition=c:
bcdedit /set {default} osdevice partition=c:
bcdedit /set {bootmgr} device partition=c:
shutdown -r -f -t 3
goto end
:end