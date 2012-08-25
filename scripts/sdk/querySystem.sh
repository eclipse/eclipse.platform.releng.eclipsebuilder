
#!/usr/bin/env bash

echo "\$WINDOW_MANAGER"
echo "$WINDOW_MANAGER"
echo "\$DESKTOP_SESSION"
echo "$DESKTOP_SESSION"
echo "\$XDG_CURRENT_DESKTOP"
echo "$XDG_CURRENT_DESKTOP"
echo "\$GDMSESSION"
echo "$GDMSESSION"

echo "uname -a"
uname -a
echo 
echo "lsb_release -a"
lsb_release -a
echo 
echo "cat /etc/lsb-release"
cat /etc/lsb-release
echo 
echo "cat /etc/SuSE-release"
cat /etc/SuSE-release
echo 
echo "rpm -q cairo"
rpm -q cairo
echo 
echo "rpm -q gtk2"
rpm -q gtk2
echo 
echo "rpm -q glibc"
rpm -q glibc
echo 
echo "rpm -q pango"
rpm -q pango
echo 
echo "rpm -q glib2"
rpm -q glib2 
echo 
echo "rpm -q ORBit2"
rpm -q ORBit2
echo 
echo
    echo "Check if any window managers are running (xfwm|twm|metacity|beryl|fluxbox|compiz):"
    ps -ef | egrep -i "xfwm|twm|metacity|beryl|fluxbox|compiz" | grep -v egrep
    echo
    echo
    # unity|mint|gnome|kde|xfce|ion|wmii|dwm (was original list, but matched too much, 
    # espeically "ion' I suppose. 
    echo "Check for popular desktop environments (gnome or kde):"
    ps -ef | egrep -i "gnome|kde" | grep -v egrep

# we always end with "success" even though some commands may "fail"
exit 0