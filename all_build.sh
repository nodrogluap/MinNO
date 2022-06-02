#!/bin/bash

PREFIX_PATH=`pwd`/bin/
if [ "$1" != "" ]; then
	PREFIX_PATH=$1
fi
echo "Libraries will be built to: ${PREFIX_PATH}"
echo "Building grpc libraries:"
cd submodules/grpc
git submodule update --init
make HAS_SYSTEM_OPENSSL_ALPN=false
cp -R bins ../bin/
prefix=../bin make install
cd ../bin/lib
ln -s libgrpc++.so libgrpc++.so.1
echo "grpc libraries built! Remember to add the installation direcory to your path!"
echo "Building protobuf libraries"
cd ../../grpc/third_party/protobuf
./configure --prefix=`pwd`/../../../bin
make
make check
make install
echo "protobuf libraries built!"
cd ../../../
echo "Building *.pb.cc andd *.pb.h files using *.proto files:"
# Old directories for building grpc libraries commented out
#./bin/opt/protobuf/protoc -I include/minknow/rpc/ -I grpc/third_party/protobuf/src/ --grpc_out=include/minknow/rpc/ --plugin=protoc-gen-grpc=bin/opt/grpc_cpp_plugin include/minknow/rpc/*.proto
mkdir -p ../include/
./bin/opt/protobuf/protoc -I minknow_api/proto/ -I grpc/third_party/protobuf/src/ --grpc_out=../include/ --plugin=protoc-gen-grpc=bin/bin/grpc_cpp_plugin minknow_api/proto/minknow_api/*.proto
# Old directories for building grpc libraries commented out
#./bin/opt/protobuf/protoc -I include/minknow/rpc/ -I grpc/third_party/protobuf/src/ --cpp_out=include/minknow/rpc/ include/minknow/rpc/*.proto
./bin/opt/protobuf/protoc -I minknow_api/proto/ -I grpc/third_party/protobuf/src/ --cpp_out=../include/ minknow_api/proto/minknow_api/*.proto
echo "Build complete!"
