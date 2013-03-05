//@author: vux
//@help: standard constant shader
//@tags: color
//@credits: 

float2 r;
float2 invr;
Texture2D tex;
Texture2D tvel; 

SamplerState g_samLinear : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

 
struct VS_IN
{
	uint iv : SV_VertexID;
};

struct vs2ps
{
    float4 PosWVP: SV_POSITION;
	float4 col : COLOR;
	float2 dir : TEXCOORD;
};

struct psIn
{
    float4 PosWVP: SV_POSITION;
	float4 col : COLOR;
};

vs2ps VS(VS_IN input)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
	
	float2 uv = float2(input.iv % r.x / r.y , (input.iv / r.x) / r.y);
	uv.y-=uv.x/r.x;
	
	float2 p = uv;
	p.xy *= 2.0;
	p.xy -= 1.0;
	p.y *= -1;

    Out.PosWVP  = float4(p,0,1);
	Out.col = tex.SampleLevel(g_samLinear,uv,0);
	Out.dir = tvel.SampleLevel(g_samLinear,uv,0).xy;
    return Out;
} 

[maxvertexcount(2)]
void GS(point vs2ps input[1], inout LineStream<psIn> lines)
{
    psIn output;
	
	output.PosWVP = input[0].PosWVP;
	output.col = input[0].col;
	lines.Append(output);
	output.PosWVP = input[0].PosWVP + float4(input[0].dir,0,0);
	lines.Append(output);
}


float4 PS_Tex(psIn In): SV_Target
{
    return  In.col;
}

technique10 Constant
{
	pass P0
	{
		SetHullShader( 0 );
		SetDomainShader( 0 );
		SetGeometryShader( CompileShader( gs_4_0, GS() ) );
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS_Tex() ) );
	}
}




