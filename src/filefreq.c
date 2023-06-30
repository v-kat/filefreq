#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/fs.h>
#include <linux/path.h>
// #include <linux/segment.h>
#include <linux/uaccess.h>
#include <linux/buffer_head.h>
#define MODULE_NAME "filefreq"


MODULE_AUTHOR("Ivy");
MODULE_DESCRIPTION("filefreq module");
MODULE_LICENSE("Dual MIT/GPL");
MODULE_VERSION("0.1");

// cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies 
// 1900000 1800000 1600000

// lscpu -> then -min MHz

// 1000000

// need to loop over /sys/devices/system/cpu/cpu0 -> 15 can be hardcoded for loop
// for each file using a path -> open/write to the file

static int __init filefreq_init(void)
{
    printk(KERN_INFO "filefreq world!\n");

    // struct path {
    //   struct vfsmount *mnt;
    //   struct dentry *dentry;
    // };
    // extern void path_get(struct path *);

    // Set the current segment to KERNEL_DS (kernel data segment)
    // unsigned long oldfs = get_fs();

    // set_fs(KERNEL_DS);

    // // Write to the file
    // // struct file *file, const char *data, size_t len, loff_t *pos

    // pos is a pointer to current file location
    // int err;

    // Get the path struct for the file
    // err = kern_path(path, flags, &file_path);
    // if (err)
    //     return ERR_PTR(err);

    // Open the file
    // const char *path, int flags, int mode
    // filp = filp_open(file_path.mnt, file_path.dentry, flags, mode);

    // struct path file_path;

    // by default the system has 1900000 1800000 1600000 
    //    in the /sys/devices/system/cpu/cpu*/cpufreq/scaling_available_frequencies  files
    
    for (int i = 0; i < 16; i++) 
    {
      struct file *filp;
      ssize_t ret;
      char lameBuffer[128] = "";
      size_t lenBuffer = strlen(lameBuffer);
      const char *lowMhz = " 1000000"; // adding 1 ghz to downscale more default the system has is 1900000 1800000 1600000 
      size_t lenLowMhz = strlen(lowMhz);
      loff_t pos;
      int num_chars;
      
      printk(KERN_INFO "filefreq starting the loop \n");
      num_chars = snprintk(lameBuffer, lenBuffer, "/sys/devices/system/cpu/cpu%d/cpufreq/scaling_available_frequencies\0", i);
      if (num_chars > sizeof(lameBuffer) - lenBuffer) // doesn't handle buffer things too well....
      {    
        printk(KERN_ERR "filefreq buffer was too small for freqFilePath \n");
        return -1;
      }

      printk(KERN_INFO "filefreq before opening file \n");
      filp = filp_open(lameBuffer, O_WRONLY, 0644);
      if (IS_ERR(filp))
      {  
        printk(KERN_ERR "filefreq failed to open file %s \n", num_chars);
        return -1;
      }

      pos = vfs_llseek(filp, 0, SEEK_END); // how much to offset from the file

      ret = kernel_write(filp, lowMhz, lenLowMhz, &pos);
      if (ret < 0) 
      {
        printk(KERN_ERR "filefreq failed to write to file %s \n", lameBuffer);
        return ret;
      }

    printk(KERN_INFO "filefreq before the last return \n");
    }
    return 0;
}
static void __exit filefreq_cleanup(void) {
    printk(KERN_INFO "filefreq bye world!\n");
}
module_init(filefreq_init);
module_exit(filefreq_cleanup);
