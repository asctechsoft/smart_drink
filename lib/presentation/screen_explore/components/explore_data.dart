// Hardcoded article data

import 'package:smartdrinkai/models/ui_models/article.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

List<ArticleSection> getArticleSections() => [
  ArticleSection(
    title: 'drink_water'.tr,
    articles: [
      Article(
        id: '1',
        title: 'how_to_drink_water_properly'.tr,
        body: '',
        category: 'drink_water'.tr,
        thumbnailAsset: 'assets/images/webp/img_water_properly.webp',
        blocks: [
          ArticleBlock.heading(
            'drink_in_small_amounts_throughout_the_day_not_all_at_once'.tr,
          ),
          ArticleBlock.descriptionItem(
            'dont_wait_until_youre_extremely_thirsty_to_drink'.tr,
          ),

          ArticleBlock.textWithImage(
            'avoid_drinking_a_large_amount_of_water'.tr,
            asset: 'assets/images/webp/img_avoid_drinking.webp',
          ),
          ArticleBlock.heading('recommended_daily_water_intake'.tr),
          ArticleBlock.descriptionItem(
            'around_3035_ml_per_kilogram_of_body_weight_per_day'.tr,
          ),
          ArticleBlock.descriptionItem(
            'if_you_are_very_active_the_weather_is_hot_or'.tr,
          ),
          ArticleBlock.descriptionItem(
            'if_you_have_heart_kidney_or_blood_pressure_problems_you'.tr,
          ),

          ArticleBlock.image('assets/images/webp/img_ml_per_body.webp'),
          ArticleBlock.heading('best_time_to_drink_water'.tr),
          ArticleBlock.descriptionItem(
            'after_waking_up_1_small_glass_of_warm_water_to'.tr,
          ),
          ArticleBlock.descriptionItem(
            'late_morning_midafternoon_drink_12_small_glasses_and_dont_wait'.tr,
          ),
          ArticleBlock.descriptionItem(
            '30_minutes_before_meals_1_small_glass_to_support_digestion'.tr,
          ),
          ArticleBlock.descriptionItem(
            '12_hours_before_bed_if_you_dont_usually_wake_up'.tr,
          ),

          ArticleBlock.image('assets/images/webp/img_morning.webp'),
          ArticleBlock.heading('what_kind_of_water_should_you_drink'.tr),

          ArticleBlock.bulletsWithImage('best_options'.tr, [
            'filtered_water'.tr,
            'boiled_and_cooled_water'.tr,
            'mineral_water_from_a_reliable_source'.tr,
          ], asset: 'assets/images/webp/img_boiled.webp'),

          ArticleBlock.bulletsWithImage('limit_your_intake_of'.tr, [
            'sugary_soft_drinks_carbonated_drinks'.tr,
            'drinks_that_are_very_high_in_sugar_milk_tea_bottled'.tr,
          ]),
          ArticleBlock.descriptionItem(
            'coffee_tea_and_similar_drinks_still_count_as_part_of'.tr,
          ),
          ArticleBlock.heading('listen_to_your_body'.tr),
          ArticleBlock.image('assets/images/webp/img_body_listen.webp'),
          ArticleBlock.bulletsWithImage('signs_you_may_be_dehydrated'.tr, [
            'dark_yellow_urine_with_a_strong_smell'.tr,
            'dry_lips_dry_skin_lightheadedness_fatigue'.tr,
          ]),
          ArticleBlock.descriptionItem(
            'urinating_very_little_during_the_day'.tr,
          ),

          ArticleBlock.bulletsWithImage(
            'signs_you_may_be_drinking_too_much_water_especially_in'.tr,
            [
              'frequent_urination_with_very_clear_waterlike_urine'.tr,
              'feeling_bloated_nauseous_having_headaches_or_feeling_faint'.tr,
            ],
          ),
          ArticleBlock.descriptionItem(
            'if_you_have_underlying_health_conditions_or_notice_anything_unusual'
                .tr,
          ),
        ],
      ),
      Article(
        id: '2',
        title: 'be_careful_with_these_common_waterintake_mistakes'.tr,
        body: '',
        category: 'drink_water'.tr,
        thumbnailAsset: 'assets/images/webp/img_careful.webp',
        blocks: [
          ArticleBlock.heading('waiting_until_youre_thirsty_to_drink'.tr),

          ArticleBlock.image('assets/images/webp/img_thirsty.webp'),
          ArticleBlock.descriptionItem(
            'by_the_time_you_feel_thirsty_your_body_is_already'.tr,
          ),
          ArticleBlock.descriptionItem(
            'problems_can_make_you_tired_give_you_headaches_and_reduce'.tr,
          ),
          ArticleBlock.bulletsWithImage('how_to_fix_it'.tr, [
            'sip_water_regularly_throughout_the_day_instead_of_waiting_until'
                .tr,
          ]),
          ArticleBlock.nestedBullets([
            'after_waking_up_1_small_glass_200300_ml'.tr,
            'late_morning_afternoon_evening_1_small_glass_each_time'.tr,
          ]),
          ArticleBlock.heading('drinking_far_less_than_your_body_needs'.tr),
          ArticleBlock.descriptionItem(
            'only_drinking_23_glasses_a_day_especially_common_in_office'.tr,
          ),
          ArticleBlock.textWithImage(
            'problems_dry_skin_constipation_fatigue_peeing_less_often_dark_yellow'
                .tr,
            asset: 'assets/images/webp/img_dry_skin.webp',
          ),
          ArticleBlock.bulletsWithImage(
            'how_to_fix_suggested_daily_water_intake_total_from_plain'.tr,
            [
              'on_average_3040_ml_per_kg_of_body_weight_per_day'.tr,
              'example_60_kg_about_1824_litersday'.tr,
              'if_you_exercise_a_lot_or_its_very_hot_increase'.tr,
            ],
          ),

          ArticleBlock.heading('drinking_too_much_at_once'.tr),
          ArticleBlock.descriptionItem(
            'forgetting_to_drink_all_day_then_making_up_for_it'.tr,
          ),

          ArticleBlock.bulletsWithImage('problems'.tr, [
            'overloads_the_kidneys_and_can_dilute_sodium_in_the_blood'.tr,
            'can_cause_bloating_indigestion_and_nausea'.tr,
          ], asset: 'assets/images/webp/img_kidneys.webp'),
          ArticleBlock.descriptionItem('how_to_fix_it'.tr),

          ArticleBlock.descriptionItem(
            'break_it_up_drink_about_150250_ml_at_a_time'.tr,
          ),

          ArticleBlock.heading('drinking_too_close_to_mealtimes'.tr),
          ArticleBlock.descriptionItem(
            'drinking_500_700_ml_of_water_right_before_or_right_after_a_meal'
                .tr,
          ),

          ArticleBlock.textWithImage(
            'problems_dilutes_stomach_acid_may_slow_digestion_and_cause_bloating'
                .tr,
            asset: 'assets/images/webp/img_dilutes.webp',
          ),

          ArticleBlock.bulletsWithImage('how_to_fix_it'.tr, [
            '30_minutes_before_a_meal_1_small_glass_100200_ml'.tr,
            'during_the_meal_sip_small_amounts_if_needed'.tr,
            'avoid_drinking_large_amounts_immediately_after_a_big_meal'.tr,
          ]),

          ArticleBlock.heading(
            'not_drinking_enough_before_during_and_after_exercise'.tr,
          ),
          ArticleBlock.descriptionItem(
            'going_for_a_run_playing_football_or_working_out_at'.tr,
          ),

          ArticleBlock.descriptionItem(
            'problems_dehydration_muscle_cramps_fatigue_low_blood_pressure_dizziness'
                .tr,
          ),

          ArticleBlock.bulletsWithImage('how_to_fix_it'.tr, [
            '3060_minutes_before_exercise_drink_200300_ml'.tr,
            'during_exercise_every_1520_minutes_take_a_few_small_sips'.tr,
            'after_exercise_rehydrate_gradually_dont_chug_a_huge_amount_in'.tr,
          ]),
          ArticleBlock.image('assets/images/webp/img_huge_amount.webp'),

          ArticleBlock.heading('frequently_drinking_very_coldiced_water'.tr),
          ArticleBlock.descriptionItem(
            'loving_icecold_drinks_all_year_round'.tr,
          ),

          ArticleBlock.bulletsWithImage('problems'.tr, [
            'can_cause_sudden_blood_vessel_constriction_in_the_throat'.tr,
            'for_people_with_stomach_issues_it_can_trigger_spasms_and'.tr,
          ], asset: 'assets/images/webp/img_cause_sudden.webp'),

          ArticleBlock.descriptionItem(
            'how_to_fix_it_go_for_cool_or_slightly_chilled'.tr,
          ),
          ArticleBlock.heading('using_sugary_drinks_instead_of_plain_water'.tr),
          ArticleBlock.descriptionItem(
            'prefering_soft_drinks_milk_tea_energy_drinks_bottled_juices_as'.tr,
          ),

          ArticleBlock.bulletsWithImage('problems'.tr, [
            'raises_blood_sugar_increases_the_risk_of_weight_gain_and_tooth_decay'
                .tr,
            'doesnt_hydrate_as_effectively_as_plain_water'.tr,
          ], asset: 'assets/images/webp/img_raises.webp'),

          ArticleBlock.bulletsWithImage('how_to_fix_it'.tr, [
            'plain_water_should_still_be_your_main_drink'.tr,
            'sugary_drinks_limit_them_and_treat_them_like_an_occasional'.tr,
          ]),

          ArticleBlock.heading('ignoring_the_color_of_your_urine'.tr),
          ArticleBlock.descriptionItem('only_paying_attention_to_how_much'.tr),

          ArticleBlock.bulletsWithImage('how_to_fix_it'.tr, [
            'pale_yellow_fairly_clear_usually_fine'.tr,
            'dark_yellow_with_a_strong_smell_you_may_be_dehydrated'.tr,
            'red_brown_or_unusually_cloudy_you_should_see_a_doctor'.tr,
          ]),

          ArticleBlock.heading(
            'blindly_believing_you_must_drink_3_liters_a_day'.tr,
          ),
          ArticleBlock.descriptionItem(
            'forcing_yourself_to_follow_a_fixed_number_23_liters_without'.tr,
          ),

          ArticleBlock.bulletsWithImage('how_to_fix_it'.tr, [
            'the_3040_mlkg_body_weight_formula'.tr,
            'your_sense_of_thirst'.tr,
            'the_color_of_your_urine'.tr,
          ], asset: 'assets/images/webp/img_combine.webp'),

          ArticleBlock.heading('drinking_a_lot_of_water_right_before_bed'.tr),
          ArticleBlock.descriptionItem(
            'drinking_500700_ml_of_water_just_before_sleeping_because_you'.tr,
          ),
          ArticleBlock.descriptionItem('problems'.tr),
          ArticleBlock.descriptionItem(
            'you_may_need_to_wake_up_to_pee_which_disrupts'.tr,
          ),
          ArticleBlock.descriptionItem(
            'older_adults_or_people_with_heart_or_kidney_issues_may'.tr,
          ),
          ArticleBlock.descriptionItem('how_to_fix_it'.tr),
          ArticleBlock.descriptionItem(
            '12_hours_before_bed_you_can_have_a_small_glass'.tr,
          ),
          ArticleBlock.descriptionItem(
            'right_before_sleep_just_take_a_few_sips_if_you'.tr,
          ),

          ArticleBlock.image('assets/images/webp/img_feel_thirsty.webp'),
        ],
      ),
      Article(
        id: '3',
        title: 'benefits_of_drinking_lemon_water'.tr,
        body: '',
        category: 'drink_water'.tr,
        thumbnailAsset: 'assets/images/webp/img_benefits.webp',
        blocks: [
          ArticleBlock.heading('keeps_your_body_in_balance'.tr),
          ArticleBlock.descriptionItem(
            'the_light_citrus_flavor_makes_plain_water_more_enjoyable_so'.tr,
          ),
          ArticleBlock.heading('vitamin_c_boost'.tr),
          ArticleBlock.descriptionItem(
            'lemons_are_a_good_source_of_vitamin_c_an_antioxidant'.tr,
          ),

          ArticleBlock.heading('supports_digestion'.tr),
          ArticleBlock.descriptionItem(
            'warm_lemon_water_in_the_morning_may_stimulate_digestion_and'.tr,
          ),

          ArticleBlock.image('assets/images/webp/img_heavy_after.webp'),

          ArticleBlock.heading('freshens_breath'.tr),
          ArticleBlock.descriptionItem(
            'the_acidic_citrusy_taste_can_help_reduce_bad_breath_temporarily'
                .tr,
          ),

          ArticleBlock.heading('may_support_skin_health'.tr),
          ArticleBlock.descriptionItem(
            'staying_well_hydrated_plus_getting_some_vitamin_c_can_support'.tr,
          ),

          ArticleBlock.image('assets/images/webp/img_hydrated_plus.webp'),
        ],
      ),
    ],
  ),
  ArticleSection(
    title: 'health_benefits'.tr,
    articles: [
      Article(
        id: '4',
        title: 'how_water_helps_you_sleep_better'.tr,
        body: '',
        category: 'health_benefits'.tr,
        thumbnailAsset: 'assets/images/webp/img_sleep_better.webp',
        blocks: [
          ArticleBlock.heading('keeps_your_body_in_balance'.tr),
          ArticleBlock.descriptionItem(
            'when_youre_properly_hydrated_your_heart_circulation_and_body_temperature'
                .tr,
          ),
          ArticleBlock.image('assets/images/webp/img_into_sleep.webp'),
          ArticleBlock.heading('reduces_nighttime_cramps_and_discomfort'.tr),
          ArticleBlock.descriptionItem(
            'mild_dehydration_can_contribute_to_muscle_cramps_headaches_dry_mouth'
                .tr,
          ),
          ArticleBlock.heading('helps_your_body_recover_while_you_rest'.tr),
          ArticleBlock.descriptionItem(
            'staying_hydrated_supports_circulation_and_waste_removal_helping_your_body'
                .tr,
          ),
          ArticleBlock.textWithImage(
            'important_note_drink_most_of_your_fluids_earlier_in_the'.tr,
            asset: 'assets/images/webp/img_earlier.webp',
          ),

          ArticleBlock.heading(
            'supports_hormone_and_nervous_system_function'.tr,
          ),
          ArticleBlock.descriptionItem(
            'water_plays_a_role_in_how_your_body_produces_and'.tr,
          ),
          ArticleBlock.image('assets/images/webp/img_hormones.webp'),
        ],
      ),
      Article(
        id: '5',
        title: 'drinking_water_and_weight_loss'.tr,
        body: '',
        category: 'health_benefits'.tr,
        thumbnailAsset: 'assets/images/webp/img_weight_loss.webp',
        blocks: [
          ArticleBlock.heading('helps_control_appetite'.tr),
          ArticleBlock.descriptionItem(
            'we_often_mistake_thirst_for_hunger_drinking_a_glass_of'.tr,
          ),
          ArticleBlock.heading('replaces_highcalorie_drinks'.tr),
          ArticleBlock.descriptionItem(
            'swapping_sugary_drinks_soft_drinks_milk_tea_sweetened_coffee_juice'
                .tr,
          ),
          ArticleBlock.image('assets/images/webp/img_soft_drink.webp'),

          ArticleBlock.heading('supports_metabolism_and_energy_levels'.tr),
          ArticleBlock.descriptionItem(
            'even_mild_dehydration_can_make_you_feel_tired_and_less'.tr,
          ),
          ArticleBlock.heading('helps_digestion_and_reduces_bloating'.tr),

          ArticleBlock.textWithImage(
            'drinking_enough_water_helps_your_digestive_system_work_smoothly_and'
                .tr,
            asset: 'assets/images/webp/img_digestive.webp',
          ),

          ArticleBlock.bulletsWithImage('important_reminder'.tr, [
            'eating_a_balanced_lowercalorie_diet'.tr,
            'moving_more_exercise_walking_daily_activity'.tr,
            'sleeping_and_managing_stress'.tr,
          ]),
          ArticleBlock.bulletsWithImage(
            'use_water_wisely_drink_water_regularly_swap_sugary_drinks_when'.tr,
            [],
          ),
        ],
      ),
      Article(
        id: '6',
        title: 'drinking_water_and_the_digestive_system'.tr,
        body: '',
        category: 'health_benefits'.tr,
        thumbnailAsset: 'assets/images/webp/img_drinking.webp',
        blocks: [
          ArticleBlock.heading('helps_start_digestion_in_the_mouth'.tr),
          ArticleBlock.descriptionItem(
            'water_is_a_key_part_of_saliva_which_helps_soften'.tr,
          ),
          ArticleBlock.heading('supports_stomach_function'.tr),

          ArticleBlock.textWithImage(
            'your_stomach_needs_enough_fluid_to_mix_food_with_stomach'.tr,
            asset: 'assets/images/webp/img_digestive.webp',
          ),
          ArticleBlock.image('assets/images/webp/img_mix_food.webp'),
          ArticleBlock.heading('keeps_things_moving_in_the_intestines'.tr),
          ArticleBlock.descriptionItem(
            'water_helps_dissolve_nutrients_and_carries_them_along_the_digestive'
                .tr,
          ),

          ArticleBlock.heading('works_together_with_fiber'.tr),
          ArticleBlock.descriptionItem(
            'dietary_fiber_from_vegetables_fruit_whole_grains_needs_water_to'
                .tr,
          ),

          ArticleBlock.heading('reduces_constipation_and_bloating'.tr),

          ArticleBlock.textWithImage(
            'when_youre_dehydrated_your_body_pulls_more_water_out_of'.tr,
            asset: 'assets/images/webp/img_dehydrated.webp',
          ),
          ArticleBlock.heading('may_ease_heartburn_in_some_people'.tr),

          ArticleBlock.textWithImage(
            'small_sips_of_water_may_ease_mild_heartburn_but_drinking'.tr,
            asset: 'assets/images/webp/img_heartburn.webp',
          ),

          ArticleBlock.bulletsWithImage('practical_tips'.tr, [
            'drink_water_regularly_throughout_the_day'.tr,
            'have_a_small_glass_1530_minutes_before_meals'.tr,
            'during_meals_sip_slowlydont_chug'.tr,
            'if_youre_often_bloated_or_constipated_increase_both_water_and'.tr,
          ]),
        ],
      ),
      Article(
        id: '7',
        title: 'the_effects_of_water_on_the_brain_and_concentration'.tr,
        body: '',
        category: 'health_benefits'.tr,
        thumbnailAsset: 'assets/images/webp/img_effects.webp',
        blocks: [
          ArticleBlock.heading('maintains_energy_and_alertness'.tr),
          ArticleBlock.descriptionItem(
            'the_brain_is_7075_water_so_even_mild_dehydration_can'.tr,
          ),
          ArticleBlock.heading('supports_focus_and_concentration'.tr),

          ArticleBlock.textWithImage(
            'dehydration_can_reduce_focus_and_concentration_causing_students_office_workers'
                .tr,
            asset: 'assets/images/webp/img_dehydration.webp',
          ),
          ArticleBlock.heading('helps_mood_and_stress_levels'.tr),
          ArticleBlock.textWithImage(
            'not_drinking_enough_water_can_make_you_irritable_low_and'.tr,
            asset: 'assets/images/webp/img_stress_levels.webp',
          ),

          ArticleBlock.heading('reduces_headaches_in_some_people'.tr),
          ArticleBlock.descriptionItem(
            'not_drinking_enough_water_can_trigger_headaches_for_many_people'
                .tr,
          ),
          ArticleBlock.image('assets/images/webp/img_headaches.webp'),
          ArticleBlock.heading('supports_memory_and_mental_performance'.tr),
          ArticleBlock.descriptionItem(
            'staying_hydrated_supports_memory_reaction_time_and_focusespecially_during_exams'
                .tr,
          ),
          ArticleBlock.bulletsWithImage(
            'dont_rely_on_coffee_or_energy_drinks_alone_keep'.tr, [
           ]),
        ],
      ),
      Article(
        id: '8',
        title: 'impact_of_alcohol_on_your_health'.tr,
        body: '',
        category: 'health_benefits'.tr,
        thumbnailAsset: 'assets/images/webp/img_alcohol.webp',
        blocks: [
          ArticleBlock.heading('shortterm_effects'.tr),
          ArticleBlock.descriptionItem(
            'alcohol_can_slow_your_reactions_and_impair_balance_increasing_accident'
                .tr,
          ),
          ArticleBlock.descriptionItem(
            'it_may_affect_mood_and_behavior_from_relaxed_to_irritable_or_aggressive'
                .tr,
          ),
          ArticleBlock.descriptionItem(
            'it_also_dehydrates_you_by_increasing_urination_leading_to_headaches_dry_mouth_and_hangovers'
                .tr,
          ),
          ArticleBlock.descriptionItem(
            'plus_it_can_irritate_the_stomach_and_cause_nausea_vomiting_or_pain'
                .tr,
          ),

          ArticleBlock.image('assets/images/webp/img_alcohol_effect.webp'),
          ArticleBlock.heading(
            'longterm_effects_with_frequent_or_heavy_drinking'.tr,
          ),
          ArticleBlock.descriptionItem(
            'liver_damage_over_time_alcohol_can_cause_fatty_liver_hepatitis'.tr,
          ),
          ArticleBlock.descriptionItem(
            'heart_and_blood_pressure_problems_heavy_drinking_over_time_can'.tr,
          ),
          ArticleBlock.descriptionItem(
            'brain_and_mental_health_longterm_alcohol_use_can_impair_memory'.tr,
          ),
          ArticleBlock.descriptionItem(
            'digestive_system_and_cancer_risk_heavy_longterm_alcohol_use_can'
                .tr,
          ),
          ArticleBlock.descriptionItem(
            'immune_system_chronic_heavy_drinking_can_weaken_your_immune_system'
                .tr,
          ),
          ArticleBlock.image('assets/images/webp/img_liver_damage.webp'),
          ArticleBlock.heading('weight_and_sleep'.tr),
          ArticleBlock.descriptionItem(
            'alcohol_adds_empty_calories_that_can_lead_to_weight_gain'.tr,
          ),
          ArticleBlock.descriptionItem(
            'important_note_even_lowtomoderate_drinking_isnt_riskfree_for_some_people'
                .tr,
          ),
          ArticleBlock.image('assets/images/webp/img_low_to_moderate.webp'),
        ],
      ),
      Article(
        id: '9',
        title: 'drinking_water_to_reduce_hormonal_acne'.tr,
        body: '',
        category: 'health_benefits'.tr,
        thumbnailAsset: 'assets/images/webp/img_reduce.webp',
        blocks: [
          ArticleBlock.heading('supports_the_bodys_detox_and_balance'.tr),
          ArticleBlock.descriptionItem(
            'your_kidneys_and_liver_process_hormones_and_waste_staying_hydrated'
                .tr,
          ),
          ArticleBlock.heading('helps_maintain_skin_barrier_and_moisture'.tr),
          ArticleBlock.textWithImage(
            'dehydration_can_make_skin_look_dull_tight_and_easily_irritated'.tr,
            asset: 'assets/images/webp/img_moisture.webp',
          ),
          ArticleBlock.heading(
            'supports_blood_circulation_and_nutrient_delivery'.tr,
          ),
          ArticleBlock.bulletsWithImage(
            'water_helps_keep_blood_flowing_smoothly'.tr,
            [
              'nutrients_oxygen_and_beneficial_compounds_are_transported_more_efficiently_to'
                  .tr,
              'waste_products_are_carried_away_more_effectively'.tr,
            ],
          ),

          ArticleBlock.descriptionItem(
            'this_can_contribute_to_a_brighter_healthierlooking_complexion_over_time'
                .tr,
          ),
          ArticleBlock.image('assets/images/webp/img_smoothly.webp'),
          ArticleBlock.heading('may_reduce_drynessrelated_oiliness'.tr),
          ArticleBlock.bulletsWithImage(
            'for_some_people_when_the_skin_is_very_dehydrated'.tr,
            [
              'it_may_compensate_by_producing_more_oil'.tr,
              'this_can_make_skin_look_shiny_but_still_feel_dry'.tr,
            ],
          ),
          ArticleBlock.descriptionItem(
            'staying_hydrated_plus_using_the_right_moisturizer_can_help_your'
                .tr,
          ),
          ArticleBlock.image('assets/images/webp/img_oilliness.webp'),
        ],
      ),
    ],
  ),
  ArticleSection(
    title: 'healthier_skin'.tr,
    articles: [
      Article(
        id: '10',
        title: 'how_to_drink_water_to_reduce_facial_oiliness'.tr,
        body: '',
        category: 'healthier_skin'.tr,
        thumbnailAsset: 'assets/images/webp/img_water_reduce.webp',
        blocks: [
          ArticleBlock.heading('supports_skin_hydration_from_the_inside'.tr),
          ArticleBlock.bulletsWithImage(
            'water_helps_maintain_your_bodys_overall_fluid_balance_when_youre'
                .tr,
            [
              'your_skin_is_less_likely_to_feel_tight_rough_or_flaky'.tr,
              'fine_lines_caused_by_dryness_can_appear_softer'.tr,
            ],
          ),
          ArticleBlock.descriptionItem(
            'think_of_it_as_giving_your_skin_a_better_base_so'.tr,
          ),
          ArticleBlock.heading('helps_the_skin_barrier_function_better'.tr),
          ArticleBlock.descriptionItem(
            'for_some_very_dehydrated_skin_can_trigger_the_skin_to'.tr,
          ),
          ArticleBlock.textWithImage(
            'while_water_wont_turn_off_oily_skin_staying_hydrated_plus_using'
                .tr,
            asset: 'assets/images/webp/img_wont_turn.webp',
          ),
          ArticleBlock.heading('helps_with_detox_processes_indirectly'.tr),
          ArticleBlock.bulletsWithImage(
            'water_itself_doesnt_detox_your_skin_like_magic_but'.tr,
            [
              'it_helps_your_kidneys_and_liver_work_properly'.tr,
              'these_organs_process_waste_products_and_byproducts_that_if_not'
                  .tr,
            ],
          ),
          ArticleBlock.descriptionItem(
            'less_internal_stress_can_show_up_externally_as_calmer_more'.tr,
          ),
          ArticleBlock.image('assets/images/webp/img_balanced_skin.webp'),
          ArticleBlock.heading('may_reduce_drynessrelated_oiliness'.tr),
          ArticleBlock.bulletsWithImage(
            'for_some_people_when_the_skin_is_very_dehydrated'.tr,
            [
              'it_may_compensate_by_producing_more_oil'.tr,
              'this_can_make_skin_look_shiny_but_still_feel_dry'.tr,
            ],
          ),
          ArticleBlock.descriptionItem(
            'staying_hydrated_plus_using_the_right_moisturizer_can_help_your'
                .tr,
          ),
          ArticleBlock.image('assets/images/webp/img_overcompensating.webp'),
        ],
      ),
      Article(
        id: '11',
        title: 'waterdrinking_mistakes_that_harm_your_skin'.tr,
        body: '',
        category: 'healthier_skin'.tr,
        thumbnailAsset: 'assets/images/webp/img_mistakes.webp',
        blocks: [
          ArticleBlock.heading('drinking_too_little_water_all_day'.tr),
          ArticleBlock.descriptionItem(
            'chronic_mild_dehydration_can_make_your_skin_look_dull_tight'.tr,
          ),
          ArticleBlock.image('assets/images/webp/img_more_noticeable.webp'),
          ArticleBlock.heading('believing_water_alone_will_fix_my_skin'.tr),
          ArticleBlock.descriptionItem(
            'water_supports_healthy_skin_but_it_cant_replace_sunscreen_a'.tr,
          ),
          ArticleBlock.image('assets/images/webp/img_clear_skin.webp'),
        ],
      ),
      Article(
        id: '12',
        title: 'best_times_to_drink_water_for_smoother_clearer_skin'.tr,
        body: '',
        category: 'healthier_skin'.tr,
        thumbnailAsset: 'assets/images/webp/img_best_times.webp',
        blocks: [
          ArticleBlock.heading('right_after_waking_up'.tr),
          ArticleBlock.descriptionItem(
            'have_1_small_glass_200300_ml_in_the_morningthis_helps'.tr,
          ),
          ArticleBlock.image('assets/images/webp/img_rehydrate.webp'),
          ArticleBlock.heading('30_minutes_before_meals'.tr),
          ArticleBlock.descriptionItem(
            'drink_a_small_glass_of_water_2030_minutes_before_eatingthis'.tr,
          ),
          ArticleBlock.descriptionItem(
            'this_supports_digestion_helps_nutrients_absorb_better_and_may_prevent'
                .tr,
          ),
          ArticleBlock.heading('between_meals_not_just_with_them'.tr),
          ArticleBlock.descriptionItem(
            'sip_water_between_meals_instead_of_only_during_mealssteady_hydration'
                .tr,
          ),
          ArticleBlock.descriptionItem(
            'steady_hydration_helps_keep_the_skin_barrier'.tr,
          ),
          ArticleBlock.image('assets/images/webp/img_meals.webp'),
          ArticleBlock.heading('before_and_after_exercise'.tr),
          ArticleBlock.descriptionItem(
            'before_exercise_drink_a_small_glass_of_waterafter_exercise_rehydrate'
                .tr,
          ),
          ArticleBlock.image('assets/images/webp/img_exercise.webp'),
          ArticleBlock.heading(
            'during_long_periods_of_screen_time_or_study'.tr,
          ),
          ArticleBlock.descriptionItem(
            'when_working_or_studying_for_hours_take_a_few_sips'.tr,
          ),
          ArticleBlock.image('assets/images/webp/img_long_period.webp'),
          ArticleBlock.heading(
            '12_hours_before_bed_but_not_too_much_right_before'.tr,
          ),
          ArticleBlock.descriptionItem(
            'you_can_drink_a_small_glass_12_hours_before_sleepingavoid_chugging'
                .tr,
          ),
          ArticleBlock.descriptionItem(
            'avoid_chugging_water_right_before_bed_so_your_sleep'.tr,
          ),
          ArticleBlock.image('assets/images/webp/img_before_bed.webp'),
        ],
      ),
      Article(
        id: '13',
        title: 'drinking_water_during_your_period'.tr,
        body: '',
        category: 'healthier_skin'.tr,
        thumbnailAsset: 'assets/images/webp/img_during.webp',
        blocks: [
          ArticleBlock.heading(''.tr),
          ArticleBlock.descriptionItem(
            'drinking_enough_water_actually_helps_your_body_release_excess_fluid'
                .tr,
          ),
          ArticleBlock.heading('helps_with_cramps_and_headaches'.tr),
          ArticleBlock.descriptionItem(
            'mild_dehydration_can_make_period_cramps_and_headaches_feel_worse'
                .tr,
          ),
          ArticleBlock.image('assets/images/webp/img_mild_dehydration.webp'),
          ArticleBlock.heading('supports_mood_and_energy'.tr),
          ArticleBlock.descriptionItem(
            'when_youre_low_on_water_youre_more_likely_to_feel_tired'.tr,
          ),
          ArticleBlock.descriptionItem(
            'good_hydration_helps_keep_your_energy'.tr,
          ),
          ArticleBlock.heading('aids_digestion'.tr),
          ArticleBlock.descriptionItem(
            'many_people_experience_constipation_or_digestive_changes_during_their_period'
                .tr,
          ),
          ArticleBlock.image('assets/images/webp/img_constipation.webp'),
        ],
      ),
      Article(
        id: '14',
        title: 'hydration_for_pregnant_women'.tr,
        body: '',
        category: 'healthier_skin'.tr,
        thumbnailAsset: 'assets/images/webp/img_pregnant.webp',
        blocks: [
          ArticleBlock.heading('supports_blood_volume_and_circulation'.tr),
          ArticleBlock.descriptionItem(
            'supports_blood_volume_and_circulation_during_pregnancy_your_blood_volume'
                .tr,
          ),
          ArticleBlock.heading('helps_form_amniotic_fluid'.tr),
          ArticleBlock.descriptionItem(
            'water_contributes_to_the_production_of_amniotic_fluid_which_cushions'
                .tr,
          ),
          ArticleBlock.image('assets/images/webp/img_contributes.webp'),
          ArticleBlock.heading('reduces_common_pregnancy_discomforts'.tr),

          ArticleBlock.bulletsWithImage(''.tr, [
            'reduce_constipation_and_hemorrhoids'.tr,
            'ease_swelling_water_retention'.tr,
            'lower_the_chance_of_headaches_and_dizziness'.tr,
          ]),
          ArticleBlock.heading('supports_kidney_function'.tr),
          ArticleBlock.descriptionItem(
            'water_contributes_to_the_production_of_amniotic_fluid_which_cushions'
                .tr,
          ),
          ArticleBlock.image('assets/images/webp/img_amniotic.webp'),
          ArticleBlock.heading('how_much_to_drink_general_guideline'.tr),
          ArticleBlock.descriptionItem(
            'pregnant_women_should_aim_for_225_liters_of_fluid_per_day'.tr,
          ),
          ArticleBlock.bulletsWithImage(
            'this_includes_water_soups_milk_herbal_teas_and_water_from_foods'
                .tr,
            [
              'pale_yellow_urine_usually_wellhydrated'.tr,
              'dark_yellow_strong_smell_may_need_more_fluids'.tr,
            ],
          ),
          ArticleBlock.bulletsWithImage(
            'always_follow_your_doctors_or_midwifes_advice_especially_if_you'
                .tr,
            [],
          ),
          ArticleBlock.image('assets/images/webp/img_gestational.webp'),
        ],
      ),
    ],
  ),
  ArticleSection(
    title: 'seasonal_situational_content'.tr,
    articles: [
      Article(
        id: '15',
        title: 'how_much_water_should_you_drink_in_hot_weather'.tr,
        body: '',
        category: 'seasonal'.tr,
        thumbnailAsset: 'assets/images/webp/img_should.webp',
        blocks: [
          ArticleBlock.heading('general_guideline'.tr),
          ArticleBlock.bulletsWithImage(
            'recommended_fluid_intake_for_healthy_adults'.tr,
            [
              '23_liters_per_day_under_normal_conditions'.tr,
              'in_hot_weather_add_051_liter_more_especially_if_sweating'.tr,
            ],
          ),
          ArticleBlock.bulletsWithImage('simple_rule'.tr, [
            '3040_ml_of_water_per_kg_of_body_weight'.tr,
          ]),
          ArticleBlock.bulletsWithImage('example_hot_weather'.tr, [
            '60_kg_person_base_18_24l'.tr,
            'add_05_1l_if_workingexercising_in_the_heat_total'.tr,
          ]),
          ArticleBlock.image('assets/images/webp/img_recommended.webp'),
          ArticleBlock.heading('listen_to_your_body'.tr),
          ArticleBlock.descriptionItem(
            'instead_of_chasing_a_perfect_number_watch_forthirst_feeling_thirsty'
                .tr,
          ),
          ArticleBlock.image('assets/images/webp/img_symptom.webp'),
          ArticleBlock.heading('when_you_sweat_a_lot'.tr),
          ArticleBlock.descriptionItem(
            'if_youre_working_outside_exercising_or_riding_a_motorbike_in'.tr,
          ),
          ArticleBlock.descriptionItem(
            'for_very_intense_sweating_over_a_long_period_an'.tr,
          ),
          ArticleBlock.image('assets/images/webp/img_sweat.webp'),
          ArticleBlock.heading('dont_overdo_it'.tr),
          ArticleBlock.descriptionItem(
            'avoid_forcing_huge_amounts_of_water_in_a_short_time'.tr,
          ),
          ArticleBlock.descriptionItem('key_idea_in_hot_weather'.tr),
          ArticleBlock.image('assets/images/webp/img_extreme.webp'),
        ],
      ),
      Article(
        id: '16',
        title: 'hydration_tips_while_working_out'.tr,
        body: '',
        category: 'seasonal_situational_content'.tr,
        thumbnailAsset: 'assets/images/webp/img_working.webp',
        blocks: [
          ArticleBlock.heading('before_your_workout'.tr),
          ArticleBlock.descriptionItem(
            '12_hours_before_drink_about_300500_ml_of_water1520_minutes'.tr,
          ),

          ArticleBlock.image('assets/images/webp/img_stomach.webp'),
          ArticleBlock.heading('during_your_workout'.tr),
          ArticleBlock.descriptionItem(
            'for_lightmoderate_exercise_under_1_hour_sip_100150_ml_every'.tr,
          ),
          ArticleBlock.descriptionItem(
            'for_intense_long_workouts_over_1_hour_especially_in_heat'.tr,
          ),
          ArticleBlock.image('assets/images/webp/img_light_moderate.webp'),
          ArticleBlock.heading('after_your_workout'.tr),
          ArticleBlock.descriptionItem(
            'drink_200500_ml_of_water_within_30_minutes_after_finishing'.tr,
          ),
          ArticleBlock.descriptionItem(
            'if_your_clothes_are_soaked_with_sweat'.tr,
          ),
          ArticleBlock.image('assets/images/webp/img_workout.webp'),
          ArticleBlock.heading('what_to_drink'.tr),
          ArticleBlock.descriptionItem(
            'best_choice_plain_water_for_most_workouts'.tr,
          ),
          ArticleBlock.bulletsWithImage('electrolyte_drinks_useful_if'.tr, [
            'you_exercise_hard_for_more_than_60_minutes'.tr,
            'you_sweat_heavily'.tr,
            'youre_training_in_very_hothumid_weather'.tr,
            'avoid_very_sugary_drinks_hydration_source'.tr,
          ]),
        ],
      ),
      Article(
        id: '17',
        title: 'drinking_a_when_sick_fever_cold'.tr,
        body: '',
        category: 'seasonal_situational_content'.tr,
        thumbnailAsset: 'assets/images/webp/img_sick.webp',
        blocks: [
          ArticleBlock.heading('why_water_matters_when_youre_sick'.tr),
          ArticleBlock.descriptionItem(
            'when_your_temperature_is_higher_you_sweat_more_and_breathe'.tr,
          ),
          ArticleBlock.descriptionItem(
            'coldflu_symptoms_dry_you_out_runny_nose_fast_breathing_coughing'
                .tr,
          ),
          ArticleBlock.descriptionItem(
            'hydration_supports_your_immune_system_water_helps_your_blood_carry'
                .tr,
          ),

          ArticleBlock.image('assets/images/webp/img_immune.webp'),
          ArticleBlock.heading('signs_you_may_not_be_drinking_enough'.tr),

          ArticleBlock.descriptionItem(
            'dark_yellow_urine_and_peeing_very_little'.tr,
          ),
          ArticleBlock.descriptionItem('very_dry_mouth_and_lips'.tr),
          ArticleBlock.descriptionItem(
            'feeling_dizzy_weak_or_extremely_tired'.tr,
          ),
          ArticleBlock.descriptionItem(
            'headache_that_feels_worse_when_you_stand_up'.tr,
          ),
          ArticleBlock.descriptionItem(
            'if_you_notice_these_signs_try_to_increase_your_fluid'.tr,
          ),
          ArticleBlock.image('assets/images/webp/img_peeing.webp'),
          ArticleBlock.heading('what_and_how_to_drink'.tr),
          ArticleBlock.descriptionItem('plain_water_main_choice_sip_often'.tr),
          ArticleBlock.descriptionItem(
            'warm_liquids_warm_water_herbal_tea_or_clear_broth_can'.tr,
          ),
          ArticleBlock.descriptionItem(
            'oral_rehydration_solution_ors_or_electrolyte_drinks_useful_if_you'
                .tr,
          ),
          ArticleBlock.descriptionItem(
            'tip_if_you_dont_feel_like_drinking_much_at_once'.tr,
          ),
          ArticleBlock.twoImages(
            'assets/images/webp/img_plain_left.webp',
            'assets/images/webp/img_plain_right.webp',
          ),
          ArticleBlock.heading('when_to_seek_medical_help_important'.tr),
          ArticleBlock.bulletsWithImage(
            'drinking_water_at_home_helps_but_you_should_see_a'.tr,
            [
              'you_cant_keep_fruits_down_vomit_everything'.tr,
              'you_feel_very_dizzy_confused_or_have_a_very_fast'.tr,
              'you_have_trouble_breathing_chest_pain_or_a_high_lasting'.tr,
              'a_baby_child_pregnant_woman_or_elderly_person_shows_signs'.tr,
            ],
          ),
          ArticleBlock.descriptionItem(
            'hydration_doesnt_cure_the_illness_but_it_helps_your_body'.tr,
          ),
        ],
      ),
      Article(
        id: '18',
        title: 'hydration_tips_for_office_workers_students_and_drivers'.tr,
        body: '',
        category: 'seasonal_situational_content'.tr,
        thumbnailAsset: 'assets/images/webp/img_hydration.webp',
        blocks: [
          ArticleBlock.heading('office_workers'.tr),
          ArticleBlock.descriptionItem(
            'keep_a_water_bottle_on_your_desk_where_you_can'.tr,
          ),
          ArticleBlock.descriptionItem(
            'drink_a_small_glass_150250_ml_every_12_hours'.tr,
          ),
          ArticleBlock.descriptionItem(
            'use_triggers_drink_when_you_check_emails_finish_a_task'.tr,
          ),
          ArticleBlock.descriptionItem(
            'limit_coffee_and_sugary_drinks_let_plain_water_be_your'.tr,
          ),
          ArticleBlock.image('assets/images/webp/img_office.webp'),
          ArticleBlock.heading('students'.tr),
          ArticleBlock.descriptionItem(
            'start_the_day_with_a_small_glass_of_water_before'.tr,
          ),

          ArticleBlock.descriptionItem(
            'carry_a_reusable_bottle_and_sip_during_breaks_between_classes'.tr,
          ),
          ArticleBlock.descriptionItem(
            'when_studying_for_long_periods_drink_a_few_sips_every'.tr,
          ),
          ArticleBlock.descriptionItem(
            'dont_rely_on_energy_drinks_or_very_sweet_tea_as'.tr,
          ),
          ArticleBlock.image('assets/images/webp/img_student.webp'),
          ArticleBlock.heading('drivers'.tr),
          ArticleBlock.descriptionItem(
            'drink_water_before_heading_out_on_long_drives_to_ensure'.tr,
          ),
          ArticleBlock.descriptionItem(
            'always_carry_a_water_bottle_while_driving_especially_on_long'.tr,
          ),
          ArticleBlock.descriptionItem(
            'on_long_drives_stop_every_2_hours_to_stretch_and_hydrate'.tr,
          ),
          ArticleBlock.descriptionItem(
            'choose_water_for_longerlasting_hydration_instead_of_sugary_drinks_and'
                .tr,
          ),
          ArticleBlock.descriptionItem(
            'even_on_short_trips_sip_water_to_maintain_energy_and_alertness'.tr,
          ),
          ArticleBlock.image('assets/images/webp/img_drives.webp'),
        ],
      ),
    ],
  ),
];

