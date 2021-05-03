# MinNO

Automatically stop an [Oxford Nanopore MinION sequencing device](https://nanoporetech.com/products/minion-comparison) after a specific amount of data has been collected in an experiment. 
This can be useful for extending the life of the consumable [flow cell](https://store.nanoporetech.com/flowcells/spoton-flow-cell-mk-i-r9-4.html) when it will be reused for multiple experiments (e.g. with [different barcodes on the next samples](https://store.nanoporetech.com/catalog/product/view/id/508/s/rapid-barcoding-kit-96/category/28/)).

# Quick start

1. Download the prebuilt executable for Windows from [releases page](https://github.com/nodrogluap/MinNO/releases) and place it in C:\Windows.

2. Start your experiment using MinKNOW as per usual. Let's say you are writing the experiment output data to D:\data\. Once the experiment is running, open a Windows command prompt and start MinNO, in this case, stopping after 5 billion bases have been generated:


```
MinNO 5e9 D:\data\reads\experiment_name\fastq\pass
```

# Compiling from source

This code has only been tested on Windows, and requires that you have [Visual Studio 14 / 2015](https://visualstudio.microsoft.com/vs/older-downloads/), otherwise you may need to tinker with the paths in the batch file.

```
git clone --recurse-submodules https://github.com/nodrogluap/OpenDBA/
cd MinNO
all_build.bat
make MinNO.exe
```
