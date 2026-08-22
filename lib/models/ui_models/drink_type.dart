import 'package:flutter/material.dart';

/// Drink kinds shown in the "Loại đồ uống" picker. [waterPercent] is how much of
/// the volume counts as hydration; [viName] is the display label (localise later)
/// and [imagePath] its artwork.
enum DrinkType {
  water(
    'water',
    Icons.water_drop,
    '💧',
    100,
    ['provides_100_percent_water', 'the_best_choice_for_hydration'],
    'assets/images/menu/img_menu_coc_nuoc.webp',
    'Nước',
  ),
  milk(
    'milk',
    Icons.local_drink,
    '🥛',
    89,
    [
      'provides_about_95_percent_water',
      'nutrient_rich_with_calcium_and_protein_for_everyday_wellness',
    ],
    'assets/images/menu/img_menu_sua.webp',
    'Sữa',
  ),
  tea(
    'tea',
    Icons.emoji_food_beverage,
    '🍵',
    99,
    ['provides_about_90_percent_water', 'high_in_antioxidants_providing'],
    'assets/images/menu/img_menu_tra_dao.webp',
    'Trà',
  ),
  juice(
    'juice',
    Icons.local_cafe,
    '🧃',
    88,
    [
      'provides_about_85_percent_water',
      'packed_with_vitamin_c_and_antioxidants',
    ],
    'assets/images/menu/img_menu_juice.webp',
    'Nước trái cây',
  ),

  coffee(
    'coffee',
    Icons.coffee,
    '☕',
    98,
    ['provides_about_75_percent_water', 'boosts_alertness_through_caffeine'],
    'assets/images/menu/img_menu_cafe.webp',
    'Cà phê',
  ),
  beer(
    'beer',
    Icons.sports_bar,
    '🍻',
    92,
    ['provides_about_70_percent_water', 'crafted_using_barley_hops_and_water'],
    'assets/images/menu/img_menu_bia.webp',
    'Bia',
  ),
  wine(
    'wine',
    Icons.wine_bar,
    '🍷',
    86,
    [
      'provides_about_50_percent_water',
      'partially_hydrating_but_can_contribute_to_dehydration',
    ],
    'assets/images/menu/img_menu_ruou_vang.webp',
    'Rượu vang',
  ),
  strongDrinks(
    'strong_drinks',
    Icons.liquor,
    '🥃',
    60,
    [
      'this_drink_dehydrates_you_drink_more_water',
      'highly_alcoholic_commonly_served',
    ],
    'assets/images/menu/img_menu_ruou_ngams.webp',
    'Rượu ngâm',
  ),
  milkTea(
    'milk_tea',
    Icons.bubble_chart,
    '🧋',
    85,
    [],
    'assets/images/menu/img_menu_tra_sua.webp',
    'Trà sữa',
  ),
  smoothie(
    'smoothie',
    Icons.local_drink,
    '🥤',
    82,
    [],
    'assets/images/menu/img_menu_nuoc_ep.webp',
    'Sinh tố',
  ),
  soju(
    'soju',
    Icons.liquor,
    '🍶',
    78,
    [],
    'assets/images/menu/img_menu_ruou_ngams.webp',
    'Rượu Hàn Quốc',
  ),
  sweetSoup(
    'sweet_soup',
    Icons.icecream,
    '🍧',
    76,
    [],
    'assets/images/menu/img_menu_che.webp',
    'Chè',
  ),
  soda(
    'soda',
    Icons.bubble_chart,
    '🥤',
    99,
    [],
    'assets/images/menu/img_menu_nuoc_khoang.webp',
    'Nước có ga',
  ),
  coconut(
    'coconut',
    Icons.eco,
    '🥥',
    95,
    [],
    'assets/images/menu/img_menu_dua.webp',
    'Nước dừa',
  ),
  electrolyte(
    'electrolyte',
    Icons.bolt,
    '⚡',
    96,
    [],
    'assets/images/menu/img_menu_nuoc_khoang.webp',
    'Nước điện giải',
  ),
  energy(
    'energy',
    Icons.battery_charging_full,
    '🔋',
    90,
    [],
    'assets/images/menu/img_menu_tang_luc.webp',
    'Nước tăng lực',
  ),
  yogurtDrink(
    'yogurt_drink',
    Icons.local_drink,
    '🥛',
    84,
    [],
    'assets/images/menu/img_menu_sua_chua.webp',
    'Sữa chua uống',
  ),
  detox(
    'detox',
    Icons.spa,
    '🥒',
    98,
    [],
    'assets/images/menu/img_menu_chanh.webp',
    'Nước detox',
  ),
  teaCeremony(
    'tea_ceremony',
    Icons.emoji_food_beverage,
    '🍵',
    99,
    [],
    'assets/images/menu/img_menu_tra_dao.webp',
    'Trà đạo',
  ),
  herbalWine(
    'herbal_wine',
    Icons.liquor,
    '🍯',
    65,
    [],
    'assets/images/menu/img_menu_ruou_ngams.webp',
    'Rượu ngâm',
  );

  final String label;
  final IconData icon;
  final String emoji;
  final int waterPercent;
  final List<String> descriptions;
  final String imagePath;
  final String viName;

  const DrinkType(
    this.label,
    this.icon,
    this.emoji,
    this.waterPercent,
    this.descriptions,
    this.imagePath,
    this.viName,
  );
}
