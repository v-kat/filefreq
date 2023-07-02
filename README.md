## NixOS Filefreq - out of tree kernel module derivation

### How to Install
* clone the repository (`git clone git@github.com:v-kat/filefreq.git`) and place the following on top of your `configuration.nix`:
```nix
filefreq = config.boot.kernelPackages.callPackage /cloned-directory/filefreq/filefreq.nix {};
```
* In your `configuration.nix` place 
```nix
boot.extraModulePackages = [ filefreq ];
```
* rebuild and switch `sudo nixos-rebuild switch` then `sudo insmod /run/current-system/kernel-modules/lib/modules/*/misc/filefreq.ko`
* check that the module loads `dmesg | grep "filefreq"`
* Might need your cpufreq governor set to "userspace"
* This assumes 8 cores and I might go back and modify the code. For now you can modify the 16 in a for loop to change it
* Also just settings min to 1GHz to down throttle but ran into architecture support with modifying "scaling_available_frequencies"

### About
* Was trying to learn more about nix. Initially tried a kernel flake library https://github.com/jordanisaacs/kernel-module-flake as a builder but was hard to keep it in sync with local kernel version and settings. 
* I also wanted to use rust but out of tree kernel module documentation for 6.3 and 6.4 isn't good or really existent.
* Might look at the acpi cpufreq driver in the future to see about adding more than 3 frequencies and other changes. 
