//@author: vux
//@help: standard constant shader
//@tags: color
//@credits: 

Texture2D texture2d <string uiname="Texture";>;

SamplerState g_samLinear : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

 
cbuffer cbPerDraw : register( b0 )
{
	float4x4 tVP : VIEWPROJECTION;
};


cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLD;
	float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 
	float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
	float4x4 tTex <string uiname="Texture Transform"; bool uvspace=true; >;
	float4x4 tColor <string uiname="Color Transform";>;
};

struct VS_IN
{
	float4 PosO : POSITION;
	float4 TexCd : TEXCOORD0;

};

struct vs2ps
{
    float4 PosWVP: SV_POSITION;
    float4 TexCd: TEXCOORD0;
	float Discard : TEXCOORD1;
	float Z : COLOR0;
};

vs2ps VS(VS_IN input)
{
    vs2ps Out = (vs2ps)0;
	int width, height, levels;
	texture2d.GetDimensions(0, width, height, levels);
	int2 xy = float2(width, height) * input.TexCd.xy;
	
	float4 PosO = texture2d[xy];
    Out.PosWVP  = mul(PosO,mul(tW,tVP));
    Out.TexCd = mul(input.TexCd, tTex);
	Out.Discard = length(PosO.xyz) < 0.5f;
	
	Out.Z = Out.PosWVP.z / Out.PosWVP.w;
    return Out;
}




float4 PS(vs2ps In): SV_Target
{
	if (In.Discard > 0.001f) {
		discard;
	}
    float4 col = texture2d.Sample(g_samLinear,In.TexCd.xy) * cAmb;
	col.a *= Alpha;
    return col;
}


float4 PSDepthInView(vs2ps In): SV_Target
{
	if (In.Discard > 0.001f) {
		discard;
	}
	float4 col;
	col.rgb = In.Z;
	col.a = Alpha;
    return col;
}




technique10 Constant
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}


technique10 DepthInView
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PSDepthInView() ) );
	}
}



