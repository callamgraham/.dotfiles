;; This "home-environment" file can be passed to 'guix home reconfigure'
;; to reproduce the content of your profile.  This is "symbolic": it only
;; specifies package names.  To reproduce the exact same profile, you also
;; need to capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

;; some utilities courtesy of David Wilson, for pulling manifests
(define (read-manifest manifest-path)
  (with-input-from-file manifest-path
    (lambda ()
      (read))))

(define (gather-manifest-packages manifests)
  (if (pair? manifests)
      (begin
        (let ((manifest (read-manifest (string-append
                                        "/home/callam/.dotfiles/.manifests/"
                                        (symbol->string (car manifests))
                                        ".scm"))))

          (append (map specification->package+output
                       (cadadr manifest))
                  (gather-manifest-packages (cdr manifests)))))
      '()))



(use-modules (gnu home)
             (gnu packages)
	     (gnu packages gnupg)
             (gnu services)
             (guix gexp)
	     (guix channels)
	     (gnu home services)
             (gnu home services shells)
	     (gnu home services guix)
	     (gnu home services gnupg)
	     (gnu home services ssh)
	     (gnu home services sway))

(home-environment
  ;; Below is the list of packages that will show up in your
  ;; Home profile, under ~/.guix-home/profile.
 (packages
  (append
   (gather-manifest-packages '(emacs)) 
   (specifications->packages (list
				      ;; gaming
				      "steam"
				      "protonup-ng"
				      "dolphin-emu"
				      "xrandr" ; for the primary_monitor script
				      "citra" ; from my personal channel
				      "desmume" ; DS
				      "mgba" ; gba
				      "retroarch"
				      
				      ;; sys admin
                                      "parted"
                                      "stow"
				      "gnupg"
				      "dunst"
				      "flatpak"
				      "zip"
				      "unzip"
				      "unrar-free"
				      "xdg-user-dirs"
				      "p7zip"
				      "neofetch" ; shows user info
				      ;; "pantalaimon" ; for ement encrypted
				      "ripgrep"
				      "rsync"
				      "htop"
				      "ntfs-3g"
				      "udiskie"
				      "zoxide"
				      "openssh"
				      "fd"

				      ;; UI
				      "swayfx"
				      "wofi"
				      "waybar"
				      "alacritty"
				      "openbox"
				      ;; "weston"
				      
				      ;; browser
				      "firefox" ; might want to move this to a container?
				      "qutebrowser"

				      ;; office
				      "libreoffice"
				      "evince"
				      
				      ;; fonts/icons
				      "font-google-noto"
                                      "font-adobe-source-code-pro"
				      "font-awesome"
				      "font-jetbrains-mono"
				      "breeze-icons"
				      "font-microsoft-web-core-fonts"
				      "adwaita-icon-theme"
				      "emacs-nerd-icons"

				      ;; media
				      "qpwgraph"
				      "pavucontrol"
				      "handbrake"
				      "transmission:gui"
				      "mpv"
				      "feh"
				      "libheif"
				      "imagemagick" ;; for converting image files 
				      
				      ;; programming
				      "cmake"
				      "gcc-toolchain"
				      "clang-toolchain"
                                      "git"				   
				      "python"
				      "rust:cargo"
				      "rust:out"
				      "rust:tools"

				      ;; tree sitter grammars
				      "tree-sitter-rust"
				      "tree-sitter-python"
				      "tree-sitter-bash"
				      "tree-sitter-dockerfile"
				      "tree-sitter-latex"
				      "tree-sitter-org"
				      
				      ;; other...
                                      "vim"))))

  ;; Below is the list of Home services.  To search for available
  ;; services, run 'guix home search KEYWORD' in a terminal.
 (services
  (list (service home-bash-service-type
                 (home-bash-configuration
		  (environment-variables '(("XWAYLAND_DISPLAY" . "DP-3")))
                  (aliases '(("grep" . "grep --color=auto")
			     ;; ("CC" . "gcc")
			     ("ll" . "ls -l")
                             ("ls" . "ls -p --color=auto")
			     ("unrar" . "unrar-free")
			     ("z" . "zoxide")
			     ("update-home" . "guix home reconfigure ~/.dotfiles/.config/guix/home-configuration.scm")
			     ("update-system" . "sudo -E guix system reconfigure /home/callam/.dotfiles/.config/guix/system.scm")
			     ;;("update-emacs" . "guix package --manifest=/home/callam/.dotfiles/.manifests/emacs.scm --profile=/home/callam/.emacs-profile")
			     ("cleanup" . "sudo guix gc -d 2m -F 50G")
			     ("rust" . "cd ~
guix shell --network --container --emulate-fhs \
     -m /home/callam/.dotfiles/.manifests/rust_dev.scm \
     -m /home/callam/.dotfiles/.manifests/prog.scm \
     -m /home/callam/.dotfiles/.manifests/emacs.scm \
     --preserve='^DISPLAY$' \
     --share=$HOME/Projects/Rust=$HOME \
     --expose=$HOME/.emacs.d/init.el=$HOME/.emacs.d/init.el \
     --expose=$HOME/.ssh=$HOME/.ssh \
     --expose=$HOME/.gnupg=$HOME/.gnupg \
     --expose=$HOME/.gitconfig=$HOME/.gitconfig \
     --expose=$HOME/.dotfiles/.bin/rust-shell-init=$HOME/.bin/rust-shell-init \
     --expose=$HOME/.dotfiles/.config/guix/rust-profile=$HOME/.profile \
     -- ~/.bin/rust-shell-init 
")
			     ("pydev" . "cd ~
guix shell --network --container --emulate-fhs \
     -m /home/callam/.dotfiles/.manifests/python_dev.scm \
     -m /home/callam/.dotfiles/.manifests/prog.scm \
     -m /home/callam/.dotfiles/.manifests/emacs.scm \
     --preserve='^DISPLAY$' \
     --share=$HOME/Projects/Python=$HOME \
     --expose=$HOME/.emacs.d/init.el=$HOME/.emacs.d/init.el \
     --expose=$HOME/.ssh=$HOME/.ssh \
     --expose=$HOME/.gnupg=$HOME/.gnupg \
     --expose=$HOME/.gitconfig=$HOME/.gitconfig \
     --expose=$HOME/.dotfiles/.bin/python-shell-init=$HOME/.bin/python-shell-init \
     --expose=$HOME/.dotfiles/.config/guix/python-profile=$HOME/.profile \
     -- ~/.bin/python-shell-init 
")
			     ))
                  ))
	;; setup ssh
	(service home-openssh-service-type
		 (home-openssh-configuration
		  (hosts
		   (list (openssh-host (name "raspberrypi")
				       (host-name "192.168.68.56")
				       (identity-file "~/.ssh/raspberrypi")
				       (user "callam"))
			 (openssh-host (name "basement")
				       (host-name "192.168.68.72")
				       (identity-file "~/.ssh/basement")
				       (user "callam")
				       (port 4444))))))
	
	;; gnupg
	(service home-gpg-agent-service-type
		 (home-gpg-agent-configuration
		  (pinentry-program
		   (file-append pinentry-emacs "/bin/pinentry-emacs"))
		  (ssh-support? #t)
		  (default-cache-ttl 28800)
		  (max-cache-ttl 28800)
		  (default-cache-ttl-ssh 28800)
		  (max-cache-ttl-ssh 28800)
		  (extra-content
		   "allow-emacs-pinentry
allow-loopback-pinentry")
		  ))

	;; Setup additional channels
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
		  (name 'cig-guix)
		  (url "https://github.com/callamgraham/cig-guix")
		  (branch "main")
		  (introduction
		   (make-channel-introduction
		    "ac662eaca8b75b91adbf685904d308a7f34c32c2"
		    (openpgp-fingerprint
		     "6DF3 6F47 6B7F 26E1 6861  5C2A 173B 393D E95E D1AE"))))
		 ))

	;; setup sway window manager
	(service home-sway-service-type
		 (sway-configuration
		  (variables `(
			       (mod . "Mod4") ; Window key as mod
			       (term . "alacritty") ; alacritty for terminal
			       (menu . "wofi --show drun -I | xargs swaymsg exec --")
			       (left . "h")
			       (right . "l")
			       (up . "j")
			       (down . "k")))
		  (inputs
		   (list (sway-input
			  (identifier '*)
			  (extra-content '("xkb_numlock enable")))
			 (sway-input
			  (identifier "5426:132:Razer_Razer_DeathAdder_V2")
			  (extra-content '("pointer_accel -0.6")))))
		  (outputs
		   (list
		    (sway-output
		     (identifier "DP-3")
		     (resolution "2560x1440")
		     (position (point (x 0) (y 0)))
		     (background "/home/callam/.dotfiles/.wallpaper/banff.jpg")
		     (extra-content '("adaptive_sync on")))
		    (sway-output
		     (identifier "HDMI-A-1")
		     (resolution "1920x1080")
		     (position (point (x 2560) (y 0)))
		     (background "/home/callam/.dotfiles/.wallpaper/banff.jpg"))
		    ))
		  (startup-programs '())
		  (startup+reload-programs '("/home/callam/.guix-home/profile/bin/waybar"))
		  (gestures '())
		  (keybindings `(
				 ($mod+Return . "exec $menu")
				 ($mod+Shift+q . "kill")
				 ($mod+t . "exec $term")
				 ($mod+Shift+c . "reload")
				 ($mod+Left . "focus left")
				 ($mod+Down . "focus down")
				 ($mod+Up . "focus up")
				 ($mod+Right . "focus right")
				 ($mod+Shift+Left . "move left")
				 ($mod+Shift+Down . "move down")
				 ($mod+Shift+Up . "move up")
				 ($mod+Shift+Right . "move right")
				 ($mod+1 . "workspace number 1")
				 ($mod+2 . "workspace number 2")
				 ($mod+3 . "workspace number 3")
				 ($mod+4 . "workspace number 4")
				 ($mod+5 . "workspace number 5")
				 ($mod+6 . "workspace number 6")
				 ($mod+7 . "workspace number 7")
				 ($mod+8 . "workspace number 8")
				 ($mod+9 . "workspace number 9")
				 ($mod+0 . "workspace number 10")
				 ($mod+Shift+1 . "move container to workspace number 1")
				 ($mod+Shift+2 . "move container to workspace number 2")
				 ($mod+Shift+3 . "move container to workspace number 3")
				 ($mod+Shift+4 . "move container to workspace number 4")
				 ($mod+Shift+5 . "move container to workspace number 5")
				 ($mod+Shift+6 . "move container to workspace number 6")
				 ($mod+Shift+7 . "move container to workspace number 7")
				 ($mod+Shift+8 . "move container to workspace number 8")
				 ($mod+Shift+9 . "move container to workspace number 9")
				 ($mod+Shift+0 . "move container to workspace number 10")
				 ($mod+b . "splith")
				 ($mod+v . "splitv")
				 ($mod+s . "layout stacking")
				 ($mod+w . "layout tabbed")
				 ($mod+e . "layout toggle split")
				 ($mod+f . "fullscreen")
				 ($mod+Shift+space . "floating toggle")
				 ($mod+space . "focus mode_toggle")
				 ($mod+a . "focus parent")
				 ($mod+Shift+minus . "move scratchpad")
				 ($mod+minus . "scratchpad show")
				 ))
		  (extra-content '("gaps inner 10"
				   "set $rm DP-3"
				   "set $lm HDMI-A-1"
				   "default_border pixel 2"
				   "workspace 1 output $rm"
				   "workspace 2 output $lm"
				   "workspace 3 output $lm"
				   "workspace 4 output $lm"
				   "workspace 5 output $lm"
				   "workspace 6 output $lm"
				   "workspace 7 output $lm"
				   "workspace 8 output $lm"
				   "workspace 9 output $lm"
				   "workspace 10 output $lm"
				   "exec --no-startup-id swaymsg 'workspace 2; exec /home/callam/.guix-home/profile/bin/alacritty'"
				   "exec --no-startup-id swaymsg 'workspace 3; exec /home/callam/.guix-home/profile/bin/emacs'"
				   "exec --no-startup-id swaymsg 'workspace 4; exec /home/callam/.guix-home/profile/bin/firefox'"
				   ))
		  ))
	
	;; setup env variables
	(simple-service 'some-useful-env-vars-service
			home-environment-variables-service-type
			`(("GUIX_SANDBOX_HOME" . "/extra/nvme1/sandbox") ;; used for nonguix containers
			  ("XDG_DATA_DIRS" . "$XDG_DATA_DIRS:/home/callam/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share/applications") ;; so wofi can launch flatpaks
			  ("EDITOR" . "emacsclient")
			  ("GUIX_LOCPATH" . "$HOME/.guix-home/profile/lib/locale")
			  ("PATH" . "$PATH:/home/callam/.bin:/home/callam/.emacs-profile/bin")
			  ;;("WLR_RENDERER" . "vulkan")
			  ("XDG_CURRENT_DESKTOP" . "sway")))
	 
	;; setup dotfiles - this is effecively gnu stow, will need to flesh this out...
	(service home-xdg-configuration-files-service-type		  
		  `(
		    ;; sway
		    ;; ("sway/config" ,(local-file "/home/callam/.dotfiles/.config/sway/config"))		    
		    
		    ;; helix
		    ("helix/config.toml" ,(local-file "/home/callam/.dotfiles/.config/helix/config.toml"))

		    ;; waybar
		    ("waybar/config" ,(local-file "/home/callam/.dotfiles/.config/waybar/config"))
		    ("waybar/style.css" ,(local-file "/home/callam/.dotfiles/.config/waybar/style.css"))
		    
		    ;; wofi
		    ("wofi/config" ,(local-file "/home/callam/.dotfiles/.config/wofi/config"))
		    ("wofi/style.css" ,(local-file "/home/callam/.dotfiles/.config/wofi/style.css"))

		    ;; xdg
		    ("user-dirs.dirs" ,(local-file "/home/callam/.dotfiles/.config/user-dirs.dirs"))
		    ("user-dirs.locale" ,(local-file "/home/callam/.dotfiles/.config/user-dirs.locale"))
		    ))

	 (service home-files-service-type
		  
		  `(
		    ;;(".tmux.conf" ,(local-file "/home/callam/.dotfiles/tmux.conf"))
		    (".gitconfig" ,(local-file "/home/callam/.dotfiles/gitconfig"))

		    ;; emacs
		    (".emacs.d/init.el" ,(local-file "/home/callam/.dotfiles/.emacs.d/init.el"))
		    (".emacs.d/etc/eshell/aliases" ,(local-file "/home/callam/.dotfiles/.emacs.d/eshell/aliases"))
		    ;; (".emacs.d/custom.el" ,(local-file "/home/callam/.dotfiles/.emacs.d/eshell/aliases")) ;; not sure i can do this with the custom file as its read only
		    ))
	 
	 
	 ))
 
 )
