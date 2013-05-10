#!/system/bin/sh

# custom bootanimtion support (if no bootanimation.zip is found, will run original animation)
mount -o rw,remount /system
if [ -e /system/media/bootanimation.zip ] && [ ! -e /system/etc/cusboot ]; then
  cp /sbin/blaze/bootanimation_cus /system/bin/bootanimation
  chmod 755 /system/bin/bootanimation
  chown 0.2000 /system/bin/bootanimation
  echo "On" > /system/etc/cusboot
  mount -o ro,remount /system
elif [ -e /system/media/bootanimation.zip ] && [ -e /system/etc/cusboot ]; then
  mount -o ro,remount /system
elif [ ! -e /system/media/bootanimation.zip ] && [ ! -e /system/etc/cusboot ]; then
  mount -o ro,remount /system
else
  cp /sbin/blaze/bootanimation_ori /system/bin/bootanimation
  chmod 755 /system/bin/bootanimation
  chown 0.2000 /system/bin/bootanimation
  rm /system/etc/cusboot
  mount -o ro,remount /system
fi

# custom boot sound support
mount -o rw,remount /system
if [ -e /system/media/PowerOn.ogg ]; then
  mv /system/media/PowerOn.ogg /system/media/audio/ui/PowerOn.ogg
  chmod 644 /system/media/audio/ui/PowerOn.ogg
  mount -o ro,remount /system
elif [ -e /system/media/ori_sound ]; then
  cp /sbin/blaze/PowerOn.ogg /system/media/audio/ui/PowerOn.ogg
  chmod 644 /system/media/audio/ui/PowerOn.ogg
  rm /system/media/ori_sound
  mount -o ro,remount /system
elif [ -e /system/media/mute ]; then
  mv /system/media/audio/ui/PowerOn.ogg /system/media/audio/ui/PowerOn.ogg.bak
  rm /system/media/mute
  mount -o ro,remount /system
elif [ -e /system/media/unmute ]; then
  mv /system/media/audio/ui/PowerOn.ogg.bak /system/media/audio/ui/PowerOn.ogg
  rm /system/media/unmute
  mount -o ro,remount /system
else
  mount -o ro,remount /system
fi

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
