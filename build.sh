#!/bin/bash

VERSION="v9"
OUTDIR="../out"
ZIPDIR="../tools/zipfile"
PLACEHOLDER="Delete_before_compiling"
INITRAMFS_ANDROID="initramfs/ramdisk_boot"
INITRAMFS_ANDROID2="ramdisk_boot1"
INITRAMFS_RECOVERY="ramdisk_recovery"
INITRAMFS_RECOVERY_OLD="ramdisk_recovery_old"
INITRAMFS_RECOVERY_TOUCH="ramdisk_recovery_touch"
INITRAMFS_RECOVERY_MOD="ramdisk_recovery_mod"
INITRAMFS_RECOVERY_TWRP="ramdisk_recovery_twrp"
MODULES=("drivers/net/wireless/bcmdhd/dhd.ko" "drivers/scsi/scsi_wait_scan.ko" "drivers/samsung/j4fs/j4fs.ko")

  case "$1" in
  clean)
          make mrproper
          rm -rf ${OUTDIR}
          rm -f ../tools/zipfile/system/lib/modules/cifs.ko
          rm -f ../tools/zipfile/system/lib/modules/dhd.ko
          rm -f ../tools/zipfile/system/lib/modules/j4fs.ko
          rm -f ../tools/zipfile/system/lib/modules/scsi_wait_scan.ko
   ;;
   *)  
        mkdir -p ${OUTDIR}   
        make -j8 blazing_defconfig
       
        # create modules first to include in ramdisk
        make -j8 

        for module in "${MODULES[@]}" ; do
            cp "${module}" ${INITRAMFS_ANDROID}/lib/modules
        done  
        chmod 644 ${INITRAMFS_ANDROID}/lib/modules/*
        
        for module in "${MODULES[@]}" ; do
            cp "${module}" ../tools/zipfile/system/lib/modules
        done  
        cp fs/cifs/cifs.ko ../tools/zipfile/system/lib/modules
        chmod 644 ../tools/zipfile/system/lib/modules/*

        # create the android ramdisk
        rm initramfs/stage1/boot.cpio
        cd ${INITRAMFS_ANDROID}
        find . | cpio -o -H newc > ../stage1/boot.cpio
        cd ..

        rm initramfs/stage1/boot1.cpio
        cd ${INITRAMFS_ANDROID2}
        rm data/$PLACEHOLDER
        rm system/$PLACEHOLDER
        find . | cpio -o -H newc > ../stage1/boot1.cpio
        echo > data/$PLACEHOLDER
        echo > system/$PLACEHOLDER
        cd ..

        # create the recovery ramdisk, "cwm6" is for 6.0.1.2, "old" is for 5.5.0.4, "touch" is for touch recovery, "twrp" for TWRP 2.5; default is modified 6.0.3.1
      case "$1" in
      old)  
        rm stage1/recovery.cpio
        cd ${INITRAMFS_RECOVERY_OLD}
        cp recovery.cpio ../stage1/recovery.cpio
        cd ../..
      ;;
      touch)
        rm stage1/recovery.cpio
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
      cwm6)
        rm stage1/recovery.cpio
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
      twrp)
        rm stage1/recovery.cpio
        cd ${INITRAMFS_RECOVERY_TWRP}
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
        rm stage1/recovery.cpio
        cd ${INITRAMFS_RECOVERY_MOD}
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
        echo 0 > .version
        make -j8
        cp arch/arm/boot/zImage ${OUTDIR}
        cp arch/arm/boot/zImage ${ZIPDIR}
     
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
      cwm6)  
        echo "Creating flashable zip..."
        cd tools/zipfile
        zip -r Blazing_Kernel_${VERSION}_CWM6.zip *
        cd ..
        echo "Sigining zip..."
        java -jar signapk.jar -w testkey.x509.pem testkey.pk8 zipfile/Blazing_Kernel_${VERSION}_CWM6.zip ${OUTDIR}/Blazing_Kernel_${VERSION}_CWM6.zip
      ;;
      twrp)  
        echo "Creating flashable zip..."
        cd tools/zipfile
        zip -r Blazing_Kernel_${VERSION}_TWRP.zip *
        cd ..
        echo "Sigining zip..."
        java -jar signapk.jar -w testkey.x509.pem testkey.pk8 zipfile/Blazing_Kernel_${VERSION}_TWRP.zip ${OUTDIR}/Blazing_Kernel_${VERSION}_TWRP.zip
      ;;
      *)
        echo "Creating flashable zip..."
        cd tools/zipfile
        zip -r Blazing_Kernel_${VERSION}_CWM6_MOD.zip *
        cd ..
        echo "Sigining zip..."
        java -jar signapk.jar -w testkey.x509.pem testkey.pk8 zipfile/Blazing_Kernel_${VERSION}_CWM6_MOD.zip ${OUTDIR}/Blazing_Kernel_${VERSION}_CWM6_MOD.zip
      ;;
      esac   
      rm zipfile/*.zip zipfile/zImage 
      cd ../kernel
   ;;
   esac
