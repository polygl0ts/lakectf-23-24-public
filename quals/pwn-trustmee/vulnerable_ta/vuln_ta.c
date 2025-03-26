#include "tee_internal_api.h"
#include "tee_logging.h" /* OpenTEE logging functions */
#include "vuln_ta.h"	


TEE_Result TA_EXPORT TA_CreateEntryPoint(void)
{
	return TEE_SUCCESS;
}

void TA_EXPORT TA_DestroyEntryPoint(void)
{
	return TEE_SUCCESS;
}

TEE_Result TA_EXPORT TA_OpenSessionEntryPoint(uint32_t paramTypes, TEE_Param params[4],
					      void **sessionContext)
{
	paramTypes = paramTypes;
	params = params;
	sessionContext = sessionContext;
	for(int i=0; i<0x100; i++){
		GRADE_KEY[i] = getRandomByte();
	}

	return TEE_AllocateOperation((TEE_OperationHandle *)sessionContext,
				     TEE_ALG_MD5, TEE_MODE_DIGEST, 0);
}

void TA_EXPORT TA_CloseSessionEntryPoint(void *sessionContext)
{
	sessionContext = sessionContext;
}


TEE_Result calculate_signature(void* sessionContext, struct signedStudent* sigStudent){
	TEE_Result out;
	if(sigStudent->grade < 1 || sigStudent->grade > 6){
		return TEE_ERROR_SECURITY;
	}
	TEE_DigestUpdate(sessionContext, sigStudent->firstname, NAME_LEN);
	TEE_DigestUpdate(sessionContext, sigStudent->lastname, NAME_LEN);
	TEE_DigestUpdate(sessionContext, &sigStudent->grade, sizeof(int));
	TEE_DigestUpdate(sessionContext, GRADE_KEY, 0x100);
	size_t hash_len = SIG_LEN;
	char hash[SIG_LEN];
	printf("address of sig %p\n", sigStudent->signature);
	out = TEE_DigestDoFinal(sessionContext, NULL, 0, hash, &hash_len);
	printf("hash: %s\n", hash);
	TEE_MemMove(sigStudent->signature, hash, hash_len);
	printf("hash length: %d\n", hash_len);
	if(out!=TEE_SUCCESS){
		return out;
	}
	return TEE_SUCCESS;
}

TEE_Result TA_EXPORT TA_InvokeCommandEntryPoint(void *sessionContext, uint32_t commandID,
						uint32_t paramTypes, TEE_Param params[4])
{
	sessionContext = sessionContext;
	commandID = commandID;
	paramTypes = paramTypes;
	params = params;

	
	if(commandID == SIGN_CLASS){
		// reads some buffer
		char* inbuf = params[0].memref.buffer;
		size_t insiz = params[0].memref.size;
		char* outbuf = params[1].memref.buffer;
		size_t outsiz = params[1].memref.size;
		TEE_Result valid = TEE_CheckMemoryAccessRights(5, inbuf, insiz);
		if(valid != TEE_SUCCESS){
			OT_LOG(LOG_ERR, "Bad Parameters!");
			return TEE_ERROR_BAD_PARAMETERS;
		}
		valid = TEE_CheckMemoryAccessRights(5, outbuf, outsiz);
		if(valid != TEE_SUCCESS){
			OT_LOG(LOG_ERR, "Bad Parameters!");
			return TEE_ERROR_BAD_PARAMETERS;
		}
		struct studentclass* curClass = (struct studentclass*)inbuf;
		struct signedStudentclass* curClassSigned = (struct signedStudentclass*)outbuf;
		for(int i=0; i<NR_STUDENTS; i++){
			TEE_MemMove(curClassSigned->sigsStudents[i].firstname, curClass->students[i].firstname, NAME_LEN);
			TEE_MemMove(curClassSigned->sigsStudents[i].lastname, curClass->students[i].lastname, NAME_LEN);
			curClassSigned->sigsStudents[i].grade = curClass->students[i].grade;
			curClassSigned->sigsStudents[i].sciper = curClass->students[i].sciper;
			TEE_Result out = calculate_signature(sessionContext, &curClassSigned->sigsStudents[i]);
			if(out != TEE_SUCCESS){
				OT_LOG(LOG_ERR, "Signature Calculation Failed!");
				return out;
			}
		}
		return TEE_SUCCESS;
	}
	if(commandID == SIGN_STUDENT){
		// reads some buffer
		char* inbuf = params[0].memref.buffer;
		size_t insiz = params[0].memref.size;
		char* outbuf = params[1].memref.buffer;
		size_t outsiz = params[1].memref.size;
		TEE_Result valid = TEE_CheckMemoryAccessRights(5, inbuf, insiz);
		if(valid != TEE_SUCCESS){
			OT_LOG(LOG_ERR, "Bad Parameters!");
			return TEE_ERROR_BAD_PARAMETERS;
		}
		valid = TEE_CheckMemoryAccessRights(5, outbuf, outsiz);
		if(valid != TEE_SUCCESS){
			OT_LOG(LOG_ERR, "Bad Parameters!");
			return TEE_ERROR_BAD_PARAMETERS;
		}
		struct student* curStudent = (struct student*)inbuf;
		struct signedStudent* curSignedStudent = (struct signedStudent*)outbuf;
		TEE_MemMove(curSignedStudent->firstname, curStudent->firstname, NAME_LEN);
		TEE_MemMove(curSignedStudent->lastname, curStudent->lastname, NAME_LEN);
		curSignedStudent->grade = curStudent->grade;
		curSignedStudent->sciper = curStudent->sciper;
		TEE_Result out = calculate_signature(sessionContext, curSignedStudent);
		if(out != TEE_SUCCESS){
			OT_LOG(LOG_ERR, "Signature Calculation Failed!");
			return out;
		}
		return TEE_SUCCESS;
	}
	if(commandID == SIGN_CLASS_STUDENT){
		// reads some buffer
		char* inbuf = params[0].memref.buffer;
		size_t insiz = params[0].memref.size;
		char* outbuf = params[1].memref.buffer;
		size_t outsiz = params[1].memref.size;
		int index = (int)params[2].value.a;
		TEE_Result valid = TEE_CheckMemoryAccessRights(5, inbuf, insiz);
		if(valid != TEE_SUCCESS){
			OT_LOG(LOG_ERR, "Bad Parameters!");
			return TEE_ERROR_BAD_PARAMETERS;
		}
		valid = TEE_CheckMemoryAccessRights(5, outbuf, outsiz);
		if(valid != TEE_SUCCESS){
			OT_LOG(LOG_ERR, "Bad Parameters!");
			return TEE_ERROR_BAD_PARAMETERS;
		}
		struct studentclass* curClass = (struct studentclass*)inbuf;
		struct signedStudent* curSignedStudent = (struct signedStudent*)outbuf;
		TEE_MemMove(curSignedStudent->firstname, curClass->students[index].firstname, NAME_LEN);
		TEE_MemMove(curSignedStudent->lastname, curClass->students[index].lastname, NAME_LEN);
		curSignedStudent->grade = curClass->students[index].grade;
		curSignedStudent->sciper = curClass->students[index].sciper;
		TEE_Result out = calculate_signature(sessionContext, curSignedStudent);
		if(out != TEE_SUCCESS){
			OT_LOG(LOG_ERR, "Signature Calculation Failed!");
			return out;
		}
		return TEE_SUCCESS;
	}	
	return TEE_ERROR_BAD_PARAMETERS;
}
