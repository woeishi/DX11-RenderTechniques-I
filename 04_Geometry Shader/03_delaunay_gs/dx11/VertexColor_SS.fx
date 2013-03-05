//@author: vux
//@help: standard constant shader
//@tags: color
//@credits: 

float4x4 tW : WORLD;
float4x4 tWVP: WORLDVIEWPROJECTION;
float4x4 tWV: WORLDVIEW;
Texture2D tex; 

SamplerState sam : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

struct vsin
{
	float4 pos : POSITION;
};

struct gs2ps
{
    float4 pos: SV_POSITION;
    float4 col : COLOR0;
};



vsin VS(vsin input)
{
    return input;
}

float lthr;
[maxvertexcount(3)]
void GS( triangle vsin input[3], inout TriangleStream<gs2ps> gsout )
{
	gs2ps output;
	float4 t1 = input[0].pos.xyzw;
	float4 t2 = input[1].pos.xyzw;
	float4 t3 = input[2].pos.xyzw;
	
	
	float3 ce = t1.xyz + t2.xyz + t3.xyz ;
	ce *= 0.3333333f;
	
	ce *= 0.5f;
	ce += 0.5f;
	ce.y = 1.0f -ce.y;
	
	float4 c = tex.SampleLevel(sam,ce.xy,0);
	
	if (c.r > lthr)
	{	
		output.col = c;
		output.pos = mul(t1,tWVP);	
		gsout.Append(output);
		
		output.pos = mul(t2,tWVP);	
		gsout.Append(output);
	
		output.pos = mul(t3,tWVP);	
		gsout.Append(output);
	}
}


float4 PS(gs2ps input) : SV_Target
{
	return input.col;
}

technique10 Render
{
	pass P0
	{
		SetHullShader( 0 );
		SetDomainShader( 0 );
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetGeometryShader( CompileShader(gs_4_0,GS()));
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}





