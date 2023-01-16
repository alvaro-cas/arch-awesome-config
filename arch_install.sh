#!/bin/bash
# Set color for input and color for output
BLUE="\033[0;36m"
GREEN="\033[0;32m"
RED="\033[0;31m"
NOCOLOR="\033[0m"

echo -ne "${BLUE}Install Arch base? [y/N]: ${NOCOLOR}"
read "answer"
if [ "$answer" == "Y" -o "$answer" == "y" ]
then

    # Set time and date
    timedatectl set-ntp true

    echo -e "${GREEN}### Partition disk ###\n${NOCOLOR}"
    # Prepare for encryption
    modprobe dm-crypt
    modprobe dm-mod
    # Show available devices
    lsblk

    echo -ne "\n${BLUE}Name of target disk: ${NOCOLOR}"
    read target_disk

    # Unmount target to continue with parition
    sudo umount ${target_disk}?*

    # Start partition
    sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${target_disk}
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
EOF

    echo -e "${GREEN} ### Done partitioning disk ###${NOCOLOR}"
    echo -e "\n\n${BLUE}Provide the name of your partitions.${NOCOLOR}"
    lsblk
    echo -ne "\n${BLUE}Partition 1: ${NOCOLOR}"
    read target_disk_one
    echo -ne "${BLUE}Partition 2: ${NOCOLOR}"
    read target_disk_two
    echo -ne "${BLUE}Partition 3: ${NOCOLOR}"
    read target_disk_three

    # Encrypt and open
    echo -e "\n\n${GREEN}### Encrypting disks ###${NOCOLOR}"
    cryptsetup luksFormat -v -s 512 -h sha512 ${target_disk_three}
    cryptsetup open ${target_disk_three} luks_root

    echo -e "\n\n${GREEN}### Formatting disks ###${NOCOLOR}"
    mkfs.vfat -n "EFI" ${target_disk_one}
    mkfs.ext4 -L boot ${target_disk_two}
    mkfs.ext4 -L root /dev/mapper/luks_root

    # MOunting
    mount /dev/mapper/luks_root /mnt
    mkdir /mnt/boot
    mount ${target_disk_two} /mnt/boot
    mkdir /mnt/boot/efi
    mount ${target_disk_one} /mnt/boot/efi

    cd /mnt
    dd if=/dev/zero of=swap bs=1M count=1024
    chmod 0600 swap
    mkswap swap
    swapon swap

    echo -e "\n\n${GREEN}### Base system ###${NOCOLOR}"
    pacman -Sy
    pacstrap /mnt base linux linux-firmware networkmanager grub efibootmgr dosfstools os-prober mtools base-devel sudo git

    echo -e "\n\n${GREEN}### Configure system ###${NOCOLOR}"
    genfstab -U /mnt >> /mnt/etc/fstab

    # Timezone and Localization
    echo -e "\n\n${GREEN}### Time zone and Localization ###${NOCOLOR}"
    ### Change zoneinfo to desired
    arch-chroot /mnt bash -c "ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime"
    arch-chroot /mnt bash -c "hwclock --systohc"
    ### Change locale to desired
    arch-chroot /mnt bash -c "sed -i '/en_US.UTF-8 UTF-8/s/^#//' /etc/locale.gen"
    arch-chroot /mnt bash -c "locale-gen"

    # Configure network
    echo -e "\n\n${GREEN}### Network ###${NOCOLOR}"
    echo -ne "\n${BLUE}Hostname: ${NOCOLOR}"
    read hostname
    arch-chroot /mnt bash -c "echo ${hostname} >> /etc/hostname"
    arch-chroot /mnt bash -c "echo -e '127.0.0.1      localhost\n::1            localhost\n127.0.0.1      ${hostname}.localdomain  ${hostname}' >> /etc/hosts"

    # Grub
    arch-chroot /mnt bash -c "sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub"
    target_grub=$(sed 's/\//\\\//g' <<< ${target_disk_three})
    arch-chroot /mnt bash -c "sed -i 's/GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"cryptdevice=${target_grub}:luks_root\"/g' /etc/default/grub"

    # Initramfs
    arch-chroot /mnt bash -c "sed -i 's/block/block encrypt/g' /etc/mkinitcpio.conf"
    arch-chroot /mnt bash -c "mkinitcpio -p linux"

    # Add user and set password
    echo -e "\n\n${GREEN}### Set user and passwd ###${NOCOLOR}"
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
    arch-chroot /mnt bash -c "grub-install --boot-directory=/boot --efi-directory=/boot/efi ${target_disk_two}"
    arch-chroot /mnt bash -c "grub-mkconfig -o /boot/grub/grub.cfg"
    arch-chroot /mnt bash -c "grub-mkconfig -o /boot/efi/EFI/arch/grub.cfg"

    # Internet interface
    arch-chroot /mnt bash -c "systemctl enable NetworkManager"

    # Exit and reboot
    echo -e "${GREEN}### Finishing...Done! ###${NOCOLOR}"
    reboot
else
  echo -e "${RED}### Skipped Arch installation ###${NOCOLOR}"
fi
