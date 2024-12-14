;; system declaration for the server
(use-modules 
  (gnu)
  (gnu home services)
  (guix channels)
  (gnu packages linux)
  (nongnu packages linux)
  (nongnu system linux-initrd))

(use-package-modules terminals certs wm xdisorg vim gl package-management)
(use-service-modules cups desktop networking ssh docker)


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
		     vim
		     git)
                    %base-packages))


  ;; system services
  (services (append (list

		     ;; containers
		     (service containerd-service-type)
		     (service docker-service-type)

		     ;; firewall
		     (service nftables-service-type
			      (nftables-configuration
			       (ruleset basement-nftables-config)))

		     ;; network
		     (network-manager-service-type)
		     (wpa-supplicant-service-type)
		     (service elogind-service-type)

		     ;; enable ssh
		     (service openssh-service-type
                              (openssh-configuration
			       (authorized-keys
				'(("callam", (local-file "basement.pub"))))
                               (port-number 4444)))
		     
		     ;; Channels
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
				      )))
		    %base-services))

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
