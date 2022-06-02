# MinNO

Automatically stop an [Oxford Nanopore MinION sequencing device](https://nanoporetech.com/products/minion-comparison) after a specific amount of data has been collected in an experiment. 
This can be useful for extending the life of the consumable [flow cell](https://store.nanoporetech.com/flowcells/spoton-flow-cell-mk-i-r9-4.html) when it will be reused for multiple experiments (e.g. with [different barcodes on the next samples](https://store.nanoporetech.com/catalog/product/view/id/508/s/rapid-barcoding-kit-96/category/28/)).

# Quick start

1. Download the prebuilt ``MinNO.exe`` executable for Windows from [releases page](https://github.com/nodrogluap/MinNO/releases) and place it on the desktop.

2. Start your experiment using MinKNOW as per usual, with live base calling enabled. Suppose you are writing the experiment output data to D:\data. Once the experiment is running, Shift+Right click on the desktop, and choose the "Open PowerShell window here" option (or "Open command window here" depending on the Windows version). Start MinNO by typing the following at the command prompt (in this case, stopping after 2 billion bases have been generated):

```
.\minno 2e9 D:\data\reads\experiment_name\fastq\pass
```

3. The sequencing will automatically stop after 2 billion bases have been called.

# Compiling from source

This code has only been tested on Windows, and requires that you have [Visual Studio 14 / 2015](https://visualstudio.microsoft.com/vs/older-downloads/) and the NVIDIA C++ compiler, otherwise you may need to tinker with the paths in the batch file.

```
git clone --recurse-submodules https://github.com/nodrogluap/MinNO
cd MinNO
all_build.bat
make MinNO.exe
```

For a Linux build, similarly (requires that you have automake+autoconf+libtool pre-installed, e.g. via the system package manager or conda):

```
git clone --recurse-submodules https://github.com/nodrogluap/MinNO
cd MinNO
sh all_build.sh
make MinNO
```
