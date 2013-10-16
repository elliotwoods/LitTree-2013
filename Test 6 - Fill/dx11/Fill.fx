Texture2D<float4> World;
RWTexture2D<float> Output : BACKBUFFER;

cbuffer cColor : register(b0)
{
	float2 size : TARGETSIZE;
	float Attack = 0.01f;
	float MaxStepWorldDistance = 0.05f;
	int PyramidScale = 2;
	float KillPower = 4;
}

int makeStepValue(int offset) {
	//const int steps[9] = {1, 2, 4, 7, 12, 20, 33, 54, 88};
	return offset == 0 ? 0 : pow(2, (offset - 1) * 2) * sign(offset);
}

[numthreads(4, 4, 1)]
void main(uint3 threadID : SV_DispatchThreadID)
{
	const int Steps = 5;
	const float existenceThreshold = 0.001f;
	
	int2 xy = int2(threadID.xy) * PyramidScale;
	float3 myPosition = World[xy].xyz;
	float myValue = Output[xy];
	
	if (length(myPosition) < existenceThreshold) {
		Output[xy] = 0.0f;
		//return;
	}
	
	for(int i = -Steps; i <= Steps; i++) {
		for(int j = -Steps; j <= Steps; j++) {			
			int2 offset = int2(i, j);
			
			float4 outputLookup = World[xy + offset];
			float3 outputPosition = outputLookup.xyz;
			float distance = length(outputPosition - myPosition);
			float killFactor = 1.0f - smoothstep(0, MaxStepWorldDistance, distance);
			killFactor = pow(abs(killFactor), KillPower);
			
			float addition = myValue * killFactor * Attack;
			Output[xy + offset] = clamp(Output[xy + offset] + addition, 0.0f, 1.0f);
			
			if (length(outputPosition) < existenceThreshold || outputLookup.a < 0.5f) {
				Output[xy + offset] = 0.0f;
			}
		}
	}
}

technique11 Fill
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, main() ) );
	}
}




