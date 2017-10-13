#!/bin/sh
mkdir -p /apache/dev/{htdocs,secure,pdf}
mkdir -p /opt/sites/dev

if [[ ! -L /opt/sites/dev/php ]]; then
    ln -s /apache/dev /opt/sites/dev/php
fi

if [[ ! -L /opt/apps/tomcat ]]; then
    ln -s /opt/apps/apachetomcat-v5.5.36 /opt/apps/tomcat
fi

cat /opt/install/hosts >> /etc/hosts

if [[ -n $XDEBUG_REMOTE_HOST ]]; then
    xdebug_conf=/etc/php.d/xdebug.ini
    if [[ -e $xdebug_conf ]]; then
        if [[ `grep -Fx "[XDebug]" $xdebug_conf` ]]; then
            if [[ "x${XDEBUG_REMOTE_HOST}" = x`sed -n "s/xdebug.remote_host = \(.*\)$/\1/p" $xdebug_conf` ]]; then
                echo "The XDebug remote debug has been enabled before, the remote host is:$XDEBUG_REMOTE_HOST." 
            else
                sed -i "s/\(xdebug.remote_host =\).*/\1 $XDEBUG_REMOTE_HOST/g" $xdebug_conf
                echo "The XDebug remote debug is enabled before, the remote host has been changed to: ${XDEBUG_REMOTE_HOST}."
            fi
        else
            sed -i "$ a [XDebug]\nxdebug.remote_host = ${XDEBUG_REMOTE_HOST}\nxdebug.remote_enable = 1\nxdebug.remote_autostart = 1" $xdebug_conf
            echo "The XDebug remote debug is enabled, the remote host is: ${XDEBUG_REMOTE_HOST}."
        fi
    else
        echo "The $xdebug_conf file does not exits."
    fi
else
    echo "The Xdebug does not enable remote debug."
fi

TOMCAT_HOME="/opt/instances/dev/aohflvdev/bin"
TOMCAT_START="$TOMCAT_HOME/startup.sh"
$TOMCAT_START

# the path to your PID file
PIDFILE=/opt/instances/dev/aohflvdev/logs/httpd-aohflvdev.pid
#
# the path to your httpd binary, including options if necessary
HTTPD="httpd -f /opt/instances/dev/aohflvdev/conf/httpd.conf -DFOREGROUND"

# fix mime.types file not exitsed
if [[ ! -e /etc/httpd/conf/mime.types ]]; then
    ln -s /etc/mime.types /etc/httpd/conf/mime.types
fi

# fix DocumentRoot sas does not exit
mkdir -p /apache/dev/htdocs/sas

if [[ -n `type svn 2>/dev/null` ]]; then
    source /opt/install/svn_create_projects.sh
fi
echo "Start httpd process now."
$HTTPD
