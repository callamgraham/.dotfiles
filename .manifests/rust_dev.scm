(specifications->manifest
 '(
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

   ;; for cross compiling
   "gcc-cross-x86_64-w64-mingw32-toolchain"
   "docker"
   "docker-cli"
   "rust-gcc" ;;?? not sure if I need this?
   ))
