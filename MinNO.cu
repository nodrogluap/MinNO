#if defined(_WIN32)
	#include <conio.h>
	#include <windows.h>
	extern "C"{
		#include "getopt.h"
	}
	#include <direct.h>
	#define GetCurrentDir _getcwd
	#define sleep(x) Sleep(1000 * (x))
	#define FILE_SEPARATOR "\\"
#else
	#include <unistd.h>
	#define GetCurrentDir getcwd
	#define FILE_SEPARATOR "/"
#endif

#include <string>
#include <iostream>
#include <sstream>
#include <dirent.h>
#include <sys/types.h>
#include <fstream>

#include <sys/stat.h>

#include "Connection.h"

#include "include/minknow_api/acquisition.grpc.pb.h"
#include "include/minknow_api/analysis_configuration.grpc.pb.h"
#include "include/minknow_api/data.grpc.pb.h"
#include "include/minknow_api/device.grpc.pb.h"
#include "include/minknow_api/instance.grpc.pb.h"
#include "include/minknow_api/keystore.grpc.pb.h"
#include "include/minknow_api/log.grpc.pb.h"
#include "include/minknow_api/manager.grpc.pb.h"
#include "include/minknow_api/minion_device.grpc.pb.h"
#include "include/minknow_api/promethion_device.grpc.pb.h"
#include "include/minknow_api/protocol.grpc.pb.h"
#include "include/minknow_api/statistics.grpc.pb.h"

using namespace minknow_api::acquisition;
using namespace minknow_api::analysis_configuration;
using namespace minknow_api::data;
using namespace minknow_api::device;
using namespace minknow_api::instance;
using namespace minknow_api::keystore;
using namespace minknow_api::log;
using namespace minknow_api::manager;
using namespace minknow_api::minion_device;
using namespace minknow_api::promethion_device;
using namespace minknow_api::protocol;
using namespace minknow_api::statistics;

int main(int argc, char** argv) {
	
	std::string host = "localhost"; // Default minknow host
	int port = 8000; // Default minknow port
	
	int wait_time = 60;
	
	int verbose = 0;
	int help = 0;
	
	char c;
	
	while( ( c = getopt (argc, argv, "P:H:w:vh") ) != -1 ) {
		switch(c) {		
			case 'P':
				if(optarg) port = atoi(optarg);
				break;
			case 'H':
				if(optarg) host = optarg;
				break;
			case 'w':
				if(optarg) wait_time = atoi(optarg);
				break;
			case 'v':
				verbose = 1;
				break;
			case 'h':
				help = 1;
				break;	
			default:
				/* You won't actually get here. */
				break;
		}
	}
	
	int num_args = argc - optind;
	if (help || num_args != 2){
		std::cerr << "Usage: " << argv[0] << " [options] <amount_of_data> <fastq_directory>" << std::endl
			<< "Client that keeps track of the amount of data read in by a MinKNOW device from a given directory and stops the run once the required amount has been reached." << std::endl
			<< "amount_of_data is the amount of data you want MinKNOW to read in before ending the run." << std::endl
			<< "fastq_directory is the directory containing the fastq files that will be monitored to see how much data has been read in. This should be the default directory that MinKNOW writes to." << std::endl
			<< "Options are:" << std::endl
			<< "[-H Host to open a connection on] default=" << host << std::endl
			<< "[-P Port to connect to] default=" << port << std::endl
			<< "[-w Wait time between directory checks. Measured in seconds] default=" << wait_time << std::endl
			<< "[-v verbose mode]" << std::endl
			<< "[-h help (this message)]" << std::endl << std::endl;
			
		if(num_args > 2) std::cerr << "Error: Too many arguments." << std::endl;
		if(num_args < 2) std::cerr << "Error: No arguments given." << std::endl;

		return 0;
		
	}
	
	std::istringstream ss(argv[optind]);
	int file_size;
	if (!(ss >> file_size)) {
		std::cerr << "File size is not a valid number (" << argv[optind] << ") Please enter a valid integer for file size." << std::endl;
		return 0;
	} else if (!ss.eof()) {
		std::cerr << "Trailing characters found after file size (" << argv[optind] << ") Please enter a valid integer for file size." << std::endl;
		return 0;
	}

	char *fastq_directory = argv[optind + 1];
	struct stat check_dir;
	
	if(stat (fastq_directory, &check_dir) != 0){
		std::cerr << "Directory path given (" << fastq_directory << ") is not a valid path. Please enter a valid directory." << std::endl;
		return 0;
	}
	
	std::cerr << "file size: " << file_size << std::endl;
	std::cerr << "fastq_directory: " << fastq_directory << std::endl;
	
	// Create a new connection
	Connection new_con(host, port, verbose);
	std::cerr << "Client connection established" << std::endl;
	
	std::unique_ptr<DeviceService::Stub> dev_stub_ =  DeviceService::NewStub(new_con.get_channel());
	std::unique_ptr<AcquisitionService::Stub> acq_stub_ = AcquisitionService::NewStub(new_con.get_channel());
	std::unique_ptr<ProtocolService::Stub> proto_stub_ = ProtocolService::NewStub(new_con.get_channel());
	
	std::cerr << "Checking for successful connection by getting the number of channels from the MinION." << std::endl;
	ClientContext cell_context;
	::minknow_api::device::GetFlowCellInfoRequest cell_request;
	::minknow_api::device::GetFlowCellInfoResponse cell_response;
	::grpc::Status return_status = dev_stub_->get_flow_cell_info(&cell_context, cell_request, &cell_response);
	
	if(cell_response.channel_count() == 0){
		std::cerr << "Unable to establish connection to MinKNOW. Please double check that you have the right host and port and try again. Exiting." << std::endl;
		return 0;
	}
	
	std::cerr << "Max number of channels: " << cell_response.channel_count() << std::endl;
	
	std::string fastq_directory_str(fastq_directory);
	
	int total_data_read = 0;
	
	while(true){
		std::cerr << "Checking directory..." << std::endl;
		total_data_read = 0;
		struct dirent *entry;
		DIR *dir = opendir(fastq_directory);
		while (entry = readdir(dir)) {
			std::string filename = entry->d_name;
			if(filename.substr(filename.find_last_of(".") + 1) == "fastq") {
				std::string file_path = fastq_directory_str + "\\" + filename;
				std::cerr << file_path << std::endl;
				std::ifstream f(file_path.c_str());
				if(!f.is_open()){
					std::cerr << "Error opening file." << std::endl;
					break;
				}
				std::string line;
				int line_num = 1;
				while(!f.eof()){
					getline(f,line);
					if(line_num % 2 == 0 && line_num % 4 != 0){
						total_data_read += line.length();
					}
					line_num++;
				}
				f.close();
			} 
		}
		closedir(dir);
		if(total_data_read >= file_size){
			break;
		}
		std::cerr << "Not enough data found. Waiting for " << wait_time << " seconds..." << std::endl;
		sleep(wait_time);
	}

	std::cerr << "Stopping MinKNOW run as we have read in all the data we wanted to:" << std::endl;
	// ClientContext stop_context;
	// ::minknow_api::acquisition::StopRequest stop_request;
	// // ::minknow_api::acquisition::StopRequest_DataAction action = StopRequest_DataAction_STOP_DEFAULT;
	// ::minknow_api::acquisition::StopRequest_DataAction action = StopRequest_DataAction_STOP_KEEP_ALL_DATA;
	// // ::minknow_api::acquisition::StopRequest_DataAction action = StopRequest_DataAction_STOP_FINISH_PROCESSING;
	// stop_request.set_data_action_on_stop(action);
	
	// ::minknow_api::acquisition::StopResponse stop_response;
	// ::grpc::Status status1 = acq_stub_->stop(&stop_context, stop_request, &stop_response);
	ClientContext stop_context;
	::minknow_api::protocol::StopProtocolRequest stop_request;
	::minknow_api::acquisition::StopRequest_DataAction action = StopRequest_DataAction_STOP_KEEP_ALL_DATA;
	stop_request.set_data_action_on_stop(action);
	::minknow_api::protocol::StopProtocolResponse stop_response;
	::grpc::Status status_stop = proto_stub_->stop_protocol(&stop_context, stop_request, &stop_response);
	
	
	return 0;
}
