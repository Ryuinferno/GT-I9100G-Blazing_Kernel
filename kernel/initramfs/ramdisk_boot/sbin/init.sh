#!/system/bin/sh

# custom bootanimtion support (if no bootanimation.zip is found, will run original animation)
mount -o rw,remount /system
if [ -e /system/media/bootanimation.zip ] && [ ! -e /system/etc/cusboot ]; then
  mv /system/bin/samsungani /system/bin/samsungani_orig
  cp /system/bin/bootanimation /system/bin/samsungani
  chmod 755 /system/bin/samsungani
  echo "on" > /system/etc/cusboot
  mount -o ro,remount /system
elif [ -e /system/media/bootanimation.zip ] && [ -e /system/etc/cusboot ]; then
   mount -o ro,remount /system
elif [ ! -e /system/media/bootanimation.zip ] && [ ! -e /system/etc/cusboot ]; then
   mount -o ro,remount /system
else
  rm /system/bin/samsungani
  mv /system/bin/samsungani_orig /system/bin/samsungani
  chmod 755 /system/bin/samsungani
  rm /system/etc/cusboot
  mount -o ro,remount /system
fi;

# init.d support
if [ -d /system/etc/init.d ]; then
  run-parts /system/etc/init.d
fi;

if [ -d /data/etc/init.d ]; then
  run-parts /data/etc/init.d
fi;



