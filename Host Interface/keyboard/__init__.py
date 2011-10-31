import sys

plat = sys.platform.lower()

if plat[:5] == 'linux':
    from keyboardlinux import *
elif plat[:6] == 'darwin':
    from keyboardosx import *
elif plat[:5] == 'win32':
    from keyboardwindows import *
