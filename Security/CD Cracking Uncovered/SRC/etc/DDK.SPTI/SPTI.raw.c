/*----------------------------------------------------------------------------
 *
 *				������ ������� � CD-ROM � ����� ������ ����� SPTI
 *				=================================================
 *
 * build 0x001 @ 27.05.2003
----------------------------------------------------------------------------*/
#include <windows.h>
#include <stdio.h>
#include "SPTI.raw.h"

#define RAW_READ_CMD			0xBE	// ATAPI RAW READ

#define WHATS_READ				0xF8	// Sync & All Headers & User Data + EDC/ECC
#define PACKET_LEN				2352	// ����� ������ �������

//#define WHATS_READ			0x10	// User Data
//#define PACKET_LEN			2048	// ����� ������ �������

//-[DWORD READ_RAW_SECTOR_FROM_CD]---------------------------------------------
//		������� ������ ���� ��� ��������� �������� � CDROM � ����� (RAW) ����,
// �������� ���������� ������
//
//	ARG:
//		driver		-	��� ��������� (���� "\\.\X:")
//		adapter_id	-	����� ���� (0 - primary, 1 - secondary)
//		read_id		-	����� ���������� �� ���� (0 - master, 1 - slaeyer)
//		buf			-	����� ���� ������
//		buf_len		-	������ ������ � ������
//		StartSector	-	� ������ ������� ������, ������ �� ����
//		N_SECTOR	-	������� �������� ������ \
//		flags		-	��� ������ (��. ������������ �� ATAPI)
//
//	RET:
//		!=0			-	������� ����������� �������
//		==0			-	������� ����������� � �������
//
//	NOTE:
//		�������� ������ ��� NT/W2K/XP � ������� ���� ��������������
//-----------------------------------------------------------------------------
DWORD READ_RAW_SECTOR_FROM_CD(char *driver, int adapter_id, int read_id,
char *buf, int buf_len, DWORD StartSector, DWORD N_SECTOR, BYTE flags)
{
	HANDLE				hCD;
	SCSI_PASS_THROUGH	srb;
	DWORD				returned, length, status;

	// ��������� ����������
	//------------------------------------------------------------------------
	// ��������! �� ���� ������ ��� "\\\\.\\SCSI0" ��� ��� "\\\\.\\CdRom0"
	// ��� ����� �� ���������! (���, ������, ������ ������ ����������)
	hCD = CreateFile (	driver, GENERIC_WRITE|GENERIC_READ,
						FILE_SHARE_READ|FILE_SHARE_WRITE,0,OPEN_EXISTING,0,0);
	if (hCD == INVALID_HANDLE_VALUE) return 0;

	// ��������� SRB
	//------------------------------------------------------------------------
	memset(&srb, 0, sizeof(SCSI_PASS_THROUGH));	// ������������

	// �����
	srb.Length				= sizeof(SCSI_PASS_THROUGH);
	srb.PathId				= 0;					// SCSI controller ID
	srb.TargetId			= adapter_id;			// target device ID
	srb.Lun 				= read_id;				// logical unit device ID
	srb.CdbLength			= 12;					// ����� CDB ������
	srb.SenseInfoLength		= 0;					// ��� �� ����� SenseInfo
	srb.DataIn 				= SCSI_IOCTL_DATA_IN;	// �� ����� ������
	srb.DataTransferLength	= PACKET_LEN*N_SECTOR;	// ������� �� ����� ������
	srb.TimeOutValue 		= 200;					// ����� ������ �� TimeOut
	srb.DataBufferOffset	= buf;					// ��������� �� �����
	srb.SenseInfoOffset 	= 0;					// SenseInfo �� �� �����

	// CDB-�����, ���������� ������� ATAPI
	srb.Cdb[0]				= RAW_READ_CMD;			// ������ ����� ������
	srb.Cdb[1]				= 0x0;					// ������ ����� - �����
	
	// ����� ������� ������� ��� ������, ������ ������� ���������� �������
	// ���� �������� �����, � ����� ������� ���� �������� �����
	srb.Cdb[2]				= HIBYTE(HIWORD(StartSector));
	srb.Cdb[3]				= LOBYTE(HIWORD(StartSector));
	srb.Cdb[4]				= HIBYTE(LOWORD(StartSector));
	srb.Cdb[5]				= LOBYTE(LOWORD(StartSector));

	// ���������� �������� ��� ������
	srb.Cdb[6]				= LOBYTE(HIWORD(N_SECTOR));
	srb.Cdb[7]				= LOBYTE(LOWORD(N_SECTOR));
	srb.Cdb[8]				= HIBYTE(LOWORD(N_SECTOR));

	srb.Cdb[9]				= flags;				// ��� ������
	srb.Cdb[10]				= 0;					// Sub-Channel Data Bits
	srb.Cdb[11]				= 0;					// reserverd

	// ���������� SRB-���� ATAPI-����������
	status = DeviceIoControl(hCD, IOCTL_SCSI_PASS_THROUGH,
			&srb, sizeof(SCSI_PASS_THROUGH), &srb, 0, &returned, FALSE);

	return 1;
}

#define FNAME	"raw.sector.dat"

main(int argc, char **argv)
{
	FILE *f;
	char *buf;

	if (argc<6)
	{
		fprintf(stderr,	"USAGE: SPTI.raw.exe \\\\.\\X: adapter_id device_id"\
						"start_sector N_sector\n"); return -1;
	}

	buf = malloc(PACKET_LEN*atol(argv[5]));
	if (READ_RAW_SECTOR_FROM_CD(argv[1], atol(argv[2]), atol(argv[3]),buf,
		PACKET_LEN*atol(argv[5]),atol(argv[4]),atol(argv[5]),WHATS_READ) != 0)
	{
		f=fopen(FNAME,"w");fwrite(buf,1,PACKET_LEN*atol(argv[5]),f);fclose(f);
	}

	return 0;
}