#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/fs.h>
// #include <linux/path.h>
// #include <linux/mount.h>
// #include <linux/segment.h>
// #include <linux/uaccess.h>
// #include <linux/buffer_head.h>
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
    printk(KERN_INFO "filefreq was inited correctly\n");

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
    
    // for (int i = 0; i < 1; i++) 
    for (int i = 0; i < 16; i++) 
    {
      struct file *filp;
      ssize_t ret;
      char lameBuffer[128] = "";
      // const char *lowMhz = " 1000000"; // adding 1 ghz to downscale more default the system has is 1900000 1800000 1600000 
      const char *lowMhz = "1000000\n"; // adding 1 ghz to downscale more than the 1600000 default 
      size_t lenLowMhz = strlen(lowMhz);
      // loff_t pos;
      
      // sprintf(lameBuffer, "/sys/devices/system/cpu/cpu%d/cpufreq/scaling_available_frequencies", i);
      sprintf(lameBuffer, "/sys/devices/system/cpu/cpu%d/cpufreq/scaling_min_freq", i);
      printk(KERN_INFO "filefreq modifying %s \n", lameBuffer);

      // filp = filp_open(lameBuffer, O_RDONLY, 444);
      // filp = filp_open("/home/abysm/rust-cpufreq/zah/blahhh.txt", O_RDONLY, 0644);
      // if (IS_ERR(filp))
      // {  
      //   printk(KERN_ERR "filefreq file probably doesnt exist %s with err: %ld \n", lameBuffer, PTR_ERR(filp));
      //   return -1;
      // }


      printk(KERN_INFO "filefreq before opening file \n");
      // filp = filp_open(lameBuffer, O_WRONLY | O_CREAT, 0644);

      // vfs_mkdir("/home/abysm/rust-cpufreq/zzz", 0644);
      // if (err) {
      //   // Error occurred while creating the directory
      //   return err;
      // }

      // if the directory doesn't exist it's a -2 despite O_creat
        // can try to fix above with nt vfs_mkdir(char *path, mode_t mode); but might get weird
        // might need recurisve stuff but can test in different path then try.
        // need to figure out if /sys/devices/system is even there... -> can do that as an attempt
      // if the directory is there it's a -13 because of not root but then on stage 2 -2


      // filp = filp_open("/home/abysm/rust-cpufreq/zah/blahhh.txt", O_RDWR | O_CREAT, 0644);
      // filp = filp_open("/home/abysm/rust-cpufreq/zzz/blahhh.txt", O_RDWR | O_CREAT, 0644);
      // need to find out how to create directory recursively
      
      // struct path result;
      // kern_path(lameBuffer, LOOKUP_FOLLOW, &result);
      // struct vfsmount *mnt; // https://android.googlesource.com/kernel/common/+/a9ed4a6560b8/kernel/usermode_driver.c
      // file = file_open_root(mnt->mnt_root, mnt, name, O_CREAT | O_WRONLY, 0777);
      
      // // filp = file_open_root(path, O_RDWR | O_CREAT, 0644);
      // filp = file_open_root(lameBuffer, O_RDWR | O_CREAT, 0700);

      // maybe vfs_mkdir

      // O_DIRECTORY doesn't exist and so doesn't mkdir and so doesn't kmkdir
      // filp = filp_open("/home/abysm/rust-cpufreq/bahhh/text.txt", O_DIRECTORY | O_RDWR | O_CREAT, 0744);
      // filp = filp_open(lameBuffer, O_RDWR | O_CREAT, 0744);
      // filp = filp_open("/home/abysm/rust-cpufreq/text.txt", O_TRUNC | O_RDWR | O_CREAT, 0744); // scaling_min_freq with 0744 returns -9 error code till added O_RDWR
      filp = filp_open(lameBuffer, O_TRUNC | O_RDWR | O_CREAT, 0744); // scaling_min_freq with 0744 returns -9 error code
      if (IS_ERR(filp))
      {  
        // printk(KERN_ERR "filefreq failed to open file %s with err: %ld \n", "/home/abysm/rust-cpufreq/zah/blahhh.txt", PTR_ERR(filp));
        printk(KERN_ERR "filefreq failed to open file %s with err: %ld \n", lameBuffer, PTR_ERR(filp));
        // printk(KERN_ERR "filefreq failed to open file %s with err: %l"/home/abysm/rust-cpufreq/zah/blahhh.txt"d \n", lameBuffer, PTR_ERR(filp));
        return -1;
      }

      // pos = vfs_llseek(filp, 0, SEEK_END); // how much to offset from the file

      ret = kernel_write(filp, lowMhz, lenLowMhz,  &filp->f_pos);
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


// [   18.577263] filefreq was inited correctly
// [   18.577264] filefreq modifying /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq 
// [   18.577265] filefreq before opening file 
// [   18.577271] filefreq failed to open file /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq with err: -2

// guess need to look up directories and what's there system cpu cpufreq
