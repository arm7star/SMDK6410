# Introduction
SMDK6410 μCOS-III V3.02.00.

# μC/OS-III

μC/OS-III (pronounced “Micro C O S Three) is a scalable, ROMable, preemptive real-time kernel that manages an unlimited number of tasks. μC/OS-III is a third-generation kernel and offers all of the services expected from a modern real-time kernel, such as resource management, synchronization, inter-task communications, and more. However, μC/OS-III offers many unique features not found in other real-time kernels, such as the ability to complete performance measurements at run-time, to directly signal or send messages to tasks, achieve pending on multiple kernel objects, and more.

# Toolchain
## linux
gcc-arm-none-eabi-4_9-2015q3-20150921-linux
## Cygwin
Cygwin gcc-arm-none-eabi-4_9-2015q3-20150921-win32 make.exe

# Clean
make clean; make distclean; make clobber

# Build
make all

# Run
Load SMDK6410.axf to SDRAM address 0x5000000 with jtag.  
gdb> file SMDK6410.axf  
gdb> load  
gdb> run  

```
App_TaskStart: 0
App_TaskStart: 1
App_TaskStart: 2
App_TaskStart: 3
App_TaskStart: 4
```
