float4x4 tWVP: WORLDVIEWPROJECTION;
float4x4 tVI : VIEWINVERSE;

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
};

gsIn VS(vsIn input)
{
    gsIn output;
    output.pos  = input.pos;
    return output;
}

float minedgelength = 0.1f;

void AppendEdge(float3 p1,float3 p2,inout LineStream<psIn> gsout)
{
	psIn output;
	if (distance(p1,p2) > minedgelength)
	{
		output.pos =  mul( float4(p1,1.0), tWVP );
		gsout.Append(output);
		output.pos =  mul( float4(p2,1.0), tWVP );
		gsout.Append(output);	
		gsout.RestartStrip();
	}
}

void AppendEdgeAll(float3 p1,float3 p2,float3 p3,inout LineStream<psIn> gsout)
{
	psIn output;
	
	float3 dtest;
	dtest.x = distance(p1,p2) > minedgelength ? 1.0f : 0.0f;
	dtest.y = distance(p3,p1) > minedgelength ? 1.0f : 0.0f;
	dtest.z = distance(p2,p3) > minedgelength ? 1.0f : 0.0f;
	
	if (any(dtest))
	{
		output.pos =  mul( float4(p1,1.0), tWVP );
		gsout.Append(output);
		output.pos =  mul( float4(p2,1.0), tWVP );
		gsout.Append(output);
		output.pos =  mul( float4(p3,1.0), tWVP );
		gsout.Append(output);
	}
}

[maxvertexcount(4)]
void GS_Line(triangle gsIn input[3], inout LineStream<psIn> gsout)
{
	psIn output;
	
	float3 p1 = input[0].pos.xyz;
	float3 p2 = input[1].pos.xyz;
	float3 p3 = input[2].pos.xyz;

	AppendEdgeAll(p1,p2,p3,gsout);
		
}

float4 PS_Tex(psIn input): SV_Target
{
    return 1;
}


technique10 RenderSprite
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetGeometryShader( CompileShader( gs_4_0, GS_Line() ) );
		SetPixelShader( CompileShader( ps_4_0, PS_Tex() ) );
	}
} 


 
