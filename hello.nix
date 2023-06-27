# { stdenv }:

# {
#   stdenv,
#   # lib,
#   # perl,
#   # gmp,
#   # libmpc,
#   # mpfr,
#   # bison,
#   # flex,
#   # pahole,
#   # buildPackages,
#   # rustPlatform,
#   # rustc,
#   # rustfmt,
#   # cargo,
#   # rust-bindgen,
# }: {
#   nixpkgs,
#   kernel,
#   # generate-config.pl flags. see below
#   # generateConfigFlags,
#   # structuredExtraConfig,
#   # enableRust ? false,
# }: 

let
  pkgs = import <nixpkgs> {};
  # kernel = pkgs.linux; # gave 6.3.4 not 6.3.8 for some reason
  # kdir = "${kernel.modDirVersion}";

in
  pkgs.stdenv.mkDerivation {
    pname = "my-hello";
    version = "1.0";
    src = ./src;
    hardeningDisable = [ "pic" "format" ];                                             # 1
    # linuxDev = pkgs.linuxPackagesFor kernelDrv;
    # kernel = linuxDev.kernel;                      # 2
    # nativeBuildInputs = kernel.moduleBuildDependencies;                       # 2
    nativeBuildInputs = pkgs.linux.moduleBuildDependencies; 


  # makeFlags = [
  #   "KERNELRELEASE=${kernel.modDirVersion}"                                 # 3
  #   "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"    # 4
  #   "INSTALL_MOD_PATH=$(out)"                                               # 5
  # ];

    # TODO - make another rust_out_of_tree with explicitly code 6.3.8
    # make sure can use sudo insmod on that 1


    buildPhase = ''
    '';
    # builder = ;
    installPhase = ''
      mkdir -p $out/lib/modules/6.3.8/misc
      pwd
      ls -lah
      echo "6.3.8/laaahh"

      ls -lah $out/lib/modules/6.3.8/misc
      pwd
      # echo $out
      cp ./rust_out_of_tree.ko $out/lib/modules/6.3.8/misc
    '';
    # shellHook = ''
    #   echo "hi again"
    # '';
      # echo "hi test"
    # args = [ ./message.txt ];
  }