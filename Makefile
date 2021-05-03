#----General Definitions----#

#----Compilers----#

NVCC= nvcc

#----Compiler Flags----#

ARCH= -arch=sm_60
OPT= -O3
VERBOSE=-lineinfo --ptxas-options=-v
VERBOSE=
DEBUG=-g
CUDA_DEBUG=-G

#----Directories----#

DIR := ${CURDIR}
INCLUDE=./include
MINKNOW=include/minknow_api

#----ont flags----#

GRPC_FILES=$(MINKNOW)/acquisition.grpc.pb.cc $(MINKNOW)/acquisition.pb.cc $(MINKNOW)/analysis_configuration.grpc.pb.cc $(MINKNOW)/analysis_configuration.pb.cc $(MINKNOW)/data.grpc.pb.cc $(MINKNOW)/data.pb.cc $(MINKNOW)/device.grpc.pb.cc $(MINKNOW)/device.pb.cc $(MINKNOW)/instance.grpc.pb.cc $(MINKNOW)/instance.pb.cc $(MINKNOW)/keystore.grpc.pb.cc $(MINKNOW)/keystore.pb.cc $(MINKNOW)/log.grpc.pb.cc $(MINKNOW)/log.pb.cc $(MINKNOW)/manager.grpc.pb.cc $(MINKNOW)/manager.pb.cc $(MINKNOW)/minion_device.grpc.pb.cc $(MINKNOW)/minion_device.pb.cc $(MINKNOW)/promethion_device.grpc.pb.cc $(MINKNOW)/promethion_device.pb.cc $(MINKNOW)/protocol.grpc.pb.cc $(MINKNOW)/protocol.pb.cc $(MINKNOW)/rpc_options.pb.cc $(MINKNOW)/statistics.grpc.pb.cc $(MINKNOW)/statistics.pb.cc

#----Windows----#

#----Include Directories----#

INCLUDE_GRPC_WIN=submodules/grpc/include
INCLUDE_GOOGLE_WIN=submodules/grpc/third_party/protobuf/src

GRPC_LIB_WIN=submodules/grpc/bin/grpc/release
PROTO_LIB_WIN=submodules/grpc/bin/protobuf/release
EAY_LIB_WIN=submodules/grpc/bin/dependencies
ZLIB_LIB_WIN=submodules/grpc/bin/zlib/release/lib
WINDOW_LIB="C:\Program Files (x86)\Windows Kits\10\Lib\10.0.17763.0\um\x64"

#----Include Flags----#

GRPC_FLAGS_WIN=-lgpr -lgrpc++ -lgrpc
PROTO_FLAGS_WIN=-llibprotoc -llibprotobuf
EAY_FLAGS_WIN=-llibeay32 -lssleay32
ZLIB_FLAGS_WIN=-lzlib
WINDOW_FLAGS=-lWSock32 -lWS2_32 -lGdi32 -lUser32

#----make objects for windows----#

MinNO.exe: MinNO.c Connection.h
	$(NVCC) -I. -I$(INCLUDE) -I$(INCLUDE_GRPC_WIN) -I$(INCLUDE_GOOGLE_WIN) -D_WIN32_WINNT=0x0600 $(GRPC_FILES) MinNO.cu -o MinNO.exe -L$(GRPC_LIB_WIN) $(GRPC_FLAGS_WIN) -L$(PROTO_LIB_WIN) $(PROTO_FLAGS_WIN) -L$(EAY_LIB_WIN) $(EAY_FLAGS_WIN) -L$(ZLIB_LIB_WIN) $(ZLIB_FLAGS_WIN) -L$(WINDOW_LIB) $(WINDOW_FLAGS)
