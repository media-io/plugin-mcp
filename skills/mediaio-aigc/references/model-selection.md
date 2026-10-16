# Model selection

Release 2026-10-16-parameter-guidance; environment prod; contract_digest `5f113f916338f43286fbd74ef93c7c1a74a0ae6e3aab4a30bd2a716e7475ab90`; selection_digest `8f8cae7474b4ab11c38258d43a547e8cf63bd424b23619c952c7d89c4c06d0a5`.

Use these defaults only when the user has not selected a model. An explicit selection never authorizes automatic substitution. Read the connected tool schema for all settings.

| Tool | Default request.model |
| --- | --- |
| `text_to_image` | `text2image_gpt_image_2` |
| `image_to_image` | `image2image_gpt_image_2` |
| `text_to_video` | `text2video_tomoviee_2.0` |
| `image_to_video` | `image2video_kling_3.0` |
| `reference_to_video` | `image2video_wan_3.0_reference_image` |
| `motion_control` | `image2video_kling_motion_control_2.6` |
| `image_audio_to_video` | `image2video_tomusic_1_0` |

| Intent | Tool | Models in preference order |
| --- | --- | --- |
| Image from text | `text_to_image` | `text2image_gpt_image_2` |
| Edit or reinterpret images | `image_to_image` | `image2image_gpt_image_2` |
| Video from text | `text_to_video` | `text2video_tomoviee_2.0` |
| Animate an image | `image_to_video` | `image2video_kling_3.0` |
| Video guided by reference media | `reference_to_video` | `image2video_wan_3.0_reference_image` |
| Transfer motion from a video | `motion_control` | `image2video_kling_motion_control_2.6` |
| Music video from an image and audio | `image_audio_to_video` | `image2video_tomusic_1_0` |

| Alias | Tool | Exact model candidates |
| --- | --- | --- |
| Nano Banana | `image_to_image` | `image2image_banana` |
| Nano Banana Pro | `image_to_image` | `image2image_banana_2` |
| GPT Image 2 | `image_to_image` | `image2image_gpt_image_2` |
| GPT Image 2.5 Flare | `image_to_image` | `image2image_gpt_image_2.5` |
| GPT Image 2.5 Sunburst | `image_to_image` | `image2image_gpt_image_2.5_sunburst` |
| ToMoviee Lite | `image_to_image` | `image2image_media_1.0` |
| ToMoviee Pro (ex-Media 2.0) | `image_to_image` | `image2image_media_2.0` |
| ToMoviee 3.0 Pro | `image_to_image` | `image2image_media_3.0` |
| Nano Banana 2 | `image_to_image` | `image2image_nano_banana_2` |
| Nano Banana 2.1 | `image_to_image` | `image2image_nano_banana_2_1` |
| Nano Banana 2 Lite | `image_to_image` | `image2image_nano_banana_2_lite` |
| Seedream 4.0 | `image_to_image` | `image2image_seedream_4.0` |
| Seedream 5.0 Lite | `image_to_image` | `image2image_seedream_5.0_lite` |
| Seedream 5.0 Pro | `image_to_image` | `image2image_seedream_5.0_pro` |
| ToMoviee Image 4.0 | `image_to_image` | `image2image_tomoviee_4.0` |
| Wan 2.7 | `image_to_image` | `image2image_wan_2.7` |
| Wan 2.7 Pro | `image_to_image` | `image2image_wan_2.7_pro` |
| Nano Banana | `text_to_image` | `text2image_banana` |
| Nano Banana Pro | `text_to_image` | `text2image_banana_2` |
| GPT Image 2 | `text_to_image` | `text2image_gpt_image_2` |
| GPT Image 2.5 Flare | `text_to_image` | `text2image_gpt_image_2.5` |
| GPT Image 2.5 Sunburst | `text_to_image` | `text2image_gpt_image_2.5_sunburst` |
| Nano Banana 2 | `text_to_image` | `text2image_nano_banana_2` |
| Nano Banana 2.1 | `text_to_image` | `text2image_nano_banana_2_1` |
| Nano Banana 2 Lite | `text_to_image` | `text2image_nano_banana_2_lite` |
| Seedream 4.0 | `text_to_image` | `text2image_seedream_4.0` |
| Seedream 5.0 Lite | `text_to_image` | `text2image_seedream_5.0_lite` |
| Seedream 5.0 Pro | `text_to_image` | `text2image_seedream_5.0_pro` |
| ToMoviee Lite | `text_to_image` | `text2image_soul_character` |
| ToMoviee 2.0 | `text_to_image` | `text2image_tomoviee_2.0` |
| ToMoviee Image 4.0 | `text_to_image` | `text2image_tomoviee_4.0` |
| Wan 2.7 | `text_to_image` | `text2image_wan_2.7` |
| Wan 2.7 Pro | `text_to_image` | `text2image_wan_2.7_pro` |
| Gemini Omni Flash | `image_to_video` | `image2video_gemini_omni_flash` |
| Gemini Omni Flash | `reference_to_video` | `image2video_gemini_omni_flash_reference_image` |
| HappyHorse 1.0 | `image_to_video` | `image2video_happyhorse_1.0` |
| HappyHorse 1.0 | `reference_to_video` | `image2video_happyhorse_1.0_reference_image` |
| HappyHorse 1.1 | `image_to_video` | `image2video_happyhorse_1.5` |
| HappyHorse 1.1 | `reference_to_video` | `image2video_happyhorse_1.5_reference_image` |
| Kling 2.5 Turbo | `image_to_video` | `image2video_kling_2.5_turbo`, `image2video_kling_2.5_turbo_head_and_tail` |
| Kling 2.6 | `image_to_video` | `image2video_kling_2.6` |
| Kling 3.0 | `image_to_video` | `image2video_kling_3.0`, `image2video_kling_3.0_head_and_tail` |
| Kling 3.0 Turbo | `image_to_video` | `image2video_kling_3.0_fast` |
| Kling 3.0 Omni | `reference_to_video` | `image2video_kling_3.0_omni_reference_image` |
| Kling Motion Control | `motion_control` | `image2video_kling_motion_control_2.6` |
| Kling O1 | `image_to_video` | `image2video_kling_o1`, `image2video_kling_o1_head_and_tail` |
| Kling O1 | `reference_to_video` | `image2video_kling_o1_reference_image` |
| ToMoviee 2.0 Pro (ex-Media 1.0) | `image_to_video` | `image2video_media_1.0` |
| Hailuo 02 | `image_to_video` | `image2video_minimax_02` |
| Hailuo 2.3 | `image_to_video` | `image2video_minimax_2.3` |
| MiniMax H3 | `image_to_video` | `image2video_minimax_h3_head_and_tail_switch`, `image2video_minimax_h3_switch` |
| MiniMax H3 Max | `image_to_video` | `image2video_minimax_h3_max` |
| MiniMax H3 | `reference_to_video` | `image2video_minimax_h3_reference_image_switch` |
| Seedance 2.0 Mini | `image_to_video` | `image2video_seedance_2.0_mini`, `image2video_seedance_2.0_mini_head_and_tail` |
| Seedance 2.5 | `image_to_video` | `image2video_seedance_2.5`, `image2video_seedance_2.5_head_and_tail` |
| Seedance 2.0 Fast | `image_to_video` | `image2video_seedance2.0_fast`, `image2video_seedance2.0_fast_head_and_tail` |
| Seedance 2.0 Fast | `reference_to_video` | `image2video_seedance2.0_fast_reference_image` |
| Seedance 2.0 Mini | `reference_to_video` | `image2video_seedance_2.0_mini_reference_image` |
| Seedance 2.5 | `reference_to_video` | `image2video_seedance_2.5_reference_image` |
| ToMoviee 4.0 | `image_to_video` | `image2video_tomoviee4_head_and_tail_switch`, `image2video_tomoviee4_switch` |
| ToMoviee 4.0 | `reference_to_video` | `image2video_tomoviee4_reference_image_switch` |
| ToMoviee 2.0 | `image_to_video` | `image2video_tomoviee_2.0` |
| ToMoviee 2.0 Fast | `image_to_video` | `image2video_tomoviee_2.0_fast` |
| Seedance 2.0 | `image_to_video` | `image2video_tomoviee_2.5`, `image2video_tomoviee_2.5_head_and_tail` |
| Seedance 2.0 | `reference_to_video` | `image2video_tomoviee_2.5_reference_image` |
| ToMoviee 3.0 | `image_to_video` | `image2video_tomoviee_3.0` |
| ToMusic 1.0 | `image_audio_to_video` | `image2video_tomusic_1_0` |
| Google Veo 3.1 | `image_to_video` | `image2video_veo_3.1` |
| Google Veo 3.1 Fast | `image_to_video` | `image2video_veo_3.1_fast` |
| Google Veo 3.1 Lite | `image_to_video` | `image2video_veo_3.1_lite`, `image2video_veo_3.1_lite_head_and_tail` |
| Google Veo 3 Fast | `image_to_video` | `image2video_veo_3_fast` |
| Vidu 2.0 | `image_to_video` | `image2video_vidu_2.0`, `image2video_vidu_2.0_head_and_tail` |
| Vidu 2.0 | `reference_to_video` | `image2video_vidu_2.0_reference_image` |
| Vidu Q1 | `image_to_video` | `image2video_vidu_q1`, `image2video_vidu_q1_head_and_tail` |
| Vidu Q2 | `image_to_video` | `image2video_vidu_q2` |
| Vidu Q3 | `image_to_video` | `image2video_vidu_q3` |
| Wan 2.2 | `image_to_video` | `image2video_wan_2.2` |
| Wan 2.5 | `image_to_video` | `image2video_wan_2.5` |
| Wan 2.6 | `image_to_video` | `image2video_wan_2.6` |
| Wan 3.0 | `image_to_video` | `image2video_wan_3.0`, `image2video_wan_3.0_head_and_tail` |
| Wan 3.0 | `reference_to_video` | `image2video_wan_3.0_reference_image` |
| Gemini Omni Flash | `text_to_video` | `text2image_gemini_omni_flash` |
| HappyHorse 1.0 | `text_to_video` | `text2video_happyhorse_1.0` |
| HappyHorse 1.1 | `text_to_video` | `text2video_happyhorse_1.5` |
| Kling 2.5 Turbo | `text_to_video` | `text2video_kling_2.5_turbo` |
| Kling 2.6 | `text_to_video` | `text2video_kling_2.6` |
| Kling 3.0 | `text_to_video` | `text2video_kling_3.0` |
| Kling 3.0 Turbo | `text_to_video` | `text2video_kling_3.0_fast` |
| Kling O1 | `text_to_video` | `text2video_kling_o1` |
| Hailuo 2.3 | `text_to_video` | `text2video_minimax_2.3` |
| MiniMax H3 Max | `text_to_video` | `text2video_minimax_h3_max` |
| MiniMax H3 | `text_to_video` | `text2video_minimax_h3_switch` |
| Seedance 2.0 Mini | `text_to_video` | `text2video_seedance_2.0_mini` |
| Seedance 2.5 | `text_to_video` | `text2video_seedance_2.5` |
| Seedance 2.0 Fast | `text_to_video` | `text2video_seedance2.0_fast` |
| ToMoviee 4.0 | `text_to_video` | `text2video_tomoviee4_switch` |
| ToMoviee 2.0 | `text_to_video` | `text2video_tomoviee_2.0` |
| Seedance 2.0 | `text_to_video` | `text2video_tomoviee_2.5` |
| Google Veo 3.1 | `text_to_video` | `text2video_veo_3.1` |
| Google Veo 3.1 Fast | `text_to_video` | `text2video_veo_3.1_fast` |
| Google Veo 3.1 Lite | `text_to_video` | `text2video_veo_3.1_lite` |
| Google Veo 3 Fast | `text_to_video` | `text2video_veo_3_fast` |
| Vidu Q3 | `text_to_video` | `text2video_vidu_q3` |
| Wan 2.5 | `text_to_video` | `text2video_wan_2.5` |
| Wan 2.6 | `text_to_video` | `text2video_wan_2.6` |
| Wan 3.0 | `text_to_video` | `text2video_wan_3.0` |

Ambiguous aliases require clarification when variants materially differ. Deprecated models remain callable during their declared compatibility window, but are never defaults or recommendations. Replacement candidates are informational; changing models requires the user’s request. Disabled and candidate models are unavailable. Historical task IDs remain queryable with get_generation and get_generation_card; never recreate a task to recover a receipt.
