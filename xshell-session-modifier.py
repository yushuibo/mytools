#!/usr/bin/env python
# -*- coding=UTF-8 -*-
'''
@ Since: 2019-08-04 22:47:07
@ Author: shy
@ Email: yushuibo@ebupt.com / hengchen2005@gmail.com
@ Version: v1.0
@ Description: A xshell session attr modify by multiple
@ LastTime: 2020-08-08 15:44:27
'''

import io
import re
import os

templates = """[CONNECTION:PROXY]
Proxy=
StartUp=0
[CONNECTION:SERIAL]
BaudRate=6
StopBits=0
FlowCtrl=0
Parity=0
DataBits=3
ComPort=0
[Information]
MinorVersion=0
MajorVersion=3
Description=
[SessionInfo]
Version=6.0
Description=Xshell session file
[TRACE]
SockConn=1
SshLogin=0
SshTunneling=0
SshPacket=0
TelnetOptNego=0
[CONNECTION:SSH]
LaunchAuthAgent=1
KeyExchange=
SSHCiphers=aes128-ctr:1,aes192-ctr:1,aes256-ctr:1,aes128-gcm@openssh.com:1,aes256-gcm@openssh.com:1,aes128-cbc:1,aes192-cbc:1,aes256-cbc:1,3des-cbc:1,blowfish-cbc:1,cast128-cbc:1,arcfour:1,rijndael128-cbc:1,rijndael192-cbc:1,rijndael256-cbc:1,rijndael-cbc@lysator.liu.se:1,arcfour128:1,arcfour256:1,chacha20-poly1305@openssh.com:1
ForwardToXmanager=1
Compression=1
NoTerminal=0
UseAuthAgent=0
MAC=
SSHMACs=hmac-sha2-256-etm@openssh.com:1,hmac-sha2-512-etm@openssh.com:1,hmac-sha1-etm@openssh.com:1,hmac-sha2-256:1,hmac-sha2-512:1,hmac-sha1:1,hmac-sha1-96:1,hmac-md5:1,hmac-md5-96:1,hmac-ripemd160:1,hmac-ripemd160@openssh.com:1,hmac-sha1-96-etm@openssh.com:1,hmac-md5-etm@openssh.com:1,hmac-md5-96-etm@openssh.com:1
InitRemoteDirectory=
ForwardX11=1
VexMode=0
Cipher=
Display=localhost:0.0
FwdReqCount=0
InitLocalDirectory=
SSHKeyExchanges=curve25519-sha256@libssh.org:1,ecdh-sha2-nistp256:1,ecdh-sha2-nistp384:1,ecdh-sha2-nistp521:1,diffie-hellman-group-exchange-sha256:1,diffie-hellman-group-exchange-sha1:1,diffie-hellman-group14-sha1:1,diffie-hellman-group1-sha1:1
SaveHostKey=1
RemoteCommand=
[BELL]
FilePath=
RepeatTime=3
FlashWindow=0
BellMode=0
IgnoreTime=3
[USERINTERFACE]
NoQuickButton=0
QuickCommand=Default Quick Command Set
[CONNECTION:FTP]
Passive=1
InitRemoteDirectory=
InitLocalDirectory=
[TRANSFER]
FolderMethod=1
DropXferHandler=2
XmodemUploadCmd=rx
ZmodemUploadCmd=rz -E
FolderPath=D:\\workspace
YmodemUploadCmd=rb -E
AutoZmodem=1
SendFolderPath=D:\\workspace
DuplMethod=0
XYMODEM_1K=0
[CONNECTION]
Port=22
Host=%(h)s
Protocol=SSH
AutoReconnect=0
AutoReconnectLimit=0
Description=
AutoReconnectInterval=30
FtpPort=21
UseNaglesAlgorithm=0
IPV=0
[TERMINAL]
Rows=56
CtrlAltIsAltGr=1
InitOriginMode=0
InitReverseMode=0
DisableBlinkingText=0
CodePage=65001
InitAutoWrapMode=1
Cols=160
InitEchoMode=0
Type=xterm
DisableAlternateScreen=0
CJKAmbiAsWide=1
ScrollBottomOnKeyPress=0
DisableTitleChange=0
ForceEraseOnDEL=0
InitInsertMode=0
ShiftForcesLocalUseOfMouse=1
FontLineCharacter=1
ScrollbackSize=200000
InitCursorMode=0
FixedCols=0
BackspaceSends=2
UseInitSize=0
UseLAltAsMeta=0
UseRAltAsMeta=0
AltKeyMapPath=
DeleteSends=0
DisableTermPrinting=0
IgnoreResizeRequest=1
ScrollBottomOnTermOutput=1
FontPowerLine=1
ScrollErasedText=1
KeyMap=0
RecvLLAsCRLF=0
EraseWithBackgroundColor=1
InitNewlineMode=0
InitKeypadMode=0
TerminalNameForEcho=
[TERMINAL:WINDOW]
ColorScheme=spacevim-dark
FontQuality=6
LineSpace=0
CursorColor=16777215
CursorBlinkInterval=500
TabColorType=0
CursorAppearance=0
TabColorOther=0
FontSize=10
AsianFontSize=10
CursorBlink=1
BGImageFile=
BoldMethod=2
CursorTextColor=0
BGImagePos=0
AsianFont=DejaVu Sans Mono
FontFace=DejaVu Sans Mono
CharSpace=0
MarginBottom=5
MarginLeft=5
MarginTop=5
MarginRight=5
[CONNECTION:TELNET]
XdispLoc=1
NegoMode=0
Display=$PCADDR:0.0
[HIGHLIGHT]
HighlightSet=None
[CONNECTION:AUTHENTICATION]
Pkcs11Pin=
Library=0
Passphrase=
Pkcs11Middleware=
Delegation=0
UseInitScript=1
TelnetLoginPrompt=ogin:
Password=%(a)s
RloginPasswordPrompt=assword:
UseExpectSend=0
TelnetPasswordPrompt=assword:
ExpectSend_Count=0
Method=0
ScriptPath=%(p)s
UserKey=
UserName=%(u)s
[LOGGING]
FilePath=%%n_%%Y-%%m-%%d_%%t.log
Overwrite=1
WriteFileTimestamp=0
TimestampFormat=[%%a]
Encoding=2
TermCode=0
AutoStart=0
Prompt=0
WriteTermTimestamp=0
[ADVANCED]
WaitPrompt=
PromptMax=0
SendLineDelayType=0
SendLineDelayInterval=0
SendCharDelayInterval=0
[CONNECTION:RLOGIN]
TermSpeed=38400
[CONNECTION:KEEPALIVE]
SendKeepAliveInterval=180
KeepAliveInterval=180
TCPKeepAlive=1
KeepAliveString=\\r
SendKeepAlive=1
KeepAlive=1

"""

# 129.5 (J@dxby123)
passwd01 = 'dOYGFQKPIhBHO/clttUYeHPSKNWjKJK+pW6T56dyX2meBLxNhGJBwB8='
# 129.4 (Migu@2019)
passwd02 = 'dOYGFQKPIhBHO/clttUYeHPSKNWjKJK+pW6T56dyX2meBLxNhGJBwB8='


def rewrite(f):
    print('starting process file: "{}" ...'.format(f))

    host, spath, username, passwd = '', '', '', ''
    rfp = io.open(f, 'r', encoding='utf-16')
    try:
        data = rfp.read()
    except Exception:
        rfp.close()
        rfp = io.open(f, 'r')
        data = rfp.read()

    for line in data.split('\n'):
        if not line:
            continue

        if re.match(r'^Host=.*$', line):
            host = line.split('=')[1]

        if re.match(r'^ScriptPath=.*$', line):
            spath = line.split('=')[1]
        if re.match(r'^UserName=.*$', line):
            username = line.split('=')[1]
        if re.match(r'^Password=.*$', line):
            passwd = line.split('=')[1]

        if host == '10.25.129.5' and username != 'mg_jiangyajun':
            passwd = passwd01
        elif host == '10.25.129.4' and username != 'mg_jiangyajun':
            passwd = passwd01
        else:
            pass

    rfp.close()

    new_content = templates % dict(
        h=host if host else '',
        p=spath if spath else '',
        a=passwd if passwd else '',
        u=username if username else '')

    with io.open(f, 'w', encoding='utf-16') as wfp:
        wfp.write(new_content)
        wfp.flush()


path = 'c:/Users/shy/OneDrive/sync/backup/xshell'
for root, _, files in os.walk(path):

    for f in files:
        if f.endswith('.ini'):
            continue
        f = '{}/{}'.format(root, f)
        print(f)
        rewrite(f)
