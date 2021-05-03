#ifndef _CONNECTION_H
#define _CONNECTION_H

#include <string>

#include <grpc++/grpc++.h>
using grpc::Channel;
using grpc::ClientContext;
using grpc::Status;

class Connection {
	public:
		// Constuctor that sets up initial connection with the MinION
		// mk_host: Host address of the MinKNOW to connect to
		// mk_port: Port of MinKNOW to connect to
		Connection(std::string mk_host="127.0.0.1", int mk_port=8000, int verbose=0){
			host = mk_host;
			port = mk_port;
	
			// Creating channel arguments that set the max send and recieve message sizes
			int max_send_receive_size = 16 * 1024 * 1024;
			if(verbose) std::cerr << "Setting the max send and receive size to be: " << max_send_receive_size << std::endl;
			grpc::ChannelArguments* channel_args = new grpc::ChannelArguments();
			channel_args->SetMaxReceiveMessageSize(max_send_receive_size);
			channel_args->SetMaxSendMessageSize(max_send_receive_size);

			std::string target = host + ":" + std::to_string(port);
            std::cerr << "Connecting on: " << target << std::endl;

			// Create channel to connect to
			channel = grpc::CreateCustomChannel(target, grpc::InsecureChannelCredentials(), *channel_args);
		}

		// Function to get created channel
		// Returns the channel
		std::shared_ptr<Channel> get_channel(){
			return channel;
		}

	private:
		std::string host;
		int port;
		std::shared_ptr<Channel> channel;
};

#endif
