;; This is an operating system configuration generated
;; by the graphical installer.
;;
;; Once installation is complete, you can learn and modify
;; this file to tweak the system configuration, and pass it
;; to the 'guix system reconfigure' command to effect your
;; changes.


;; Indicate which modules to import to access the variables
;; used in this configuration.
(use-modules 
  (gnu)
  (gnu home services)
  (guix channels)
  (gnu home services guix)
  (gnu packages linux)
  (nongnu packages linux)
  (nongnu system linux-initrd)
  )
(use-package-modules terminals certs wm xdisorg vim gl package-management)
(use-service-modules cups desktop networking ssh xorg nix sddm docker)

;; Modify configurations of default %desktop-services
(define %my-desktop-services
  (modify-services %desktop-services
                   ;; Configure the substitute server for the Nonguix repo
                   (guix-service-type
                    config =>
                    (guix-configuration
                     (inherit config)
                     (substitute-urls
		      (append (list "https://substitutes.nonguix.org")
			      %default-substitute-urls))
                     (authorized-keys
		      (append (list (plain-file "nonguix.pub" "(public-key
                                                                (ecc
                                                                 (curve Ed25519)
                                                                  (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)
                                                                 )
                                                                )"))
			      %default-authorized-guix-keys))))

		   (delete gdm-service-type)
		   ))

(define etc-sudoers-config
  (plain-file "etc-sudoers-config"
              "Defaults  timestamp_timeout=480
root      ALL=(ALL) ALL
%wheel    ALL=(ALL) ALL
callam    ALL=(ALL) NOPASSWD:/home/callam/.guix-home/profile/sbin/shutdown,/home/callam/.guix-home/profile/sbin/reboot"))


(operating-system
 (kernel linux)
 (sudoers-file etc-sudoers-config)
 (initrd microcode-initrd)
 (firmware (list linux-firmware))
 (locale "en_CA.utf8")
 (timezone "America/Toronto")
 (keyboard-layout (keyboard-layout "us"))
 (host-name "Desktop")

  ;; The list of user accounts ('root' is implicit).
  (users (cons* (user-account
                  (name "callam")
                  (comment "Callam Graham")
                  (group "users")
		  (uid 1000)
                  (home-directory "/home/callam")
                  (supplementary-groups '("wheel" "netdev" "audio" "video" "docker")))
                %base-user-accounts))

  ;; Packages installed system-wide.  Users can also install packages
  ;; under their own account: use 'guix search KEYWORD' to search
  ;; for packages and 'guix install PACKAGE' to install a package.
  (packages (append (list 
		     vim
		     sway
		     wofi
		     waybar
		     mesa
		     pipewire
		     wireplumber
		     alacritty)
                    %base-packages))

  ;; Below is the list of system services.  To search for available
  ;; services, run 'guix system search KEYWORD' in a terminal.

  (services (append (list
			  ;; configure env variables
		     (service sddm-service-type)
		     (service docker-service-type)
		     (simple-service 'variant-packages-service
				     home-channels-service-type
				     (list
				      (channel
				       (name 'nonguix)
				       (url "https://gitlab.com/nonguix/nonguix")
				       (introduction
					(make-channel-introduction
					 "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
					 (openpgp-fingerprint
					  "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
				      (channel
				       (name 'guix-gaming-games)
				       (url "https://gitlab.com/guix-gaming-channels/games.git")
				       ;; Enable signature verification:
				       (introduction
					(make-channel-introduction
					 "c23d64f1b8cc086659f8781b27ab6c7314c5cca5"
					 (openpgp-fingerprint
					  "50F3 3E2E 5B0C 3D90 0424  ABE8 9BDC F497 A4BB CC7F"))))
				      
				      )))
		    %my-desktop-services))
  
  (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets (list "/boot/efi"))
                (keyboard-layout keyboard-layout)))
  (swap-devices (list (swap-space
		       (target (uuid "d212b416-ffb8-4720-b865-0b8907390dc9"))
		       )))

  ;; The list of file systems that get "mounted".  The unique
  ;; file system identifiers there ("UUIDs") can be obtained
  ;; by running 'blkid' in a terminal.
  (file-systems (cons* (file-system
                         (mount-point "/")
                         (device (uuid
                                  "38e7122c-604f-41e7-a48f-95d73a2e3c8b"
                                  'ext4))
                         (type "ext4"))
		       
                       (file-system
                         (mount-point "/boot/efi")
                         (device (uuid "19F4-7892"
                                       'fat32))
                         (type "vfat"))

		       ;; TODO need to add mount option to give user rw permissions, something tike (option "umask=0022,uid=1000")
                       (file-system
                         (mount-point "/extra/ssd1")
                         ;; (device "/dev/sda1")
			 (device (uuid "5a7d7e88-c601-48fa-8d44-660cf07d0129"))
                         (type "ext4")
			 (create-mount-point? #t)
			 )

                       (file-system
                         (mount-point "/extra/nvme1")
                         ;; (device "/dev/nvme0n1p1")
			 (device (uuid "6ec2c6e9-1c9d-446c-b2b5-562302f7b3c1"))
                         (type "ext4")
			 (create-mount-point? #t)
			 )
		       
		       %base-file-systems)))
