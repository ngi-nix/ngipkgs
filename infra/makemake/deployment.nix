# <https://github.com/NixOS/nixops-hetzner>
{
  deployment = {
    targetEnv = "hetzner";
    hetzner = {
      mainIPv4 = "116.202.113.248"; # 2a01:4f8:231:4187::2
      createSubAccount = false;

      partitionCommand = ''
        if ! [ -e /usr/local/sbin/zfs ]; then
          echo "installing zfs..."
          bash -i -c 'echo y | zfsonlinux_install'
        fi

        umount -R /mnt || true

        zpool destroy rpool || true

        for disk in /dev/nvme0n1 /dev/nvme1n1; do
          echo "partitioning $disk..."
          index="''${disk: -3:1}"
          parted -s $disk "mklabel msdos"
          parted -a optimal -s $disk "mkpart primary ext4 1m 256m"
          parted -a optimal -s $disk "mkpart primary zfs 256m 100%"
          udevadm settle
          mkfs.ext4 -L boot$index ''${disk}p1
        done

        echo "creating ZFS pool..."
        zpool create -f -o ashift=12 -O atime=off -O compression=lz4 -O xattr=sa -O acltype=posixacl \
          rpool mirror /dev/nvme0n1p2 /dev/nvme1n1p2
        zfs set mountpoint=legacy rpool

        zfs create -o primarycache=all -o recordsize=16k -o logbias=throughput rpool/root
        zfs create -o primarycache=all -o recordsize=16k -o logbias=throughput rpool/postgres
      '';

      mountCommand = ''
        mkdir -p /mnt
        mount -t zfs rpool/root /mnt
        mkdir -p /mnt/postgres
        mount -t zfs rpool/postgres /mnt/postgres
        mkdir -p /mnt/boot
        mount /dev/disk/by-label/boot0 /mnt/boot
      '';
    };
  };
}
