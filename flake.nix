{
  inputs = {
  # TODO remove again
    naersk.url = "github:nix-community/naersk/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    kernelFlake.url = "github:jordanisaacs/kernel-module-flake";
  };

  # inputs.kernelFlake.inputs.nixpkgs.follows = "nixpkgs";
  # tried above to fix buildLib

  # TODO remove again
  outputs = { self, naersk, nixpkgs, utils, kernelFlake }:
  # outputs = { self, nixpkgs, utils, kernelFlake }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        kernel = pkgs.kernel;
        # systemTypeSupported = "x86_64-linux";
        # pkgs = import nixpkgs { system = systemTypeSupported; };
        # kFlake = import kernelFlake;
        # buildLib = kernelFlake.lib.builders {inherit pkgs;};
        # buildLib = (builtins.getFlake "github:jordanisaacs/kernel-module-flake").outputs.lib.builders; # kinda worked
        buildLib = kernel.outputs.lib.builders; # kinda worked
     #    # TODO remove again
     #    naersk-lib = pkgs.callPackage naersk { };

        packageName = "rust-cpufreq";
     #    # default = true; # weird error
     #    # nixosModules.default = {};
     #    # both didn't fix default option doesn't exist
        
        kernelFlake.enableBPF = false;
        kernelFlake.enableEditor = false;
        kernelFlake.enableGdb = false;
        kernelFlake.useRustForLinux = true;

     #    # used in fail derivation
        sysKernel = kernel.dev;
        kernelVersion = sysKernel.modDirVersion;

        kernelLib = kernelFlake.lib.builders {inherit pkgs;};

     #    # buildLib = pkgs.callPackage ./build {};

     #    # TODO was last trying below for some reason
     #    # rust-kernel-lib = pkgs.callPackage kernelFlake { };

     #    ## TODO put this back in?
        buildRustModule = kernelLib.buildRustModule {inherit builtKernel;};

     #    ################################################################
     #    ################################################################
     #    # TODO can probably just use https://github.com/Rust-for-Linux/rust-out-of-tree-module
     #    ## can toss this out and not bother with a flake and just do thang
     #    ## still don't understand flake outputs and stuff
     #    ## this flake is using the above and some other stuff I don't want

     #    ## remove naersk again 
     #    ## see about including kernel and buildRustModule
     #    ## understand defaultPackage stuff
     #    ## put in runQemu and also maybe get rid of flake utils
     #    ## check chatgpt for eachDefaultSystem
     #    ############################################################### 
     #    ############################################################### 

     #    # kernelLib = kernelFlake.lib.builders {inherit pkgs;};

     # #    system = "x86_64-system";
     # # pkgs2 = nixpkgs.legacyPackages.${system};

     # # kernelFlake' = pkgs.callPackage kernelFlake {};
     # # builtins.trace kernelFlake true;


     # # buildLib = kernelFlake.lib.builders {inherit pkgs;};

     #    # buildLib = kernelFlake.outputs.lib.builders;

     #    configfile = buildLib.buildKernelConfig {
     #      generateConfigFlags = {};
     #      structuredExtraConfig = {};

     #      inherit kernel nixpkgs;
     #    };

     #    kernel = buildLib.buildKernel {
     #     inherit configfile;

     #     src = ./linux;
     #     version = "";
     #     modDirVersion = "";
     #    };

     #    buildRustModule = buildLib.buildRustModule {inherit kernel;};
     #    # cpuFileFreqModule = kernelLib.buildRustModule { 
     #    # kernelFlake.rustModule = {}; 
     #    cpuFileFreqModule = buildLib.buildRustModule { 
     #      name = packageName; 
     #      src = ./.; 
     #    };

     #     modules = [exampleModule];

     #     initramfs = buildLib.buildInitramfs {
     #       inherit kernel modules;
     #     };

     #     exampleModule = cpuFileFreqModule;

     #     runQemu = buildLib.buildQemuCmd {inherit kernel initramfs;};
         # ^ this might be a package

        # cpuFileFreqModule = rust-kernel-lib.buildRustModule { name = "rust-cpufreq"; src = ./.; };

        # cpuFileFreqModule = pkgs.callPackage buildLib.buildRustModule { name = "rust-cpufreq"; src = ./.; };
        # cpuFileFreqModule = kernelFlake.lib.builders.buildRustModule { name = "rust-cpufreq"; src = ./.; };

        # inputs.nixpkgs.follows = "dwarffs/nixpkgs"

        # system = "x86_64-system";
        # pkgs = nixpkgs.legacyPackages.${system};

        # kernelLib = kernelFlake.lib.builders {inherit pkgs;};

        # buildRustModule = buildLib.buildRustModule {inherit builtKernel;};
        # buildCModule = buildLib.buildCModule {inherit builtKernel;};

        configfile = buildLib.buildKernelConfig {
         generateConfigFlags = {};
         structuredExtraConfig = {};

         inherit builtKernel nixpkgs;
        };

        builtKernel = buildLib.buildKernel {
         inherit configfile;

         src = ./kernel-src;
         version = "";
         modDirVersion = "";
        };

        modules = [cpuFileFreqModule];

        initramfs = buildLib.buildInitramfs {
         inherit builtKernel modules;
        };

        cpuFileFreqModule = buildRustModule { name = "cpu-file-freq-module"; src = ./src.; };

        runQemu = buildLib.buildQemuCmd {inherit builtKernel initramfs;};
        runGdb = buildLib.buildGdbCmd {inherit builtKernel modules;};
      in
      {
        # want first one and no naersk
        # defaultPackage = cpuFileFreqModule;

        # packages.x86_64-linux.hello = runQemu;
        # packages.${packageName} = cpuFileFreqModule;

        devShell = pkgs.mkShell {
          inputsFrom = builtins.attrValues self.packages.${system};
          # run-qemu might be a package 
            # buildQemuCmd = pkgs.callPackage ./run-qemu.nix {};

          buildInputs = [ pkgs.cargo pkgs.rust-analyzer pkgs.clippy ];
        };

        # defaultPackage = naersk-lib.buildPackage ./.;
        defaultPackage = pkgs.stdenv.mkDerivation {
          name = "rust-cpufreq";
          # src = "/home/abysm/kernel-module-flake";
          # src = "/home/abysm/rust-cpufreq";
          src = ./src;
          # src = "./rust-cpufreq";
          # src = "./src";

          buildPhase = ''
          '';
          # unpackPhase = "true"; # this is needed for source code to be included

            # pwd
            # ls -lah
            # cd ..
            # ls -lah
            # pwd
            # cd /tmp
            # ls -lah
            # pwd
            # cd ..
            # cd /bin
            # ls -lah
            # pwd
            # cd ..
            # cd /dev
            # ls -lah
            # pwd
            # cd ..
            # cd /nix
            # ls -lah
            # pwd
            # cd ..

            # runHook preInstall
          # todo move 6.3.5 to variable like https://blog.prag.dev/building-kernel-modules-on-nixos
          installPhase = ''
            mkdir -p $out/lib/modules/$kernelVersion/misc
            pwd
            ls -lah
            echo $out

            cp ./rust_out_of_tree.ko $out/lib/modules/$kernelVersion/misc
            ls -lah $out/lib/modules/$kernelVersion/misc
          '';
          # https://nixos.org/manual/nixpkgs/stable/#sec-stdenv-phases
          # above just makes a local version and not the system one....

              # cp $x $out/lib/modules/$kernelVersion/misc/
            # mkdir -p $out/lib/modules/$kernelVersion/misc

          # tried to hackily copy in a bin to root....


              # nuke-refs $x
            # runHook postInstall
            # cp ./rust_out_of_tree.ko $out/lib/modules/$kernelVersion/misc/
          meta.platforms = ["x86_64-linux"];
        };
        # defaultPackage = self.packages.${systemTypeSupported}.${packageName};
        # call package instantiates and returns the package
        

        # defaultPackage.${systemTypeSupported} = ./;
        # defaultPackage.${systemTypeSupported} = cpuFileFreqModule;
        # defaultPackage.${systemTypeSupported} = {};


        # devShell = with pkgs; mkShell {
        #   buildInputs = [ cargo rustc rustfmt pre-commit rustPackages.clippy 
        #     # cdk
        #     # flex
        #     # bison
        #     # openssl
        #     # linuxKernel.packages.linux_zen.system76
        #     # libelf
        #     # libiberty
        #     # autoconf

        #     # qemu_full
        #     # libvirt
        #     # bridge-utils
        #     # gdb
        #     # gdbgui
        #     # pahole

        #     # llvm
        #     # lld
        #     # libclang
        #   ];
        #   RUST_SRC_PATH = rustPlatform.rustLibSrc;
        # };
      }); # for utils
      # }; # for simpl let
}
