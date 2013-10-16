//@author: vux
//@help: template for standard shaders
//@tags: template
//@credits: 

Texture2D worldTexture <string uiname="World XYZ";>;
Texture2D imageTexture <string uiname="Image";>;
 
cbuffer cbPerDraw : register( b0 )
{
	float4x4 tVP : VIEWPROJECTION;	
};

cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLD;
	float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
};

struct VS_IN
{
	float4 PosO : POSITION;
	float4 TexCd : TEXCOORD0;

};

struct vs2ps
{
    float4 PosWVP: SV_POSITION;
    int2 Index: TEXCOORD0;
	float Size : PSIZE0;
	float Discard : TEXCOORD1;
};

vs2ps VS(VS_IN input)
{
    vs2ps output;
	
	int cols, rows, levels;
	worldTexture.GetDimensions(0, cols, rows, levels);
	output.Index.x = (float) cols * input.TexCd.x;
	output.Index.y = (float) rows * input.TexCd.y;
	
	float4 PosO = worldTexture[output.Index];
	output.PosWVP = mul(PosO, mul(tW,tVP));
	
	output.Size = 300.0f;
	output.Discard = !(PosO.w > 0.5);
    return output;
}




float4 PS(vs2ps In): SV_Target
{
	if (In.Discard) {
		discard;
	}
    float4 col = imageTexture[In.Index];
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




