//@author: gregsn, woei
//@help: simple vertex shader example for node13
//@tags: tutorial

Texture2D InputTexture <string uiname="Texture";>;

SamplerState LinearSampler : IMMUTABLE
{
    Filter = MIN_MAG_MIP_POINT;
    AddressU = WRAP;
    AddressV = WRAP;
};

float4x4 tW: WORLD;
float4x4 tV: VIEW;
float4x4 tP: PROJECTION;
float4x4 tVP: VIEWPROJECTION;
float4x4 tWVP: WORLDVIEWPROJECTION;

float Alpha <float uimin=0.0; float uimax=1.0;> = 1;
float4 Color <bool color=true;String uiname="Color";> = { 1.0f, 1.0f, 1.0f, 1.0f };
float4x4 tTex <string uiname="Texture Transform";>;
float4x4 tColor <string uiname="Color Transform";>;

float2 slider: FOOBAR;

struct vs2ps
{
    float4 PosWVP: SV_POSITION;
    float4 UV: TEXCOORD0;
	float distort: TEXCOORD1;
};

vs2ps VS(
	float4 PosO: POSITION,
	float3 NormO: NORMAL,
	float4 UV: TEXCOORD0)
{
    vs2ps Out = (vs2ps)0;
	
	//simple sinus wave on z component
//	PosO.z += sin(UV.x*3.14159*2*slider.x)*slider.y;

	// height map: lookup a texture and use it as distortion values
	float3 distortAmount = InputTexture.SampleLevel(LinearSampler, UV.xy, slider.x).rgb;
	// offset position along the normals = offset to outside
	PosO.xyz += distortAmount * NormO * slider.y;
	
	// an example how to pass custom data from vertexshader to pixel shader
	Out.distort = distortAmount;
    
	Out.PosWVP  = mul(PosO, tWVP);
	
    Out.UV = mul(UV, tTex);
    return Out;
}

float4 PS(vs2ps In): SV_Target
{
    float4 col = 1;
	col.rgb = In.distort;
	col.a *= Alpha;
    return col;
}

technique10 Template
{
	pass P0
	{
		SetVertexShader(CompileShader(vs_4_0, VS()));
		SetPixelShader(CompileShader(ps_4_0, PS()));
	}
}