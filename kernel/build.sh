#!/bin/bash

VERSION="v1"
OUTDIR="../out"
INITRAMFS_ANDROID="initramfs/ramdisk_boot"
INITRAMFS_RECOVERY="ramdisk_recovery"
INITRAMFS_RECOVERY_OLD="ramdisk_recovery_old"
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
            cp "${module}" ${INITRAMFS_ANDROID}/lib/modules/
        done

        # create the android ramdisk
        cd ${INITRAMFS_ANDROID}
        find . | cpio -o -H newc > ../stage1/boot.cpio
        cd ..

        # create the recovery ramdisk, default is for 6.0.1.2, "old" is for 5.5.0.4
      case "$1" in
      old)  
        cd ${INITRAMFS_RECOVERY_OLD}
        cp recovery.cpio ../stage1/recovery.cpio
        cd ../..
      ;;
      *)
        cd ${INITRAMFS_RECOVERY}
        find . | cpio -o -H newc > ../stage1/recovery.cpio
        cd ../..
      ;;
      esac
        
        # build the zImage
        make
        cp arch/arm/boot/zImage ${OUTDIR}
        cd ${OUTDIR}
      case "$1" in
      old)  
        tar -cf GT-I9100G_Blazing_Kernel_${VERSION}_old.tar zImage
      ;;
      *)
        tar -cf GT-I9100G_Blazing_Kernel_${VERSION}.tar zImage
      ;;
      esac
        cd ../kernel
   ;;
   esac
