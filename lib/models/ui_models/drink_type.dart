import 'package:flutter/material.dart';

enum DrinkType {
  water('water', Icons.water_drop, '🥛', 100, [
    'provides_100_percent_water',
    'the_best_choice_for_hydration',
  ], 'assets/images/webp/img_cup_water.webp'),
  milk('milk', Icons.local_drink, '🥛🫙', 95, [
    'provides_about_95_percent_water',
    'nutrient_rich_with_calcium_and_protein_for_everyday_wellness',
  ], 'assets/images/webp/img_cup_milk.webp'),
  tea('tea', Icons.emoji_food_beverage, '🍵', 90, [
    'provides_about_90_percent_water',
    'high_in_antioxidants_providing',
  ], 'assets/images/webp/img_cup_tea.webp'),
  juice('juice', Icons.local_cafe, '🧃', 85, [
    'provides_about_85_percent_water',
    'packed_with_vitamin_c_and_antioxidants',
  ], 'assets/images/webp/img_juice.webp'),
  soup('soup', Icons.soup_kitchen, '🍲', 85, [
    'provides_about_85_percent_water',
    'nutrient_content_varies_greatly_based_on_ingredients',
  ], 'assets/images/webp/img_soup.webp'),
  coffee('coffee', Icons.coffee, '☕', 75, [
    'provides_about_75_percent_water',
    'boosts_alertness_through_caffeine',
  ], 'assets/images/webp/img_coffce.webp'),
  beer('beer', Icons.sports_bar, '🍻', 70, [
    'provides_about_70_percent_water',
    'crafted_using_barley_hops_and_water',
  ], 'assets/images/webp/img_beer.webp'),
  wine('wine', Icons.wine_bar, '🍷', 50, [
    'provides_about_50_percent_water',
    'partially_hydrating_but_can_contribute_to_dehydration',
  ], 'assets/images/webp/img_wine.webp'),
  strongDrinks('strong_drinks', Icons.liquor, '🥃', 0, [
    'this_drink_dehydrates_you_drink_more_water',
    'highly_alcoholic_commonly_served',
  ], 'assets/images/webp/img_strong.webp');

  final String label;
  final IconData icon;
  final String emoji;
  final int waterPercent;
  final List<String> descriptions;
  final String imagePath;

  const DrinkType(
    this.label,
    this.icon,
    this.emoji,
    this.waterPercent,
    this.descriptions,
    this.imagePath,
  );
}

