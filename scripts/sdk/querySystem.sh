
#!/usr/bin/env bash
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
# we always end with "success" even though some commands may "fail"
exit 0