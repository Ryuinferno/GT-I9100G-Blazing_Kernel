#!/system/bin/sh

# init.d support
if [ -d /system/etc/init.d ]; then
  run-parts /system/etc/init.d
else
  mount -o rw,remount /system
  mkdir /system/etc/init.d
  chmod 777 /system/etc/init.d
  mount -o ro,remount /system
fi

if [ -d /data/etc/init.d ]; then
  run-parts /data/etc/init.d
else
  mkdir /data/etc
  chmod 777 /data/etc
  mkdir /data/etc/init.d
  chmod 777 /data/etc/init.d
fi



