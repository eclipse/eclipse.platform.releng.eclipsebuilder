
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
echo "rpm -q glib"
rpm -q glib 
echo 
echo "rpm -q ORBit2"
rpm -q ORBit2
echo 
echo
    echo "Check if any window managers are running:"
    ps -ef | egrep -i "xfwm|twm|metacity|beryl|fluxbox|compiz" | grep -v egrep
    echo
    echo
    echo "Check for popular desktop environments:"
    ps -ef | egrep -i "unity|mint|gnome|kde|xfce|ion|wmii|dwm" | grep -v egrep

# we always end with "success" even though some commands may "fail"
exit 0