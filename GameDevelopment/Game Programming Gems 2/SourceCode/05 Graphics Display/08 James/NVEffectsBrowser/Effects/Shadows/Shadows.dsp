# Microsoft Developer Studio Project File - Name="Shadows" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=Shadows - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "Shadows.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "Shadows.mak" CFG="Shadows - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "Shadows - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "Shadows - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName "sdietrich"
# PROP Scc_LocalPath "..\..\.."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "Shadows - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "SHADOWS_EXPORTS" /YX /FD /c
# ADD CPP /nologo /MT /W3 /GX /O2 /I "..\..\..\commonsrc" /I "..\..\shared" /I "..\..\..\include" /I "..\..\..\..\INCLUDE" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "SHADOWS_EXPORTS" /YX /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib d3dx8.lib /nologo /dll /machine:I386

!ELSEIF  "$(CFG)" == "Shadows - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "SHADOWS_EXPORTS" /YX /FD /GZ /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /I "..\..\..\commonsrc" /I "..\..\shared" /I "..\..\..\include" /I "..\..\..\..\INCLUDE" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "SHADOWS_EXPORTS" /FR /YX /FD /GZ /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib d3dx8.lib /nologo /dll /debug /machine:I386 /out:"Shadows.dll" /pdbtype:sept

!ENDIF 

# Begin Target

# Name "Shadows - Win32 Release"
# Name "Shadows - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=.\DrawObject.nvv

!IF  "$(CFG)" == "Shadows - Win32 Release"

# Begin Custom Build
InputPath=.\DrawObject.nvv

"DrawObject.vso" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	..\..\nvasm DrawObject.nvv

# End Custom Build

!ELSEIF  "$(CFG)" == "Shadows - Win32 Debug"

# Begin Custom Build
InputPath=.\DrawObject.nvv

"DrawObject.vso" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	..\..\nvasm DrawObject.nvv

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=..\..\shared\eb_property.cpp
# End Source File
# Begin Source File

SOURCE=..\..\..\CommonSrc\nvmesh.cpp
# End Source File
# Begin Source File

SOURCE=.\shader_Shadows.cpp
# End Source File
# Begin Source File

SOURCE=.\ShadowGen.nvv

!IF  "$(CFG)" == "Shadows - Win32 Release"

# Begin Custom Build
InputPath=.\ShadowGen.nvv

"ShadowGen.vso" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	..\..\nvasm ShadowGen.nvv

# End Custom Build

!ELSEIF  "$(CFG)" == "Shadows - Win32 Debug"

# Begin Custom Build
InputPath=.\ShadowGen.nvv

"ShadowGen.vso" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	..\..\nvasm ShadowGen.nvv

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\ShadowShow.nvv

!IF  "$(CFG)" == "Shadows - Win32 Release"

# Begin Custom Build
InputPath=.\ShadowShow.nvv

"ShadowShow.vso" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	..\..\nvasm ShadowShow.nvv

# End Custom Build

!ELSEIF  "$(CFG)" == "Shadows - Win32 Debug"

# Begin Custom Build
InputPath=.\ShadowShow.nvv

"ShadowShow.vso" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	..\..\nvasm ShadowShow.nvv

# End Custom Build

!ENDIF 

# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=.\Constants.h
# End Source File
# Begin Source File

SOURCE=.\ModelInstance.h
# End Source File
# Begin Source File

SOURCE=.\shader_Shadows.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# End Group
# End Target
# End Project