#!/bin/bash
# Set color for input and color for output
BLUE="\033[0;36m"
GREEN="\033[0;32m"
RED="\033[0;31m"
NOCOLOR="\033[0m"

check_error() {
  if [[ "${?}" -ne 0 ]]
  then
    echo -e "${RED}${1} encountered an error! Try again!${NOCOLOR}"
    exit 1
  else
    echo -e "${GREEN}${1} passed successfully.${NOCOLOR}"
  fi
}

echo -ne "${BLUE}Install Arch base system? [y/N]: ${NOCOLOR}"
read "ANSWER"
if [[ "${ANSWER}" = "Y" -o "${ANSWER}" = "y" ]]
then

    # Set time and date
    timedatectl set-ntp true

    echo -e "${GREEN}===> Partition disk <===\n${NOCOLOR}"
    # Prepare for encryption
    modprobe dm-crypt
    modprobe dm-mod
    # Show available devices
    lsblk

    echo -ne "\n${BLUE}Name of target disk (ex. /dev/sda => sda): ${NOCOLOR}"
    read DISK
    TARGET_DISK="/dev/${DISK}"
    sudo umount ${TARGET_DISK}?* &> /dev/null
    check_error 'Unmount disk'

    # Start partition
    sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${TARGET_DISK}
  g # Create gpt table
  n # new partition
    # default
    # default
  +550M # Efi partition
  n # new partition
    # default
    # default
  +2G # Swap partition
  n # new partition
    # default
    # default
    # default
  t # Change partition type
  1 # Partition number one
  1 # Type Efi
  w # write changes
EOF &> /dev/null
    check_error 'Partition'

    TARGET_DISK_ONE=$(lsblk | grep nvme | awk '{print $1}' | tail -3 | cut -c 5- | head -1)
    TARGET_DISK_TWO=$(lsblk | grep ${DISK} | awk '{print $1}' | tail -3 | cut -c 5- | tail -2 | head -1)
    TARGET_DISK_THREE=$(lsblk | grep ${DISK} | awk '{print $1}' | tail -3 | cut -c 5- | tail -1)

    # Encrypt and open
    echo -e "\n\n${GREEN}===> Encrypting disks <===${NOCOLOR}"
    cryptsetup luksFormat -v -s 512 -h sha512 ${TARGET_DISK_THREE} &> /dev/null
    check_error 'LuksFormat'
    cryptsetup open ${TARGET_DISK_THREE} luks_root

    mkfs.vfat -n "EFI" ${TARGET_DISK_ONE} &> /dev/null
    check_error 'EFI format'
    mkfs.ext4 -L boot ${TARGET_DISK_TWO} &> /dev/null
    check_error 'Boot format'
    mkfs.ext4 -L root /dev/mapper/luks_root &> /dev/null
    check_error 'Root format'

    # Mounting
    mount /dev/mapper/luks_root /mnt
    mkdir /mnt/boot
    mount ${TARGET_DISK_TWO} /mnt/boot
    mkdir /mnt/boot/efi
    mount ${TARGET_DISK_ONE} /mnt/boot/efi

    cd /mnt
    dd if=/dev/zero of=swap bs=1M count=1024
    chmod go-r swap
    mkswap swap
    swapon swap

    echo -e "\n\n${GREEN}===> Base system <===${NOCOLOR}"
    pacman -Sy
    pacstrap /mnt base linux linux-firmware networkmanager grub efibootmgr dosfstools os-prober mtools base-devel sudo git &> /dev/null
    check_error 'Base install'

    # Generate disk table
    genfstab -U /mnt >> /mnt/etc/fstab
    # Change zoneinfo to desired
    arch-chroot /mnt bash -c "ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime"
    arch-chroot /mnt bash -c "hwclock --systohc"
    # Change locale to desired
    arch-chroot /mnt bash -c "sed -i '/en_US.UTF-8 UTF-8/s/^#//' /etc/locale.gen"
    arch-chroot /mnt bash -c "locale-gen"

    # Configure network
    echo -e "\n\n${GREEN}===> Network <===${NOCOLOR}"
    echo -ne "\n${BLUE}Hostname: ${NOCOLOR}"
    read HOST
    arch-chroot /mnt bash -c "echo ${HOST} >> /etc/hostname"
    arch-chroot /mnt bash -c "echo -e '127.0.0.1      localhost\n::1            localhost\n127.0.0.1      ${HOST}.localdomain  ${HOST}' >> /etc/hosts"

    # Grub
    arch-chroot /mnt bash -c "sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub"
    TARGET_GRUB=$(sed 's/\//\\\//g' <<< ${TARGET_DISK_THREE})
    arch-chroot /mnt bash -c "sed -i 's/GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"cryptdevice=${TARGET_GRUB}:luks_root\"/g' /etc/default/grub"

    # Initramfs
    arch-chroot /mnt bash -c "sed -i 's/block/block encrypt/g' /etc/mkinitcpio.conf"
    arch-chroot /mnt bash -c "mkinitcpio -p linux"

    # Add user and set password
    echo -e "\n\n${GREEN}===> Set user and passwd <===${NOCOLOR}"
    echo -e "\n${BLUE}Set administrator password${NOCOLOR}"
    arch-chroot /mnt bash -c "passwd"

    echo -ne "\n${BLUE}Username: ${NOCOLOR}"
    read username
    arch-chroot /mnt bash -c "useradd -m ${username}"

    echo -e "${BLUE}Set ${username} password${NOCOLOR}"
    arch-chroot /mnt bash -c "passwd ${username}"
    arch-chroot /mnt bash -c "usermod -aG wheel,audio,video,optical,storage ${username}"

    # Sudo to user
    arch-chroot /mnt bash -c "sed -i '/%wheel ALL=(ALL:ALL) ALL/s/^#//' /etc/sudoers"

    # Install grub
    arch-chroot /mnt bash -c "grub-install --boot-directory=/boot --efi-directory=/boot/efi ${TARGET_DISK_TWO}"
    arch-chroot /mnt bash -c "grub-mkconfig -o /boot/grub/grub.cfg"
    arch-chroot /mnt bash -c "grub-mkconfig -o /boot/efi/EFI/arch/grub.cfg"

    # Internet interface
    arch-chroot /mnt bash -c "systemctl enable NetworkManager"

    # Exit and reboot
    echo -e "${GREEN}===> Done! Bye. <===${NOCOLOR}"
    reboot
else
  echo -e "${RED}===> Bye. <===${NOCOLOR}"
fi
