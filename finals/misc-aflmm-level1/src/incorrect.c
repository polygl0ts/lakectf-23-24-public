#include <stdio.h>
#include <stdlib.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>

char* __afl_area_ptr;
int __afl_fork_pid;
int __afl_temp;
int __afl_prev_loc;

void setup(){
	puts("setup");
	char* wow = "__AFL_SHM_ID";
	char* aflshm = getenv(wow);
	//printf("afl shm id: %s\n", aflshm);
	int __shmid = atoi(aflshm);
	//printf("afl shm id atoi: %d\n", __shmid);
	char* shmaddr = shmat(__shmid, NULL, 0x0);
	__afl_area_ptr = shmaddr;
	if(shmaddr == -1){
		exit(1);
	}
	write(199, &__afl_temp, 4);
}

void afl_crash(){
	__afl_temp = 11;
	write(199, &__afl_temp,4);	
}

void afl_exit(){
	__afl_temp = 0;
	write(199, &__afl_temp, 4);
}

void afl_fork(){
	__afl_fork_pid = 1337;
	write(199, &__afl_fork_pid, 4);	
}

void afl_edge(int edge_id){
	int tmp1 = edge_id ^ __afl_prev_loc;
	__afl_prev_loc = edge_id >> 1;
	char d = __afl_area_ptr[tmp1];
	__afl_area_ptr[tmp1] = d+1;
	__afl_area_ptr[tmp1] = __afl_area_ptr[tmp1] + (0xfe < d);	
}

int main(int argc, char** argv){
	int ctr;
	int important_crash = 0;
	setup();
	while(1){
		ctr = read(0xc6,&__afl_temp,4);
		if(ctr != 4){
			printf("over!\n");
			break;
		}
		__afl_prev_loc = 0;
		memset(__afl_area_ptr, 0, 0x800000);
		__afl_area_ptr[0] = 1; //change bitmap
		afl_fork();
		char buf[20];
		read(0, buf, 20);
		//puts(buf);
		if(buf[0] == 'a'){
			afl_edge(0x1234);
		if(buf[1] == 'b'){
			afl_edge(0x23e5);
		if(buf[2] == '\n'){
			afl_edge(0x1b36);
			important_crash = 1;
		}}}
		if(important_crash){
			afl_crash();
		} else {
			afl_exit();
		}
	}
}
