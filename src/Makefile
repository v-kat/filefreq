obj-m += filefreq.o
# CFLAGS_module.o := -DDEBUG

KDIR = $(KERNEL)/lib/modules/$(KERNEL_VERSION)/build

all:
	make -C $(KDIR) M=$(PWD) modules

clean:
	make -C $(KDIR) M=$(PWD) clean
