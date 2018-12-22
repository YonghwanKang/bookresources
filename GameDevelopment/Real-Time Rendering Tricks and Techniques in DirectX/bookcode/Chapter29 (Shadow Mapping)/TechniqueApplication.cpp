/***************************************************************
* TechniqueApplication.cpp                                     *
*                                                              *
* This file contains the implementation of the                 *
* TechniqueApplication class.    	        				   *
* To compile correctly, this file must be linked with:         *
* kernel32.lib                                                 *
* user32.lib                                                   *
* d3dx8dt.lib                                                  *
* d3d8.lib                                                     *
*                                                              *
***************************************************************/

#include "TechniqueApplication.h"

#define TEX_DIMENSION 1024

#define D3DFVF_MESHVERTEX (D3DFVF_XYZ | D3DFVF_NORMAL | D3DFVF_DIFFUSE)
#define D3DFVF_TESTVERTEX (D3DFVF_XYZRHW | D3DFVF_TEX1)

struct MESH_VERTEX
{
	float x, y, z;
	float nx, ny, nz;
	DWORD color;
};

struct TEST_VERTEX
{
	float x, y, z, rhw;
	float u, v;
};

CTechniqueApplication::CTechniqueApplication()
{
	m_pPlaneVertexBuffer       = NULL;
	m_pMeshVertexBuffer        = NULL;
	m_pTestVertexBuffer        = NULL;
	m_pMeshIndexBuffer         = NULL;
	m_pMesh                    = NULL;
	m_pMeshMaterials           = NULL;
	m_pShadowTexture           = NULL;
	m_pShadowTextureSurface    = NULL;
	m_pShadowZSurface          = NULL;
	m_pBackBuffer              = NULL;
	m_pZBuffer                 = NULL;
	m_NumMaterials             = 0;
	m_CompareShader            = 0;
	m_DistanceShader           = 0;
}

CTechniqueApplication::~CTechniqueApplication()
{
}

BOOL CTechniqueApplication::PostInitialize()
{	
	D3DCAPS8 Caps;
	m_pD3D->GetDeviceCaps(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, &Caps);
	if (Caps.VertexShaderVersion == D3DVS_VERSION(1,1) && 
		Caps.PixelShaderVersion == D3DPS_VERSION(1,1))
	{
		if (FAILED(EasyCreateWindowed(m_hWnd, D3DDEVTYPE_HAL, 
						  D3DCREATE_HARDWARE_VERTEXPROCESSING)))
			return FALSE;
	}
	else
	{
		if (FAILED(EasyCreateWindowed(m_hWnd, D3DDEVTYPE_REF, 
						  D3DCREATE_SOFTWARE_VERTEXPROCESSING)))
			return FALSE;
	}


	//Do the basic camera positioning, etc.
	SetupDevice();
	
	//Load the mesh object
	LoadMesh();

	//Create the buffers we're actually going to use
	ExtractBuffers();

	if (FAILED(CreatePlaneBuffers()))
		return FALSE;

	//Create the shader
	if (FAILED(CreateShaders()))
		return FALSE;

	return TRUE;
}

void CTechniqueApplication::Render()
{
	//The light is moving side to side over the model.
	float Time = (float)GetTickCount() / 2000.0f;

	//These are reusable matrices
    D3DXMATRIX LightViewMatrix;
	D3DXMATRIX TextureMatrix;


	//Create the Texture Matrix
	float Offset = 0.5f + (0.5f / (float)TEX_DIMENSION);
	ZeroMemory(&TextureMatrix, sizeof(D3DXMATRIX));
    TextureMatrix._11 =  0.5f;
    TextureMatrix._22 = -0.5f;
    TextureMatrix._33 =  1.0f;
    TextureMatrix._41 =  Offset;
    TextureMatrix._42 =  Offset;
    TextureMatrix._44 =  1.0f;


	//Set the view parameters
	D3DXVECTOR4 EyePos(75.0, 75.0f, -75.0f, 0.0f);
	D3DXVECTOR4 LightPos(-25.0f * sin(Time) - 50.0f, 90.0f, 0.0f, 1.0f);

	//Set things up for the light
	D3DXMatrixLookAtLH(&LightViewMatrix, &(D3DXVECTOR3)LightPos,
		               &D3DXVECTOR3(0.0f, 0.0f, 0.0f),
					   &D3DXVECTOR3(0.0f, 1.0f, 0.0f));

	//Assume the light is pointed toward the origin.
	D3DXVECTOR4 LightDir = D3DXVECTOR4(0.0f, 0.0f, 0.0f, 0.0f) - LightPos;
	D3DXVec4Normalize(&LightDir, &LightDir);

	//Set the ambient light value.
	D3DXVECTOR4 Ambient    (0.1f,  0.1f, 0.1f, 0.0f);
	m_pD3DDevice->SetVertexShaderConstant(6, &Ambient, 1);

	//For this sample only - there is now world matrix transformation,
	//so there is no need to transform to object space.
	m_pD3DDevice->SetVertexShaderConstant(5, &LightDir, 1);


	//Set things up for the viewer
	D3DXMatrixLookAtLH(&m_ViewMatrix, &(D3DXVECTOR3)EyePos,
		               &D3DXVECTOR3(0.0f, 0.0f, 0.0f),
					   &D3DXVECTOR3(0.0f, 1.0f, 0.0f));


	D3DXMATRIX LightShaderMatrix = m_WorldMatrix * 
		                           LightViewMatrix * 
								   m_ProjectionMatrix;

	D3DXMATRIX EyeShaderMatrix =   m_WorldMatrix * 
		                           m_ViewMatrix * 
								   m_ProjectionMatrix;

	D3DXMATRIX TextureShaderMatrix = m_WorldMatrix * LightViewMatrix * 
		                             m_ProjectionMatrix * TextureMatrix;

	D3DXMatrixTranspose(&LightShaderMatrix,   &LightShaderMatrix);
	D3DXMatrixTranspose(&EyeShaderMatrix,     &EyeShaderMatrix);
	D3DXMatrixTranspose(&TextureShaderMatrix, &TextureShaderMatrix);

	//Set the global distance scaling constants
	D3DXVECTOR4 DistanceScalers(100.0f, 0.025f, 0.0f, 1.0f);
	m_pD3DDevice->SetVertexShaderConstant(4, &DistanceScalers, 1);

	//The texture should be null for all distance operations
	m_pD3DDevice->SetTexture(0, NULL);

	//First, render the light's point of view into the render target.
	m_pD3DDevice->SetVertexShader(m_DistanceShader);


	D3DVIEWPORT8 NormalViewport;
	m_pD3DDevice->GetViewport(&NormalViewport);

	//Set up the renderTarget
	m_pD3DDevice->SetRenderTarget(m_pShadowTextureSurface, m_pShadowZSurface);

	D3DVIEWPORT8 ShadowViewport;
	ShadowViewport.X = 0;
	ShadowViewport.Y = 0;
	ShadowViewport.Width  = TEX_DIMENSION;
	ShadowViewport.Height = TEX_DIMENSION;
	ShadowViewport.MinZ = 0.0f;
	ShadowViewport.MaxZ = 1.0f;
	m_pD3DDevice->SetViewport(&ShadowViewport);

	m_pD3DDevice->Clear(0, NULL, D3DCLEAR_TARGET | D3DCLEAR_ZBUFFER, 
		                D3DCOLOR_XRGB(255, 255, 255), 1.0f, 0);

	//Draw the plane and the mesh using the light view matrix
	m_pD3DDevice->SetVertexShaderConstant(0, &LightShaderMatrix, 4);
	RenderPlane();

	//Draw the mesh
	m_pD3DDevice->SetStreamSource(0, m_pMeshVertexBuffer, sizeof(MESH_VERTEX));
	m_pD3DDevice->SetIndices(m_pMeshIndexBuffer, 0);
	m_pD3DDevice->DrawIndexedPrimitive(D3DPT_TRIANGLELIST, 0, 
    								   m_pMesh->GetNumVertices(), 0,
									   m_pMesh->GetNumFaces());


	//Set the renderTarget back to the normal back buffer
	m_pD3DDevice->SetRenderTarget(m_pBackBuffer, m_pZBuffer);

	m_pD3DDevice->SetViewport(&NormalViewport);

	//Use the compare shader
	m_pD3DDevice->SetVertexShader(m_CompareShader);

	//Set the pixel shader
	m_pD3DDevice->SetPixelShader(m_PixelShader);

	//Set the texture states to clamp the coordinates
	m_pD3DDevice->SetTextureStageState(0, D3DTSS_ADDRESSU, D3DTADDRESS_CLAMP);
	m_pD3DDevice->SetTextureStageState(0, D3DTSS_ADDRESSV, D3DTADDRESS_CLAMP);

	//Render everything from the eye's point of view - use the first
	//rendering as a texture.
	m_pD3DDevice->SetTexture(0, m_pShadowTexture);

	m_pD3DDevice->SetVertexShaderConstant(0,  &EyeShaderMatrix, 4);
	m_pD3DDevice->SetVertexShaderConstant(10, &LightShaderMatrix, 4);
	m_pD3DDevice->SetVertexShaderConstant(20, &TextureShaderMatrix, 4);

	RenderPlane();

	m_pD3DDevice->SetStreamSource(0, m_pMeshVertexBuffer, sizeof(MESH_VERTEX));
	m_pD3DDevice->SetIndices(m_pMeshIndexBuffer, 0);
	m_pD3DDevice->DrawIndexedPrimitive(D3DPT_TRIANGLELIST, 0, 
    								   m_pMesh->GetNumVertices(), 0,
									   m_pMesh->GetNumFaces());

	//Turn off the pixel shader
	m_pD3DDevice->SetPixelShader(NULL);

	//Draw a small rectangle showing the light's view (for debugging)..
	m_pD3DDevice->SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);
	m_pD3DDevice->SetRenderState(D3DRS_ZENABLE, FALSE);
	m_pD3DDevice->SetVertexShader(D3DFVF_TESTVERTEX);
	m_pD3DDevice->SetStreamSource(0, m_pTestVertexBuffer, sizeof(TEST_VERTEX));
	m_pD3DDevice->DrawPrimitive(D3DPT_TRIANGLESTRIP, 0, 2);
	m_pD3DDevice->SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);
	m_pD3DDevice->SetRenderState(D3DRS_ZENABLE, TRUE);
}

HRESULT CTechniqueApplication::LoadMesh()
{
	LPD3DXBUFFER pD3DXMtrlBuffer;
	LPD3DXMESH   pOriginalMesh;

    //Load and initialize the mesh. This is a repeat of the code
	//from Chapter 10.
	if(FAILED(D3DXLoadMeshFromX("..\\media\\fattorus.x",
								D3DXMESH_MANAGED, 
                                m_pD3DDevice, NULL, &pD3DXMtrlBuffer,
								&m_NumMaterials, &pOriginalMesh)))
        return FALSE;

	D3DXMATERIAL* d3dxMaterials = 
		(D3DXMATERIAL*)pD3DXMtrlBuffer->GetBufferPointer();

    m_pMeshMaterials = new D3DMATERIAL8[m_NumMaterials];

    for(long MatCount = 0; MatCount < m_NumMaterials; MatCount++)
		m_pMeshMaterials[MatCount] = d3dxMaterials[MatCount].MatD3D;

    pD3DXMtrlBuffer->Release();

	//This is new. If the FVF doesn't match, clone the mesh and
	//create one that does. Then, release the loaded mesh. If the 
	//FVF does match, set the member mesh and move on.
	if (pOriginalMesh->GetFVF() != D3DFVF_MESHVERTEX)
	{
		pOriginalMesh->CloneMeshFVF(D3DXMESH_MANAGED,
									D3DFVF_MESHVERTEX,
                                    m_pD3DDevice, &m_pMesh);
		
		pOriginalMesh->Release();
		pOriginalMesh = NULL;
	}
	else
		m_pMesh = pOriginalMesh;

	return S_OK;
}

BOOL CTechniqueApplication::PreReset()
{
	//Delete the shaders
	m_pD3DDevice->DeleteVertexShader(m_CompareShader);
	m_pD3DDevice->DeleteVertexShader(m_DistanceShader);
	m_pD3DDevice->DeletePixelShader(m_PixelShader);

	//Get rid of all the render target objects
	CleanUpTarget();

	return TRUE;
}

BOOL CTechniqueApplication::PostReset()
{
	SetupDevice();

	//Recreate the shader
	if (FAILED(CreateShaders()))
		return FALSE;

	return TRUE;
}


BOOL CTechniqueApplication::PreTerminate()
{
	//Delete the shaders
	m_pD3DDevice->DeleteVertexShader(m_CompareShader);
	m_pD3DDevice->DeleteVertexShader(m_DistanceShader);
	m_pD3DDevice->DeletePixelShader(m_PixelShader);

	//Get rid of all the render target objects
	CleanUpTarget();
	
	//Clean up
	if (m_pPlaneVertexBuffer)
	{
		m_pPlaneVertexBuffer->Release();
		m_pPlaneVertexBuffer = NULL;
	}

	if (m_pTestVertexBuffer)
	{
		m_pTestVertexBuffer->Release();
		m_pTestVertexBuffer = NULL;
	}

	if (m_pMeshVertexBuffer)
	{
		m_pMeshVertexBuffer->Release();
		m_pMeshVertexBuffer = NULL;
	}

	if (m_pMeshIndexBuffer)
	{
		m_pMeshIndexBuffer->Release();
		m_pMeshIndexBuffer  = NULL;
	}

	if (m_pMesh)
	{
		m_pMesh->Release();
		m_pMesh = NULL;
	}

	if (m_pMeshMaterials)
	{
		delete m_pMeshMaterials;
		m_pMeshMaterials = NULL;
	}

	return TRUE;
}


HRESULT CTechniqueApplication::SetupDevice()
{
	//Do all the basic setup
	RECT WindowRect;
	GetClientRect(m_hWnd, &WindowRect);
	D3DXMatrixPerspectiveFovLH(&m_ProjectionMatrix,
					D3DX_PI / 4,
					(float)(WindowRect.right - WindowRect.left) / 
					(float)(WindowRect.bottom - WindowRect.top),
				    1.0f, 1000.0f);

	D3DXMatrixIdentity(&m_WorldMatrix);

	//Create the shadow render target. This will be used to render the light
	//view depth.
	if (FAILED(D3DXCreateTexture(m_pD3DDevice, TEX_DIMENSION, TEX_DIMENSION, 1, 
		                         D3DUSAGE_RENDERTARGET, D3DFMT_X8R8G8B8,
								 D3DPOOL_DEFAULT, &m_pShadowTexture)))
		return E_FAIL;

	//Create the target depth buffer
	if (FAILED(m_pD3DDevice->CreateDepthStencilSurface(TEX_DIMENSION, 
		                                               TEX_DIMENSION,
													   D3DFMT_D24S8,
													   D3DMULTISAMPLE_NONE,
													   &m_pShadowZSurface)))
		return E_FAIL;


    //Keep a handle to the back buffer for easy swapping
	if (FAILED(m_pD3DDevice->GetRenderTarget(&m_pBackBuffer)))
		return E_FAIL;

    //Same for the depth buffer
	if (FAILED(m_pD3DDevice->GetDepthStencilSurface(&m_pZBuffer)))
		return E_FAIL;

	//Get the top level surface of the target texture.
	if (FAILED(m_pShadowTexture->GetSurfaceLevel(0, &m_pShadowTextureSurface)))
		return E_FAIL;


	return S_OK;
}

HRESULT CTechniqueApplication::ExtractBuffers()
{
	//Get the buffers
	m_pMesh->GetVertexBuffer(&m_pMeshVertexBuffer);
	m_pMesh->GetIndexBuffer(&m_pMeshIndexBuffer);

	MESH_VERTEX *pMeshVertices;
	short       *pIndices;
	DWORD       *pAttribs;

	//Lock the vertex buffer, but allow writing.
	m_pMeshVertexBuffer->Lock(0, 
		                      m_pMesh->GetNumVertices() * sizeof(MESH_VERTEX),
		                      (BYTE **)&pMeshVertices, 0);


	//We only need to read the indices
	m_pMeshIndexBuffer->Lock(0, 3 * m_pMesh->GetNumFaces() * sizeof(short),
	                         (BYTE **)&pIndices, D3DLOCK_READONLY);

	//The attribute buffer maps the materials to each face.
	m_pMesh->LockAttributeBuffer(D3DLOCK_READONLY, &pAttribs);

	//Loop through each face and set the vertex color based on the material.
	//This is a pretty simple example, but you could also use this to preload
	//other data, such as converting colors to data that the vertex shader
	//may use in computations.
	for (long Face = 0; Face < m_pMesh->GetNumFaces(); Face++)
	{
		D3DXCOLOR Diffuse = (D3DXCOLOR)m_pMeshMaterials[pAttribs[Face]].Diffuse;

		pMeshVertices[pIndices[Face * 3 + 0]].color = Diffuse;
		pMeshVertices[pIndices[Face * 3 + 1]].color = Diffuse;
		pMeshVertices[pIndices[Face * 3 + 2]].color = Diffuse;
	}

	//Give back all of our buffers.
	m_pMeshVertexBuffer->Unlock();
	m_pMeshIndexBuffer->Unlock();
	m_pMesh->UnlockAttributeBuffer();

	return S_OK;
}

HRESULT CTechniqueApplication::CreateShaders()
{
	//Set up the declaration to match the FVF and to
	//read from stream zero.
	DWORD Declaration[] =
	{
		D3DVSD_STREAM(0),
		D3DVSD_REG(D3DVSDE_POSITION,D3DVSDT_FLOAT3),
		D3DVSD_REG(D3DVSDE_NORMAL,  D3DVSDT_FLOAT3),
		D3DVSD_REG(D3DVSDE_DIFFUSE, D3DVSDT_D3DCOLOR),
		D3DVSD_END()
	};

	
	ID3DXBuffer* pShaderBuffer;
	ID3DXBuffer* pShaderErrors;

	//Assemble and create the first shader. Under real circumstances, you would 
	//probably want to do more error handling.
	if (FAILED(D3DXAssembleShaderFromFile("..\\media\\Shaders\\CompareDepth.vsh", 
		                            0, NULL, &pShaderBuffer, &pShaderErrors)))
		return E_FAIL;

	if (FAILED(m_pD3DDevice->CreateVertexShader(Declaration, 
		                           (DWORD *)pShaderBuffer->GetBufferPointer(),
								   &m_CompareShader, 0)))
		return E_FAIL;

	//release the working buffers
	pShaderBuffer->Release();

	//Assemble and create the second shader. Under real circumstances, you would 
	//probably want to do more error handling.
	if (FAILED(D3DXAssembleShaderFromFile("..\\media\\Shaders\\EncodeDepth.vsh", 
		                            0, NULL, &pShaderBuffer, &pShaderErrors)))
		return E_FAIL;

	if (FAILED(m_pD3DDevice->CreateVertexShader(Declaration, 
		                           (DWORD *)pShaderBuffer->GetBufferPointer(),
								   &m_DistanceShader, 0)))
		return E_FAIL;

	//release the working buffers
	pShaderBuffer->Release();

	//Assemble and create the pixel shader. Under real circumstances, you would 
	//probably want to do more error handling.
	if (FAILED(D3DXAssembleShaderFromFile("..\\media\\Shaders\\ShadowMap.psh", 
		                            0, NULL, &pShaderBuffer, &pShaderErrors)))
		return E_FAIL;

	if (FAILED(m_pD3DDevice->CreatePixelShader(
		                           (DWORD *)pShaderBuffer->GetBufferPointer(),
								   &m_PixelShader)))
		return E_FAIL;

	//release the working buffers
	pShaderBuffer->Release();

	return S_OK;
}

void CTechniqueApplication::PreRender()
{
	//Clear the device
	m_pD3DDevice->Clear(0, NULL,
						D3DCLEAR_TARGET | D3DCLEAR_ZBUFFER,
						D3DCOLOR_XRGB(100, 100, 200), 1.0f, 0);

	//Call BeginScene to set up the device
	m_pD3DDevice->BeginScene();
		
	return;
}


HRESULT CTechniqueApplication::CreatePlaneBuffers()
{
	//Create as managed so we don't have to worry about recreating it
	//if the device is lost.
	if (FAILED(m_pD3DDevice->CreateVertexBuffer(4 * sizeof(MESH_VERTEX), 
		                                        0, D3DFVF_MESHVERTEX,
									            D3DPOOL_MANAGED,
												&m_pPlaneVertexBuffer)))
		return E_FAIL;

	//Create a set of 4 vertices for the plane
	MESH_VERTEX *pVertices;

	//Lock the vertex buffer, but allow writing.
	m_pPlaneVertexBuffer->Lock(0, 4 * sizeof(MESH_VERTEX), (BYTE **)&pVertices, 0);

	//Initialize everything to zero. If I don't set a certain attribute,
	//assume it's zero..
	memset(pVertices, 0x00, 4 * sizeof(MESH_VERTEX));

	//WARNING - this is a bit confusing. I'm setting X and Z positions, but
	//I'm setting the y *Normal* value. If you don't read closely, it 
	//might be very confusing.
	float Size = 50.0f;
	pVertices[0].x = -Size; pVertices[0].ny = 1.0f; pVertices[0].z = -Size;
	pVertices[1].x =  Size; pVertices[1].ny = 1.0f; pVertices[1].z = -Size;
	pVertices[2].x = -Size; pVertices[2].ny = 1.0f; pVertices[2].z =  Size;
	pVertices[3].x =  Size; pVertices[3].ny = 1.0f; pVertices[3].z =  Size;

	pVertices[0].color = pVertices[1].color = 
		                 pVertices[2].color = pVertices[3].color = 0xffffffff;

	m_pPlaneVertexBuffer->Unlock();

	//Also, create the mask vertex buffer
	if (FAILED(m_pD3DDevice->CreateVertexBuffer(4 * sizeof(TEST_VERTEX), 
		                                        0, D3DFVF_TESTVERTEX,
									            D3DPOOL_MANAGED,
												&m_pTestVertexBuffer)))
		return E_FAIL;

	//Create a set of 4 vertices for the texture viewing surface
	TEST_VERTEX *pTestVertices;

	//Lock the vertex buffer, but allow writing.
	m_pTestVertexBuffer->Lock(0, 4 * sizeof(TEST_VERTEX), (BYTE **)&pTestVertices, 0);

	//Set up the 4 corners of a small square
	pTestVertices[0].x = 500.0f; pTestVertices[0].y = 0.0f;
	pTestVertices[0].z = 1.0f;   pTestVertices[0].rhw = 1.0f;
	pTestVertices[0].u = 0.0f;   pTestVertices[0].v = 0.0f;

	pTestVertices[1].x = 500.0f; pTestVertices[1].y = 100.0f;
	pTestVertices[1].u = 0.0f;   pTestVertices[1].v = 1.0f;
	pTestVertices[1].z = 1.0f;   pTestVertices[1].rhw = 1.0f;

	pTestVertices[2].x = 600.0f; pTestVertices[2].y = 0.0f;
	pTestVertices[2].u = 1.0f;   pTestVertices[2].v = 0.0f;
	pTestVertices[2].z = 1.0f;   pTestVertices[2].rhw = 1.0f;

	pTestVertices[3].x = 600.0f; pTestVertices[3].y = 100.0f;
	pTestVertices[3].u = 1.0f;   pTestVertices[3].v = 1.0f;
	pTestVertices[3].z = 1.0f;   pTestVertices[3].rhw = 1.0f;

	m_pTestVertexBuffer->Unlock();

	return S_OK;
}

void CTechniqueApplication::RenderPlane()
{
	//Draw the mesh
	m_pD3DDevice->SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);
	m_pD3DDevice->SetStreamSource(0, m_pPlaneVertexBuffer, sizeof(MESH_VERTEX));
	m_pD3DDevice->DrawPrimitive(D3DPT_TRIANGLESTRIP, 0, 2);
	m_pD3DDevice->SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);
}

void CTechniqueApplication::CleanUpTarget()
{
	if (m_pShadowTexture)
	{
		m_pShadowTexture->Release();
		m_pShadowTexture = NULL;
	}

	if (m_pShadowTextureSurface)
	{
		m_pShadowTextureSurface->Release();
		m_pShadowTextureSurface = NULL;
	}

	if (m_pShadowZSurface)
	{
		m_pShadowZSurface->Release();
		m_pShadowZSurface = NULL;
	}

	if (m_pBackBuffer)
	{
		m_pBackBuffer->Release();
		m_pBackBuffer = NULL;
	}

	if (m_pZBuffer)
	{
		m_pZBuffer->Release();
		m_pZBuffer = NULL;
	}
}