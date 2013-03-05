float4x4 tWVP: WORLDVIEWPROJECTION;
float4x4 tVI : VIEWINVERSE;

Texture2D texture2d; 

SamplerState g_samLinear : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};



    float3 g_positions[4]: IMMUTABLE =
    {
        float3( -1, 1, 0 ),
        float3( 1, 1, 0 ),
        float3( -1, -1, 0 ),
        float3( 1, -1, 0 ),
    } ;
    float2 g_texcoords[4]: IMMUTABLE = 
    { 
        float2(0,1), 
        float2(1,1),
        float2(0,0),
        float2(1,0),
    };

float radius = 0.01f;

struct vsIn
{
	float4 pos : POSITION;
};


struct gsIn
{
    float4 pos: POSITION;
}; 

struct psIn
{
	float4 pos: SV_POSITION;
    float2 uv: TEXCOORD0;
};

gsIn VS(vsIn input)
{
    gsIn output;
    output.pos  = input.pos;
    return output;
}


[maxvertexcount(4)]
void GS_Particle(point gsIn input[1], inout TriangleStream<psIn> SpriteStream)
{
    psIn output;
    for(int i=0; i<4; i++)
    {
        float3 position = g_positions[i]*radius;
        position = mul( position, (float3x3)tVI ) + input[0].pos.xyz;
        output.pos = mul( float4(position,1.0), tWVP );
        output.uv = g_texcoords[i];
        SpriteStream.Append(output);
    }
    SpriteStream.RestartStrip();
}

float4 PS_Tex(psIn input): SV_Target
{
    float4 col = texture2d.Sample( g_samLinear, input.uv);
    return col;
}


technique10 RenderSprite
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetGeometryShader( CompileShader( gs_4_0, GS_Particle() ) );
		SetPixelShader( CompileShader( ps_4_0, PS_Tex() ) );
	}
} 


 
