Shader "Fixes/SeeThrough"
{
    Properties
    {
        _PlayerPos("PlayerPos", Vector) = (0.5, 0.5, 0, 0)
        _Size("Size", Float) = 1
        _Smoothness("Smoothness", Range(0, 1)) = 0.5
        _Opacity("Opacity", Range(0, 1)) = 1
        [NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
        _Tint("Tint", Color) = (0, 0, 0, 0)
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
        SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue" = "Transparent"
            "ShaderGraphShader" = "true"
            "ShaderGraphTargetId" = "UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _CLUSTERED_RENDERING
        // GraphKeywords: <None>

        // Defines

        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float3 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float2 interp6 : INTERP6;
             float3 interp7 : INTERP7;
             float4 interp8 : INTERP8;
             float4 interp9 : INTERP9;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

        PackedVaryings PackVaryings(Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz = input.positionWS;
            output.interp1.xyz = input.normalWS;
            output.interp2.xyzw = input.tangentWS;
            output.interp3.xyzw = input.texCoord0;
            output.interp4.xyz = input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp6.xy = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp7.xyz = input.sh;
            #endif
            output.interp8.xyzw = input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp9.xyzw = input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

        Varyings UnpackVaryings(PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp5.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp6.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp7.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp8.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp9.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }


        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float2 _PlayerPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        float4 _MainTex_TexelSize;
        float4 _Tint;
        CBUFFER_END

            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            // Graph Includes
            // GraphIncludes: <None>

            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif

            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif

            // Graph Functions

            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
            {
                Out = A * B;
            }

            void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
            {
                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }

            void Unity_Add_float2(float2 A, float2 B, out float2 Out)
            {
                Out = A + B;
            }

            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
            {
                Out = UV * Tiling + Offset;
            }

            void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
            {
                Out = A * B;
            }

            void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
            {
                Out = A - B;
            }

            void Unity_Divide_float(float A, float B, out float Out)
            {
                Out = A / B;
            }

            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
                Out = A * B;
            }

            void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
            {
                Out = A / B;
            }

            void Unity_Length_float2(float2 In, out float Out)
            {
                Out = length(In);
            }

            void Unity_OneMinus_float(float In, out float Out)
            {
                Out = 1 - In;
            }

            void Unity_Saturate_float(float In, out float Out)
            {
                Out = saturate(In);
            }

            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
            {
                Out = smoothstep(Edge1, Edge2, In);
            }


            float2 Unity_GradientNoise_Dir_float(float2 p)
            {
                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                p = p % 289;
                // need full precision, otherwise half overflows when p > 1
                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                x = (34 * x + 1) * x % 289;
                x = frac(x / 41) * 2 - 1;
                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
            }

            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
            {
                float2 p = UV * Scale;
                float2 ip = floor(p);
                float2 fp = frac(p);
                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
            }

            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }

            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
            {
                Out = clamp(In, Min, Max);
            }

            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };

            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }

            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif

            // Graph Pixel
            struct SurfaceDescription
            {
                float3 BaseColor;
                float3 NormalTS;
                float3 Emission;
                float Metallic;
                float Smoothness;
                float Occlusion;
                float Alpha;
            };

            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                UnityTexture2D _Property_9e5787ff777c43db8b9ea801e309fc9b_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                float4 _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_9e5787ff777c43db8b9ea801e309fc9b_Out_0.tex, _Property_9e5787ff777c43db8b9ea801e309fc9b_Out_0.samplerstate, _Property_9e5787ff777c43db8b9ea801e309fc9b_Out_0.GetTransformedUV(IN.uv0.xy));
                float _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_R_4 = _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0.r;
                float _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_G_5 = _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0.g;
                float _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_B_6 = _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0.b;
                float _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_A_7 = _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0.a;
                float4 _Property_b37916350fdd4197bd2377cc4806d65b_Out_0 = _Tint;
                float4 _Multiply_3a41105f027849dd80cc07ab836b38e9_Out_2;
                Unity_Multiply_float4_float4(_SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0, _Property_b37916350fdd4197bd2377cc4806d65b_Out_0, _Multiply_3a41105f027849dd80cc07ab836b38e9_Out_2);
                float _Property_3da0c57fa07440e889d95435bcf4a0aa_Out_0 = _Smoothness;
                float4 _ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                float2 _Property_eb4fae0eaa8e4fe3ac5491ba9981452e_Out_0 = _PlayerPos;
                float2 _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3;
                Unity_Remap_float2(_Property_eb4fae0eaa8e4fe3ac5491ba9981452e_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3);
                float2 _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2;
                Unity_Add_float2((_ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0.xy), _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3, _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2);
                float2 _TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3;
                Unity_TilingAndOffset_float((_ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0.xy), float2 (1, 1), _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2, _TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3);
                float2 _Multiply_3c357794168141569d428cf555d98c3b_Out_2;
                Unity_Multiply_float2_float2(_TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3, float2(2, 2), _Multiply_3c357794168141569d428cf555d98c3b_Out_2);
                float2 _Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2;
                Unity_Subtract_float2(_Multiply_3c357794168141569d428cf555d98c3b_Out_2, float2(1, 1), _Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2);
                float _Divide_460be555daed4e16b511e7a1a2600d99_Out_2;
                Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_460be555daed4e16b511e7a1a2600d99_Out_2);
                float _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0 = _Size;
                float _Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2;
                Unity_Multiply_float_float(_Divide_460be555daed4e16b511e7a1a2600d99_Out_2, _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0, _Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2);
                float2 _Vector2_80510f86d5564e69a6a87561f22e4e37_Out_0 = float2(_Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2, _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0);
                float2 _Divide_ef5d4c7889484ffb9129e280560351a9_Out_2;
                Unity_Divide_float2(_Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2, _Vector2_80510f86d5564e69a6a87561f22e4e37_Out_0, _Divide_ef5d4c7889484ffb9129e280560351a9_Out_2);
                float _Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1;
                Unity_Length_float2(_Divide_ef5d4c7889484ffb9129e280560351a9_Out_2, _Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1);
                float _OneMinus_7f29374d2cde401bb19dcde091630251_Out_1;
                Unity_OneMinus_float(_Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1, _OneMinus_7f29374d2cde401bb19dcde091630251_Out_1);
                float _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1;
                Unity_Saturate_float(_OneMinus_7f29374d2cde401bb19dcde091630251_Out_1, _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1);
                float _Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3;
                Unity_Smoothstep_float(0, _Property_3da0c57fa07440e889d95435bcf4a0aa_Out_0, _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1, _Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3);
                float _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2;
                Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2);
                float _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2;
                Unity_Multiply_float_float(_Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3, _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2, _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2);
                float _Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2;
                Unity_Add_float(_Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3, _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2, _Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2);
                float _Property_aa04ea6e4cde4cf283c8da199d728c36_Out_0 = _Opacity;
                float _Multiply_3b690d7382254556a19014f1915567e9_Out_2;
                Unity_Multiply_float_float(_Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2, _Property_aa04ea6e4cde4cf283c8da199d728c36_Out_0, _Multiply_3b690d7382254556a19014f1915567e9_Out_2);
                float _Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3;
                Unity_Clamp_float(_Multiply_3b690d7382254556a19014f1915567e9_Out_2, 0, 1, _Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3);
                float _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1;
                Unity_OneMinus_float(_Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3, _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1);
                surface.BaseColor = (_Multiply_3a41105f027849dd80cc07ab836b38e9_Out_2.xyz);
                surface.NormalTS = IN.TangentSpaceNormal;
                surface.Emission = float3(0, 0, 0);
                surface.Metallic = 0;
                surface.Smoothness = 0.5;
                surface.Occlusion = 1;
                surface.Alpha = _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1;
                return surface;
            }

            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                output.ObjectSpaceNormal = input.normalOS;
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;

                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

            #endif





                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                output.WorldSpacePosition = input.positionWS;
                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                output.uv0 = input.texCoord0;
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                    return output;
            }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif

            ENDHLSL
            }
            Pass
            {
                Name "GBuffer"
                Tags
                {
                    "LightMode" = "UniversalGBuffer"
                }

                // Render State
                Cull Back
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite Off

                // Debug
                // <None>

                // --------------------------------------------------
                // Pass

                HLSLPROGRAM

                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
                #pragma instancing_options renderinglayer
                #pragma multi_compile _ DOTS_INSTANCING_ON
                #pragma vertex vert
                #pragma fragment frag

                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>

                // Keywords
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DYNAMICLIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
                #pragma multi_compile_fragment _ _SHADOWS_SOFT
                #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
                #pragma multi_compile _ SHADOWS_SHADOWMASK
                #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
                #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
                #pragma multi_compile_fragment _ _LIGHT_LAYERS
                #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
                #pragma multi_compile_fragment _ DEBUG_DISPLAY
                // GraphKeywords: <None>

                // Defines

                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define ATTRIBUTES_NEED_TEXCOORD2
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_TANGENT_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define VARYINGS_NEED_VIEWDIRECTION_WS
                #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                #define VARYINGS_NEED_SHADOW_COORD
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_GBUFFER
                #define _FOG_FRAGMENT 1
                #define _SURFACE_TYPE_TRANSPARENT 1
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                // custom interpolator pre-include
                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                // --------------------------------------------------
                // Structs and Packing

                // custom interpolators pre packing
                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv0 : TEXCOORD0;
                     float4 uv1 : TEXCOORD1;
                     float4 uv2 : TEXCOORD2;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float3 normalWS;
                     float4 tangentWS;
                     float4 texCoord0;
                     float3 viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                     float2 staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                     float2 dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                     float3 sh;
                    #endif
                     float4 fogFactorAndVertexLight;
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                     float4 shadowCoord;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 TangentSpaceNormal;
                     float3 WorldSpacePosition;
                     float4 ScreenPosition;
                     float4 uv0;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 interp0 : INTERP0;
                     float3 interp1 : INTERP1;
                     float4 interp2 : INTERP2;
                     float4 interp3 : INTERP3;
                     float3 interp4 : INTERP4;
                     float2 interp5 : INTERP5;
                     float2 interp6 : INTERP6;
                     float3 interp7 : INTERP7;
                     float4 interp8 : INTERP8;
                     float4 interp9 : INTERP9;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };

                PackedVaryings PackVaryings(Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.interp0.xyz = input.positionWS;
                    output.interp1.xyz = input.normalWS;
                    output.interp2.xyzw = input.tangentWS;
                    output.interp3.xyzw = input.texCoord0;
                    output.interp4.xyz = input.viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                    output.interp5.xy = input.staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.interp6.xy = input.dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.interp7.xyz = input.sh;
                    #endif
                    output.interp8.xyzw = input.fogFactorAndVertexLight;
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.interp9.xyzw = input.shadowCoord;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }

                Varyings UnpackVaryings(PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    output.tangentWS = input.interp2.xyzw;
                    output.texCoord0 = input.interp3.xyzw;
                    output.viewDirectionWS = input.interp4.xyz;
                    #if defined(LIGHTMAP_ON)
                    output.staticLightmapUV = input.interp5.xy;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.dynamicLightmapUV = input.interp6.xy;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.interp7.xyz;
                    #endif
                    output.fogFactorAndVertexLight = input.interp8.xyzw;
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.shadowCoord = input.interp9.xyzw;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }


                // --------------------------------------------------
                // Graph

                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float2 _PlayerPos;
                float _Size;
                float _Smoothness;
                float _Opacity;
                float4 _MainTex_TexelSize;
                float4 _Tint;
                CBUFFER_END

                    // Object and Global properties
                    SAMPLER(SamplerState_Linear_Repeat);
                    TEXTURE2D(_MainTex);
                    SAMPLER(sampler_MainTex);

                    // Graph Includes
                    // GraphIncludes: <None>

                    // -- Property used by ScenePickingPass
                    #ifdef SCENEPICKINGPASS
                    float4 _SelectionID;
                    #endif

                    // -- Properties used by SceneSelectionPass
                    #ifdef SCENESELECTIONPASS
                    int _ObjectId;
                    int _PassValue;
                    #endif

                    // Graph Functions

                    void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                    {
                        Out = A * B;
                    }

                    void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                    {
                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                    }

                    void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                    {
                        Out = A + B;
                    }

                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                    {
                        Out = UV * Tiling + Offset;
                    }

                    void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                    {
                        Out = A * B;
                    }

                    void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                    {
                        Out = A - B;
                    }

                    void Unity_Divide_float(float A, float B, out float Out)
                    {
                        Out = A / B;
                    }

                    void Unity_Multiply_float_float(float A, float B, out float Out)
                    {
                        Out = A * B;
                    }

                    void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                    {
                        Out = A / B;
                    }

                    void Unity_Length_float2(float2 In, out float Out)
                    {
                        Out = length(In);
                    }

                    void Unity_OneMinus_float(float In, out float Out)
                    {
                        Out = 1 - In;
                    }

                    void Unity_Saturate_float(float In, out float Out)
                    {
                        Out = saturate(In);
                    }

                    void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                    {
                        Out = smoothstep(Edge1, Edge2, In);
                    }


                    float2 Unity_GradientNoise_Dir_float(float2 p)
                    {
                        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                        p = p % 289;
                        // need full precision, otherwise half overflows when p > 1
                        float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                        x = (34 * x + 1) * x % 289;
                        x = frac(x / 41) * 2 - 1;
                        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                    }

                    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                    {
                        float2 p = UV * Scale;
                        float2 ip = floor(p);
                        float2 fp = frac(p);
                        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                    }

                    void Unity_Add_float(float A, float B, out float Out)
                    {
                        Out = A + B;
                    }

                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                    {
                        Out = clamp(In, Min, Max);
                    }

                    // Custom interpolators pre vertex
                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                    // Graph Vertex
                    struct VertexDescription
                    {
                        float3 Position;
                        float3 Normal;
                        float3 Tangent;
                    };

                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                    {
                        VertexDescription description = (VertexDescription)0;
                        description.Position = IN.ObjectSpacePosition;
                        description.Normal = IN.ObjectSpaceNormal;
                        description.Tangent = IN.ObjectSpaceTangent;
                        return description;
                    }

                    // Custom interpolators, pre surface
                    #ifdef FEATURES_GRAPH_VERTEX
                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                    {
                    return output;
                    }
                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                    #endif

                    // Graph Pixel
                    struct SurfaceDescription
                    {
                        float3 BaseColor;
                        float3 NormalTS;
                        float3 Emission;
                        float Metallic;
                        float Smoothness;
                        float Occlusion;
                        float Alpha;
                    };

                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                    {
                        SurfaceDescription surface = (SurfaceDescription)0;
                        UnityTexture2D _Property_9e5787ff777c43db8b9ea801e309fc9b_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                        float4 _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_9e5787ff777c43db8b9ea801e309fc9b_Out_0.tex, _Property_9e5787ff777c43db8b9ea801e309fc9b_Out_0.samplerstate, _Property_9e5787ff777c43db8b9ea801e309fc9b_Out_0.GetTransformedUV(IN.uv0.xy));
                        float _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_R_4 = _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0.r;
                        float _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_G_5 = _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0.g;
                        float _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_B_6 = _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0.b;
                        float _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_A_7 = _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0.a;
                        float4 _Property_b37916350fdd4197bd2377cc4806d65b_Out_0 = _Tint;
                        float4 _Multiply_3a41105f027849dd80cc07ab836b38e9_Out_2;
                        Unity_Multiply_float4_float4(_SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0, _Property_b37916350fdd4197bd2377cc4806d65b_Out_0, _Multiply_3a41105f027849dd80cc07ab836b38e9_Out_2);
                        float _Property_3da0c57fa07440e889d95435bcf4a0aa_Out_0 = _Smoothness;
                        float4 _ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                        float2 _Property_eb4fae0eaa8e4fe3ac5491ba9981452e_Out_0 = _PlayerPos;
                        float2 _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3;
                        Unity_Remap_float2(_Property_eb4fae0eaa8e4fe3ac5491ba9981452e_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3);
                        float2 _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2;
                        Unity_Add_float2((_ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0.xy), _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3, _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2);
                        float2 _TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3;
                        Unity_TilingAndOffset_float((_ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0.xy), float2 (1, 1), _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2, _TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3);
                        float2 _Multiply_3c357794168141569d428cf555d98c3b_Out_2;
                        Unity_Multiply_float2_float2(_TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3, float2(2, 2), _Multiply_3c357794168141569d428cf555d98c3b_Out_2);
                        float2 _Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2;
                        Unity_Subtract_float2(_Multiply_3c357794168141569d428cf555d98c3b_Out_2, float2(1, 1), _Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2);
                        float _Divide_460be555daed4e16b511e7a1a2600d99_Out_2;
                        Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_460be555daed4e16b511e7a1a2600d99_Out_2);
                        float _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0 = _Size;
                        float _Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2;
                        Unity_Multiply_float_float(_Divide_460be555daed4e16b511e7a1a2600d99_Out_2, _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0, _Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2);
                        float2 _Vector2_80510f86d5564e69a6a87561f22e4e37_Out_0 = float2(_Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2, _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0);
                        float2 _Divide_ef5d4c7889484ffb9129e280560351a9_Out_2;
                        Unity_Divide_float2(_Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2, _Vector2_80510f86d5564e69a6a87561f22e4e37_Out_0, _Divide_ef5d4c7889484ffb9129e280560351a9_Out_2);
                        float _Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1;
                        Unity_Length_float2(_Divide_ef5d4c7889484ffb9129e280560351a9_Out_2, _Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1);
                        float _OneMinus_7f29374d2cde401bb19dcde091630251_Out_1;
                        Unity_OneMinus_float(_Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1, _OneMinus_7f29374d2cde401bb19dcde091630251_Out_1);
                        float _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1;
                        Unity_Saturate_float(_OneMinus_7f29374d2cde401bb19dcde091630251_Out_1, _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1);
                        float _Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3;
                        Unity_Smoothstep_float(0, _Property_3da0c57fa07440e889d95435bcf4a0aa_Out_0, _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1, _Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3);
                        float _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2;
                        Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2);
                        float _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2;
                        Unity_Multiply_float_float(_Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3, _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2, _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2);
                        float _Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2;
                        Unity_Add_float(_Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3, _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2, _Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2);
                        float _Property_aa04ea6e4cde4cf283c8da199d728c36_Out_0 = _Opacity;
                        float _Multiply_3b690d7382254556a19014f1915567e9_Out_2;
                        Unity_Multiply_float_float(_Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2, _Property_aa04ea6e4cde4cf283c8da199d728c36_Out_0, _Multiply_3b690d7382254556a19014f1915567e9_Out_2);
                        float _Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3;
                        Unity_Clamp_float(_Multiply_3b690d7382254556a19014f1915567e9_Out_2, 0, 1, _Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3);
                        float _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1;
                        Unity_OneMinus_float(_Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3, _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1);
                        surface.BaseColor = (_Multiply_3a41105f027849dd80cc07ab836b38e9_Out_2.xyz);
                        surface.NormalTS = IN.TangentSpaceNormal;
                        surface.Emission = float3(0, 0, 0);
                        surface.Metallic = 0;
                        surface.Smoothness = 0.5;
                        surface.Occlusion = 1;
                        surface.Alpha = _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1;
                        return surface;
                    }

                    // --------------------------------------------------
                    // Build Graph Inputs
                    #ifdef HAVE_VFX_MODIFICATION
                    #define VFX_SRP_ATTRIBUTES Attributes
                    #define VFX_SRP_VARYINGS Varyings
                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                    #endif
                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                    {
                        VertexDescriptionInputs output;
                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                        output.ObjectSpaceNormal = input.normalOS;
                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                        output.ObjectSpacePosition = input.positionOS;

                        return output;
                    }
                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                    {
                        SurfaceDescriptionInputs output;
                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                    #ifdef HAVE_VFX_MODIFICATION
                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                    #endif





                        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                        output.WorldSpacePosition = input.positionWS;
                        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                        output.uv0 = input.texCoord0;
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                    #else
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                    #endif
                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                            return output;
                    }

                    // --------------------------------------------------
                    // Main

                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

                    // --------------------------------------------------
                    // Visual Effect Vertex Invocations
                    #ifdef HAVE_VFX_MODIFICATION
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                    #endif

                    ENDHLSL
                    }
                    Pass
                    {
                        Name "ShadowCaster"
                        Tags
                        {
                            "LightMode" = "ShadowCaster"
                        }

                        // Render State
                        Cull Back
                        ZTest LEqual
                        ZWrite On
                        ColorMask 0

                        // Debug
                        // <None>

                        // --------------------------------------------------
                        // Pass

                        HLSLPROGRAM

                        // Pragmas
                        #pragma target 4.5
                        #pragma exclude_renderers gles gles3 glcore
                        #pragma multi_compile_instancing
                        #pragma multi_compile _ DOTS_INSTANCING_ON
                        #pragma vertex vert
                        #pragma fragment frag

                        // DotsInstancingOptions: <None>
                        // HybridV1InjectedBuiltinProperties: <None>

                        // Keywords
                        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
                        // GraphKeywords: <None>

                        // Defines

                        #define _NORMALMAP 1
                        #define _NORMAL_DROPOFF_TS 1
                        #define ATTRIBUTES_NEED_NORMAL
                        #define ATTRIBUTES_NEED_TANGENT
                        #define ATTRIBUTES_NEED_TEXCOORD0
                        #define VARYINGS_NEED_POSITION_WS
                        #define VARYINGS_NEED_NORMAL_WS
                        #define VARYINGS_NEED_TEXCOORD0
                        #define FEATURES_GRAPH_VERTEX
                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                        #define SHADERPASS SHADERPASS_SHADOWCASTER
                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                        // custom interpolator pre-include
                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                        // Includes
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                        // --------------------------------------------------
                        // Structs and Packing

                        // custom interpolators pre packing
                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                        struct Attributes
                        {
                             float3 positionOS : POSITION;
                             float3 normalOS : NORMAL;
                             float4 tangentOS : TANGENT;
                             float4 uv0 : TEXCOORD0;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : INSTANCEID_SEMANTIC;
                            #endif
                        };
                        struct Varyings
                        {
                             float4 positionCS : SV_POSITION;
                             float3 positionWS;
                             float3 normalWS;
                             float4 texCoord0;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };
                        struct SurfaceDescriptionInputs
                        {
                             float3 WorldSpacePosition;
                             float4 ScreenPosition;
                             float4 uv0;
                        };
                        struct VertexDescriptionInputs
                        {
                             float3 ObjectSpaceNormal;
                             float3 ObjectSpaceTangent;
                             float3 ObjectSpacePosition;
                        };
                        struct PackedVaryings
                        {
                             float4 positionCS : SV_POSITION;
                             float3 interp0 : INTERP0;
                             float3 interp1 : INTERP1;
                             float4 interp2 : INTERP2;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };

                        PackedVaryings PackVaryings(Varyings input)
                        {
                            PackedVaryings output;
                            ZERO_INITIALIZE(PackedVaryings, output);
                            output.positionCS = input.positionCS;
                            output.interp0.xyz = input.positionWS;
                            output.interp1.xyz = input.normalWS;
                            output.interp2.xyzw = input.texCoord0;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }

                        Varyings UnpackVaryings(PackedVaryings input)
                        {
                            Varyings output;
                            output.positionCS = input.positionCS;
                            output.positionWS = input.interp0.xyz;
                            output.normalWS = input.interp1.xyz;
                            output.texCoord0 = input.interp2.xyzw;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }


                        // --------------------------------------------------
                        // Graph

                        // Graph Properties
                        CBUFFER_START(UnityPerMaterial)
                        float2 _PlayerPos;
                        float _Size;
                        float _Smoothness;
                        float _Opacity;
                        float4 _MainTex_TexelSize;
                        float4 _Tint;
                        CBUFFER_END

                            // Object and Global properties
                            SAMPLER(SamplerState_Linear_Repeat);
                            TEXTURE2D(_MainTex);
                            SAMPLER(sampler_MainTex);

                            // Graph Includes
                            // GraphIncludes: <None>

                            // -- Property used by ScenePickingPass
                            #ifdef SCENEPICKINGPASS
                            float4 _SelectionID;
                            #endif

                            // -- Properties used by SceneSelectionPass
                            #ifdef SCENESELECTIONPASS
                            int _ObjectId;
                            int _PassValue;
                            #endif

                            // Graph Functions

                            void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                            {
                                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                            }

                            void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                            {
                                Out = A + B;
                            }

                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                            {
                                Out = UV * Tiling + Offset;
                            }

                            void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                            {
                                Out = A * B;
                            }

                            void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                            {
                                Out = A - B;
                            }

                            void Unity_Divide_float(float A, float B, out float Out)
                            {
                                Out = A / B;
                            }

                            void Unity_Multiply_float_float(float A, float B, out float Out)
                            {
                                Out = A * B;
                            }

                            void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                            {
                                Out = A / B;
                            }

                            void Unity_Length_float2(float2 In, out float Out)
                            {
                                Out = length(In);
                            }

                            void Unity_OneMinus_float(float In, out float Out)
                            {
                                Out = 1 - In;
                            }

                            void Unity_Saturate_float(float In, out float Out)
                            {
                                Out = saturate(In);
                            }

                            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                            {
                                Out = smoothstep(Edge1, Edge2, In);
                            }


                            float2 Unity_GradientNoise_Dir_float(float2 p)
                            {
                                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                p = p % 289;
                                // need full precision, otherwise half overflows when p > 1
                                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                x = (34 * x + 1) * x % 289;
                                x = frac(x / 41) * 2 - 1;
                                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                            }

                            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                            {
                                float2 p = UV * Scale;
                                float2 ip = floor(p);
                                float2 fp = frac(p);
                                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                            }

                            void Unity_Add_float(float A, float B, out float Out)
                            {
                                Out = A + B;
                            }

                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                            {
                                Out = clamp(In, Min, Max);
                            }

                            // Custom interpolators pre vertex
                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                            // Graph Vertex
                            struct VertexDescription
                            {
                                float3 Position;
                                float3 Normal;
                                float3 Tangent;
                            };

                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                            {
                                VertexDescription description = (VertexDescription)0;
                                description.Position = IN.ObjectSpacePosition;
                                description.Normal = IN.ObjectSpaceNormal;
                                description.Tangent = IN.ObjectSpaceTangent;
                                return description;
                            }

                            // Custom interpolators, pre surface
                            #ifdef FEATURES_GRAPH_VERTEX
                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                            {
                            return output;
                            }
                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                            #endif

                            // Graph Pixel
                            struct SurfaceDescription
                            {
                                float Alpha;
                            };

                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                            {
                                SurfaceDescription surface = (SurfaceDescription)0;
                                float _Property_3da0c57fa07440e889d95435bcf4a0aa_Out_0 = _Smoothness;
                                float4 _ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                float2 _Property_eb4fae0eaa8e4fe3ac5491ba9981452e_Out_0 = _PlayerPos;
                                float2 _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3;
                                Unity_Remap_float2(_Property_eb4fae0eaa8e4fe3ac5491ba9981452e_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3);
                                float2 _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2;
                                Unity_Add_float2((_ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0.xy), _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3, _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2);
                                float2 _TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3;
                                Unity_TilingAndOffset_float((_ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0.xy), float2 (1, 1), _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2, _TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3);
                                float2 _Multiply_3c357794168141569d428cf555d98c3b_Out_2;
                                Unity_Multiply_float2_float2(_TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3, float2(2, 2), _Multiply_3c357794168141569d428cf555d98c3b_Out_2);
                                float2 _Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2;
                                Unity_Subtract_float2(_Multiply_3c357794168141569d428cf555d98c3b_Out_2, float2(1, 1), _Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2);
                                float _Divide_460be555daed4e16b511e7a1a2600d99_Out_2;
                                Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_460be555daed4e16b511e7a1a2600d99_Out_2);
                                float _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0 = _Size;
                                float _Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2;
                                Unity_Multiply_float_float(_Divide_460be555daed4e16b511e7a1a2600d99_Out_2, _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0, _Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2);
                                float2 _Vector2_80510f86d5564e69a6a87561f22e4e37_Out_0 = float2(_Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2, _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0);
                                float2 _Divide_ef5d4c7889484ffb9129e280560351a9_Out_2;
                                Unity_Divide_float2(_Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2, _Vector2_80510f86d5564e69a6a87561f22e4e37_Out_0, _Divide_ef5d4c7889484ffb9129e280560351a9_Out_2);
                                float _Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1;
                                Unity_Length_float2(_Divide_ef5d4c7889484ffb9129e280560351a9_Out_2, _Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1);
                                float _OneMinus_7f29374d2cde401bb19dcde091630251_Out_1;
                                Unity_OneMinus_float(_Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1, _OneMinus_7f29374d2cde401bb19dcde091630251_Out_1);
                                float _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1;
                                Unity_Saturate_float(_OneMinus_7f29374d2cde401bb19dcde091630251_Out_1, _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1);
                                float _Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3;
                                Unity_Smoothstep_float(0, _Property_3da0c57fa07440e889d95435bcf4a0aa_Out_0, _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1, _Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3);
                                float _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2;
                                Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2);
                                float _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2;
                                Unity_Multiply_float_float(_Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3, _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2, _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2);
                                float _Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2;
                                Unity_Add_float(_Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3, _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2, _Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2);
                                float _Property_aa04ea6e4cde4cf283c8da199d728c36_Out_0 = _Opacity;
                                float _Multiply_3b690d7382254556a19014f1915567e9_Out_2;
                                Unity_Multiply_float_float(_Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2, _Property_aa04ea6e4cde4cf283c8da199d728c36_Out_0, _Multiply_3b690d7382254556a19014f1915567e9_Out_2);
                                float _Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3;
                                Unity_Clamp_float(_Multiply_3b690d7382254556a19014f1915567e9_Out_2, 0, 1, _Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3);
                                float _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1;
                                Unity_OneMinus_float(_Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3, _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1);
                                surface.Alpha = _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1;
                                return surface;
                            }

                            // --------------------------------------------------
                            // Build Graph Inputs
                            #ifdef HAVE_VFX_MODIFICATION
                            #define VFX_SRP_ATTRIBUTES Attributes
                            #define VFX_SRP_VARYINGS Varyings
                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                            #endif
                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                            {
                                VertexDescriptionInputs output;
                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                output.ObjectSpaceNormal = input.normalOS;
                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                output.ObjectSpacePosition = input.positionOS;

                                return output;
                            }
                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                            {
                                SurfaceDescriptionInputs output;
                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                            #ifdef HAVE_VFX_MODIFICATION
                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                            #endif







                                output.WorldSpacePosition = input.positionWS;
                                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                output.uv0 = input.texCoord0;
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                            #else
                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                            #endif
                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                    return output;
                            }

                            // --------------------------------------------------
                            // Main

                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

                            // --------------------------------------------------
                            // Visual Effect Vertex Invocations
                            #ifdef HAVE_VFX_MODIFICATION
                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                            #endif

                            ENDHLSL
                            }
                            Pass
                            {
                                Name "DepthNormals"
                                Tags
                                {
                                    "LightMode" = "DepthNormals"
                                }

                                // Render State
                                Cull Back
                                ZTest LEqual
                                ZWrite On

                                // Debug
                                // <None>

                                // --------------------------------------------------
                                // Pass

                                HLSLPROGRAM

                                // Pragmas
                                #pragma target 4.5
                                #pragma exclude_renderers gles gles3 glcore
                                #pragma multi_compile_instancing
                                #pragma multi_compile _ DOTS_INSTANCING_ON
                                #pragma vertex vert
                                #pragma fragment frag

                                // DotsInstancingOptions: <None>
                                // HybridV1InjectedBuiltinProperties: <None>

                                // Keywords
                                // PassKeywords: <None>
                                // GraphKeywords: <None>

                                // Defines

                                #define _NORMALMAP 1
                                #define _NORMAL_DROPOFF_TS 1
                                #define ATTRIBUTES_NEED_NORMAL
                                #define ATTRIBUTES_NEED_TANGENT
                                #define ATTRIBUTES_NEED_TEXCOORD0
                                #define ATTRIBUTES_NEED_TEXCOORD1
                                #define VARYINGS_NEED_POSITION_WS
                                #define VARYINGS_NEED_NORMAL_WS
                                #define VARYINGS_NEED_TANGENT_WS
                                #define VARYINGS_NEED_TEXCOORD0
                                #define FEATURES_GRAPH_VERTEX
                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                #define SHADERPASS SHADERPASS_DEPTHNORMALS
                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                // custom interpolator pre-include
                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                // Includes
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                // --------------------------------------------------
                                // Structs and Packing

                                // custom interpolators pre packing
                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                struct Attributes
                                {
                                     float3 positionOS : POSITION;
                                     float3 normalOS : NORMAL;
                                     float4 tangentOS : TANGENT;
                                     float4 uv0 : TEXCOORD0;
                                     float4 uv1 : TEXCOORD1;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : INSTANCEID_SEMANTIC;
                                    #endif
                                };
                                struct Varyings
                                {
                                     float4 positionCS : SV_POSITION;
                                     float3 positionWS;
                                     float3 normalWS;
                                     float4 tangentWS;
                                     float4 texCoord0;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                    #endif
                                };
                                struct SurfaceDescriptionInputs
                                {
                                     float3 TangentSpaceNormal;
                                     float3 WorldSpacePosition;
                                     float4 ScreenPosition;
                                     float4 uv0;
                                };
                                struct VertexDescriptionInputs
                                {
                                     float3 ObjectSpaceNormal;
                                     float3 ObjectSpaceTangent;
                                     float3 ObjectSpacePosition;
                                };
                                struct PackedVaryings
                                {
                                     float4 positionCS : SV_POSITION;
                                     float3 interp0 : INTERP0;
                                     float3 interp1 : INTERP1;
                                     float4 interp2 : INTERP2;
                                     float4 interp3 : INTERP3;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                    #endif
                                };

                                PackedVaryings PackVaryings(Varyings input)
                                {
                                    PackedVaryings output;
                                    ZERO_INITIALIZE(PackedVaryings, output);
                                    output.positionCS = input.positionCS;
                                    output.interp0.xyz = input.positionWS;
                                    output.interp1.xyz = input.normalWS;
                                    output.interp2.xyzw = input.tangentWS;
                                    output.interp3.xyzw = input.texCoord0;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    output.instanceID = input.instanceID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    output.cullFace = input.cullFace;
                                    #endif
                                    return output;
                                }

                                Varyings UnpackVaryings(PackedVaryings input)
                                {
                                    Varyings output;
                                    output.positionCS = input.positionCS;
                                    output.positionWS = input.interp0.xyz;
                                    output.normalWS = input.interp1.xyz;
                                    output.tangentWS = input.interp2.xyzw;
                                    output.texCoord0 = input.interp3.xyzw;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    output.instanceID = input.instanceID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    output.cullFace = input.cullFace;
                                    #endif
                                    return output;
                                }


                                // --------------------------------------------------
                                // Graph

                                // Graph Properties
                                CBUFFER_START(UnityPerMaterial)
                                float2 _PlayerPos;
                                float _Size;
                                float _Smoothness;
                                float _Opacity;
                                float4 _MainTex_TexelSize;
                                float4 _Tint;
                                CBUFFER_END

                                    // Object and Global properties
                                    SAMPLER(SamplerState_Linear_Repeat);
                                    TEXTURE2D(_MainTex);
                                    SAMPLER(sampler_MainTex);

                                    // Graph Includes
                                    // GraphIncludes: <None>

                                    // -- Property used by ScenePickingPass
                                    #ifdef SCENEPICKINGPASS
                                    float4 _SelectionID;
                                    #endif

                                    // -- Properties used by SceneSelectionPass
                                    #ifdef SCENESELECTIONPASS
                                    int _ObjectId;
                                    int _PassValue;
                                    #endif

                                    // Graph Functions

                                    void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                    {
                                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                    }

                                    void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                    {
                                        Out = A + B;
                                    }

                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                    {
                                        Out = UV * Tiling + Offset;
                                    }

                                    void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                    {
                                        Out = A * B;
                                    }

                                    void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                    {
                                        Out = A - B;
                                    }

                                    void Unity_Divide_float(float A, float B, out float Out)
                                    {
                                        Out = A / B;
                                    }

                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                    {
                                        Out = A * B;
                                    }

                                    void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                    {
                                        Out = A / B;
                                    }

                                    void Unity_Length_float2(float2 In, out float Out)
                                    {
                                        Out = length(In);
                                    }

                                    void Unity_OneMinus_float(float In, out float Out)
                                    {
                                        Out = 1 - In;
                                    }

                                    void Unity_Saturate_float(float In, out float Out)
                                    {
                                        Out = saturate(In);
                                    }

                                    void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                    {
                                        Out = smoothstep(Edge1, Edge2, In);
                                    }


                                    float2 Unity_GradientNoise_Dir_float(float2 p)
                                    {
                                        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                        p = p % 289;
                                        // need full precision, otherwise half overflows when p > 1
                                        float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                        x = (34 * x + 1) * x % 289;
                                        x = frac(x / 41) * 2 - 1;
                                        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                    }

                                    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                    {
                                        float2 p = UV * Scale;
                                        float2 ip = floor(p);
                                        float2 fp = frac(p);
                                        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                    }

                                    void Unity_Add_float(float A, float B, out float Out)
                                    {
                                        Out = A + B;
                                    }

                                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                    {
                                        Out = clamp(In, Min, Max);
                                    }

                                    // Custom interpolators pre vertex
                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                    // Graph Vertex
                                    struct VertexDescription
                                    {
                                        float3 Position;
                                        float3 Normal;
                                        float3 Tangent;
                                    };

                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                    {
                                        VertexDescription description = (VertexDescription)0;
                                        description.Position = IN.ObjectSpacePosition;
                                        description.Normal = IN.ObjectSpaceNormal;
                                        description.Tangent = IN.ObjectSpaceTangent;
                                        return description;
                                    }

                                    // Custom interpolators, pre surface
                                    #ifdef FEATURES_GRAPH_VERTEX
                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                    {
                                    return output;
                                    }
                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                    #endif

                                    // Graph Pixel
                                    struct SurfaceDescription
                                    {
                                        float3 NormalTS;
                                        float Alpha;
                                    };

                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                    {
                                        SurfaceDescription surface = (SurfaceDescription)0;
                                        float _Property_3da0c57fa07440e889d95435bcf4a0aa_Out_0 = _Smoothness;
                                        float4 _ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                        float2 _Property_eb4fae0eaa8e4fe3ac5491ba9981452e_Out_0 = _PlayerPos;
                                        float2 _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3;
                                        Unity_Remap_float2(_Property_eb4fae0eaa8e4fe3ac5491ba9981452e_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3);
                                        float2 _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2;
                                        Unity_Add_float2((_ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0.xy), _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3, _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2);
                                        float2 _TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3;
                                        Unity_TilingAndOffset_float((_ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0.xy), float2 (1, 1), _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2, _TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3);
                                        float2 _Multiply_3c357794168141569d428cf555d98c3b_Out_2;
                                        Unity_Multiply_float2_float2(_TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3, float2(2, 2), _Multiply_3c357794168141569d428cf555d98c3b_Out_2);
                                        float2 _Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2;
                                        Unity_Subtract_float2(_Multiply_3c357794168141569d428cf555d98c3b_Out_2, float2(1, 1), _Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2);
                                        float _Divide_460be555daed4e16b511e7a1a2600d99_Out_2;
                                        Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_460be555daed4e16b511e7a1a2600d99_Out_2);
                                        float _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0 = _Size;
                                        float _Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2;
                                        Unity_Multiply_float_float(_Divide_460be555daed4e16b511e7a1a2600d99_Out_2, _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0, _Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2);
                                        float2 _Vector2_80510f86d5564e69a6a87561f22e4e37_Out_0 = float2(_Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2, _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0);
                                        float2 _Divide_ef5d4c7889484ffb9129e280560351a9_Out_2;
                                        Unity_Divide_float2(_Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2, _Vector2_80510f86d5564e69a6a87561f22e4e37_Out_0, _Divide_ef5d4c7889484ffb9129e280560351a9_Out_2);
                                        float _Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1;
                                        Unity_Length_float2(_Divide_ef5d4c7889484ffb9129e280560351a9_Out_2, _Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1);
                                        float _OneMinus_7f29374d2cde401bb19dcde091630251_Out_1;
                                        Unity_OneMinus_float(_Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1, _OneMinus_7f29374d2cde401bb19dcde091630251_Out_1);
                                        float _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1;
                                        Unity_Saturate_float(_OneMinus_7f29374d2cde401bb19dcde091630251_Out_1, _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1);
                                        float _Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3;
                                        Unity_Smoothstep_float(0, _Property_3da0c57fa07440e889d95435bcf4a0aa_Out_0, _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1, _Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3);
                                        float _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2;
                                        Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2);
                                        float _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2;
                                        Unity_Multiply_float_float(_Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3, _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2, _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2);
                                        float _Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2;
                                        Unity_Add_float(_Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3, _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2, _Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2);
                                        float _Property_aa04ea6e4cde4cf283c8da199d728c36_Out_0 = _Opacity;
                                        float _Multiply_3b690d7382254556a19014f1915567e9_Out_2;
                                        Unity_Multiply_float_float(_Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2, _Property_aa04ea6e4cde4cf283c8da199d728c36_Out_0, _Multiply_3b690d7382254556a19014f1915567e9_Out_2);
                                        float _Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3;
                                        Unity_Clamp_float(_Multiply_3b690d7382254556a19014f1915567e9_Out_2, 0, 1, _Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3);
                                        float _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1;
                                        Unity_OneMinus_float(_Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3, _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1);
                                        surface.NormalTS = IN.TangentSpaceNormal;
                                        surface.Alpha = _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1;
                                        return surface;
                                    }

                                    // --------------------------------------------------
                                    // Build Graph Inputs
                                    #ifdef HAVE_VFX_MODIFICATION
                                    #define VFX_SRP_ATTRIBUTES Attributes
                                    #define VFX_SRP_VARYINGS Varyings
                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                    #endif
                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                    {
                                        VertexDescriptionInputs output;
                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                        output.ObjectSpaceNormal = input.normalOS;
                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                        output.ObjectSpacePosition = input.positionOS;

                                        return output;
                                    }
                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                    {
                                        SurfaceDescriptionInputs output;
                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                    #ifdef HAVE_VFX_MODIFICATION
                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                    #endif





                                        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                        output.WorldSpacePosition = input.positionWS;
                                        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                        output.uv0 = input.texCoord0;
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                    #else
                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                    #endif
                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                            return output;
                                    }

                                    // --------------------------------------------------
                                    // Main

                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

                                    // --------------------------------------------------
                                    // Visual Effect Vertex Invocations
                                    #ifdef HAVE_VFX_MODIFICATION
                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                    #endif

                                    ENDHLSL
                                    }
                                    Pass
                                    {
                                        Name "Meta"
                                        Tags
                                        {
                                            "LightMode" = "Meta"
                                        }

                                        // Render State
                                        Cull Off

                                        // Debug
                                        // <None>

                                        // --------------------------------------------------
                                        // Pass

                                        HLSLPROGRAM

                                        // Pragmas
                                        #pragma target 4.5
                                        #pragma exclude_renderers gles gles3 glcore
                                        #pragma vertex vert
                                        #pragma fragment frag

                                        // DotsInstancingOptions: <None>
                                        // HybridV1InjectedBuiltinProperties: <None>

                                        // Keywords
                                        #pragma shader_feature _ EDITOR_VISUALIZATION
                                        // GraphKeywords: <None>

                                        // Defines

                                        #define _NORMALMAP 1
                                        #define _NORMAL_DROPOFF_TS 1
                                        #define ATTRIBUTES_NEED_NORMAL
                                        #define ATTRIBUTES_NEED_TANGENT
                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                        #define ATTRIBUTES_NEED_TEXCOORD2
                                        #define VARYINGS_NEED_POSITION_WS
                                        #define VARYINGS_NEED_TEXCOORD0
                                        #define VARYINGS_NEED_TEXCOORD1
                                        #define VARYINGS_NEED_TEXCOORD2
                                        #define FEATURES_GRAPH_VERTEX
                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                        #define SHADERPASS SHADERPASS_META
                                        #define _FOG_FRAGMENT 1
                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                        // custom interpolator pre-include
                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                        // Includes
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                        // --------------------------------------------------
                                        // Structs and Packing

                                        // custom interpolators pre packing
                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                        struct Attributes
                                        {
                                             float3 positionOS : POSITION;
                                             float3 normalOS : NORMAL;
                                             float4 tangentOS : TANGENT;
                                             float4 uv0 : TEXCOORD0;
                                             float4 uv1 : TEXCOORD1;
                                             float4 uv2 : TEXCOORD2;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : INSTANCEID_SEMANTIC;
                                            #endif
                                        };
                                        struct Varyings
                                        {
                                             float4 positionCS : SV_POSITION;
                                             float3 positionWS;
                                             float4 texCoord0;
                                             float4 texCoord1;
                                             float4 texCoord2;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                            #endif
                                        };
                                        struct SurfaceDescriptionInputs
                                        {
                                             float3 WorldSpacePosition;
                                             float4 ScreenPosition;
                                             float4 uv0;
                                        };
                                        struct VertexDescriptionInputs
                                        {
                                             float3 ObjectSpaceNormal;
                                             float3 ObjectSpaceTangent;
                                             float3 ObjectSpacePosition;
                                        };
                                        struct PackedVaryings
                                        {
                                             float4 positionCS : SV_POSITION;
                                             float3 interp0 : INTERP0;
                                             float4 interp1 : INTERP1;
                                             float4 interp2 : INTERP2;
                                             float4 interp3 : INTERP3;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                            #endif
                                        };

                                        PackedVaryings PackVaryings(Varyings input)
                                        {
                                            PackedVaryings output;
                                            ZERO_INITIALIZE(PackedVaryings, output);
                                            output.positionCS = input.positionCS;
                                            output.interp0.xyz = input.positionWS;
                                            output.interp1.xyzw = input.texCoord0;
                                            output.interp2.xyzw = input.texCoord1;
                                            output.interp3.xyzw = input.texCoord2;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            output.instanceID = input.instanceID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            output.cullFace = input.cullFace;
                                            #endif
                                            return output;
                                        }

                                        Varyings UnpackVaryings(PackedVaryings input)
                                        {
                                            Varyings output;
                                            output.positionCS = input.positionCS;
                                            output.positionWS = input.interp0.xyz;
                                            output.texCoord0 = input.interp1.xyzw;
                                            output.texCoord1 = input.interp2.xyzw;
                                            output.texCoord2 = input.interp3.xyzw;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            output.instanceID = input.instanceID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            output.cullFace = input.cullFace;
                                            #endif
                                            return output;
                                        }


                                        // --------------------------------------------------
                                        // Graph

                                        // Graph Properties
                                        CBUFFER_START(UnityPerMaterial)
                                        float2 _PlayerPos;
                                        float _Size;
                                        float _Smoothness;
                                        float _Opacity;
                                        float4 _MainTex_TexelSize;
                                        float4 _Tint;
                                        CBUFFER_END

                                            // Object and Global properties
                                            SAMPLER(SamplerState_Linear_Repeat);
                                            TEXTURE2D(_MainTex);
                                            SAMPLER(sampler_MainTex);

                                            // Graph Includes
                                            // GraphIncludes: <None>

                                            // -- Property used by ScenePickingPass
                                            #ifdef SCENEPICKINGPASS
                                            float4 _SelectionID;
                                            #endif

                                            // -- Properties used by SceneSelectionPass
                                            #ifdef SCENESELECTIONPASS
                                            int _ObjectId;
                                            int _PassValue;
                                            #endif

                                            // Graph Functions

                                            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                            {
                                                Out = A * B;
                                            }

                                            void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                            {
                                                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                            }

                                            void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                            {
                                                Out = A + B;
                                            }

                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                            {
                                                Out = UV * Tiling + Offset;
                                            }

                                            void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                            {
                                                Out = A * B;
                                            }

                                            void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                            {
                                                Out = A - B;
                                            }

                                            void Unity_Divide_float(float A, float B, out float Out)
                                            {
                                                Out = A / B;
                                            }

                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                            {
                                                Out = A * B;
                                            }

                                            void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                            {
                                                Out = A / B;
                                            }

                                            void Unity_Length_float2(float2 In, out float Out)
                                            {
                                                Out = length(In);
                                            }

                                            void Unity_OneMinus_float(float In, out float Out)
                                            {
                                                Out = 1 - In;
                                            }

                                            void Unity_Saturate_float(float In, out float Out)
                                            {
                                                Out = saturate(In);
                                            }

                                            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                            {
                                                Out = smoothstep(Edge1, Edge2, In);
                                            }


                                            float2 Unity_GradientNoise_Dir_float(float2 p)
                                            {
                                                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                p = p % 289;
                                                // need full precision, otherwise half overflows when p > 1
                                                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                x = (34 * x + 1) * x % 289;
                                                x = frac(x / 41) * 2 - 1;
                                                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                            }

                                            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                            {
                                                float2 p = UV * Scale;
                                                float2 ip = floor(p);
                                                float2 fp = frac(p);
                                                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                            }

                                            void Unity_Add_float(float A, float B, out float Out)
                                            {
                                                Out = A + B;
                                            }

                                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                            {
                                                Out = clamp(In, Min, Max);
                                            }

                                            // Custom interpolators pre vertex
                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                            // Graph Vertex
                                            struct VertexDescription
                                            {
                                                float3 Position;
                                                float3 Normal;
                                                float3 Tangent;
                                            };

                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                            {
                                                VertexDescription description = (VertexDescription)0;
                                                description.Position = IN.ObjectSpacePosition;
                                                description.Normal = IN.ObjectSpaceNormal;
                                                description.Tangent = IN.ObjectSpaceTangent;
                                                return description;
                                            }

                                            // Custom interpolators, pre surface
                                            #ifdef FEATURES_GRAPH_VERTEX
                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                            {
                                            return output;
                                            }
                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                            #endif

                                            // Graph Pixel
                                            struct SurfaceDescription
                                            {
                                                float3 BaseColor;
                                                float3 Emission;
                                                float Alpha;
                                            };

                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                            {
                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                UnityTexture2D _Property_9e5787ff777c43db8b9ea801e309fc9b_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                                                float4 _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_9e5787ff777c43db8b9ea801e309fc9b_Out_0.tex, _Property_9e5787ff777c43db8b9ea801e309fc9b_Out_0.samplerstate, _Property_9e5787ff777c43db8b9ea801e309fc9b_Out_0.GetTransformedUV(IN.uv0.xy));
                                                float _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_R_4 = _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0.r;
                                                float _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_G_5 = _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0.g;
                                                float _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_B_6 = _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0.b;
                                                float _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_A_7 = _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0.a;
                                                float4 _Property_b37916350fdd4197bd2377cc4806d65b_Out_0 = _Tint;
                                                float4 _Multiply_3a41105f027849dd80cc07ab836b38e9_Out_2;
                                                Unity_Multiply_float4_float4(_SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0, _Property_b37916350fdd4197bd2377cc4806d65b_Out_0, _Multiply_3a41105f027849dd80cc07ab836b38e9_Out_2);
                                                float _Property_3da0c57fa07440e889d95435bcf4a0aa_Out_0 = _Smoothness;
                                                float4 _ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                float2 _Property_eb4fae0eaa8e4fe3ac5491ba9981452e_Out_0 = _PlayerPos;
                                                float2 _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3;
                                                Unity_Remap_float2(_Property_eb4fae0eaa8e4fe3ac5491ba9981452e_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3);
                                                float2 _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2;
                                                Unity_Add_float2((_ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0.xy), _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3, _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2);
                                                float2 _TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3;
                                                Unity_TilingAndOffset_float((_ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0.xy), float2 (1, 1), _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2, _TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3);
                                                float2 _Multiply_3c357794168141569d428cf555d98c3b_Out_2;
                                                Unity_Multiply_float2_float2(_TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3, float2(2, 2), _Multiply_3c357794168141569d428cf555d98c3b_Out_2);
                                                float2 _Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2;
                                                Unity_Subtract_float2(_Multiply_3c357794168141569d428cf555d98c3b_Out_2, float2(1, 1), _Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2);
                                                float _Divide_460be555daed4e16b511e7a1a2600d99_Out_2;
                                                Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_460be555daed4e16b511e7a1a2600d99_Out_2);
                                                float _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0 = _Size;
                                                float _Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2;
                                                Unity_Multiply_float_float(_Divide_460be555daed4e16b511e7a1a2600d99_Out_2, _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0, _Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2);
                                                float2 _Vector2_80510f86d5564e69a6a87561f22e4e37_Out_0 = float2(_Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2, _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0);
                                                float2 _Divide_ef5d4c7889484ffb9129e280560351a9_Out_2;
                                                Unity_Divide_float2(_Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2, _Vector2_80510f86d5564e69a6a87561f22e4e37_Out_0, _Divide_ef5d4c7889484ffb9129e280560351a9_Out_2);
                                                float _Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1;
                                                Unity_Length_float2(_Divide_ef5d4c7889484ffb9129e280560351a9_Out_2, _Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1);
                                                float _OneMinus_7f29374d2cde401bb19dcde091630251_Out_1;
                                                Unity_OneMinus_float(_Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1, _OneMinus_7f29374d2cde401bb19dcde091630251_Out_1);
                                                float _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1;
                                                Unity_Saturate_float(_OneMinus_7f29374d2cde401bb19dcde091630251_Out_1, _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1);
                                                float _Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3;
                                                Unity_Smoothstep_float(0, _Property_3da0c57fa07440e889d95435bcf4a0aa_Out_0, _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1, _Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3);
                                                float _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2;
                                                Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2);
                                                float _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2;
                                                Unity_Multiply_float_float(_Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3, _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2, _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2);
                                                float _Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2;
                                                Unity_Add_float(_Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3, _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2, _Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2);
                                                float _Property_aa04ea6e4cde4cf283c8da199d728c36_Out_0 = _Opacity;
                                                float _Multiply_3b690d7382254556a19014f1915567e9_Out_2;
                                                Unity_Multiply_float_float(_Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2, _Property_aa04ea6e4cde4cf283c8da199d728c36_Out_0, _Multiply_3b690d7382254556a19014f1915567e9_Out_2);
                                                float _Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3;
                                                Unity_Clamp_float(_Multiply_3b690d7382254556a19014f1915567e9_Out_2, 0, 1, _Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3);
                                                float _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1;
                                                Unity_OneMinus_float(_Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3, _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1);
                                                surface.BaseColor = (_Multiply_3a41105f027849dd80cc07ab836b38e9_Out_2.xyz);
                                                surface.Emission = float3(0, 0, 0);
                                                surface.Alpha = _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1;
                                                return surface;
                                            }

                                            // --------------------------------------------------
                                            // Build Graph Inputs
                                            #ifdef HAVE_VFX_MODIFICATION
                                            #define VFX_SRP_ATTRIBUTES Attributes
                                            #define VFX_SRP_VARYINGS Varyings
                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                            #endif
                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                            {
                                                VertexDescriptionInputs output;
                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                output.ObjectSpaceNormal = input.normalOS;
                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                output.ObjectSpacePosition = input.positionOS;

                                                return output;
                                            }
                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                            {
                                                SurfaceDescriptionInputs output;
                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                            #ifdef HAVE_VFX_MODIFICATION
                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                            #endif







                                                output.WorldSpacePosition = input.positionWS;
                                                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                output.uv0 = input.texCoord0;
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                            #else
                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                            #endif
                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                    return output;
                                            }

                                            // --------------------------------------------------
                                            // Main

                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

                                            // --------------------------------------------------
                                            // Visual Effect Vertex Invocations
                                            #ifdef HAVE_VFX_MODIFICATION
                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                            #endif

                                            ENDHLSL
                                            }
                                            Pass
                                            {
                                                Name "SceneSelectionPass"
                                                Tags
                                                {
                                                    "LightMode" = "SceneSelectionPass"
                                                }

                                                // Render State
                                                Cull Off

                                                // Debug
                                                // <None>

                                                // --------------------------------------------------
                                                // Pass

                                                HLSLPROGRAM

                                                // Pragmas
                                                #pragma target 4.5
                                                #pragma exclude_renderers gles gles3 glcore
                                                #pragma vertex vert
                                                #pragma fragment frag

                                                // DotsInstancingOptions: <None>
                                                // HybridV1InjectedBuiltinProperties: <None>

                                                // Keywords
                                                // PassKeywords: <None>
                                                // GraphKeywords: <None>

                                                // Defines

                                                #define _NORMALMAP 1
                                                #define _NORMAL_DROPOFF_TS 1
                                                #define ATTRIBUTES_NEED_NORMAL
                                                #define ATTRIBUTES_NEED_TANGENT
                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                #define VARYINGS_NEED_POSITION_WS
                                                #define VARYINGS_NEED_TEXCOORD0
                                                #define FEATURES_GRAPH_VERTEX
                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                #define SHADERPASS SHADERPASS_DEPTHONLY
                                                #define SCENESELECTIONPASS 1
                                                #define ALPHA_CLIP_THRESHOLD 1
                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                // custom interpolator pre-include
                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                // Includes
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                // --------------------------------------------------
                                                // Structs and Packing

                                                // custom interpolators pre packing
                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                struct Attributes
                                                {
                                                     float3 positionOS : POSITION;
                                                     float3 normalOS : NORMAL;
                                                     float4 tangentOS : TANGENT;
                                                     float4 uv0 : TEXCOORD0;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                    #endif
                                                };
                                                struct Varyings
                                                {
                                                     float4 positionCS : SV_POSITION;
                                                     float3 positionWS;
                                                     float4 texCoord0;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                    #endif
                                                };
                                                struct SurfaceDescriptionInputs
                                                {
                                                     float3 WorldSpacePosition;
                                                     float4 ScreenPosition;
                                                     float4 uv0;
                                                };
                                                struct VertexDescriptionInputs
                                                {
                                                     float3 ObjectSpaceNormal;
                                                     float3 ObjectSpaceTangent;
                                                     float3 ObjectSpacePosition;
                                                };
                                                struct PackedVaryings
                                                {
                                                     float4 positionCS : SV_POSITION;
                                                     float3 interp0 : INTERP0;
                                                     float4 interp1 : INTERP1;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                    #endif
                                                };

                                                PackedVaryings PackVaryings(Varyings input)
                                                {
                                                    PackedVaryings output;
                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                    output.positionCS = input.positionCS;
                                                    output.interp0.xyz = input.positionWS;
                                                    output.interp1.xyzw = input.texCoord0;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    output.instanceID = input.instanceID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    output.cullFace = input.cullFace;
                                                    #endif
                                                    return output;
                                                }

                                                Varyings UnpackVaryings(PackedVaryings input)
                                                {
                                                    Varyings output;
                                                    output.positionCS = input.positionCS;
                                                    output.positionWS = input.interp0.xyz;
                                                    output.texCoord0 = input.interp1.xyzw;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    output.instanceID = input.instanceID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    output.cullFace = input.cullFace;
                                                    #endif
                                                    return output;
                                                }


                                                // --------------------------------------------------
                                                // Graph

                                                // Graph Properties
                                                CBUFFER_START(UnityPerMaterial)
                                                float2 _PlayerPos;
                                                float _Size;
                                                float _Smoothness;
                                                float _Opacity;
                                                float4 _MainTex_TexelSize;
                                                float4 _Tint;
                                                CBUFFER_END

                                                    // Object and Global properties
                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                    TEXTURE2D(_MainTex);
                                                    SAMPLER(sampler_MainTex);

                                                    // Graph Includes
                                                    // GraphIncludes: <None>

                                                    // -- Property used by ScenePickingPass
                                                    #ifdef SCENEPICKINGPASS
                                                    float4 _SelectionID;
                                                    #endif

                                                    // -- Properties used by SceneSelectionPass
                                                    #ifdef SCENESELECTIONPASS
                                                    int _ObjectId;
                                                    int _PassValue;
                                                    #endif

                                                    // Graph Functions

                                                    void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                                    {
                                                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                    }

                                                    void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                                    {
                                                        Out = A + B;
                                                    }

                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                    {
                                                        Out = UV * Tiling + Offset;
                                                    }

                                                    void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                    {
                                                        Out = A * B;
                                                    }

                                                    void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                    {
                                                        Out = A - B;
                                                    }

                                                    void Unity_Divide_float(float A, float B, out float Out)
                                                    {
                                                        Out = A / B;
                                                    }

                                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                                    {
                                                        Out = A * B;
                                                    }

                                                    void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                    {
                                                        Out = A / B;
                                                    }

                                                    void Unity_Length_float2(float2 In, out float Out)
                                                    {
                                                        Out = length(In);
                                                    }

                                                    void Unity_OneMinus_float(float In, out float Out)
                                                    {
                                                        Out = 1 - In;
                                                    }

                                                    void Unity_Saturate_float(float In, out float Out)
                                                    {
                                                        Out = saturate(In);
                                                    }

                                                    void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                    {
                                                        Out = smoothstep(Edge1, Edge2, In);
                                                    }


                                                    float2 Unity_GradientNoise_Dir_float(float2 p)
                                                    {
                                                        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                        p = p % 289;
                                                        // need full precision, otherwise half overflows when p > 1
                                                        float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                        x = (34 * x + 1) * x % 289;
                                                        x = frac(x / 41) * 2 - 1;
                                                        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                    }

                                                    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                    {
                                                        float2 p = UV * Scale;
                                                        float2 ip = floor(p);
                                                        float2 fp = frac(p);
                                                        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                    }

                                                    void Unity_Add_float(float A, float B, out float Out)
                                                    {
                                                        Out = A + B;
                                                    }

                                                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                    {
                                                        Out = clamp(In, Min, Max);
                                                    }

                                                    // Custom interpolators pre vertex
                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                    // Graph Vertex
                                                    struct VertexDescription
                                                    {
                                                        float3 Position;
                                                        float3 Normal;
                                                        float3 Tangent;
                                                    };

                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                    {
                                                        VertexDescription description = (VertexDescription)0;
                                                        description.Position = IN.ObjectSpacePosition;
                                                        description.Normal = IN.ObjectSpaceNormal;
                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                        return description;
                                                    }

                                                    // Custom interpolators, pre surface
                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                    {
                                                    return output;
                                                    }
                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                    #endif

                                                    // Graph Pixel
                                                    struct SurfaceDescription
                                                    {
                                                        float Alpha;
                                                    };

                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                    {
                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                        float _Property_3da0c57fa07440e889d95435bcf4a0aa_Out_0 = _Smoothness;
                                                        float4 _ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                        float2 _Property_eb4fae0eaa8e4fe3ac5491ba9981452e_Out_0 = _PlayerPos;
                                                        float2 _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3;
                                                        Unity_Remap_float2(_Property_eb4fae0eaa8e4fe3ac5491ba9981452e_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3);
                                                        float2 _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2;
                                                        Unity_Add_float2((_ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0.xy), _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3, _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2);
                                                        float2 _TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3;
                                                        Unity_TilingAndOffset_float((_ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0.xy), float2 (1, 1), _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2, _TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3);
                                                        float2 _Multiply_3c357794168141569d428cf555d98c3b_Out_2;
                                                        Unity_Multiply_float2_float2(_TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3, float2(2, 2), _Multiply_3c357794168141569d428cf555d98c3b_Out_2);
                                                        float2 _Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2;
                                                        Unity_Subtract_float2(_Multiply_3c357794168141569d428cf555d98c3b_Out_2, float2(1, 1), _Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2);
                                                        float _Divide_460be555daed4e16b511e7a1a2600d99_Out_2;
                                                        Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_460be555daed4e16b511e7a1a2600d99_Out_2);
                                                        float _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0 = _Size;
                                                        float _Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2;
                                                        Unity_Multiply_float_float(_Divide_460be555daed4e16b511e7a1a2600d99_Out_2, _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0, _Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2);
                                                        float2 _Vector2_80510f86d5564e69a6a87561f22e4e37_Out_0 = float2(_Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2, _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0);
                                                        float2 _Divide_ef5d4c7889484ffb9129e280560351a9_Out_2;
                                                        Unity_Divide_float2(_Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2, _Vector2_80510f86d5564e69a6a87561f22e4e37_Out_0, _Divide_ef5d4c7889484ffb9129e280560351a9_Out_2);
                                                        float _Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1;
                                                        Unity_Length_float2(_Divide_ef5d4c7889484ffb9129e280560351a9_Out_2, _Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1);
                                                        float _OneMinus_7f29374d2cde401bb19dcde091630251_Out_1;
                                                        Unity_OneMinus_float(_Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1, _OneMinus_7f29374d2cde401bb19dcde091630251_Out_1);
                                                        float _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1;
                                                        Unity_Saturate_float(_OneMinus_7f29374d2cde401bb19dcde091630251_Out_1, _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1);
                                                        float _Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3;
                                                        Unity_Smoothstep_float(0, _Property_3da0c57fa07440e889d95435bcf4a0aa_Out_0, _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1, _Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3);
                                                        float _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2;
                                                        Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2);
                                                        float _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2;
                                                        Unity_Multiply_float_float(_Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3, _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2, _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2);
                                                        float _Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2;
                                                        Unity_Add_float(_Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3, _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2, _Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2);
                                                        float _Property_aa04ea6e4cde4cf283c8da199d728c36_Out_0 = _Opacity;
                                                        float _Multiply_3b690d7382254556a19014f1915567e9_Out_2;
                                                        Unity_Multiply_float_float(_Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2, _Property_aa04ea6e4cde4cf283c8da199d728c36_Out_0, _Multiply_3b690d7382254556a19014f1915567e9_Out_2);
                                                        float _Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3;
                                                        Unity_Clamp_float(_Multiply_3b690d7382254556a19014f1915567e9_Out_2, 0, 1, _Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3);
                                                        float _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1;
                                                        Unity_OneMinus_float(_Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3, _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1);
                                                        surface.Alpha = _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1;
                                                        return surface;
                                                    }

                                                    // --------------------------------------------------
                                                    // Build Graph Inputs
                                                    #ifdef HAVE_VFX_MODIFICATION
                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                    #define VFX_SRP_VARYINGS Varyings
                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                    #endif
                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                    {
                                                        VertexDescriptionInputs output;
                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                        output.ObjectSpaceNormal = input.normalOS;
                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                        output.ObjectSpacePosition = input.positionOS;

                                                        return output;
                                                    }
                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                    {
                                                        SurfaceDescriptionInputs output;
                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                    #ifdef HAVE_VFX_MODIFICATION
                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                    #endif







                                                        output.WorldSpacePosition = input.positionWS;
                                                        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                        output.uv0 = input.texCoord0;
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                    #else
                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                    #endif
                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                            return output;
                                                    }

                                                    // --------------------------------------------------
                                                    // Main

                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                    // --------------------------------------------------
                                                    // Visual Effect Vertex Invocations
                                                    #ifdef HAVE_VFX_MODIFICATION
                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                    #endif

                                                    ENDHLSL
                                                    }
                                                    Pass
                                                    {
                                                        Name "ScenePickingPass"
                                                        Tags
                                                        {
                                                            "LightMode" = "Picking"
                                                        }

                                                        // Render State
                                                        Cull Back

                                                        // Debug
                                                        // <None>

                                                        // --------------------------------------------------
                                                        // Pass

                                                        HLSLPROGRAM

                                                        // Pragmas
                                                        #pragma target 4.5
                                                        #pragma exclude_renderers gles gles3 glcore
                                                        #pragma vertex vert
                                                        #pragma fragment frag

                                                        // DotsInstancingOptions: <None>
                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                        // Keywords
                                                        // PassKeywords: <None>
                                                        // GraphKeywords: <None>

                                                        // Defines

                                                        #define _NORMALMAP 1
                                                        #define _NORMAL_DROPOFF_TS 1
                                                        #define ATTRIBUTES_NEED_NORMAL
                                                        #define ATTRIBUTES_NEED_TANGENT
                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                        #define VARYINGS_NEED_POSITION_WS
                                                        #define VARYINGS_NEED_TEXCOORD0
                                                        #define FEATURES_GRAPH_VERTEX
                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                        #define SHADERPASS SHADERPASS_DEPTHONLY
                                                        #define SCENEPICKINGPASS 1
                                                        #define ALPHA_CLIP_THRESHOLD 1
                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                        // custom interpolator pre-include
                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                        // Includes
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                        // --------------------------------------------------
                                                        // Structs and Packing

                                                        // custom interpolators pre packing
                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                        struct Attributes
                                                        {
                                                             float3 positionOS : POSITION;
                                                             float3 normalOS : NORMAL;
                                                             float4 tangentOS : TANGENT;
                                                             float4 uv0 : TEXCOORD0;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                            #endif
                                                        };
                                                        struct Varyings
                                                        {
                                                             float4 positionCS : SV_POSITION;
                                                             float3 positionWS;
                                                             float4 texCoord0;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                            #endif
                                                        };
                                                        struct SurfaceDescriptionInputs
                                                        {
                                                             float3 WorldSpacePosition;
                                                             float4 ScreenPosition;
                                                             float4 uv0;
                                                        };
                                                        struct VertexDescriptionInputs
                                                        {
                                                             float3 ObjectSpaceNormal;
                                                             float3 ObjectSpaceTangent;
                                                             float3 ObjectSpacePosition;
                                                        };
                                                        struct PackedVaryings
                                                        {
                                                             float4 positionCS : SV_POSITION;
                                                             float3 interp0 : INTERP0;
                                                             float4 interp1 : INTERP1;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                            #endif
                                                        };

                                                        PackedVaryings PackVaryings(Varyings input)
                                                        {
                                                            PackedVaryings output;
                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                            output.positionCS = input.positionCS;
                                                            output.interp0.xyz = input.positionWS;
                                                            output.interp1.xyzw = input.texCoord0;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            output.instanceID = input.instanceID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            output.cullFace = input.cullFace;
                                                            #endif
                                                            return output;
                                                        }

                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                        {
                                                            Varyings output;
                                                            output.positionCS = input.positionCS;
                                                            output.positionWS = input.interp0.xyz;
                                                            output.texCoord0 = input.interp1.xyzw;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            output.instanceID = input.instanceID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            output.cullFace = input.cullFace;
                                                            #endif
                                                            return output;
                                                        }


                                                        // --------------------------------------------------
                                                        // Graph

                                                        // Graph Properties
                                                        CBUFFER_START(UnityPerMaterial)
                                                        float2 _PlayerPos;
                                                        float _Size;
                                                        float _Smoothness;
                                                        float _Opacity;
                                                        float4 _MainTex_TexelSize;
                                                        float4 _Tint;
                                                        CBUFFER_END

                                                            // Object and Global properties
                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                            TEXTURE2D(_MainTex);
                                                            SAMPLER(sampler_MainTex);

                                                            // Graph Includes
                                                            // GraphIncludes: <None>

                                                            // -- Property used by ScenePickingPass
                                                            #ifdef SCENEPICKINGPASS
                                                            float4 _SelectionID;
                                                            #endif

                                                            // -- Properties used by SceneSelectionPass
                                                            #ifdef SCENESELECTIONPASS
                                                            int _ObjectId;
                                                            int _PassValue;
                                                            #endif

                                                            // Graph Functions

                                                            void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                                            {
                                                                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                            }

                                                            void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                                            {
                                                                Out = A + B;
                                                            }

                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                            {
                                                                Out = UV * Tiling + Offset;
                                                            }

                                                            void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                            {
                                                                Out = A * B;
                                                            }

                                                            void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                            {
                                                                Out = A - B;
                                                            }

                                                            void Unity_Divide_float(float A, float B, out float Out)
                                                            {
                                                                Out = A / B;
                                                            }

                                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                                            {
                                                                Out = A * B;
                                                            }

                                                            void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                            {
                                                                Out = A / B;
                                                            }

                                                            void Unity_Length_float2(float2 In, out float Out)
                                                            {
                                                                Out = length(In);
                                                            }

                                                            void Unity_OneMinus_float(float In, out float Out)
                                                            {
                                                                Out = 1 - In;
                                                            }

                                                            void Unity_Saturate_float(float In, out float Out)
                                                            {
                                                                Out = saturate(In);
                                                            }

                                                            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                            {
                                                                Out = smoothstep(Edge1, Edge2, In);
                                                            }


                                                            float2 Unity_GradientNoise_Dir_float(float2 p)
                                                            {
                                                                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                                p = p % 289;
                                                                // need full precision, otherwise half overflows when p > 1
                                                                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                                x = (34 * x + 1) * x % 289;
                                                                x = frac(x / 41) * 2 - 1;
                                                                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                            }

                                                            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                            {
                                                                float2 p = UV * Scale;
                                                                float2 ip = floor(p);
                                                                float2 fp = frac(p);
                                                                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                            }

                                                            void Unity_Add_float(float A, float B, out float Out)
                                                            {
                                                                Out = A + B;
                                                            }

                                                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                            {
                                                                Out = clamp(In, Min, Max);
                                                            }

                                                            // Custom interpolators pre vertex
                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                            // Graph Vertex
                                                            struct VertexDescription
                                                            {
                                                                float3 Position;
                                                                float3 Normal;
                                                                float3 Tangent;
                                                            };

                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                            {
                                                                VertexDescription description = (VertexDescription)0;
                                                                description.Position = IN.ObjectSpacePosition;
                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                return description;
                                                            }

                                                            // Custom interpolators, pre surface
                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                            {
                                                            return output;
                                                            }
                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                            #endif

                                                            // Graph Pixel
                                                            struct SurfaceDescription
                                                            {
                                                                float Alpha;
                                                            };

                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                            {
                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                float _Property_3da0c57fa07440e889d95435bcf4a0aa_Out_0 = _Smoothness;
                                                                float4 _ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                                float2 _Property_eb4fae0eaa8e4fe3ac5491ba9981452e_Out_0 = _PlayerPos;
                                                                float2 _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3;
                                                                Unity_Remap_float2(_Property_eb4fae0eaa8e4fe3ac5491ba9981452e_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3);
                                                                float2 _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2;
                                                                Unity_Add_float2((_ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0.xy), _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3, _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2);
                                                                float2 _TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3;
                                                                Unity_TilingAndOffset_float((_ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0.xy), float2 (1, 1), _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2, _TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3);
                                                                float2 _Multiply_3c357794168141569d428cf555d98c3b_Out_2;
                                                                Unity_Multiply_float2_float2(_TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3, float2(2, 2), _Multiply_3c357794168141569d428cf555d98c3b_Out_2);
                                                                float2 _Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2;
                                                                Unity_Subtract_float2(_Multiply_3c357794168141569d428cf555d98c3b_Out_2, float2(1, 1), _Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2);
                                                                float _Divide_460be555daed4e16b511e7a1a2600d99_Out_2;
                                                                Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_460be555daed4e16b511e7a1a2600d99_Out_2);
                                                                float _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0 = _Size;
                                                                float _Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2;
                                                                Unity_Multiply_float_float(_Divide_460be555daed4e16b511e7a1a2600d99_Out_2, _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0, _Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2);
                                                                float2 _Vector2_80510f86d5564e69a6a87561f22e4e37_Out_0 = float2(_Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2, _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0);
                                                                float2 _Divide_ef5d4c7889484ffb9129e280560351a9_Out_2;
                                                                Unity_Divide_float2(_Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2, _Vector2_80510f86d5564e69a6a87561f22e4e37_Out_0, _Divide_ef5d4c7889484ffb9129e280560351a9_Out_2);
                                                                float _Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1;
                                                                Unity_Length_float2(_Divide_ef5d4c7889484ffb9129e280560351a9_Out_2, _Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1);
                                                                float _OneMinus_7f29374d2cde401bb19dcde091630251_Out_1;
                                                                Unity_OneMinus_float(_Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1, _OneMinus_7f29374d2cde401bb19dcde091630251_Out_1);
                                                                float _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1;
                                                                Unity_Saturate_float(_OneMinus_7f29374d2cde401bb19dcde091630251_Out_1, _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1);
                                                                float _Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3;
                                                                Unity_Smoothstep_float(0, _Property_3da0c57fa07440e889d95435bcf4a0aa_Out_0, _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1, _Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3);
                                                                float _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2;
                                                                Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2);
                                                                float _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2;
                                                                Unity_Multiply_float_float(_Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3, _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2, _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2);
                                                                float _Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2;
                                                                Unity_Add_float(_Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3, _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2, _Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2);
                                                                float _Property_aa04ea6e4cde4cf283c8da199d728c36_Out_0 = _Opacity;
                                                                float _Multiply_3b690d7382254556a19014f1915567e9_Out_2;
                                                                Unity_Multiply_float_float(_Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2, _Property_aa04ea6e4cde4cf283c8da199d728c36_Out_0, _Multiply_3b690d7382254556a19014f1915567e9_Out_2);
                                                                float _Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3;
                                                                Unity_Clamp_float(_Multiply_3b690d7382254556a19014f1915567e9_Out_2, 0, 1, _Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3);
                                                                float _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1;
                                                                Unity_OneMinus_float(_Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3, _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1);
                                                                surface.Alpha = _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1;
                                                                return surface;
                                                            }

                                                            // --------------------------------------------------
                                                            // Build Graph Inputs
                                                            #ifdef HAVE_VFX_MODIFICATION
                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                            #define VFX_SRP_VARYINGS Varyings
                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                            #endif
                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                            {
                                                                VertexDescriptionInputs output;
                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                output.ObjectSpacePosition = input.positionOS;

                                                                return output;
                                                            }
                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                            {
                                                                SurfaceDescriptionInputs output;
                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                            #endif







                                                                output.WorldSpacePosition = input.positionWS;
                                                                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                output.uv0 = input.texCoord0;
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                            #else
                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                            #endif
                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                    return output;
                                                            }

                                                            // --------------------------------------------------
                                                            // Main

                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                            // --------------------------------------------------
                                                            // Visual Effect Vertex Invocations
                                                            #ifdef HAVE_VFX_MODIFICATION
                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                            #endif

                                                            ENDHLSL
                                                            }
                                                            Pass
                                                            {
                                                                // Name: <None>
                                                                Tags
                                                                {
                                                                    "LightMode" = "Universal2D"
                                                                }

                                                                // Render State
                                                                Cull Back
                                                                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                                                                ZTest LEqual
                                                                ZWrite Off

                                                                // Debug
                                                                // <None>

                                                                // --------------------------------------------------
                                                                // Pass

                                                                HLSLPROGRAM

                                                                // Pragmas
                                                                #pragma target 4.5
                                                                #pragma exclude_renderers gles gles3 glcore
                                                                #pragma vertex vert
                                                                #pragma fragment frag

                                                                // DotsInstancingOptions: <None>
                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                // Keywords
                                                                // PassKeywords: <None>
                                                                // GraphKeywords: <None>

                                                                // Defines

                                                                #define _NORMALMAP 1
                                                                #define _NORMAL_DROPOFF_TS 1
                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                                #define VARYINGS_NEED_POSITION_WS
                                                                #define VARYINGS_NEED_TEXCOORD0
                                                                #define FEATURES_GRAPH_VERTEX
                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                #define SHADERPASS SHADERPASS_2D
                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                // custom interpolator pre-include
                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                // Includes
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                // --------------------------------------------------
                                                                // Structs and Packing

                                                                // custom interpolators pre packing
                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                struct Attributes
                                                                {
                                                                     float3 positionOS : POSITION;
                                                                     float3 normalOS : NORMAL;
                                                                     float4 tangentOS : TANGENT;
                                                                     float4 uv0 : TEXCOORD0;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                    #endif
                                                                };
                                                                struct Varyings
                                                                {
                                                                     float4 positionCS : SV_POSITION;
                                                                     float3 positionWS;
                                                                     float4 texCoord0;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                    #endif
                                                                };
                                                                struct SurfaceDescriptionInputs
                                                                {
                                                                     float3 WorldSpacePosition;
                                                                     float4 ScreenPosition;
                                                                     float4 uv0;
                                                                };
                                                                struct VertexDescriptionInputs
                                                                {
                                                                     float3 ObjectSpaceNormal;
                                                                     float3 ObjectSpaceTangent;
                                                                     float3 ObjectSpacePosition;
                                                                };
                                                                struct PackedVaryings
                                                                {
                                                                     float4 positionCS : SV_POSITION;
                                                                     float3 interp0 : INTERP0;
                                                                     float4 interp1 : INTERP1;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                    #endif
                                                                };

                                                                PackedVaryings PackVaryings(Varyings input)
                                                                {
                                                                    PackedVaryings output;
                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                    output.positionCS = input.positionCS;
                                                                    output.interp0.xyz = input.positionWS;
                                                                    output.interp1.xyzw = input.texCoord0;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    output.instanceID = input.instanceID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    output.cullFace = input.cullFace;
                                                                    #endif
                                                                    return output;
                                                                }

                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                {
                                                                    Varyings output;
                                                                    output.positionCS = input.positionCS;
                                                                    output.positionWS = input.interp0.xyz;
                                                                    output.texCoord0 = input.interp1.xyzw;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    output.instanceID = input.instanceID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    output.cullFace = input.cullFace;
                                                                    #endif
                                                                    return output;
                                                                }


                                                                // --------------------------------------------------
                                                                // Graph

                                                                // Graph Properties
                                                                CBUFFER_START(UnityPerMaterial)
                                                                float2 _PlayerPos;
                                                                float _Size;
                                                                float _Smoothness;
                                                                float _Opacity;
                                                                float4 _MainTex_TexelSize;
                                                                float4 _Tint;
                                                                CBUFFER_END

                                                                    // Object and Global properties
                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                    TEXTURE2D(_MainTex);
                                                                    SAMPLER(sampler_MainTex);

                                                                    // Graph Includes
                                                                    // GraphIncludes: <None>

                                                                    // -- Property used by ScenePickingPass
                                                                    #ifdef SCENEPICKINGPASS
                                                                    float4 _SelectionID;
                                                                    #endif

                                                                    // -- Properties used by SceneSelectionPass
                                                                    #ifdef SCENESELECTIONPASS
                                                                    int _ObjectId;
                                                                    int _PassValue;
                                                                    #endif

                                                                    // Graph Functions

                                                                    void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                                    {
                                                                        Out = A * B;
                                                                    }

                                                                    void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                                                    {
                                                                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                                    }

                                                                    void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                                                    {
                                                                        Out = A + B;
                                                                    }

                                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                    {
                                                                        Out = UV * Tiling + Offset;
                                                                    }

                                                                    void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                                    {
                                                                        Out = A * B;
                                                                    }

                                                                    void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                                    {
                                                                        Out = A - B;
                                                                    }

                                                                    void Unity_Divide_float(float A, float B, out float Out)
                                                                    {
                                                                        Out = A / B;
                                                                    }

                                                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                    {
                                                                        Out = A * B;
                                                                    }

                                                                    void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                                    {
                                                                        Out = A / B;
                                                                    }

                                                                    void Unity_Length_float2(float2 In, out float Out)
                                                                    {
                                                                        Out = length(In);
                                                                    }

                                                                    void Unity_OneMinus_float(float In, out float Out)
                                                                    {
                                                                        Out = 1 - In;
                                                                    }

                                                                    void Unity_Saturate_float(float In, out float Out)
                                                                    {
                                                                        Out = saturate(In);
                                                                    }

                                                                    void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                                    {
                                                                        Out = smoothstep(Edge1, Edge2, In);
                                                                    }


                                                                    float2 Unity_GradientNoise_Dir_float(float2 p)
                                                                    {
                                                                        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                                        p = p % 289;
                                                                        // need full precision, otherwise half overflows when p > 1
                                                                        float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                                        x = (34 * x + 1) * x % 289;
                                                                        x = frac(x / 41) * 2 - 1;
                                                                        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                                    }

                                                                    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                                    {
                                                                        float2 p = UV * Scale;
                                                                        float2 ip = floor(p);
                                                                        float2 fp = frac(p);
                                                                        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                                        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                                        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                                        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                                        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                                        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                                    }

                                                                    void Unity_Add_float(float A, float B, out float Out)
                                                                    {
                                                                        Out = A + B;
                                                                    }

                                                                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                    {
                                                                        Out = clamp(In, Min, Max);
                                                                    }

                                                                    // Custom interpolators pre vertex
                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                    // Graph Vertex
                                                                    struct VertexDescription
                                                                    {
                                                                        float3 Position;
                                                                        float3 Normal;
                                                                        float3 Tangent;
                                                                    };

                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                    {
                                                                        VertexDescription description = (VertexDescription)0;
                                                                        description.Position = IN.ObjectSpacePosition;
                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                        return description;
                                                                    }

                                                                    // Custom interpolators, pre surface
                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                    {
                                                                    return output;
                                                                    }
                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                    #endif

                                                                    // Graph Pixel
                                                                    struct SurfaceDescription
                                                                    {
                                                                        float3 BaseColor;
                                                                        float Alpha;
                                                                    };

                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                    {
                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                        UnityTexture2D _Property_9e5787ff777c43db8b9ea801e309fc9b_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                                                                        float4 _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_9e5787ff777c43db8b9ea801e309fc9b_Out_0.tex, _Property_9e5787ff777c43db8b9ea801e309fc9b_Out_0.samplerstate, _Property_9e5787ff777c43db8b9ea801e309fc9b_Out_0.GetTransformedUV(IN.uv0.xy));
                                                                        float _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_R_4 = _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0.r;
                                                                        float _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_G_5 = _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0.g;
                                                                        float _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_B_6 = _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0.b;
                                                                        float _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_A_7 = _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0.a;
                                                                        float4 _Property_b37916350fdd4197bd2377cc4806d65b_Out_0 = _Tint;
                                                                        float4 _Multiply_3a41105f027849dd80cc07ab836b38e9_Out_2;
                                                                        Unity_Multiply_float4_float4(_SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0, _Property_b37916350fdd4197bd2377cc4806d65b_Out_0, _Multiply_3a41105f027849dd80cc07ab836b38e9_Out_2);
                                                                        float _Property_3da0c57fa07440e889d95435bcf4a0aa_Out_0 = _Smoothness;
                                                                        float4 _ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                                        float2 _Property_eb4fae0eaa8e4fe3ac5491ba9981452e_Out_0 = _PlayerPos;
                                                                        float2 _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3;
                                                                        Unity_Remap_float2(_Property_eb4fae0eaa8e4fe3ac5491ba9981452e_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3);
                                                                        float2 _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2;
                                                                        Unity_Add_float2((_ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0.xy), _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3, _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2);
                                                                        float2 _TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3;
                                                                        Unity_TilingAndOffset_float((_ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0.xy), float2 (1, 1), _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2, _TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3);
                                                                        float2 _Multiply_3c357794168141569d428cf555d98c3b_Out_2;
                                                                        Unity_Multiply_float2_float2(_TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3, float2(2, 2), _Multiply_3c357794168141569d428cf555d98c3b_Out_2);
                                                                        float2 _Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2;
                                                                        Unity_Subtract_float2(_Multiply_3c357794168141569d428cf555d98c3b_Out_2, float2(1, 1), _Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2);
                                                                        float _Divide_460be555daed4e16b511e7a1a2600d99_Out_2;
                                                                        Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_460be555daed4e16b511e7a1a2600d99_Out_2);
                                                                        float _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0 = _Size;
                                                                        float _Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2;
                                                                        Unity_Multiply_float_float(_Divide_460be555daed4e16b511e7a1a2600d99_Out_2, _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0, _Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2);
                                                                        float2 _Vector2_80510f86d5564e69a6a87561f22e4e37_Out_0 = float2(_Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2, _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0);
                                                                        float2 _Divide_ef5d4c7889484ffb9129e280560351a9_Out_2;
                                                                        Unity_Divide_float2(_Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2, _Vector2_80510f86d5564e69a6a87561f22e4e37_Out_0, _Divide_ef5d4c7889484ffb9129e280560351a9_Out_2);
                                                                        float _Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1;
                                                                        Unity_Length_float2(_Divide_ef5d4c7889484ffb9129e280560351a9_Out_2, _Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1);
                                                                        float _OneMinus_7f29374d2cde401bb19dcde091630251_Out_1;
                                                                        Unity_OneMinus_float(_Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1, _OneMinus_7f29374d2cde401bb19dcde091630251_Out_1);
                                                                        float _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1;
                                                                        Unity_Saturate_float(_OneMinus_7f29374d2cde401bb19dcde091630251_Out_1, _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1);
                                                                        float _Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3;
                                                                        Unity_Smoothstep_float(0, _Property_3da0c57fa07440e889d95435bcf4a0aa_Out_0, _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1, _Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3);
                                                                        float _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2;
                                                                        Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2);
                                                                        float _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2;
                                                                        Unity_Multiply_float_float(_Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3, _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2, _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2);
                                                                        float _Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2;
                                                                        Unity_Add_float(_Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3, _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2, _Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2);
                                                                        float _Property_aa04ea6e4cde4cf283c8da199d728c36_Out_0 = _Opacity;
                                                                        float _Multiply_3b690d7382254556a19014f1915567e9_Out_2;
                                                                        Unity_Multiply_float_float(_Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2, _Property_aa04ea6e4cde4cf283c8da199d728c36_Out_0, _Multiply_3b690d7382254556a19014f1915567e9_Out_2);
                                                                        float _Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3;
                                                                        Unity_Clamp_float(_Multiply_3b690d7382254556a19014f1915567e9_Out_2, 0, 1, _Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3);
                                                                        float _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1;
                                                                        Unity_OneMinus_float(_Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3, _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1);
                                                                        surface.BaseColor = (_Multiply_3a41105f027849dd80cc07ab836b38e9_Out_2.xyz);
                                                                        surface.Alpha = _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1;
                                                                        return surface;
                                                                    }

                                                                    // --------------------------------------------------
                                                                    // Build Graph Inputs
                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                    #endif
                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                    {
                                                                        VertexDescriptionInputs output;
                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                        output.ObjectSpacePosition = input.positionOS;

                                                                        return output;
                                                                    }
                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                    {
                                                                        SurfaceDescriptionInputs output;
                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                    #endif







                                                                        output.WorldSpacePosition = input.positionWS;
                                                                        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                        output.uv0 = input.texCoord0;
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                    #else
                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                    #endif
                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                            return output;
                                                                    }

                                                                    // --------------------------------------------------
                                                                    // Main

                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

                                                                    // --------------------------------------------------
                                                                    // Visual Effect Vertex Invocations
                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                    #endif

                                                                    ENDHLSL
                                                                    }
    }
        SubShader
                                                                    {
                                                                        Tags
                                                                        {
                                                                            "RenderPipeline" = "UniversalPipeline"
                                                                            "RenderType" = "Transparent"
                                                                            "UniversalMaterialType" = "Lit"
                                                                            "Queue" = "Transparent"
                                                                            "ShaderGraphShader" = "true"
                                                                            "ShaderGraphTargetId" = "UniversalLitSubTarget"
                                                                        }
                                                                        Pass
                                                                        {
                                                                            Name "Universal Forward"
                                                                            Tags
                                                                            {
                                                                                "LightMode" = "UniversalForward"
                                                                            }

                                                                        // Render State
                                                                        Cull Back
                                                                        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                                                                        ZTest LEqual
                                                                        ZWrite Off

                                                                        // Debug
                                                                        // <None>

                                                                        // --------------------------------------------------
                                                                        // Pass

                                                                        HLSLPROGRAM

                                                                        // Pragmas
                                                                        #pragma target 2.0
                                                                        #pragma only_renderers gles gles3 glcore d3d11
                                                                        #pragma multi_compile_instancing
                                                                        #pragma multi_compile_fog
                                                                        #pragma instancing_options renderinglayer
                                                                        #pragma vertex vert
                                                                        #pragma fragment frag

                                                                        // DotsInstancingOptions: <None>
                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                        // Keywords
                                                                        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
                                                                        #pragma multi_compile _ LIGHTMAP_ON
                                                                        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
                                                                        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                                                                        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                                                                        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
                                                                        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
                                                                        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
                                                                        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
                                                                        #pragma multi_compile_fragment _ _SHADOWS_SOFT
                                                                        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                                                                        #pragma multi_compile _ SHADOWS_SHADOWMASK
                                                                        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
                                                                        #pragma multi_compile_fragment _ _LIGHT_LAYERS
                                                                        #pragma multi_compile_fragment _ DEBUG_DISPLAY
                                                                        #pragma multi_compile_fragment _ _LIGHT_COOKIES
                                                                        #pragma multi_compile _ _CLUSTERED_RENDERING
                                                                        // GraphKeywords: <None>

                                                                        // Defines

                                                                        #define _NORMALMAP 1
                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                                                        #define ATTRIBUTES_NEED_TEXCOORD2
                                                                        #define VARYINGS_NEED_POSITION_WS
                                                                        #define VARYINGS_NEED_NORMAL_WS
                                                                        #define VARYINGS_NEED_TANGENT_WS
                                                                        #define VARYINGS_NEED_TEXCOORD0
                                                                        #define VARYINGS_NEED_VIEWDIRECTION_WS
                                                                        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                        #define VARYINGS_NEED_SHADOW_COORD
                                                                        #define FEATURES_GRAPH_VERTEX
                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                        #define SHADERPASS SHADERPASS_FORWARD
                                                                        #define _FOG_FRAGMENT 1
                                                                        #define _SURFACE_TYPE_TRANSPARENT 1
                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                        // custom interpolator pre-include
                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                        // Includes
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                        // --------------------------------------------------
                                                                        // Structs and Packing

                                                                        // custom interpolators pre packing
                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                        struct Attributes
                                                                        {
                                                                             float3 positionOS : POSITION;
                                                                             float3 normalOS : NORMAL;
                                                                             float4 tangentOS : TANGENT;
                                                                             float4 uv0 : TEXCOORD0;
                                                                             float4 uv1 : TEXCOORD1;
                                                                             float4 uv2 : TEXCOORD2;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                            #endif
                                                                        };
                                                                        struct Varyings
                                                                        {
                                                                             float4 positionCS : SV_POSITION;
                                                                             float3 positionWS;
                                                                             float3 normalWS;
                                                                             float4 tangentWS;
                                                                             float4 texCoord0;
                                                                             float3 viewDirectionWS;
                                                                            #if defined(LIGHTMAP_ON)
                                                                             float2 staticLightmapUV;
                                                                            #endif
                                                                            #if defined(DYNAMICLIGHTMAP_ON)
                                                                             float2 dynamicLightmapUV;
                                                                            #endif
                                                                            #if !defined(LIGHTMAP_ON)
                                                                             float3 sh;
                                                                            #endif
                                                                             float4 fogFactorAndVertexLight;
                                                                            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                                                                             float4 shadowCoord;
                                                                            #endif
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                            #endif
                                                                        };
                                                                        struct SurfaceDescriptionInputs
                                                                        {
                                                                             float3 TangentSpaceNormal;
                                                                             float3 WorldSpacePosition;
                                                                             float4 ScreenPosition;
                                                                             float4 uv0;
                                                                        };
                                                                        struct VertexDescriptionInputs
                                                                        {
                                                                             float3 ObjectSpaceNormal;
                                                                             float3 ObjectSpaceTangent;
                                                                             float3 ObjectSpacePosition;
                                                                        };
                                                                        struct PackedVaryings
                                                                        {
                                                                             float4 positionCS : SV_POSITION;
                                                                             float3 interp0 : INTERP0;
                                                                             float3 interp1 : INTERP1;
                                                                             float4 interp2 : INTERP2;
                                                                             float4 interp3 : INTERP3;
                                                                             float3 interp4 : INTERP4;
                                                                             float2 interp5 : INTERP5;
                                                                             float2 interp6 : INTERP6;
                                                                             float3 interp7 : INTERP7;
                                                                             float4 interp8 : INTERP8;
                                                                             float4 interp9 : INTERP9;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                            #endif
                                                                        };

                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                        {
                                                                            PackedVaryings output;
                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                            output.positionCS = input.positionCS;
                                                                            output.interp0.xyz = input.positionWS;
                                                                            output.interp1.xyz = input.normalWS;
                                                                            output.interp2.xyzw = input.tangentWS;
                                                                            output.interp3.xyzw = input.texCoord0;
                                                                            output.interp4.xyz = input.viewDirectionWS;
                                                                            #if defined(LIGHTMAP_ON)
                                                                            output.interp5.xy = input.staticLightmapUV;
                                                                            #endif
                                                                            #if defined(DYNAMICLIGHTMAP_ON)
                                                                            output.interp6.xy = input.dynamicLightmapUV;
                                                                            #endif
                                                                            #if !defined(LIGHTMAP_ON)
                                                                            output.interp7.xyz = input.sh;
                                                                            #endif
                                                                            output.interp8.xyzw = input.fogFactorAndVertexLight;
                                                                            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                                                                            output.interp9.xyzw = input.shadowCoord;
                                                                            #endif
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            output.instanceID = input.instanceID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            output.cullFace = input.cullFace;
                                                                            #endif
                                                                            return output;
                                                                        }

                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                        {
                                                                            Varyings output;
                                                                            output.positionCS = input.positionCS;
                                                                            output.positionWS = input.interp0.xyz;
                                                                            output.normalWS = input.interp1.xyz;
                                                                            output.tangentWS = input.interp2.xyzw;
                                                                            output.texCoord0 = input.interp3.xyzw;
                                                                            output.viewDirectionWS = input.interp4.xyz;
                                                                            #if defined(LIGHTMAP_ON)
                                                                            output.staticLightmapUV = input.interp5.xy;
                                                                            #endif
                                                                            #if defined(DYNAMICLIGHTMAP_ON)
                                                                            output.dynamicLightmapUV = input.interp6.xy;
                                                                            #endif
                                                                            #if !defined(LIGHTMAP_ON)
                                                                            output.sh = input.interp7.xyz;
                                                                            #endif
                                                                            output.fogFactorAndVertexLight = input.interp8.xyzw;
                                                                            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                                                                            output.shadowCoord = input.interp9.xyzw;
                                                                            #endif
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            output.instanceID = input.instanceID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            output.cullFace = input.cullFace;
                                                                            #endif
                                                                            return output;
                                                                        }


                                                                        // --------------------------------------------------
                                                                        // Graph

                                                                        // Graph Properties
                                                                        CBUFFER_START(UnityPerMaterial)
                                                                        float2 _PlayerPos;
                                                                        float _Size;
                                                                        float _Smoothness;
                                                                        float _Opacity;
                                                                        float4 _MainTex_TexelSize;
                                                                        float4 _Tint;
                                                                        CBUFFER_END

                                                                            // Object and Global properties
                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                            TEXTURE2D(_MainTex);
                                                                            SAMPLER(sampler_MainTex);

                                                                            // Graph Includes
                                                                            // GraphIncludes: <None>

                                                                            // -- Property used by ScenePickingPass
                                                                            #ifdef SCENEPICKINGPASS
                                                                            float4 _SelectionID;
                                                                            #endif

                                                                            // -- Properties used by SceneSelectionPass
                                                                            #ifdef SCENESELECTIONPASS
                                                                            int _ObjectId;
                                                                            int _PassValue;
                                                                            #endif

                                                                            // Graph Functions

                                                                            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                                            {
                                                                                Out = A * B;
                                                                            }

                                                                            void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                                                            {
                                                                                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                                            }

                                                                            void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                                                            {
                                                                                Out = A + B;
                                                                            }

                                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                            {
                                                                                Out = UV * Tiling + Offset;
                                                                            }

                                                                            void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                                            {
                                                                                Out = A * B;
                                                                            }

                                                                            void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                                            {
                                                                                Out = A - B;
                                                                            }

                                                                            void Unity_Divide_float(float A, float B, out float Out)
                                                                            {
                                                                                Out = A / B;
                                                                            }

                                                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                            {
                                                                                Out = A * B;
                                                                            }

                                                                            void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                                            {
                                                                                Out = A / B;
                                                                            }

                                                                            void Unity_Length_float2(float2 In, out float Out)
                                                                            {
                                                                                Out = length(In);
                                                                            }

                                                                            void Unity_OneMinus_float(float In, out float Out)
                                                                            {
                                                                                Out = 1 - In;
                                                                            }

                                                                            void Unity_Saturate_float(float In, out float Out)
                                                                            {
                                                                                Out = saturate(In);
                                                                            }

                                                                            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                                            {
                                                                                Out = smoothstep(Edge1, Edge2, In);
                                                                            }


                                                                            float2 Unity_GradientNoise_Dir_float(float2 p)
                                                                            {
                                                                                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                                                p = p % 289;
                                                                                // need full precision, otherwise half overflows when p > 1
                                                                                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                                                x = (34 * x + 1) * x % 289;
                                                                                x = frac(x / 41) * 2 - 1;
                                                                                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                                            }

                                                                            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                                            {
                                                                                float2 p = UV * Scale;
                                                                                float2 ip = floor(p);
                                                                                float2 fp = frac(p);
                                                                                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                                                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                                                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                                                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                                                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                                                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                                            }

                                                                            void Unity_Add_float(float A, float B, out float Out)
                                                                            {
                                                                                Out = A + B;
                                                                            }

                                                                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                            {
                                                                                Out = clamp(In, Min, Max);
                                                                            }

                                                                            // Custom interpolators pre vertex
                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                            // Graph Vertex
                                                                            struct VertexDescription
                                                                            {
                                                                                float3 Position;
                                                                                float3 Normal;
                                                                                float3 Tangent;
                                                                            };

                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                            {
                                                                                VertexDescription description = (VertexDescription)0;
                                                                                description.Position = IN.ObjectSpacePosition;
                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                return description;
                                                                            }

                                                                            // Custom interpolators, pre surface
                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                            {
                                                                            return output;
                                                                            }
                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                            #endif

                                                                            // Graph Pixel
                                                                            struct SurfaceDescription
                                                                            {
                                                                                float3 BaseColor;
                                                                                float3 NormalTS;
                                                                                float3 Emission;
                                                                                float Metallic;
                                                                                float Smoothness;
                                                                                float Occlusion;
                                                                                float Alpha;
                                                                            };

                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                            {
                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                UnityTexture2D _Property_9e5787ff777c43db8b9ea801e309fc9b_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                                                                                float4 _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_9e5787ff777c43db8b9ea801e309fc9b_Out_0.tex, _Property_9e5787ff777c43db8b9ea801e309fc9b_Out_0.samplerstate, _Property_9e5787ff777c43db8b9ea801e309fc9b_Out_0.GetTransformedUV(IN.uv0.xy));
                                                                                float _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_R_4 = _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0.r;
                                                                                float _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_G_5 = _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0.g;
                                                                                float _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_B_6 = _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0.b;
                                                                                float _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_A_7 = _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0.a;
                                                                                float4 _Property_b37916350fdd4197bd2377cc4806d65b_Out_0 = _Tint;
                                                                                float4 _Multiply_3a41105f027849dd80cc07ab836b38e9_Out_2;
                                                                                Unity_Multiply_float4_float4(_SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0, _Property_b37916350fdd4197bd2377cc4806d65b_Out_0, _Multiply_3a41105f027849dd80cc07ab836b38e9_Out_2);
                                                                                float _Property_3da0c57fa07440e889d95435bcf4a0aa_Out_0 = _Smoothness;
                                                                                float4 _ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                                                float2 _Property_eb4fae0eaa8e4fe3ac5491ba9981452e_Out_0 = _PlayerPos;
                                                                                float2 _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3;
                                                                                Unity_Remap_float2(_Property_eb4fae0eaa8e4fe3ac5491ba9981452e_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3);
                                                                                float2 _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2;
                                                                                Unity_Add_float2((_ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0.xy), _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3, _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2);
                                                                                float2 _TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3;
                                                                                Unity_TilingAndOffset_float((_ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0.xy), float2 (1, 1), _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2, _TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3);
                                                                                float2 _Multiply_3c357794168141569d428cf555d98c3b_Out_2;
                                                                                Unity_Multiply_float2_float2(_TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3, float2(2, 2), _Multiply_3c357794168141569d428cf555d98c3b_Out_2);
                                                                                float2 _Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2;
                                                                                Unity_Subtract_float2(_Multiply_3c357794168141569d428cf555d98c3b_Out_2, float2(1, 1), _Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2);
                                                                                float _Divide_460be555daed4e16b511e7a1a2600d99_Out_2;
                                                                                Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_460be555daed4e16b511e7a1a2600d99_Out_2);
                                                                                float _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0 = _Size;
                                                                                float _Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2;
                                                                                Unity_Multiply_float_float(_Divide_460be555daed4e16b511e7a1a2600d99_Out_2, _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0, _Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2);
                                                                                float2 _Vector2_80510f86d5564e69a6a87561f22e4e37_Out_0 = float2(_Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2, _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0);
                                                                                float2 _Divide_ef5d4c7889484ffb9129e280560351a9_Out_2;
                                                                                Unity_Divide_float2(_Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2, _Vector2_80510f86d5564e69a6a87561f22e4e37_Out_0, _Divide_ef5d4c7889484ffb9129e280560351a9_Out_2);
                                                                                float _Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1;
                                                                                Unity_Length_float2(_Divide_ef5d4c7889484ffb9129e280560351a9_Out_2, _Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1);
                                                                                float _OneMinus_7f29374d2cde401bb19dcde091630251_Out_1;
                                                                                Unity_OneMinus_float(_Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1, _OneMinus_7f29374d2cde401bb19dcde091630251_Out_1);
                                                                                float _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1;
                                                                                Unity_Saturate_float(_OneMinus_7f29374d2cde401bb19dcde091630251_Out_1, _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1);
                                                                                float _Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3;
                                                                                Unity_Smoothstep_float(0, _Property_3da0c57fa07440e889d95435bcf4a0aa_Out_0, _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1, _Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3);
                                                                                float _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2;
                                                                                Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2);
                                                                                float _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2;
                                                                                Unity_Multiply_float_float(_Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3, _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2, _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2);
                                                                                float _Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2;
                                                                                Unity_Add_float(_Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3, _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2, _Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2);
                                                                                float _Property_aa04ea6e4cde4cf283c8da199d728c36_Out_0 = _Opacity;
                                                                                float _Multiply_3b690d7382254556a19014f1915567e9_Out_2;
                                                                                Unity_Multiply_float_float(_Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2, _Property_aa04ea6e4cde4cf283c8da199d728c36_Out_0, _Multiply_3b690d7382254556a19014f1915567e9_Out_2);
                                                                                float _Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3;
                                                                                Unity_Clamp_float(_Multiply_3b690d7382254556a19014f1915567e9_Out_2, 0, 1, _Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3);
                                                                                float _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1;
                                                                                Unity_OneMinus_float(_Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3, _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1);
                                                                                surface.BaseColor = (_Multiply_3a41105f027849dd80cc07ab836b38e9_Out_2.xyz);
                                                                                surface.NormalTS = IN.TangentSpaceNormal;
                                                                                surface.Emission = float3(0, 0, 0);
                                                                                surface.Metallic = 0;
                                                                                surface.Smoothness = 0.5;
                                                                                surface.Occlusion = 1;
                                                                                surface.Alpha = _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1;
                                                                                return surface;
                                                                            }

                                                                            // --------------------------------------------------
                                                                            // Build Graph Inputs
                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                            #endif
                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                            {
                                                                                VertexDescriptionInputs output;
                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                output.ObjectSpacePosition = input.positionOS;

                                                                                return output;
                                                                            }
                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                            {
                                                                                SurfaceDescriptionInputs output;
                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                            #endif





                                                                                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                                                                output.WorldSpacePosition = input.positionWS;
                                                                                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                                output.uv0 = input.texCoord0;
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                            #else
                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                            #endif
                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                    return output;
                                                                            }

                                                                            // --------------------------------------------------
                                                                            // Main

                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

                                                                            // --------------------------------------------------
                                                                            // Visual Effect Vertex Invocations
                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                            #endif

                                                                            ENDHLSL
                                                                            }
                                                                            Pass
                                                                            {
                                                                                Name "ShadowCaster"
                                                                                Tags
                                                                                {
                                                                                    "LightMode" = "ShadowCaster"
                                                                                }

                                                                                // Render State
                                                                                Cull Back
                                                                                ZTest LEqual
                                                                                ZWrite On
                                                                                ColorMask 0

                                                                                // Debug
                                                                                // <None>

                                                                                // --------------------------------------------------
                                                                                // Pass

                                                                                HLSLPROGRAM

                                                                                // Pragmas
                                                                                #pragma target 2.0
                                                                                #pragma only_renderers gles gles3 glcore d3d11
                                                                                #pragma multi_compile_instancing
                                                                                #pragma vertex vert
                                                                                #pragma fragment frag

                                                                                // DotsInstancingOptions: <None>
                                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                                // Keywords
                                                                                #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
                                                                                // GraphKeywords: <None>

                                                                                // Defines

                                                                                #define _NORMALMAP 1
                                                                                #define _NORMAL_DROPOFF_TS 1
                                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                #define VARYINGS_NEED_POSITION_WS
                                                                                #define VARYINGS_NEED_NORMAL_WS
                                                                                #define VARYINGS_NEED_TEXCOORD0
                                                                                #define FEATURES_GRAPH_VERTEX
                                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                #define SHADERPASS SHADERPASS_SHADOWCASTER
                                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                // custom interpolator pre-include
                                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                // Includes
                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                // --------------------------------------------------
                                                                                // Structs and Packing

                                                                                // custom interpolators pre packing
                                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                struct Attributes
                                                                                {
                                                                                     float3 positionOS : POSITION;
                                                                                     float3 normalOS : NORMAL;
                                                                                     float4 tangentOS : TANGENT;
                                                                                     float4 uv0 : TEXCOORD0;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                                    #endif
                                                                                };
                                                                                struct Varyings
                                                                                {
                                                                                     float4 positionCS : SV_POSITION;
                                                                                     float3 positionWS;
                                                                                     float3 normalWS;
                                                                                     float4 texCoord0;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                    #endif
                                                                                };
                                                                                struct SurfaceDescriptionInputs
                                                                                {
                                                                                     float3 WorldSpacePosition;
                                                                                     float4 ScreenPosition;
                                                                                     float4 uv0;
                                                                                };
                                                                                struct VertexDescriptionInputs
                                                                                {
                                                                                     float3 ObjectSpaceNormal;
                                                                                     float3 ObjectSpaceTangent;
                                                                                     float3 ObjectSpacePosition;
                                                                                };
                                                                                struct PackedVaryings
                                                                                {
                                                                                     float4 positionCS : SV_POSITION;
                                                                                     float3 interp0 : INTERP0;
                                                                                     float3 interp1 : INTERP1;
                                                                                     float4 interp2 : INTERP2;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                    #endif
                                                                                };

                                                                                PackedVaryings PackVaryings(Varyings input)
                                                                                {
                                                                                    PackedVaryings output;
                                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                                    output.positionCS = input.positionCS;
                                                                                    output.interp0.xyz = input.positionWS;
                                                                                    output.interp1.xyz = input.normalWS;
                                                                                    output.interp2.xyzw = input.texCoord0;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                    output.instanceID = input.instanceID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                    output.cullFace = input.cullFace;
                                                                                    #endif
                                                                                    return output;
                                                                                }

                                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                                {
                                                                                    Varyings output;
                                                                                    output.positionCS = input.positionCS;
                                                                                    output.positionWS = input.interp0.xyz;
                                                                                    output.normalWS = input.interp1.xyz;
                                                                                    output.texCoord0 = input.interp2.xyzw;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                    output.instanceID = input.instanceID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                    output.cullFace = input.cullFace;
                                                                                    #endif
                                                                                    return output;
                                                                                }


                                                                                // --------------------------------------------------
                                                                                // Graph

                                                                                // Graph Properties
                                                                                CBUFFER_START(UnityPerMaterial)
                                                                                float2 _PlayerPos;
                                                                                float _Size;
                                                                                float _Smoothness;
                                                                                float _Opacity;
                                                                                float4 _MainTex_TexelSize;
                                                                                float4 _Tint;
                                                                                CBUFFER_END

                                                                                    // Object and Global properties
                                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                                    TEXTURE2D(_MainTex);
                                                                                    SAMPLER(sampler_MainTex);

                                                                                    // Graph Includes
                                                                                    // GraphIncludes: <None>

                                                                                    // -- Property used by ScenePickingPass
                                                                                    #ifdef SCENEPICKINGPASS
                                                                                    float4 _SelectionID;
                                                                                    #endif

                                                                                    // -- Properties used by SceneSelectionPass
                                                                                    #ifdef SCENESELECTIONPASS
                                                                                    int _ObjectId;
                                                                                    int _PassValue;
                                                                                    #endif

                                                                                    // Graph Functions

                                                                                    void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                                                                    {
                                                                                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                                                    }

                                                                                    void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                                                                    {
                                                                                        Out = A + B;
                                                                                    }

                                                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                    {
                                                                                        Out = UV * Tiling + Offset;
                                                                                    }

                                                                                    void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                                                    {
                                                                                        Out = A * B;
                                                                                    }

                                                                                    void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                                                    {
                                                                                        Out = A - B;
                                                                                    }

                                                                                    void Unity_Divide_float(float A, float B, out float Out)
                                                                                    {
                                                                                        Out = A / B;
                                                                                    }

                                                                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                                    {
                                                                                        Out = A * B;
                                                                                    }

                                                                                    void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                                                    {
                                                                                        Out = A / B;
                                                                                    }

                                                                                    void Unity_Length_float2(float2 In, out float Out)
                                                                                    {
                                                                                        Out = length(In);
                                                                                    }

                                                                                    void Unity_OneMinus_float(float In, out float Out)
                                                                                    {
                                                                                        Out = 1 - In;
                                                                                    }

                                                                                    void Unity_Saturate_float(float In, out float Out)
                                                                                    {
                                                                                        Out = saturate(In);
                                                                                    }

                                                                                    void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                                                    {
                                                                                        Out = smoothstep(Edge1, Edge2, In);
                                                                                    }


                                                                                    float2 Unity_GradientNoise_Dir_float(float2 p)
                                                                                    {
                                                                                        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                                                        p = p % 289;
                                                                                        // need full precision, otherwise half overflows when p > 1
                                                                                        float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                                                        x = (34 * x + 1) * x % 289;
                                                                                        x = frac(x / 41) * 2 - 1;
                                                                                        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                                                    }

                                                                                    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                                                    {
                                                                                        float2 p = UV * Scale;
                                                                                        float2 ip = floor(p);
                                                                                        float2 fp = frac(p);
                                                                                        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                                                        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                                                        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                                                        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                                                        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                                                        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                                                    }

                                                                                    void Unity_Add_float(float A, float B, out float Out)
                                                                                    {
                                                                                        Out = A + B;
                                                                                    }

                                                                                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                                    {
                                                                                        Out = clamp(In, Min, Max);
                                                                                    }

                                                                                    // Custom interpolators pre vertex
                                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                    // Graph Vertex
                                                                                    struct VertexDescription
                                                                                    {
                                                                                        float3 Position;
                                                                                        float3 Normal;
                                                                                        float3 Tangent;
                                                                                    };

                                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                    {
                                                                                        VertexDescription description = (VertexDescription)0;
                                                                                        description.Position = IN.ObjectSpacePosition;
                                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                                        return description;
                                                                                    }

                                                                                    // Custom interpolators, pre surface
                                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                    {
                                                                                    return output;
                                                                                    }
                                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                    #endif

                                                                                    // Graph Pixel
                                                                                    struct SurfaceDescription
                                                                                    {
                                                                                        float Alpha;
                                                                                    };

                                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                    {
                                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                                        float _Property_3da0c57fa07440e889d95435bcf4a0aa_Out_0 = _Smoothness;
                                                                                        float4 _ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                                                        float2 _Property_eb4fae0eaa8e4fe3ac5491ba9981452e_Out_0 = _PlayerPos;
                                                                                        float2 _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3;
                                                                                        Unity_Remap_float2(_Property_eb4fae0eaa8e4fe3ac5491ba9981452e_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3);
                                                                                        float2 _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2;
                                                                                        Unity_Add_float2((_ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0.xy), _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3, _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2);
                                                                                        float2 _TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3;
                                                                                        Unity_TilingAndOffset_float((_ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0.xy), float2 (1, 1), _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2, _TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3);
                                                                                        float2 _Multiply_3c357794168141569d428cf555d98c3b_Out_2;
                                                                                        Unity_Multiply_float2_float2(_TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3, float2(2, 2), _Multiply_3c357794168141569d428cf555d98c3b_Out_2);
                                                                                        float2 _Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2;
                                                                                        Unity_Subtract_float2(_Multiply_3c357794168141569d428cf555d98c3b_Out_2, float2(1, 1), _Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2);
                                                                                        float _Divide_460be555daed4e16b511e7a1a2600d99_Out_2;
                                                                                        Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_460be555daed4e16b511e7a1a2600d99_Out_2);
                                                                                        float _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0 = _Size;
                                                                                        float _Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2;
                                                                                        Unity_Multiply_float_float(_Divide_460be555daed4e16b511e7a1a2600d99_Out_2, _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0, _Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2);
                                                                                        float2 _Vector2_80510f86d5564e69a6a87561f22e4e37_Out_0 = float2(_Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2, _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0);
                                                                                        float2 _Divide_ef5d4c7889484ffb9129e280560351a9_Out_2;
                                                                                        Unity_Divide_float2(_Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2, _Vector2_80510f86d5564e69a6a87561f22e4e37_Out_0, _Divide_ef5d4c7889484ffb9129e280560351a9_Out_2);
                                                                                        float _Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1;
                                                                                        Unity_Length_float2(_Divide_ef5d4c7889484ffb9129e280560351a9_Out_2, _Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1);
                                                                                        float _OneMinus_7f29374d2cde401bb19dcde091630251_Out_1;
                                                                                        Unity_OneMinus_float(_Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1, _OneMinus_7f29374d2cde401bb19dcde091630251_Out_1);
                                                                                        float _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1;
                                                                                        Unity_Saturate_float(_OneMinus_7f29374d2cde401bb19dcde091630251_Out_1, _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1);
                                                                                        float _Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3;
                                                                                        Unity_Smoothstep_float(0, _Property_3da0c57fa07440e889d95435bcf4a0aa_Out_0, _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1, _Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3);
                                                                                        float _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2;
                                                                                        Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2);
                                                                                        float _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2;
                                                                                        Unity_Multiply_float_float(_Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3, _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2, _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2);
                                                                                        float _Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2;
                                                                                        Unity_Add_float(_Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3, _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2, _Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2);
                                                                                        float _Property_aa04ea6e4cde4cf283c8da199d728c36_Out_0 = _Opacity;
                                                                                        float _Multiply_3b690d7382254556a19014f1915567e9_Out_2;
                                                                                        Unity_Multiply_float_float(_Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2, _Property_aa04ea6e4cde4cf283c8da199d728c36_Out_0, _Multiply_3b690d7382254556a19014f1915567e9_Out_2);
                                                                                        float _Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3;
                                                                                        Unity_Clamp_float(_Multiply_3b690d7382254556a19014f1915567e9_Out_2, 0, 1, _Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3);
                                                                                        float _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1;
                                                                                        Unity_OneMinus_float(_Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3, _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1);
                                                                                        surface.Alpha = _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1;
                                                                                        return surface;
                                                                                    }

                                                                                    // --------------------------------------------------
                                                                                    // Build Graph Inputs
                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                    #endif
                                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                    {
                                                                                        VertexDescriptionInputs output;
                                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                        output.ObjectSpacePosition = input.positionOS;

                                                                                        return output;
                                                                                    }
                                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                    {
                                                                                        SurfaceDescriptionInputs output;
                                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                    #endif







                                                                                        output.WorldSpacePosition = input.positionWS;
                                                                                        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                                        output.uv0 = input.texCoord0;
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                    #else
                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                    #endif
                                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                            return output;
                                                                                    }

                                                                                    // --------------------------------------------------
                                                                                    // Main

                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

                                                                                    // --------------------------------------------------
                                                                                    // Visual Effect Vertex Invocations
                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                    #endif

                                                                                    ENDHLSL
                                                                                    }
                                                                                    Pass
                                                                                    {
                                                                                        Name "DepthNormals"
                                                                                        Tags
                                                                                        {
                                                                                            "LightMode" = "DepthNormals"
                                                                                        }

                                                                                        // Render State
                                                                                        Cull Back
                                                                                        ZTest LEqual
                                                                                        ZWrite On

                                                                                        // Debug
                                                                                        // <None>

                                                                                        // --------------------------------------------------
                                                                                        // Pass

                                                                                        HLSLPROGRAM

                                                                                        // Pragmas
                                                                                        #pragma target 2.0
                                                                                        #pragma only_renderers gles gles3 glcore d3d11
                                                                                        #pragma multi_compile_instancing
                                                                                        #pragma vertex vert
                                                                                        #pragma fragment frag

                                                                                        // DotsInstancingOptions: <None>
                                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                                        // Keywords
                                                                                        // PassKeywords: <None>
                                                                                        // GraphKeywords: <None>

                                                                                        // Defines

                                                                                        #define _NORMALMAP 1
                                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                                                                        #define VARYINGS_NEED_POSITION_WS
                                                                                        #define VARYINGS_NEED_NORMAL_WS
                                                                                        #define VARYINGS_NEED_TANGENT_WS
                                                                                        #define VARYINGS_NEED_TEXCOORD0
                                                                                        #define FEATURES_GRAPH_VERTEX
                                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                        #define SHADERPASS SHADERPASS_DEPTHNORMALS
                                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                        // custom interpolator pre-include
                                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                        // Includes
                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                        // --------------------------------------------------
                                                                                        // Structs and Packing

                                                                                        // custom interpolators pre packing
                                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                        struct Attributes
                                                                                        {
                                                                                             float3 positionOS : POSITION;
                                                                                             float3 normalOS : NORMAL;
                                                                                             float4 tangentOS : TANGENT;
                                                                                             float4 uv0 : TEXCOORD0;
                                                                                             float4 uv1 : TEXCOORD1;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                                            #endif
                                                                                        };
                                                                                        struct Varyings
                                                                                        {
                                                                                             float4 positionCS : SV_POSITION;
                                                                                             float3 positionWS;
                                                                                             float3 normalWS;
                                                                                             float4 tangentWS;
                                                                                             float4 texCoord0;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                            #endif
                                                                                        };
                                                                                        struct SurfaceDescriptionInputs
                                                                                        {
                                                                                             float3 TangentSpaceNormal;
                                                                                             float3 WorldSpacePosition;
                                                                                             float4 ScreenPosition;
                                                                                             float4 uv0;
                                                                                        };
                                                                                        struct VertexDescriptionInputs
                                                                                        {
                                                                                             float3 ObjectSpaceNormal;
                                                                                             float3 ObjectSpaceTangent;
                                                                                             float3 ObjectSpacePosition;
                                                                                        };
                                                                                        struct PackedVaryings
                                                                                        {
                                                                                             float4 positionCS : SV_POSITION;
                                                                                             float3 interp0 : INTERP0;
                                                                                             float3 interp1 : INTERP1;
                                                                                             float4 interp2 : INTERP2;
                                                                                             float4 interp3 : INTERP3;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                            #endif
                                                                                        };

                                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                                        {
                                                                                            PackedVaryings output;
                                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                                            output.positionCS = input.positionCS;
                                                                                            output.interp0.xyz = input.positionWS;
                                                                                            output.interp1.xyz = input.normalWS;
                                                                                            output.interp2.xyzw = input.tangentWS;
                                                                                            output.interp3.xyzw = input.texCoord0;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                            output.instanceID = input.instanceID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                            output.cullFace = input.cullFace;
                                                                                            #endif
                                                                                            return output;
                                                                                        }

                                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                                        {
                                                                                            Varyings output;
                                                                                            output.positionCS = input.positionCS;
                                                                                            output.positionWS = input.interp0.xyz;
                                                                                            output.normalWS = input.interp1.xyz;
                                                                                            output.tangentWS = input.interp2.xyzw;
                                                                                            output.texCoord0 = input.interp3.xyzw;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                            output.instanceID = input.instanceID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                            output.cullFace = input.cullFace;
                                                                                            #endif
                                                                                            return output;
                                                                                        }


                                                                                        // --------------------------------------------------
                                                                                        // Graph

                                                                                        // Graph Properties
                                                                                        CBUFFER_START(UnityPerMaterial)
                                                                                        float2 _PlayerPos;
                                                                                        float _Size;
                                                                                        float _Smoothness;
                                                                                        float _Opacity;
                                                                                        float4 _MainTex_TexelSize;
                                                                                        float4 _Tint;
                                                                                        CBUFFER_END

                                                                                            // Object and Global properties
                                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                                            TEXTURE2D(_MainTex);
                                                                                            SAMPLER(sampler_MainTex);

                                                                                            // Graph Includes
                                                                                            // GraphIncludes: <None>

                                                                                            // -- Property used by ScenePickingPass
                                                                                            #ifdef SCENEPICKINGPASS
                                                                                            float4 _SelectionID;
                                                                                            #endif

                                                                                            // -- Properties used by SceneSelectionPass
                                                                                            #ifdef SCENESELECTIONPASS
                                                                                            int _ObjectId;
                                                                                            int _PassValue;
                                                                                            #endif

                                                                                            // Graph Functions

                                                                                            void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                                                                            {
                                                                                                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                                                            }

                                                                                            void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                                                                            {
                                                                                                Out = A + B;
                                                                                            }

                                                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                            {
                                                                                                Out = UV * Tiling + Offset;
                                                                                            }

                                                                                            void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                                                            {
                                                                                                Out = A * B;
                                                                                            }

                                                                                            void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                                                            {
                                                                                                Out = A - B;
                                                                                            }

                                                                                            void Unity_Divide_float(float A, float B, out float Out)
                                                                                            {
                                                                                                Out = A / B;
                                                                                            }

                                                                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                                            {
                                                                                                Out = A * B;
                                                                                            }

                                                                                            void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                                                            {
                                                                                                Out = A / B;
                                                                                            }

                                                                                            void Unity_Length_float2(float2 In, out float Out)
                                                                                            {
                                                                                                Out = length(In);
                                                                                            }

                                                                                            void Unity_OneMinus_float(float In, out float Out)
                                                                                            {
                                                                                                Out = 1 - In;
                                                                                            }

                                                                                            void Unity_Saturate_float(float In, out float Out)
                                                                                            {
                                                                                                Out = saturate(In);
                                                                                            }

                                                                                            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                                                            {
                                                                                                Out = smoothstep(Edge1, Edge2, In);
                                                                                            }


                                                                                            float2 Unity_GradientNoise_Dir_float(float2 p)
                                                                                            {
                                                                                                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                                                                p = p % 289;
                                                                                                // need full precision, otherwise half overflows when p > 1
                                                                                                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                                                                x = (34 * x + 1) * x % 289;
                                                                                                x = frac(x / 41) * 2 - 1;
                                                                                                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                                                            }

                                                                                            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                                                            {
                                                                                                float2 p = UV * Scale;
                                                                                                float2 ip = floor(p);
                                                                                                float2 fp = frac(p);
                                                                                                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                                                                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                                                                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                                                                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                                                                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                                                                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                                                            }

                                                                                            void Unity_Add_float(float A, float B, out float Out)
                                                                                            {
                                                                                                Out = A + B;
                                                                                            }

                                                                                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                                            {
                                                                                                Out = clamp(In, Min, Max);
                                                                                            }

                                                                                            // Custom interpolators pre vertex
                                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                            // Graph Vertex
                                                                                            struct VertexDescription
                                                                                            {
                                                                                                float3 Position;
                                                                                                float3 Normal;
                                                                                                float3 Tangent;
                                                                                            };

                                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                            {
                                                                                                VertexDescription description = (VertexDescription)0;
                                                                                                description.Position = IN.ObjectSpacePosition;
                                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                                return description;
                                                                                            }

                                                                                            // Custom interpolators, pre surface
                                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                            {
                                                                                            return output;
                                                                                            }
                                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                            #endif

                                                                                            // Graph Pixel
                                                                                            struct SurfaceDescription
                                                                                            {
                                                                                                float3 NormalTS;
                                                                                                float Alpha;
                                                                                            };

                                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                            {
                                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                float _Property_3da0c57fa07440e889d95435bcf4a0aa_Out_0 = _Smoothness;
                                                                                                float4 _ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                                                                float2 _Property_eb4fae0eaa8e4fe3ac5491ba9981452e_Out_0 = _PlayerPos;
                                                                                                float2 _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3;
                                                                                                Unity_Remap_float2(_Property_eb4fae0eaa8e4fe3ac5491ba9981452e_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3);
                                                                                                float2 _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2;
                                                                                                Unity_Add_float2((_ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0.xy), _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3, _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2);
                                                                                                float2 _TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3;
                                                                                                Unity_TilingAndOffset_float((_ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0.xy), float2 (1, 1), _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2, _TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3);
                                                                                                float2 _Multiply_3c357794168141569d428cf555d98c3b_Out_2;
                                                                                                Unity_Multiply_float2_float2(_TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3, float2(2, 2), _Multiply_3c357794168141569d428cf555d98c3b_Out_2);
                                                                                                float2 _Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2;
                                                                                                Unity_Subtract_float2(_Multiply_3c357794168141569d428cf555d98c3b_Out_2, float2(1, 1), _Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2);
                                                                                                float _Divide_460be555daed4e16b511e7a1a2600d99_Out_2;
                                                                                                Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_460be555daed4e16b511e7a1a2600d99_Out_2);
                                                                                                float _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0 = _Size;
                                                                                                float _Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2;
                                                                                                Unity_Multiply_float_float(_Divide_460be555daed4e16b511e7a1a2600d99_Out_2, _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0, _Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2);
                                                                                                float2 _Vector2_80510f86d5564e69a6a87561f22e4e37_Out_0 = float2(_Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2, _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0);
                                                                                                float2 _Divide_ef5d4c7889484ffb9129e280560351a9_Out_2;
                                                                                                Unity_Divide_float2(_Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2, _Vector2_80510f86d5564e69a6a87561f22e4e37_Out_0, _Divide_ef5d4c7889484ffb9129e280560351a9_Out_2);
                                                                                                float _Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1;
                                                                                                Unity_Length_float2(_Divide_ef5d4c7889484ffb9129e280560351a9_Out_2, _Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1);
                                                                                                float _OneMinus_7f29374d2cde401bb19dcde091630251_Out_1;
                                                                                                Unity_OneMinus_float(_Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1, _OneMinus_7f29374d2cde401bb19dcde091630251_Out_1);
                                                                                                float _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1;
                                                                                                Unity_Saturate_float(_OneMinus_7f29374d2cde401bb19dcde091630251_Out_1, _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1);
                                                                                                float _Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3;
                                                                                                Unity_Smoothstep_float(0, _Property_3da0c57fa07440e889d95435bcf4a0aa_Out_0, _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1, _Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3);
                                                                                                float _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2;
                                                                                                Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2);
                                                                                                float _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2;
                                                                                                Unity_Multiply_float_float(_Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3, _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2, _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2);
                                                                                                float _Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2;
                                                                                                Unity_Add_float(_Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3, _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2, _Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2);
                                                                                                float _Property_aa04ea6e4cde4cf283c8da199d728c36_Out_0 = _Opacity;
                                                                                                float _Multiply_3b690d7382254556a19014f1915567e9_Out_2;
                                                                                                Unity_Multiply_float_float(_Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2, _Property_aa04ea6e4cde4cf283c8da199d728c36_Out_0, _Multiply_3b690d7382254556a19014f1915567e9_Out_2);
                                                                                                float _Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3;
                                                                                                Unity_Clamp_float(_Multiply_3b690d7382254556a19014f1915567e9_Out_2, 0, 1, _Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3);
                                                                                                float _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1;
                                                                                                Unity_OneMinus_float(_Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3, _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1);
                                                                                                surface.NormalTS = IN.TangentSpaceNormal;
                                                                                                surface.Alpha = _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1;
                                                                                                return surface;
                                                                                            }

                                                                                            // --------------------------------------------------
                                                                                            // Build Graph Inputs
                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                            #endif
                                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                            {
                                                                                                VertexDescriptionInputs output;
                                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                output.ObjectSpacePosition = input.positionOS;

                                                                                                return output;
                                                                                            }
                                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                            {
                                                                                                SurfaceDescriptionInputs output;
                                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                            #endif





                                                                                                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                                                                                output.WorldSpacePosition = input.positionWS;
                                                                                                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                                                output.uv0 = input.texCoord0;
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                            #else
                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                            #endif
                                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                    return output;
                                                                                            }

                                                                                            // --------------------------------------------------
                                                                                            // Main

                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

                                                                                            // --------------------------------------------------
                                                                                            // Visual Effect Vertex Invocations
                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                            #endif

                                                                                            ENDHLSL
                                                                                            }
                                                                                            Pass
                                                                                            {
                                                                                                Name "Meta"
                                                                                                Tags
                                                                                                {
                                                                                                    "LightMode" = "Meta"
                                                                                                }

                                                                                                // Render State
                                                                                                Cull Off

                                                                                                // Debug
                                                                                                // <None>

                                                                                                // --------------------------------------------------
                                                                                                // Pass

                                                                                                HLSLPROGRAM

                                                                                                // Pragmas
                                                                                                #pragma target 2.0
                                                                                                #pragma only_renderers gles gles3 glcore d3d11
                                                                                                #pragma vertex vert
                                                                                                #pragma fragment frag

                                                                                                // DotsInstancingOptions: <None>
                                                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                                                // Keywords
                                                                                                #pragma shader_feature _ EDITOR_VISUALIZATION
                                                                                                // GraphKeywords: <None>

                                                                                                // Defines

                                                                                                #define _NORMALMAP 1
                                                                                                #define _NORMAL_DROPOFF_TS 1
                                                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                                #define ATTRIBUTES_NEED_TEXCOORD1
                                                                                                #define ATTRIBUTES_NEED_TEXCOORD2
                                                                                                #define VARYINGS_NEED_POSITION_WS
                                                                                                #define VARYINGS_NEED_TEXCOORD0
                                                                                                #define VARYINGS_NEED_TEXCOORD1
                                                                                                #define VARYINGS_NEED_TEXCOORD2
                                                                                                #define FEATURES_GRAPH_VERTEX
                                                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                #define SHADERPASS SHADERPASS_META
                                                                                                #define _FOG_FRAGMENT 1
                                                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                // custom interpolator pre-include
                                                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                // Includes
                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                // --------------------------------------------------
                                                                                                // Structs and Packing

                                                                                                // custom interpolators pre packing
                                                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                struct Attributes
                                                                                                {
                                                                                                     float3 positionOS : POSITION;
                                                                                                     float3 normalOS : NORMAL;
                                                                                                     float4 tangentOS : TANGENT;
                                                                                                     float4 uv0 : TEXCOORD0;
                                                                                                     float4 uv1 : TEXCOORD1;
                                                                                                     float4 uv2 : TEXCOORD2;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                    #endif
                                                                                                };
                                                                                                struct Varyings
                                                                                                {
                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                     float3 positionWS;
                                                                                                     float4 texCoord0;
                                                                                                     float4 texCoord1;
                                                                                                     float4 texCoord2;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                    #endif
                                                                                                };
                                                                                                struct SurfaceDescriptionInputs
                                                                                                {
                                                                                                     float3 WorldSpacePosition;
                                                                                                     float4 ScreenPosition;
                                                                                                     float4 uv0;
                                                                                                };
                                                                                                struct VertexDescriptionInputs
                                                                                                {
                                                                                                     float3 ObjectSpaceNormal;
                                                                                                     float3 ObjectSpaceTangent;
                                                                                                     float3 ObjectSpacePosition;
                                                                                                };
                                                                                                struct PackedVaryings
                                                                                                {
                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                     float3 interp0 : INTERP0;
                                                                                                     float4 interp1 : INTERP1;
                                                                                                     float4 interp2 : INTERP2;
                                                                                                     float4 interp3 : INTERP3;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                    #endif
                                                                                                };

                                                                                                PackedVaryings PackVaryings(Varyings input)
                                                                                                {
                                                                                                    PackedVaryings output;
                                                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                    output.positionCS = input.positionCS;
                                                                                                    output.interp0.xyz = input.positionWS;
                                                                                                    output.interp1.xyzw = input.texCoord0;
                                                                                                    output.interp2.xyzw = input.texCoord1;
                                                                                                    output.interp3.xyzw = input.texCoord2;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                    output.instanceID = input.instanceID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                    output.cullFace = input.cullFace;
                                                                                                    #endif
                                                                                                    return output;
                                                                                                }

                                                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                                                {
                                                                                                    Varyings output;
                                                                                                    output.positionCS = input.positionCS;
                                                                                                    output.positionWS = input.interp0.xyz;
                                                                                                    output.texCoord0 = input.interp1.xyzw;
                                                                                                    output.texCoord1 = input.interp2.xyzw;
                                                                                                    output.texCoord2 = input.interp3.xyzw;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                    output.instanceID = input.instanceID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                    output.cullFace = input.cullFace;
                                                                                                    #endif
                                                                                                    return output;
                                                                                                }


                                                                                                // --------------------------------------------------
                                                                                                // Graph

                                                                                                // Graph Properties
                                                                                                CBUFFER_START(UnityPerMaterial)
                                                                                                float2 _PlayerPos;
                                                                                                float _Size;
                                                                                                float _Smoothness;
                                                                                                float _Opacity;
                                                                                                float4 _MainTex_TexelSize;
                                                                                                float4 _Tint;
                                                                                                CBUFFER_END

                                                                                                    // Object and Global properties
                                                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                                                    TEXTURE2D(_MainTex);
                                                                                                    SAMPLER(sampler_MainTex);

                                                                                                    // Graph Includes
                                                                                                    // GraphIncludes: <None>

                                                                                                    // -- Property used by ScenePickingPass
                                                                                                    #ifdef SCENEPICKINGPASS
                                                                                                    float4 _SelectionID;
                                                                                                    #endif

                                                                                                    // -- Properties used by SceneSelectionPass
                                                                                                    #ifdef SCENESELECTIONPASS
                                                                                                    int _ObjectId;
                                                                                                    int _PassValue;
                                                                                                    #endif

                                                                                                    // Graph Functions

                                                                                                    void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                                                                    {
                                                                                                        Out = A * B;
                                                                                                    }

                                                                                                    void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                                                                                    {
                                                                                                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                                                                    }

                                                                                                    void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                                                                                    {
                                                                                                        Out = A + B;
                                                                                                    }

                                                                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                                    {
                                                                                                        Out = UV * Tiling + Offset;
                                                                                                    }

                                                                                                    void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                                                                    {
                                                                                                        Out = A * B;
                                                                                                    }

                                                                                                    void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                                                                    {
                                                                                                        Out = A - B;
                                                                                                    }

                                                                                                    void Unity_Divide_float(float A, float B, out float Out)
                                                                                                    {
                                                                                                        Out = A / B;
                                                                                                    }

                                                                                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                                                    {
                                                                                                        Out = A * B;
                                                                                                    }

                                                                                                    void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                                                                    {
                                                                                                        Out = A / B;
                                                                                                    }

                                                                                                    void Unity_Length_float2(float2 In, out float Out)
                                                                                                    {
                                                                                                        Out = length(In);
                                                                                                    }

                                                                                                    void Unity_OneMinus_float(float In, out float Out)
                                                                                                    {
                                                                                                        Out = 1 - In;
                                                                                                    }

                                                                                                    void Unity_Saturate_float(float In, out float Out)
                                                                                                    {
                                                                                                        Out = saturate(In);
                                                                                                    }

                                                                                                    void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                                                                    {
                                                                                                        Out = smoothstep(Edge1, Edge2, In);
                                                                                                    }


                                                                                                    float2 Unity_GradientNoise_Dir_float(float2 p)
                                                                                                    {
                                                                                                        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                                                                        p = p % 289;
                                                                                                        // need full precision, otherwise half overflows when p > 1
                                                                                                        float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                                                                        x = (34 * x + 1) * x % 289;
                                                                                                        x = frac(x / 41) * 2 - 1;
                                                                                                        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                                                                    }

                                                                                                    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                                                                    {
                                                                                                        float2 p = UV * Scale;
                                                                                                        float2 ip = floor(p);
                                                                                                        float2 fp = frac(p);
                                                                                                        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                                                                        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                                                                        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                                                                        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                                                                        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                                                                        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                                                                    }

                                                                                                    void Unity_Add_float(float A, float B, out float Out)
                                                                                                    {
                                                                                                        Out = A + B;
                                                                                                    }

                                                                                                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                                                    {
                                                                                                        Out = clamp(In, Min, Max);
                                                                                                    }

                                                                                                    // Custom interpolators pre vertex
                                                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                    // Graph Vertex
                                                                                                    struct VertexDescription
                                                                                                    {
                                                                                                        float3 Position;
                                                                                                        float3 Normal;
                                                                                                        float3 Tangent;
                                                                                                    };

                                                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                    {
                                                                                                        VertexDescription description = (VertexDescription)0;
                                                                                                        description.Position = IN.ObjectSpacePosition;
                                                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                                                        return description;
                                                                                                    }

                                                                                                    // Custom interpolators, pre surface
                                                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                    {
                                                                                                    return output;
                                                                                                    }
                                                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                    #endif

                                                                                                    // Graph Pixel
                                                                                                    struct SurfaceDescription
                                                                                                    {
                                                                                                        float3 BaseColor;
                                                                                                        float3 Emission;
                                                                                                        float Alpha;
                                                                                                    };

                                                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                    {
                                                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                        UnityTexture2D _Property_9e5787ff777c43db8b9ea801e309fc9b_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                                                                                                        float4 _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_9e5787ff777c43db8b9ea801e309fc9b_Out_0.tex, _Property_9e5787ff777c43db8b9ea801e309fc9b_Out_0.samplerstate, _Property_9e5787ff777c43db8b9ea801e309fc9b_Out_0.GetTransformedUV(IN.uv0.xy));
                                                                                                        float _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_R_4 = _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0.r;
                                                                                                        float _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_G_5 = _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0.g;
                                                                                                        float _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_B_6 = _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0.b;
                                                                                                        float _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_A_7 = _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0.a;
                                                                                                        float4 _Property_b37916350fdd4197bd2377cc4806d65b_Out_0 = _Tint;
                                                                                                        float4 _Multiply_3a41105f027849dd80cc07ab836b38e9_Out_2;
                                                                                                        Unity_Multiply_float4_float4(_SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0, _Property_b37916350fdd4197bd2377cc4806d65b_Out_0, _Multiply_3a41105f027849dd80cc07ab836b38e9_Out_2);
                                                                                                        float _Property_3da0c57fa07440e889d95435bcf4a0aa_Out_0 = _Smoothness;
                                                                                                        float4 _ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                                                                        float2 _Property_eb4fae0eaa8e4fe3ac5491ba9981452e_Out_0 = _PlayerPos;
                                                                                                        float2 _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3;
                                                                                                        Unity_Remap_float2(_Property_eb4fae0eaa8e4fe3ac5491ba9981452e_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3);
                                                                                                        float2 _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2;
                                                                                                        Unity_Add_float2((_ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0.xy), _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3, _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2);
                                                                                                        float2 _TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3;
                                                                                                        Unity_TilingAndOffset_float((_ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0.xy), float2 (1, 1), _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2, _TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3);
                                                                                                        float2 _Multiply_3c357794168141569d428cf555d98c3b_Out_2;
                                                                                                        Unity_Multiply_float2_float2(_TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3, float2(2, 2), _Multiply_3c357794168141569d428cf555d98c3b_Out_2);
                                                                                                        float2 _Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2;
                                                                                                        Unity_Subtract_float2(_Multiply_3c357794168141569d428cf555d98c3b_Out_2, float2(1, 1), _Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2);
                                                                                                        float _Divide_460be555daed4e16b511e7a1a2600d99_Out_2;
                                                                                                        Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_460be555daed4e16b511e7a1a2600d99_Out_2);
                                                                                                        float _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0 = _Size;
                                                                                                        float _Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2;
                                                                                                        Unity_Multiply_float_float(_Divide_460be555daed4e16b511e7a1a2600d99_Out_2, _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0, _Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2);
                                                                                                        float2 _Vector2_80510f86d5564e69a6a87561f22e4e37_Out_0 = float2(_Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2, _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0);
                                                                                                        float2 _Divide_ef5d4c7889484ffb9129e280560351a9_Out_2;
                                                                                                        Unity_Divide_float2(_Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2, _Vector2_80510f86d5564e69a6a87561f22e4e37_Out_0, _Divide_ef5d4c7889484ffb9129e280560351a9_Out_2);
                                                                                                        float _Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1;
                                                                                                        Unity_Length_float2(_Divide_ef5d4c7889484ffb9129e280560351a9_Out_2, _Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1);
                                                                                                        float _OneMinus_7f29374d2cde401bb19dcde091630251_Out_1;
                                                                                                        Unity_OneMinus_float(_Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1, _OneMinus_7f29374d2cde401bb19dcde091630251_Out_1);
                                                                                                        float _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1;
                                                                                                        Unity_Saturate_float(_OneMinus_7f29374d2cde401bb19dcde091630251_Out_1, _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1);
                                                                                                        float _Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3;
                                                                                                        Unity_Smoothstep_float(0, _Property_3da0c57fa07440e889d95435bcf4a0aa_Out_0, _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1, _Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3);
                                                                                                        float _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2;
                                                                                                        Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2);
                                                                                                        float _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2;
                                                                                                        Unity_Multiply_float_float(_Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3, _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2, _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2);
                                                                                                        float _Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2;
                                                                                                        Unity_Add_float(_Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3, _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2, _Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2);
                                                                                                        float _Property_aa04ea6e4cde4cf283c8da199d728c36_Out_0 = _Opacity;
                                                                                                        float _Multiply_3b690d7382254556a19014f1915567e9_Out_2;
                                                                                                        Unity_Multiply_float_float(_Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2, _Property_aa04ea6e4cde4cf283c8da199d728c36_Out_0, _Multiply_3b690d7382254556a19014f1915567e9_Out_2);
                                                                                                        float _Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3;
                                                                                                        Unity_Clamp_float(_Multiply_3b690d7382254556a19014f1915567e9_Out_2, 0, 1, _Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3);
                                                                                                        float _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1;
                                                                                                        Unity_OneMinus_float(_Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3, _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1);
                                                                                                        surface.BaseColor = (_Multiply_3a41105f027849dd80cc07ab836b38e9_Out_2.xyz);
                                                                                                        surface.Emission = float3(0, 0, 0);
                                                                                                        surface.Alpha = _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1;
                                                                                                        return surface;
                                                                                                    }

                                                                                                    // --------------------------------------------------
                                                                                                    // Build Graph Inputs
                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                    #endif
                                                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                    {
                                                                                                        VertexDescriptionInputs output;
                                                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                        output.ObjectSpacePosition = input.positionOS;

                                                                                                        return output;
                                                                                                    }
                                                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                    {
                                                                                                        SurfaceDescriptionInputs output;
                                                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                    #endif







                                                                                                        output.WorldSpacePosition = input.positionWS;
                                                                                                        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                                                        output.uv0 = input.texCoord0;
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                    #else
                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                    #endif
                                                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                            return output;
                                                                                                    }

                                                                                                    // --------------------------------------------------
                                                                                                    // Main

                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

                                                                                                    // --------------------------------------------------
                                                                                                    // Visual Effect Vertex Invocations
                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                    #endif

                                                                                                    ENDHLSL
                                                                                                    }
                                                                                                    Pass
                                                                                                    {
                                                                                                        Name "SceneSelectionPass"
                                                                                                        Tags
                                                                                                        {
                                                                                                            "LightMode" = "SceneSelectionPass"
                                                                                                        }

                                                                                                        // Render State
                                                                                                        Cull Off

                                                                                                        // Debug
                                                                                                        // <None>

                                                                                                        // --------------------------------------------------
                                                                                                        // Pass

                                                                                                        HLSLPROGRAM

                                                                                                        // Pragmas
                                                                                                        #pragma target 2.0
                                                                                                        #pragma only_renderers gles gles3 glcore d3d11
                                                                                                        #pragma multi_compile_instancing
                                                                                                        #pragma vertex vert
                                                                                                        #pragma fragment frag

                                                                                                        // DotsInstancingOptions: <None>
                                                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                                                        // Keywords
                                                                                                        // PassKeywords: <None>
                                                                                                        // GraphKeywords: <None>

                                                                                                        // Defines

                                                                                                        #define _NORMALMAP 1
                                                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                                        #define VARYINGS_NEED_POSITION_WS
                                                                                                        #define VARYINGS_NEED_TEXCOORD0
                                                                                                        #define FEATURES_GRAPH_VERTEX
                                                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                        #define SHADERPASS SHADERPASS_DEPTHONLY
                                                                                                        #define SCENESELECTIONPASS 1
                                                                                                        #define ALPHA_CLIP_THRESHOLD 1
                                                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                        // custom interpolator pre-include
                                                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                        // Includes
                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                        // --------------------------------------------------
                                                                                                        // Structs and Packing

                                                                                                        // custom interpolators pre packing
                                                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                        struct Attributes
                                                                                                        {
                                                                                                             float3 positionOS : POSITION;
                                                                                                             float3 normalOS : NORMAL;
                                                                                                             float4 tangentOS : TANGENT;
                                                                                                             float4 uv0 : TEXCOORD0;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                            #endif
                                                                                                        };
                                                                                                        struct Varyings
                                                                                                        {
                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                             float3 positionWS;
                                                                                                             float4 texCoord0;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                            #endif
                                                                                                        };
                                                                                                        struct SurfaceDescriptionInputs
                                                                                                        {
                                                                                                             float3 WorldSpacePosition;
                                                                                                             float4 ScreenPosition;
                                                                                                             float4 uv0;
                                                                                                        };
                                                                                                        struct VertexDescriptionInputs
                                                                                                        {
                                                                                                             float3 ObjectSpaceNormal;
                                                                                                             float3 ObjectSpaceTangent;
                                                                                                             float3 ObjectSpacePosition;
                                                                                                        };
                                                                                                        struct PackedVaryings
                                                                                                        {
                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                             float3 interp0 : INTERP0;
                                                                                                             float4 interp1 : INTERP1;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                            #endif
                                                                                                        };

                                                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                                                        {
                                                                                                            PackedVaryings output;
                                                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                            output.positionCS = input.positionCS;
                                                                                                            output.interp0.xyz = input.positionWS;
                                                                                                            output.interp1.xyzw = input.texCoord0;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                            output.instanceID = input.instanceID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                            output.cullFace = input.cullFace;
                                                                                                            #endif
                                                                                                            return output;
                                                                                                        }

                                                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                                                        {
                                                                                                            Varyings output;
                                                                                                            output.positionCS = input.positionCS;
                                                                                                            output.positionWS = input.interp0.xyz;
                                                                                                            output.texCoord0 = input.interp1.xyzw;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                            output.instanceID = input.instanceID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                            output.cullFace = input.cullFace;
                                                                                                            #endif
                                                                                                            return output;
                                                                                                        }


                                                                                                        // --------------------------------------------------
                                                                                                        // Graph

                                                                                                        // Graph Properties
                                                                                                        CBUFFER_START(UnityPerMaterial)
                                                                                                        float2 _PlayerPos;
                                                                                                        float _Size;
                                                                                                        float _Smoothness;
                                                                                                        float _Opacity;
                                                                                                        float4 _MainTex_TexelSize;
                                                                                                        float4 _Tint;
                                                                                                        CBUFFER_END

                                                                                                            // Object and Global properties
                                                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                                                            TEXTURE2D(_MainTex);
                                                                                                            SAMPLER(sampler_MainTex);

                                                                                                            // Graph Includes
                                                                                                            // GraphIncludes: <None>

                                                                                                            // -- Property used by ScenePickingPass
                                                                                                            #ifdef SCENEPICKINGPASS
                                                                                                            float4 _SelectionID;
                                                                                                            #endif

                                                                                                            // -- Properties used by SceneSelectionPass
                                                                                                            #ifdef SCENESELECTIONPASS
                                                                                                            int _ObjectId;
                                                                                                            int _PassValue;
                                                                                                            #endif

                                                                                                            // Graph Functions

                                                                                                            void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                                                                                            {
                                                                                                                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                                                                            }

                                                                                                            void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                                                                                            {
                                                                                                                Out = A + B;
                                                                                                            }

                                                                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                                            {
                                                                                                                Out = UV * Tiling + Offset;
                                                                                                            }

                                                                                                            void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                                                                            {
                                                                                                                Out = A * B;
                                                                                                            }

                                                                                                            void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                                                                            {
                                                                                                                Out = A - B;
                                                                                                            }

                                                                                                            void Unity_Divide_float(float A, float B, out float Out)
                                                                                                            {
                                                                                                                Out = A / B;
                                                                                                            }

                                                                                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                                                            {
                                                                                                                Out = A * B;
                                                                                                            }

                                                                                                            void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                                                                            {
                                                                                                                Out = A / B;
                                                                                                            }

                                                                                                            void Unity_Length_float2(float2 In, out float Out)
                                                                                                            {
                                                                                                                Out = length(In);
                                                                                                            }

                                                                                                            void Unity_OneMinus_float(float In, out float Out)
                                                                                                            {
                                                                                                                Out = 1 - In;
                                                                                                            }

                                                                                                            void Unity_Saturate_float(float In, out float Out)
                                                                                                            {
                                                                                                                Out = saturate(In);
                                                                                                            }

                                                                                                            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                                                                            {
                                                                                                                Out = smoothstep(Edge1, Edge2, In);
                                                                                                            }


                                                                                                            float2 Unity_GradientNoise_Dir_float(float2 p)
                                                                                                            {
                                                                                                                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                                                                                p = p % 289;
                                                                                                                // need full precision, otherwise half overflows when p > 1
                                                                                                                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                                                                                x = (34 * x + 1) * x % 289;
                                                                                                                x = frac(x / 41) * 2 - 1;
                                                                                                                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                                                                            }

                                                                                                            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                                                                            {
                                                                                                                float2 p = UV * Scale;
                                                                                                                float2 ip = floor(p);
                                                                                                                float2 fp = frac(p);
                                                                                                                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                                                                                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                                                                                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                                                                                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                                                                                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                                                                                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                                                                            }

                                                                                                            void Unity_Add_float(float A, float B, out float Out)
                                                                                                            {
                                                                                                                Out = A + B;
                                                                                                            }

                                                                                                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                                                            {
                                                                                                                Out = clamp(In, Min, Max);
                                                                                                            }

                                                                                                            // Custom interpolators pre vertex
                                                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                            // Graph Vertex
                                                                                                            struct VertexDescription
                                                                                                            {
                                                                                                                float3 Position;
                                                                                                                float3 Normal;
                                                                                                                float3 Tangent;
                                                                                                            };

                                                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                            {
                                                                                                                VertexDescription description = (VertexDescription)0;
                                                                                                                description.Position = IN.ObjectSpacePosition;
                                                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                                                return description;
                                                                                                            }

                                                                                                            // Custom interpolators, pre surface
                                                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                            {
                                                                                                            return output;
                                                                                                            }
                                                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                            #endif

                                                                                                            // Graph Pixel
                                                                                                            struct SurfaceDescription
                                                                                                            {
                                                                                                                float Alpha;
                                                                                                            };

                                                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                            {
                                                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                                float _Property_3da0c57fa07440e889d95435bcf4a0aa_Out_0 = _Smoothness;
                                                                                                                float4 _ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                                                                                float2 _Property_eb4fae0eaa8e4fe3ac5491ba9981452e_Out_0 = _PlayerPos;
                                                                                                                float2 _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3;
                                                                                                                Unity_Remap_float2(_Property_eb4fae0eaa8e4fe3ac5491ba9981452e_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3);
                                                                                                                float2 _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2;
                                                                                                                Unity_Add_float2((_ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0.xy), _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3, _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2);
                                                                                                                float2 _TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3;
                                                                                                                Unity_TilingAndOffset_float((_ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0.xy), float2 (1, 1), _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2, _TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3);
                                                                                                                float2 _Multiply_3c357794168141569d428cf555d98c3b_Out_2;
                                                                                                                Unity_Multiply_float2_float2(_TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3, float2(2, 2), _Multiply_3c357794168141569d428cf555d98c3b_Out_2);
                                                                                                                float2 _Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2;
                                                                                                                Unity_Subtract_float2(_Multiply_3c357794168141569d428cf555d98c3b_Out_2, float2(1, 1), _Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2);
                                                                                                                float _Divide_460be555daed4e16b511e7a1a2600d99_Out_2;
                                                                                                                Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_460be555daed4e16b511e7a1a2600d99_Out_2);
                                                                                                                float _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0 = _Size;
                                                                                                                float _Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2;
                                                                                                                Unity_Multiply_float_float(_Divide_460be555daed4e16b511e7a1a2600d99_Out_2, _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0, _Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2);
                                                                                                                float2 _Vector2_80510f86d5564e69a6a87561f22e4e37_Out_0 = float2(_Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2, _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0);
                                                                                                                float2 _Divide_ef5d4c7889484ffb9129e280560351a9_Out_2;
                                                                                                                Unity_Divide_float2(_Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2, _Vector2_80510f86d5564e69a6a87561f22e4e37_Out_0, _Divide_ef5d4c7889484ffb9129e280560351a9_Out_2);
                                                                                                                float _Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1;
                                                                                                                Unity_Length_float2(_Divide_ef5d4c7889484ffb9129e280560351a9_Out_2, _Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1);
                                                                                                                float _OneMinus_7f29374d2cde401bb19dcde091630251_Out_1;
                                                                                                                Unity_OneMinus_float(_Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1, _OneMinus_7f29374d2cde401bb19dcde091630251_Out_1);
                                                                                                                float _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1;
                                                                                                                Unity_Saturate_float(_OneMinus_7f29374d2cde401bb19dcde091630251_Out_1, _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1);
                                                                                                                float _Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3;
                                                                                                                Unity_Smoothstep_float(0, _Property_3da0c57fa07440e889d95435bcf4a0aa_Out_0, _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1, _Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3);
                                                                                                                float _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2;
                                                                                                                Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2);
                                                                                                                float _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2;
                                                                                                                Unity_Multiply_float_float(_Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3, _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2, _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2);
                                                                                                                float _Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2;
                                                                                                                Unity_Add_float(_Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3, _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2, _Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2);
                                                                                                                float _Property_aa04ea6e4cde4cf283c8da199d728c36_Out_0 = _Opacity;
                                                                                                                float _Multiply_3b690d7382254556a19014f1915567e9_Out_2;
                                                                                                                Unity_Multiply_float_float(_Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2, _Property_aa04ea6e4cde4cf283c8da199d728c36_Out_0, _Multiply_3b690d7382254556a19014f1915567e9_Out_2);
                                                                                                                float _Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3;
                                                                                                                Unity_Clamp_float(_Multiply_3b690d7382254556a19014f1915567e9_Out_2, 0, 1, _Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3);
                                                                                                                float _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1;
                                                                                                                Unity_OneMinus_float(_Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3, _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1);
                                                                                                                surface.Alpha = _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1;
                                                                                                                return surface;
                                                                                                            }

                                                                                                            // --------------------------------------------------
                                                                                                            // Build Graph Inputs
                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                            #endif
                                                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                            {
                                                                                                                VertexDescriptionInputs output;
                                                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                                output.ObjectSpacePosition = input.positionOS;

                                                                                                                return output;
                                                                                                            }
                                                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                            {
                                                                                                                SurfaceDescriptionInputs output;
                                                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                            #endif







                                                                                                                output.WorldSpacePosition = input.positionWS;
                                                                                                                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                                                                output.uv0 = input.texCoord0;
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                            #else
                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                            #endif
                                                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                                    return output;
                                                                                                            }

                                                                                                            // --------------------------------------------------
                                                                                                            // Main

                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                                                                            // --------------------------------------------------
                                                                                                            // Visual Effect Vertex Invocations
                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                            #endif

                                                                                                            ENDHLSL
                                                                                                            }
                                                                                                            Pass
                                                                                                            {
                                                                                                                Name "ScenePickingPass"
                                                                                                                Tags
                                                                                                                {
                                                                                                                    "LightMode" = "Picking"
                                                                                                                }

                                                                                                                // Render State
                                                                                                                Cull Back

                                                                                                                // Debug
                                                                                                                // <None>

                                                                                                                // --------------------------------------------------
                                                                                                                // Pass

                                                                                                                HLSLPROGRAM

                                                                                                                // Pragmas
                                                                                                                #pragma target 2.0
                                                                                                                #pragma only_renderers gles gles3 glcore d3d11
                                                                                                                #pragma multi_compile_instancing
                                                                                                                #pragma vertex vert
                                                                                                                #pragma fragment frag

                                                                                                                // DotsInstancingOptions: <None>
                                                                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                                                                // Keywords
                                                                                                                // PassKeywords: <None>
                                                                                                                // GraphKeywords: <None>

                                                                                                                // Defines

                                                                                                                #define _NORMALMAP 1
                                                                                                                #define _NORMAL_DROPOFF_TS 1
                                                                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                                                #define VARYINGS_NEED_POSITION_WS
                                                                                                                #define VARYINGS_NEED_TEXCOORD0
                                                                                                                #define FEATURES_GRAPH_VERTEX
                                                                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                                #define SHADERPASS SHADERPASS_DEPTHONLY
                                                                                                                #define SCENEPICKINGPASS 1
                                                                                                                #define ALPHA_CLIP_THRESHOLD 1
                                                                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                                // custom interpolator pre-include
                                                                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                                // Includes
                                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                                // --------------------------------------------------
                                                                                                                // Structs and Packing

                                                                                                                // custom interpolators pre packing
                                                                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                                struct Attributes
                                                                                                                {
                                                                                                                     float3 positionOS : POSITION;
                                                                                                                     float3 normalOS : NORMAL;
                                                                                                                     float4 tangentOS : TANGENT;
                                                                                                                     float4 uv0 : TEXCOORD0;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                                    #endif
                                                                                                                };
                                                                                                                struct Varyings
                                                                                                                {
                                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                                     float3 positionWS;
                                                                                                                     float4 texCoord0;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                    #endif
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                    #endif
                                                                                                                };
                                                                                                                struct SurfaceDescriptionInputs
                                                                                                                {
                                                                                                                     float3 WorldSpacePosition;
                                                                                                                     float4 ScreenPosition;
                                                                                                                     float4 uv0;
                                                                                                                };
                                                                                                                struct VertexDescriptionInputs
                                                                                                                {
                                                                                                                     float3 ObjectSpaceNormal;
                                                                                                                     float3 ObjectSpaceTangent;
                                                                                                                     float3 ObjectSpacePosition;
                                                                                                                };
                                                                                                                struct PackedVaryings
                                                                                                                {
                                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                                     float3 interp0 : INTERP0;
                                                                                                                     float4 interp1 : INTERP1;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                    #endif
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                    #endif
                                                                                                                };

                                                                                                                PackedVaryings PackVaryings(Varyings input)
                                                                                                                {
                                                                                                                    PackedVaryings output;
                                                                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                                    output.positionCS = input.positionCS;
                                                                                                                    output.interp0.xyz = input.positionWS;
                                                                                                                    output.interp1.xyzw = input.texCoord0;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                    output.instanceID = input.instanceID;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                    #endif
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                    output.cullFace = input.cullFace;
                                                                                                                    #endif
                                                                                                                    return output;
                                                                                                                }

                                                                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                                                                {
                                                                                                                    Varyings output;
                                                                                                                    output.positionCS = input.positionCS;
                                                                                                                    output.positionWS = input.interp0.xyz;
                                                                                                                    output.texCoord0 = input.interp1.xyzw;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                    output.instanceID = input.instanceID;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                    #endif
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                    output.cullFace = input.cullFace;
                                                                                                                    #endif
                                                                                                                    return output;
                                                                                                                }


                                                                                                                // --------------------------------------------------
                                                                                                                // Graph

                                                                                                                // Graph Properties
                                                                                                                CBUFFER_START(UnityPerMaterial)
                                                                                                                float2 _PlayerPos;
                                                                                                                float _Size;
                                                                                                                float _Smoothness;
                                                                                                                float _Opacity;
                                                                                                                float4 _MainTex_TexelSize;
                                                                                                                float4 _Tint;
                                                                                                                CBUFFER_END

                                                                                                                    // Object and Global properties
                                                                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                                                                    TEXTURE2D(_MainTex);
                                                                                                                    SAMPLER(sampler_MainTex);

                                                                                                                    // Graph Includes
                                                                                                                    // GraphIncludes: <None>

                                                                                                                    // -- Property used by ScenePickingPass
                                                                                                                    #ifdef SCENEPICKINGPASS
                                                                                                                    float4 _SelectionID;
                                                                                                                    #endif

                                                                                                                    // -- Properties used by SceneSelectionPass
                                                                                                                    #ifdef SCENESELECTIONPASS
                                                                                                                    int _ObjectId;
                                                                                                                    int _PassValue;
                                                                                                                    #endif

                                                                                                                    // Graph Functions

                                                                                                                    void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                                                                                                    {
                                                                                                                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                                                                                    }

                                                                                                                    void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                                                                                                    {
                                                                                                                        Out = A + B;
                                                                                                                    }

                                                                                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                                                    {
                                                                                                                        Out = UV * Tiling + Offset;
                                                                                                                    }

                                                                                                                    void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                                                                                    {
                                                                                                                        Out = A * B;
                                                                                                                    }

                                                                                                                    void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                                                                                    {
                                                                                                                        Out = A - B;
                                                                                                                    }

                                                                                                                    void Unity_Divide_float(float A, float B, out float Out)
                                                                                                                    {
                                                                                                                        Out = A / B;
                                                                                                                    }

                                                                                                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                                                                    {
                                                                                                                        Out = A * B;
                                                                                                                    }

                                                                                                                    void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                                                                                    {
                                                                                                                        Out = A / B;
                                                                                                                    }

                                                                                                                    void Unity_Length_float2(float2 In, out float Out)
                                                                                                                    {
                                                                                                                        Out = length(In);
                                                                                                                    }

                                                                                                                    void Unity_OneMinus_float(float In, out float Out)
                                                                                                                    {
                                                                                                                        Out = 1 - In;
                                                                                                                    }

                                                                                                                    void Unity_Saturate_float(float In, out float Out)
                                                                                                                    {
                                                                                                                        Out = saturate(In);
                                                                                                                    }

                                                                                                                    void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                                                                                    {
                                                                                                                        Out = smoothstep(Edge1, Edge2, In);
                                                                                                                    }


                                                                                                                    float2 Unity_GradientNoise_Dir_float(float2 p)
                                                                                                                    {
                                                                                                                        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                                                                                        p = p % 289;
                                                                                                                        // need full precision, otherwise half overflows when p > 1
                                                                                                                        float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                                                                                        x = (34 * x + 1) * x % 289;
                                                                                                                        x = frac(x / 41) * 2 - 1;
                                                                                                                        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                                                                                    }

                                                                                                                    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                                                                                    {
                                                                                                                        float2 p = UV * Scale;
                                                                                                                        float2 ip = floor(p);
                                                                                                                        float2 fp = frac(p);
                                                                                                                        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                                                                                        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                                                                                        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                                                                                        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                                                                                        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                                                                                        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                                                                                    }

                                                                                                                    void Unity_Add_float(float A, float B, out float Out)
                                                                                                                    {
                                                                                                                        Out = A + B;
                                                                                                                    }

                                                                                                                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                                                                    {
                                                                                                                        Out = clamp(In, Min, Max);
                                                                                                                    }

                                                                                                                    // Custom interpolators pre vertex
                                                                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                                    // Graph Vertex
                                                                                                                    struct VertexDescription
                                                                                                                    {
                                                                                                                        float3 Position;
                                                                                                                        float3 Normal;
                                                                                                                        float3 Tangent;
                                                                                                                    };

                                                                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                                    {
                                                                                                                        VertexDescription description = (VertexDescription)0;
                                                                                                                        description.Position = IN.ObjectSpacePosition;
                                                                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                                                                        return description;
                                                                                                                    }

                                                                                                                    // Custom interpolators, pre surface
                                                                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                                    {
                                                                                                                    return output;
                                                                                                                    }
                                                                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                                    #endif

                                                                                                                    // Graph Pixel
                                                                                                                    struct SurfaceDescription
                                                                                                                    {
                                                                                                                        float Alpha;
                                                                                                                    };

                                                                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                                    {
                                                                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                                        float _Property_3da0c57fa07440e889d95435bcf4a0aa_Out_0 = _Smoothness;
                                                                                                                        float4 _ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                                                                                        float2 _Property_eb4fae0eaa8e4fe3ac5491ba9981452e_Out_0 = _PlayerPos;
                                                                                                                        float2 _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3;
                                                                                                                        Unity_Remap_float2(_Property_eb4fae0eaa8e4fe3ac5491ba9981452e_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3);
                                                                                                                        float2 _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2;
                                                                                                                        Unity_Add_float2((_ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0.xy), _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3, _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2);
                                                                                                                        float2 _TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3;
                                                                                                                        Unity_TilingAndOffset_float((_ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0.xy), float2 (1, 1), _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2, _TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3);
                                                                                                                        float2 _Multiply_3c357794168141569d428cf555d98c3b_Out_2;
                                                                                                                        Unity_Multiply_float2_float2(_TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3, float2(2, 2), _Multiply_3c357794168141569d428cf555d98c3b_Out_2);
                                                                                                                        float2 _Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2;
                                                                                                                        Unity_Subtract_float2(_Multiply_3c357794168141569d428cf555d98c3b_Out_2, float2(1, 1), _Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2);
                                                                                                                        float _Divide_460be555daed4e16b511e7a1a2600d99_Out_2;
                                                                                                                        Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_460be555daed4e16b511e7a1a2600d99_Out_2);
                                                                                                                        float _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0 = _Size;
                                                                                                                        float _Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2;
                                                                                                                        Unity_Multiply_float_float(_Divide_460be555daed4e16b511e7a1a2600d99_Out_2, _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0, _Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2);
                                                                                                                        float2 _Vector2_80510f86d5564e69a6a87561f22e4e37_Out_0 = float2(_Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2, _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0);
                                                                                                                        float2 _Divide_ef5d4c7889484ffb9129e280560351a9_Out_2;
                                                                                                                        Unity_Divide_float2(_Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2, _Vector2_80510f86d5564e69a6a87561f22e4e37_Out_0, _Divide_ef5d4c7889484ffb9129e280560351a9_Out_2);
                                                                                                                        float _Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1;
                                                                                                                        Unity_Length_float2(_Divide_ef5d4c7889484ffb9129e280560351a9_Out_2, _Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1);
                                                                                                                        float _OneMinus_7f29374d2cde401bb19dcde091630251_Out_1;
                                                                                                                        Unity_OneMinus_float(_Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1, _OneMinus_7f29374d2cde401bb19dcde091630251_Out_1);
                                                                                                                        float _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1;
                                                                                                                        Unity_Saturate_float(_OneMinus_7f29374d2cde401bb19dcde091630251_Out_1, _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1);
                                                                                                                        float _Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3;
                                                                                                                        Unity_Smoothstep_float(0, _Property_3da0c57fa07440e889d95435bcf4a0aa_Out_0, _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1, _Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3);
                                                                                                                        float _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2;
                                                                                                                        Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2);
                                                                                                                        float _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2;
                                                                                                                        Unity_Multiply_float_float(_Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3, _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2, _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2);
                                                                                                                        float _Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2;
                                                                                                                        Unity_Add_float(_Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3, _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2, _Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2);
                                                                                                                        float _Property_aa04ea6e4cde4cf283c8da199d728c36_Out_0 = _Opacity;
                                                                                                                        float _Multiply_3b690d7382254556a19014f1915567e9_Out_2;
                                                                                                                        Unity_Multiply_float_float(_Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2, _Property_aa04ea6e4cde4cf283c8da199d728c36_Out_0, _Multiply_3b690d7382254556a19014f1915567e9_Out_2);
                                                                                                                        float _Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3;
                                                                                                                        Unity_Clamp_float(_Multiply_3b690d7382254556a19014f1915567e9_Out_2, 0, 1, _Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3);
                                                                                                                        float _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1;
                                                                                                                        Unity_OneMinus_float(_Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3, _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1);
                                                                                                                        surface.Alpha = _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1;
                                                                                                                        return surface;
                                                                                                                    }

                                                                                                                    // --------------------------------------------------
                                                                                                                    // Build Graph Inputs
                                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                                    #endif
                                                                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                                    {
                                                                                                                        VertexDescriptionInputs output;
                                                                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                                        output.ObjectSpacePosition = input.positionOS;

                                                                                                                        return output;
                                                                                                                    }
                                                                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                                    {
                                                                                                                        SurfaceDescriptionInputs output;
                                                                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                                    #endif







                                                                                                                        output.WorldSpacePosition = input.positionWS;
                                                                                                                        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                                                                        output.uv0 = input.texCoord0;
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                                    #else
                                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                                    #endif
                                                                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                                            return output;
                                                                                                                    }

                                                                                                                    // --------------------------------------------------
                                                                                                                    // Main

                                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                                                                                    // --------------------------------------------------
                                                                                                                    // Visual Effect Vertex Invocations
                                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                                    #endif

                                                                                                                    ENDHLSL
                                                                                                                    }
                                                                                                                    Pass
                                                                                                                    {
                                                                                                                        // Name: <None>
                                                                                                                        Tags
                                                                                                                        {
                                                                                                                            "LightMode" = "Universal2D"
                                                                                                                        }

                                                                                                                        // Render State
                                                                                                                        Cull Back
                                                                                                                        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                                                                                                                        ZTest LEqual
                                                                                                                        ZWrite Off

                                                                                                                        // Debug
                                                                                                                        // <None>

                                                                                                                        // --------------------------------------------------
                                                                                                                        // Pass

                                                                                                                        HLSLPROGRAM

                                                                                                                        // Pragmas
                                                                                                                        #pragma target 2.0
                                                                                                                        #pragma only_renderers gles gles3 glcore d3d11
                                                                                                                        #pragma multi_compile_instancing
                                                                                                                        #pragma vertex vert
                                                                                                                        #pragma fragment frag

                                                                                                                        // DotsInstancingOptions: <None>
                                                                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                                                                        // Keywords
                                                                                                                        // PassKeywords: <None>
                                                                                                                        // GraphKeywords: <None>

                                                                                                                        // Defines

                                                                                                                        #define _NORMALMAP 1
                                                                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                                                        #define VARYINGS_NEED_POSITION_WS
                                                                                                                        #define VARYINGS_NEED_TEXCOORD0
                                                                                                                        #define FEATURES_GRAPH_VERTEX
                                                                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                                        #define SHADERPASS SHADERPASS_2D
                                                                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                                        // custom interpolator pre-include
                                                                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                                        // Includes
                                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                                        // --------------------------------------------------
                                                                                                                        // Structs and Packing

                                                                                                                        // custom interpolators pre packing
                                                                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                                        struct Attributes
                                                                                                                        {
                                                                                                                             float3 positionOS : POSITION;
                                                                                                                             float3 normalOS : NORMAL;
                                                                                                                             float4 tangentOS : TANGENT;
                                                                                                                             float4 uv0 : TEXCOORD0;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                                            #endif
                                                                                                                        };
                                                                                                                        struct Varyings
                                                                                                                        {
                                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                                             float3 positionWS;
                                                                                                                             float4 texCoord0;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                            #endif
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                            #endif
                                                                                                                        };
                                                                                                                        struct SurfaceDescriptionInputs
                                                                                                                        {
                                                                                                                             float3 WorldSpacePosition;
                                                                                                                             float4 ScreenPosition;
                                                                                                                             float4 uv0;
                                                                                                                        };
                                                                                                                        struct VertexDescriptionInputs
                                                                                                                        {
                                                                                                                             float3 ObjectSpaceNormal;
                                                                                                                             float3 ObjectSpaceTangent;
                                                                                                                             float3 ObjectSpacePosition;
                                                                                                                        };
                                                                                                                        struct PackedVaryings
                                                                                                                        {
                                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                                             float3 interp0 : INTERP0;
                                                                                                                             float4 interp1 : INTERP1;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                            #endif
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                            #endif
                                                                                                                        };

                                                                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                                                                        {
                                                                                                                            PackedVaryings output;
                                                                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                                            output.positionCS = input.positionCS;
                                                                                                                            output.interp0.xyz = input.positionWS;
                                                                                                                            output.interp1.xyzw = input.texCoord0;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                            output.instanceID = input.instanceID;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                            #endif
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                            output.cullFace = input.cullFace;
                                                                                                                            #endif
                                                                                                                            return output;
                                                                                                                        }

                                                                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                                                                        {
                                                                                                                            Varyings output;
                                                                                                                            output.positionCS = input.positionCS;
                                                                                                                            output.positionWS = input.interp0.xyz;
                                                                                                                            output.texCoord0 = input.interp1.xyzw;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                            output.instanceID = input.instanceID;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                            #endif
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                            output.cullFace = input.cullFace;
                                                                                                                            #endif
                                                                                                                            return output;
                                                                                                                        }


                                                                                                                        // --------------------------------------------------
                                                                                                                        // Graph

                                                                                                                        // Graph Properties
                                                                                                                        CBUFFER_START(UnityPerMaterial)
                                                                                                                        float2 _PlayerPos;
                                                                                                                        float _Size;
                                                                                                                        float _Smoothness;
                                                                                                                        float _Opacity;
                                                                                                                        float4 _MainTex_TexelSize;
                                                                                                                        float4 _Tint;
                                                                                                                        CBUFFER_END

                                                                                                                            // Object and Global properties
                                                                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                                                                            TEXTURE2D(_MainTex);
                                                                                                                            SAMPLER(sampler_MainTex);

                                                                                                                            // Graph Includes
                                                                                                                            // GraphIncludes: <None>

                                                                                                                            // -- Property used by ScenePickingPass
                                                                                                                            #ifdef SCENEPICKINGPASS
                                                                                                                            float4 _SelectionID;
                                                                                                                            #endif

                                                                                                                            // -- Properties used by SceneSelectionPass
                                                                                                                            #ifdef SCENESELECTIONPASS
                                                                                                                            int _ObjectId;
                                                                                                                            int _PassValue;
                                                                                                                            #endif

                                                                                                                            // Graph Functions

                                                                                                                            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                                                                                            {
                                                                                                                                Out = A * B;
                                                                                                                            }

                                                                                                                            void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                                                                                                            {
                                                                                                                                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                                                                                            }

                                                                                                                            void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                                                                                                            {
                                                                                                                                Out = A + B;
                                                                                                                            }

                                                                                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                                                            {
                                                                                                                                Out = UV * Tiling + Offset;
                                                                                                                            }

                                                                                                                            void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                                                                                            {
                                                                                                                                Out = A * B;
                                                                                                                            }

                                                                                                                            void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                                                                                            {
                                                                                                                                Out = A - B;
                                                                                                                            }

                                                                                                                            void Unity_Divide_float(float A, float B, out float Out)
                                                                                                                            {
                                                                                                                                Out = A / B;
                                                                                                                            }

                                                                                                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                                                                            {
                                                                                                                                Out = A * B;
                                                                                                                            }

                                                                                                                            void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                                                                                            {
                                                                                                                                Out = A / B;
                                                                                                                            }

                                                                                                                            void Unity_Length_float2(float2 In, out float Out)
                                                                                                                            {
                                                                                                                                Out = length(In);
                                                                                                                            }

                                                                                                                            void Unity_OneMinus_float(float In, out float Out)
                                                                                                                            {
                                                                                                                                Out = 1 - In;
                                                                                                                            }

                                                                                                                            void Unity_Saturate_float(float In, out float Out)
                                                                                                                            {
                                                                                                                                Out = saturate(In);
                                                                                                                            }

                                                                                                                            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                                                                                            {
                                                                                                                                Out = smoothstep(Edge1, Edge2, In);
                                                                                                                            }


                                                                                                                            float2 Unity_GradientNoise_Dir_float(float2 p)
                                                                                                                            {
                                                                                                                                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                                                                                                p = p % 289;
                                                                                                                                // need full precision, otherwise half overflows when p > 1
                                                                                                                                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                                                                                                x = (34 * x + 1) * x % 289;
                                                                                                                                x = frac(x / 41) * 2 - 1;
                                                                                                                                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                                                                                            }

                                                                                                                            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                                                                                            {
                                                                                                                                float2 p = UV * Scale;
                                                                                                                                float2 ip = floor(p);
                                                                                                                                float2 fp = frac(p);
                                                                                                                                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                                                                                                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                                                                                                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                                                                                                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                                                                                                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                                                                                                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                                                                                            }

                                                                                                                            void Unity_Add_float(float A, float B, out float Out)
                                                                                                                            {
                                                                                                                                Out = A + B;
                                                                                                                            }

                                                                                                                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                                                                            {
                                                                                                                                Out = clamp(In, Min, Max);
                                                                                                                            }

                                                                                                                            // Custom interpolators pre vertex
                                                                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                                            // Graph Vertex
                                                                                                                            struct VertexDescription
                                                                                                                            {
                                                                                                                                float3 Position;
                                                                                                                                float3 Normal;
                                                                                                                                float3 Tangent;
                                                                                                                            };

                                                                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                                            {
                                                                                                                                VertexDescription description = (VertexDescription)0;
                                                                                                                                description.Position = IN.ObjectSpacePosition;
                                                                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                                                                return description;
                                                                                                                            }

                                                                                                                            // Custom interpolators, pre surface
                                                                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                                            {
                                                                                                                            return output;
                                                                                                                            }
                                                                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                                            #endif

                                                                                                                            // Graph Pixel
                                                                                                                            struct SurfaceDescription
                                                                                                                            {
                                                                                                                                float3 BaseColor;
                                                                                                                                float Alpha;
                                                                                                                            };

                                                                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                                            {
                                                                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                                                UnityTexture2D _Property_9e5787ff777c43db8b9ea801e309fc9b_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                                                                                                                                float4 _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_9e5787ff777c43db8b9ea801e309fc9b_Out_0.tex, _Property_9e5787ff777c43db8b9ea801e309fc9b_Out_0.samplerstate, _Property_9e5787ff777c43db8b9ea801e309fc9b_Out_0.GetTransformedUV(IN.uv0.xy));
                                                                                                                                float _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_R_4 = _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0.r;
                                                                                                                                float _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_G_5 = _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0.g;
                                                                                                                                float _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_B_6 = _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0.b;
                                                                                                                                float _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_A_7 = _SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0.a;
                                                                                                                                float4 _Property_b37916350fdd4197bd2377cc4806d65b_Out_0 = _Tint;
                                                                                                                                float4 _Multiply_3a41105f027849dd80cc07ab836b38e9_Out_2;
                                                                                                                                Unity_Multiply_float4_float4(_SampleTexture2D_f111ae9a9c114bb4ba0069abc4e1aac8_RGBA_0, _Property_b37916350fdd4197bd2377cc4806d65b_Out_0, _Multiply_3a41105f027849dd80cc07ab836b38e9_Out_2);
                                                                                                                                float _Property_3da0c57fa07440e889d95435bcf4a0aa_Out_0 = _Smoothness;
                                                                                                                                float4 _ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                                                                                                float2 _Property_eb4fae0eaa8e4fe3ac5491ba9981452e_Out_0 = _PlayerPos;
                                                                                                                                float2 _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3;
                                                                                                                                Unity_Remap_float2(_Property_eb4fae0eaa8e4fe3ac5491ba9981452e_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3);
                                                                                                                                float2 _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2;
                                                                                                                                Unity_Add_float2((_ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0.xy), _Remap_d404dcd4fc534fe58431fb20e6bb146a_Out_3, _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2);
                                                                                                                                float2 _TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3;
                                                                                                                                Unity_TilingAndOffset_float((_ScreenPosition_66e1c589a5a94c90a54e67862b4f21cd_Out_0.xy), float2 (1, 1), _Add_021bb2d6fc874a159f47d889e4bb8711_Out_2, _TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3);
                                                                                                                                float2 _Multiply_3c357794168141569d428cf555d98c3b_Out_2;
                                                                                                                                Unity_Multiply_float2_float2(_TilingAndOffset_80a754c01e4d471f82d6e02660888f57_Out_3, float2(2, 2), _Multiply_3c357794168141569d428cf555d98c3b_Out_2);
                                                                                                                                float2 _Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2;
                                                                                                                                Unity_Subtract_float2(_Multiply_3c357794168141569d428cf555d98c3b_Out_2, float2(1, 1), _Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2);
                                                                                                                                float _Divide_460be555daed4e16b511e7a1a2600d99_Out_2;
                                                                                                                                Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_460be555daed4e16b511e7a1a2600d99_Out_2);
                                                                                                                                float _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0 = _Size;
                                                                                                                                float _Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2;
                                                                                                                                Unity_Multiply_float_float(_Divide_460be555daed4e16b511e7a1a2600d99_Out_2, _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0, _Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2);
                                                                                                                                float2 _Vector2_80510f86d5564e69a6a87561f22e4e37_Out_0 = float2(_Multiply_e916bff4d60440f3bcf2a47e7bfc750d_Out_2, _Property_a5f836c20ec84fc289bd5676f4b457e3_Out_0);
                                                                                                                                float2 _Divide_ef5d4c7889484ffb9129e280560351a9_Out_2;
                                                                                                                                Unity_Divide_float2(_Subtract_49859029b59d4a06a5da07e22eb4aba2_Out_2, _Vector2_80510f86d5564e69a6a87561f22e4e37_Out_0, _Divide_ef5d4c7889484ffb9129e280560351a9_Out_2);
                                                                                                                                float _Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1;
                                                                                                                                Unity_Length_float2(_Divide_ef5d4c7889484ffb9129e280560351a9_Out_2, _Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1);
                                                                                                                                float _OneMinus_7f29374d2cde401bb19dcde091630251_Out_1;
                                                                                                                                Unity_OneMinus_float(_Length_4f282897d42d4da3a041bd1c37ff4e3e_Out_1, _OneMinus_7f29374d2cde401bb19dcde091630251_Out_1);
                                                                                                                                float _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1;
                                                                                                                                Unity_Saturate_float(_OneMinus_7f29374d2cde401bb19dcde091630251_Out_1, _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1);
                                                                                                                                float _Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3;
                                                                                                                                Unity_Smoothstep_float(0, _Property_3da0c57fa07440e889d95435bcf4a0aa_Out_0, _Saturate_5a5ee705fbb240c2b98035579729ac56_Out_1, _Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3);
                                                                                                                                float _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2;
                                                                                                                                Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2);
                                                                                                                                float _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2;
                                                                                                                                Unity_Multiply_float_float(_Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3, _GradientNoise_f475af4e9e064d52aefcb0995b0b8496_Out_2, _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2);
                                                                                                                                float _Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2;
                                                                                                                                Unity_Add_float(_Smoothstep_bf7f8264cadb4f1691dc667299324d63_Out_3, _Multiply_3ae653c32eda46138ad9c1b7ec3fba9e_Out_2, _Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2);
                                                                                                                                float _Property_aa04ea6e4cde4cf283c8da199d728c36_Out_0 = _Opacity;
                                                                                                                                float _Multiply_3b690d7382254556a19014f1915567e9_Out_2;
                                                                                                                                Unity_Multiply_float_float(_Add_4b10c18b446447a3aa4c8184f4941f6f_Out_2, _Property_aa04ea6e4cde4cf283c8da199d728c36_Out_0, _Multiply_3b690d7382254556a19014f1915567e9_Out_2);
                                                                                                                                float _Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3;
                                                                                                                                Unity_Clamp_float(_Multiply_3b690d7382254556a19014f1915567e9_Out_2, 0, 1, _Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3);
                                                                                                                                float _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1;
                                                                                                                                Unity_OneMinus_float(_Clamp_57bb5a506b3e4b5095d3a2e1afc3cf7a_Out_3, _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1);
                                                                                                                                surface.BaseColor = (_Multiply_3a41105f027849dd80cc07ab836b38e9_Out_2.xyz);
                                                                                                                                surface.Alpha = _OneMinus_ffe73b6eeefe461bb0454665720d4a45_Out_1;
                                                                                                                                return surface;
                                                                                                                            }

                                                                                                                            // --------------------------------------------------
                                                                                                                            // Build Graph Inputs
                                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                                            #endif
                                                                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                                            {
                                                                                                                                VertexDescriptionInputs output;
                                                                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                                                output.ObjectSpacePosition = input.positionOS;

                                                                                                                                return output;
                                                                                                                            }
                                                                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                                            {
                                                                                                                                SurfaceDescriptionInputs output;
                                                                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                                            #endif







                                                                                                                                output.WorldSpacePosition = input.positionWS;
                                                                                                                                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                                                                                output.uv0 = input.texCoord0;
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                                            #else
                                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                                            #endif
                                                                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                                                    return output;
                                                                                                                            }

                                                                                                                            // --------------------------------------------------
                                                                                                                            // Main

                                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

                                                                                                                            // --------------------------------------------------
                                                                                                                            // Visual Effect Vertex Invocations
                                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                                            #endif

                                                                                                                            ENDHLSL
                                                                                                                            }
                                                                    }
                                                                        CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
                                                                                                                                CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
                                                                                                                                FallBack "Hidden/Shader Graph/FallbackError"
}
