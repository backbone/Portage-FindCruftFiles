#!/bin/bash
# Finds files not registered in portage

DIRLIST="/bin /etc /lib /lib32 /lib64 /opt /sbin
`ls /usr/ | grep -vE 'portage|local|src|lost\+found' | sed 's/\(.*\)/\/usr\/\1/'`
`ls /var/ | grep -vE 'tmp|lost\+found' | sed 's/\(.*\)/\/var\/\1/'`"

EXCLUDES='\\
^/etc/make.conf|\\
^/etc/portage|\\
^/usr/opt/android-sdk-update-manager|\\
^/usr/opt/cuda|\\
^/usr/lib64/portage|\\
^/usr/lib64/portage|\\
^/usr/lib64/gedit-2|\\
^/var/db/pkg|\\
^/var/lib/layman|\\
^/var/run|\\
^/var/cache|\\
^/var/doc|\\
^/var/www|\\
^/var/log|\\
^/usr/share/mime'

REPLACES="
s~^/lib64/grub/~/lib/grub/~ ;
s~^/usr/lib64/bcc/~/usr/lib/bcc/~ ;
s~^/usr/lib64/conkeror/~/usr/lib/conkeror/~ ;
s~^/usr/lib64/debug/~/usr/lib/debug/~ ;
s~^/usr/lib64/fpc/~/usr/lib/fpc/~ ;
s~^/usr/lib64/fvwm/~/usr/lib/fvwm/~ ;
s~^/usr/lib64/gcc/~/usr/lib/gcc/~ ;
s~^/usr/lib64/gentoolkit/~/usr/lib/gentoolkit/~ ;
s~^/usr/opt/~/opt/~ ;
"

#   ===========================================================
#  ========================= C O D E ===========================
# ===============================================================
# summarize dirlist
DIRLIST="`echo $DIRLIST`"
echo "DIRLIST=$DIRLIST"

# exclude current python, perl, kernel modules
EXCLUDES="$EXCLUDES\|`qlist -ICev python | sed 's~[^0-9]*\([0-9]*\.[0-9]*\).*~\^\/usr\/lib64\/python\1\|\\\\~'`"
EXCLUDES="`echo $EXCLUDES | sed 's~\ ~~g ; s~\\\~~g ; s~|$~~'`"
EXCLUDES="$EXCLUDES\|`qlist -ICev perl | sed 's~[^0-9]*\([0-9]*\.[0-9]*\.[0-9]*\).*~\^\/usr\/lib64\/perl5/\1\|\\\\~'`"
EXCLUDES="`echo $EXCLUDES | sed 's~\ ~~g ; s~\\\~~g ; s~|$~~'`"
EXCLUDES="$EXCLUDES\|^`realpath /lib/modules/\`uname -r\``"
EXCLUDES="`echo $EXCLUDES | sed 's~\ ~~g ; s~\\\~~g ; s~|$~~'`"

# summarize excludes
echo "EXCLUDES=$EXCLUDES"

# summarize replaces
REPLACES="`echo $REPLACES`"
echo "REPLACES=$REPLACES"

CURRENT_LIST=/tmp/current-$RANDOM.lst
PORTAGE_LIST=/tmp/portage-$RANDOM.lst
RESULT_LIST=/tmp/result-$RANDOM.lst

echo "Gathering information from portage..."
qlist / | sort -u >$PORTAGE_LIST

echo "Gathering information from file system..."
find -P $DIRLIST -type f 2>/dev/null | grep -vE "$EXCLUDES" | sed "$REPLACES" | sort -u >$CURRENT_LIST

echo "Searching for differences..."
diff $PORTAGE_LIST $CURRENT_LIST | grep -E '^>' | sed 's/> //' >$RESULT_LIST

echo "`wc -l $RESULT_LIST | cut -d" " -f1` orphaned files found:"
echo "-------------------------------------------------------------------------"
cat $RESULT_LIST

rm -f $PORTAGE_LIST $CURRENT_LIST $RESULT_LIST

exit 0

