;; system declaration for the server
(use-modules 
  (gnu)
  (gnu home services)
  (guix channels)
  (gnu packages linux)
  (nongnu packages linux)
  (nongnu system linux-initrd))

(use-package-modules terminals certs wm xdisorg vim gl package-management version-control ssh)
(use-service-modules cups desktop networking ssh docker avahi)

(define %mod-base-services
  ;; modifies to add nonguix
  (modify-services %base-services
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
		   ))

(define basement-nftables-config
  (plain-file "nftables.conf"
              "table inet filter {
	chain input {
		type filter hook input priority filter; policy drop;
		ct state invalid drop
		ct state { established, related } accept
		iif \"lo\" accept
		iif != \"lo\" ip daddr 127.0.0.0/8 drop
		iif != \"lo\" ip6 daddr ::1 drop
		ip protocol icmp accept
		ip6 nexthdr ipv6-icmp accept
		tcp dport 4444 accept
		reject
	}

	chain forward {
		type filter hook forward priority filter; policy drop;
	}

	chain output {
		type filter hook output priority filter; policy accept;
	}
}"))

(define desktop-ygg-key "7ac8e60f6eeceae4ada55a519b15cc36f68c9d09eee784dd4fe604ea8af70cd1")

(operating-system
 (kernel linux)
 (initrd microcode-initrd)
 (firmware (list linux-firmware))
 (locale "en_CA.utf8")
 (timezone "America/Toronto")
 (keyboard-layout (keyboard-layout "us"))
 (host-name "basement")

 ;; The list of user accounts ('root' is implicit).
 (users (cons* (user-account
                (name "callam")
                (comment "Callam Graham")
                (group "users")
                (home-directory "/home/callam")
                (supplementary-groups '("wheel" "netdev" "audio" "video" "docker")))
               %base-user-accounts))

 ;; Packages installed system-wide.  Users can also install packages
 ;; under their own account: use 'guix search KEYWORD' to search
 ;; for packages and 'guix install PACKAGE' to install a package.
 (packages (append (list
		    openssh
		    vim
		    git)
                   %base-packages))


 ;; system services
 (services (append (list

		    ;; containers
		    (service containerd-service-type)
		    (service docker-service-type)

		    ;; disks (for usb)
		    (service udisks-service-type)

		    ;; firewall
		    (service nftables-service-type
			     (nftables-configuration
			      (ruleset basement-nftables-config)))

		    ;; network
		    (service network-manager-service-type)
		    (service wpa-supplicant-service-type)
		    (service elogind-service-type)
		    (service ntp-service-type)
		    (service avahi-service-type)

		    ;; yggdrasil
		    (service yggdrasil-service-type
			      (yggdrasil-configuration
			       (autoconf? #f) ;; use only the public peers
			       (config-file "/home/callam/.dotfiles/.config/guix/yggdrasil/yggdrasil-private-basement.conf")
			       (json-config
				;; choose one from
				;; https://github.com/yggdrasil-network/public-peers
				;; '((peers . #("tcp://1.2.3.4:1337")))
				'((AllowedPublicKeys . #(desktop-ygg-key)))
				'(
				  ;; (listen . #("tcp://[::]:47474"))
				  (listen . #("tls://0.0.0.0:47474"))
				  )
				)
			       ;; /etc/yggdrasil-private.conf is the default value for config-file
			       ))

		    ;; enable ssh
		    (service openssh-service-type
			     (openssh-configuration
			      (permit-root-login 'prohibit-password)
			      (authorized-keys
			       `(("callam" ,(local-file "basement.pub"))))
			      (port-number 4444)))
		    
		    ;; docker containers
		    (service oci-container-service-type
			     (list
			      (oci-container-configuration
			       (image "jellyfin/jellyfin")
			       (provision "jellyfin")
			       (network "host")
			       (ports
				'(("8096" . "8096")))
			       (volumes
				'("jellyfin-config:/config"
				  "jellyfin-cache:/cache"
				  "/media/hd/TV_Shows:/media/TV_Shows"
				  "/media/hd/Audiobooks:/media/Audiobooks"
				  "/media/hd/Lectures:/media/Lectures"
				  "/media/hd/Movies:/media/Movies"
				  "/media/hd/Home_Videos:/media/Home_Videos"
				  "/media/hd/Pictures:/media/Pictures"
				  )))))
		    
		    )
		   %mod-base-services))

 ;; bootloader
 (bootloader (bootloader-configuration
              (bootloader grub-efi-bootloader)
              (targets (list "/boot/efi"))
              (keyboard-layout keyboard-layout)))

 ;;swap space
 (swap-devices (list (swap-space
		      (target "/dev/nvme0n1p2") ; need to update this!
		      )))

 ;; file system mounts
 (file-systems (cons* (file-system
                       (mount-point "/")
                       (device "/dev/nvme0n1p3")
                       (type "ext4"))
		      
		      (file-system
                       (mount-point "/boot/efi")
                       (device "/dev/nvme0n1p1")
                       (type "vfat"))
		      
		      %base-file-systems)))
