#!/bin/bash

VERSION="v2"
OUTDIR="../out"
ZIPDIR="../tools/zipfile"
PLACEHOLDER="Delete_before_compiling"
INITRAMFS_ANDROID="initramfs/ramdisk_boot"
INITRAMFS_RECOVERY="ramdisk_recovery"
INITRAMFS_RECOVERY_OLD="ramdisk_recovery_old"
INITRAMFS_RECOVERY_TOUCH="ramdisk_recovery_touch"
MODULES=("fs/cifs/cifs.ko" "drivers/net/wireless/bcmdhd/dhd.ko" "drivers/scsi/scsi_wait_scan.ko" "crypto/ansi_cprng.ko" "drivers/samsung/j4fs/j4fs.ko")

  case "$1" in
  clean)
          make mrproper

          rm initramfs/stage1/boot.cpio
          rm initramfs/stage1/recovery.cpio
          rm -rf ${OUTDIR}
   ;;
   *)
	mkdir -p ${OUTDIR}

        make blazing_defconfig

        # build modules first to include them into android ramdisk
        make -j2 modules
       
        for module in "${MODULES[@]}" ; do
            cp "${module}" ${INITRAMFS_ANDROID}/lib/modules
        done
        
        chmod 644 ${INITRAMFS_ANDROID}/lib/modules/*

        # create the android ramdisk
        cd ${INITRAMFS_ANDROID}
        find . | cpio -o -H newc > ../stage1/boot.cpio
        cd ..

        # create the recovery ramdisk, default is for 6.0.1.2, "old" is for 5.5.0.4, "touch" is for touch recovery
      case "$1" in
      old)  
        cd ${INITRAMFS_RECOVERY_OLD}
        cp recovery.cpio ../stage1/recovery.cpio
        cd ../..
      ;;
      touch)
        cd ${INITRAMFS_RECOVERY_TOUCH}
        rm data/$PLACEHOLDER
        rm system/bin/$PLACEHOLDER
        rm tmp/$PLACEHOLDER
        find . | cpio -o -H newc > ../stage1/recovery.cpio
        echo > data/$PLACEHOLDER
        echo > system/bin/$PLACEHOLDER
        echo > tmp/$PLACEHOLDER
        cd ../..
      ;;
      *)
        cd ${INITRAMFS_RECOVERY}
        rm data/$PLACEHOLDER
        rm system/bin/$PLACEHOLDER
        rm tmp/$PLACEHOLDER
        find . | cpio -o -H newc > ../stage1/recovery.cpio
        echo > data/$PLACEHOLDER
        echo > system/bin/$PLACEHOLDER
        echo > tmp/$PLACEHOLDER
        cd ../..
      ;;
      esac
        
        # build the zImage
        make
        cp arch/arm/boot/zImage ${OUTDIR}
        cp arch/arm/boot/zImage ${ZIPDIR}
        cd ${OUTDIR}
      case "$1" in
      old)  
        tar -cf GT-I9100G_Blazing_Kernel_${VERSION}_CWM5.tar zImage
      ;;
      touch)  
        tar -cf GT-I9100G_Blazing_Kernel_${VERSION}_TOUCH.tar zImage
      ;;
      *)
        tar -cf GT-I9100G_Blazing_Kernel_${VERSION}_CWM6.tar zImage
      ;;
      esac
      
      cd ..

      case "$1" in
      old)  
        echo "Creating flashable zip..."
        cd tools/zipfile
        zip -r Blazing_Kernel_${VERSION}_CWM5.zip *
        cd ..
        echo "Sigining zip..."
        java -jar signapk.jar -w testkey.x509.pem testkey.pk8 zipfile/Blazing_Kernel_${VERSION}_CWM5.zip ${OUTDIR}/Blazing_Kernel_${VERSION}_CWM5.zip
      ;;
      touch)  
        echo "Creating flashable zip..."
        cd tools/zipfile
        zip -r Blazing_Kernel_${VERSION}_TOUCH.zip *
        cd ..
        echo "Sigining zip..."
        java -jar signapk.jar -w testkey.x509.pem testkey.pk8 zipfile/Blazing_Kernel_${VERSION}_TOUCH.zip ${OUTDIR}/Blazing_Kernel_${VERSION}_TOUCH.zip
      ;;
      *)
        echo "Creating flashable zip..."
        cd tools/zipfile
        zip -r Blazing_Kernel_${VERSION}_CWM6.zip *
        cd ..
        echo "Sigining zip..."
        java -jar signapk.jar -w testkey.x509.pem testkey.pk8 zipfile/Blazing_Kernel_${VERSION}_CWM6.zip ${OUTDIR}/Blazing_Kernel_${VERSION}_CWM6.zip
      ;;
      esac   
      rm zipfile/*.zip zipfile/zImage 
      cd ../kernel
   ;;
   esac
   
   
   
