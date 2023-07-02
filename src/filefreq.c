#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/fs.h>
#define MODULE_NAME "filefreq"


MODULE_AUTHOR("Ivy");
MODULE_DESCRIPTION("filefreq module");
MODULE_LICENSE("Dual MIT/GPL");
MODULE_VERSION("0.1");

// cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies 
// 1900000 1800000 1600000

// load with -> sudo insmod /run/current-system/kernel-modules/lib/modules/*/misc/filefreq.ko
// in configuration.nix -> boot.extraModulePackages = [ filefreq ];
//    -> filefreq = config.boot.kernelPackages.callPackage /cloned-dir/filefreq.nix {};

static int __init filefreq_init(void)
{
    printk(KERN_INFO "filefreq was inited correctly\n");
    // todo check this 16 for number of cores somehow instead in future
    for (int i = 0; i < 16; i++) 
    {
      struct file *filp;
      ssize_t ret;
      char lameBuffer[128] = "";
      const char *lowMhz = "1000000\n"; // adding 1 ghz to downscale more than the 1600000 default 
      size_t lenLowMhz = strlen(lowMhz);
      
      sprintf(lameBuffer, "/sys/devices/system/cpu/cpu%d/cpufreq/scaling_setspeed", i); // on without userspace governer just gets overriden back
      printk(KERN_INFO "filefreq modifying %s \n", lameBuffer);

      printk(KERN_INFO "filefreq before opening file \n");
      filp = filp_open(lameBuffer, O_TRUNC | O_RDWR | O_CREAT, 0744);
      if (IS_ERR(filp))
      {  
        printk(KERN_ERR "filefreq failed to open file %s with err: %ld \n", lameBuffer, PTR_ERR(filp));
        return -1;
      }

      ret = kernel_write(filp, lowMhz, lenLowMhz, &filp->f_pos);
      if (ret < 0) 
      {
        printk(KERN_ERR "filefreq failed to write to file %s with ret %zu \n", lameBuffer, ret);
        return ret;
      }
    }

    printk(KERN_INFO "filefreq seems to have successfully run \n");
    return 0;
}
static void __exit filefreq_cleanup(void) {
    printk(KERN_INFO "filefreq was unloaded successfully\n");
}
module_init(filefreq_init);
module_exit(filefreq_cleanup);
