(specifications->manifest
 '(
   "bash"
   "clang"
   "openssh"
   "coreutils"
   "curl"
   "grep"
   "nss-certs"        ;internet access
   "gcc-objc:lib"
   "gcc-toolchain"
   "pkg-config"
   "glib"
   "glibc:static"
   "git"
   "rust-gcc"
   "sqlite"

   ;; for gui apps
   "libx11"
   "libxcursor"
   "libxrandr"
   "libxi"
   "libxcb"
   "mesa"  ; needed for egui
   "xf86-video-amdgpu"
   "amdgpu-firmware"
   "mesa-opencl"
   
   ;; fonts/icons
   "font-adobe-source-code-pro"
   "font-awesome"
   "font-jetbrains-mono"
   ))
