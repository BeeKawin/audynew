import 'package:flutter/material.dart';

import 'sorting_game_models.dart';

/// All predefined sorting levels for the game.
/// Levels follow ABA principles: repetition with variation, gradual difficulty progression.
class SortLevelDefinitions {
  /// Returns all available levels.
  /// [unlockedLevelIndex] controls which levels are accessible.
  static List<SortGameLevel> allLevels({int unlockedLevelIndex = 0}) {
    return [
      _animalsEasy,
      _shapesEasy,
      _animalsMedium,
      _foodMedium,
      _emotionsHard,
      _dailyObjectsHard,
    ].asMap().entries.map((entry) {
      return SortGameLevel(
        id: entry.value.id,
        name: entry.value.name,
        difficulty: entry.value.difficulty,
        theme: entry.value.theme,
        rounds: entry.value.rounds,
        starsRequired: entry.value.starsRequired,
        isLocked: entry.key > unlockedLevelIndex,
      );
    }).toList();
  }

  /// Level 1: Animals (Easy) - 2 categories, 3 items, hints on
  static const _animalsEasy = SortGameLevel(
    id: 'animals_easy',
    name: 'Animals',
    difficulty: SortDifficulty.easy,
    theme: SortTheme(
      name: 'Animals',
      primaryColor: Color(0xFF9DE7CB),
      secondaryColor: Color(0xFFC7EBF8),
      icon: Icons.pets_rounded,
      instructionText: 'Sort the animals into their homes!',
    ),
    rounds: [
      SortRound(
        items: [
          SortItem(
            id: 'cat_1',
            label: 'Cat',
            icon: Icons.pets_rounded,
            categoryId: 'land',
            color: Color(0xFFFFDAC7),
          ),
          SortItem(
            id: 'fish_1',
            label: 'Fish',
            icon: Icons.set_meal_rounded,
            categoryId: 'water',
            color: Color(0xFF8FBCEC),
          ),
          SortItem(
            id: 'bird_1',
            label: 'Bird',
            icon: Icons.flight_rounded,
            categoryId: 'sky',
            color: Color(0xFFF8C7DF),
          ),
        ],
        categories: [
          SortCategory(
            id: 'land',
            label: 'Land',
            icon: Icons.grass,
            color: Color.fromRGBO(59, 211, 54, 1),
          ),
          SortCategory(
            id: 'water',
            label: 'Water',
            icon: Icons.water_drop_rounded,
            color: Color(0xFF8FBCEC),
          ),
          SortCategory(
            id: 'sky',
            label: 'Sky',
            icon: Icons.cloud_rounded,
            color: Color(0xFFF8C7DF),
          ),
        ],
        hintEnabled: true,
      ),
      SortRound(
        items: [
          SortItem(
            id: 'dog_2',
            label: 'Dog',
            icon: Icons.pets_rounded,
            categoryId: 'land',
            color: Color(0xFFFFDAC7),
          ),
          SortItem(
            id: 'duck_2',
            label: 'Duck',
            icon: Icons.water_drop_rounded,
            categoryId: 'water',
            color: Color(0xFF8FBCEC),
          ),
          SortItem(
            id: 'butterfly_2',
            label: 'Butterfly',
            icon: Icons.flight_rounded,
            categoryId: 'sky',
            color: Color(0xFFF8C7DF),
          ),
          SortItem(
            id: 'rabbit_2',
            label: 'Rabbit',
            icon: Icons.pets_rounded,
            categoryId: 'land',
            color: Color(0xFFFFDAC7),
          ),
        ],
        categories: [
          SortCategory(
            id: 'land',
            label: 'Land',
            icon: Icons.grass,
            color: Color.fromRGBO(59, 211, 54, 1),
          ),
          SortCategory(
            id: 'water',
            label: 'Water',
            icon: Icons.water_drop_rounded,
            color: Color(0xFF8FBCEC),
          ),
          SortCategory(
            id: 'sky',
            label: 'Sky',
            icon: Icons.cloud_rounded,
            color: Color(0xFFF8C7DF),
          ),
        ],
        hintEnabled: true,
      ),
    ],
    starsRequired: 3,
  );

  /// Level 2: Shapes (Easy) - 2 categories, 4 items, hints on
  static const _shapesEasy = SortGameLevel(
    id: 'shapes_easy',
    name: 'Shapes',
    difficulty: SortDifficulty.easy,
    theme: SortTheme(
      name: 'Shapes',
      primaryColor: Color(0xFF8AD0E9),
      secondaryColor: Color(0xFFD0ABDF),
      icon: Icons.star_rounded,
      instructionText: 'Match shapes that look the same!',
    ),
    rounds: [
      SortRound(
        items: [
          SortItem(
            id: 'circle_1',
            label: 'Circle',
            icon: Icons.circle_rounded,
            categoryId: 'round',
            color: Color(0xFF8AD0E9),
          ),
          SortItem(
            id: 'square_1',
            label: 'Square',
            icon: Icons.square_rounded,
            categoryId: 'pointy',
            color: Color(0xFFD0ABDF),
          ),
          SortItem(
            id: 'triangle_1',
            label: 'Triangle',
            icon: Icons.change_history_rounded,
            categoryId: 'pointy',
            color: Color(0xFFD0ABDF),
          ),
          SortItem(
            id: 'oval_1',
            label: 'Oval',
            icon: Icons.circle_rounded,
            categoryId: 'round',
            color: Color(0xFF8AD0E9),
          ),
        ],
        categories: [
          SortCategory(
            id: 'round',
            label: 'Round',
            icon: Icons.circle_rounded,
            color: Color(0xFF8AD0E9),
          ),
          SortCategory(
            id: 'pointy',
            label: 'Pointy',
            icon: Icons.change_history_rounded,
            color: Color(0xFFD0ABDF),
          ),
        ],
        hintEnabled: true,
      ),
      SortRound(
        items: [
          SortItem(
            id: 'star_2',
            label: 'Star',
            icon: Icons.star_rounded,
            categoryId: 'pointy',
            color: Color(0xFFD0ABDF),
          ),
          SortItem(
            id: 'diamond_2',
            label: 'Diamond',
            icon: Icons.diamond_rounded,
            categoryId: 'pointy',
            color: Color(0xFFD0ABDF),
          ),
          SortItem(
            id: 'hexagon_2',
            label: 'Hexagon',
            icon: Icons.hexagon_rounded,
            categoryId: 'pointy',
            color: Color(0xFFD0ABDF),
          ),
          SortItem(
            id: 'dot_2',
            label: 'Dot',
            icon: Icons.circle_rounded,
            categoryId: 'round',
            color: Color(0xFF8AD0E9),
          ),
        ],
        categories: [
          SortCategory(
            id: 'round',
            label: 'Round',
            icon: Icons.circle_rounded,
            color: Color(0xFF8AD0E9),
          ),
          SortCategory(
            id: 'pointy',
            label: 'Pointy',
            icon: Icons.change_history_rounded,
            color: Color(0xFFD0ABDF),
          ),
        ],
        hintEnabled: true,
      ),
    ],
    starsRequired: 3,
  );

  /// Level 3: Animals (Medium) - 3 categories, 5 items, hints partial
  static const _animalsMedium = SortGameLevel(
    id: 'animals_medium',
    name: 'More Animals',
    difficulty: SortDifficulty.medium,
    theme: SortTheme(
      name: 'Animals',
      primaryColor: Color(0xFF9DE7CB),
      secondaryColor: Color(0xFFFBD38D),
      icon: Icons.pets_rounded,
      instructionText: 'Sort animals by where they live!',
    ),
    rounds: [
      SortRound(
        items: [
          SortItem(
            id: 'lion_3',
            label: 'Lion',
            icon: Icons.pets_rounded,
            categoryId: 'land',
            color: Color(0xFFFBD38D),
          ),
          SortItem(
            id: 'whale_3',
            label: 'Whale',
            icon: Icons.set_meal_rounded,
            categoryId: 'sea',
            color: Color(0xFF8FBCEC),
          ),
          SortItem(
            id: 'eagle_3',
            label: 'Eagle',
            icon: Icons.flight_rounded,
            categoryId: 'air',
            color: Color(0xFFC9E8C1),
          ),
          SortItem(
            id: 'frog_3',
            label: 'Frog',
            icon: Icons.water_drop_rounded,
            categoryId: 'land',
            color: Color(0xFFFBD38D),
          ),
          SortItem(
            id: 'dolphin_3',
            label: 'Dolphin',
            icon: Icons.emoji_nature_rounded,
            categoryId: 'sea',
            color: Color(0xFF8FBCEC),
          ),
        ],
        categories: [
          SortCategory(
            id: 'land',
            label: 'Land',
            icon: Icons.terrain_rounded,
            color: Color(0xFFFBD38D),
          ),
          SortCategory(
            id: 'sea',
            label: 'Sea',
            icon: Icons.waves_rounded,
            color: Color(0xFF8FBCEC),
          ),
          SortCategory(
            id: 'air',
            label: 'Air',
            icon: Icons.flight_rounded,
            color: Color(0xFFC9E8C1),
          ),
        ],
        hintEnabled: true,
      ),
      SortRound(
        items: [
          SortItem(
            id: 'bear_4',
            label: 'Bear',
            icon: Icons.pets_rounded,
            categoryId: 'land',
            color: Color(0xFFFBD38D),
          ),
          SortItem(
            id: 'shark_4',
            label: 'Shark',
            icon: Icons.set_meal_rounded,
            categoryId: 'sea',
            color: Color(0xFF8FBCEC),
          ),
          SortItem(
            id: 'owl_4',
            label: 'Owl',
            icon: Icons.flight_rounded,
            categoryId: 'air',
            color: Color(0xFFC9E8C1),
          ),
          SortItem(
            id: 'turtle_4',
            label: 'Turtle',
            icon: Icons.emoji_nature_rounded,
            categoryId: 'land',
            color: Color(0xFFFBD38D),
          ),
          SortItem(
            id: 'octopus_4',
            label: 'Octopus',
            icon: Icons.water_drop_rounded,
            categoryId: 'sea',
            color: Color(0xFF8FBCEC),
          ),
          SortItem(
            id: 'parrot_4',
            label: 'Parrot',
            icon: Icons.emoji_nature_rounded,
            categoryId: 'air',
            color: Color(0xFFC9E8C1),
          ),
        ],
        categories: [
          SortCategory(
            id: 'land',
            label: 'Land',
            icon: Icons.terrain_rounded,
            color: Color(0xFFFBD38D),
          ),
          SortCategory(
            id: 'sea',
            label: 'Sea',
            icon: Icons.waves_rounded,
            color: Color(0xFF8FBCEC),
          ),
          SortCategory(
            id: 'air',
            label: 'Air',
            icon: Icons.air_rounded,
            color: Color(0xFFC9E8C1),
          ),
        ],
        hintEnabled: true,
      ),
    ],
    starsRequired: 4,
  );

  /// Level 4: Food (Medium) - 3 categories, 6 items, hints partial
  static const _foodMedium = SortGameLevel(
    id: 'food_medium',
    name: 'Healthy Food',
    difficulty: SortDifficulty.medium,
    theme: SortTheme(
      name: 'Food',
      primaryColor: Color(0xFF68D391),
      secondaryColor: Color(0xFFFBD38D),
      icon: Icons.restaurant_rounded,
      instructionText: 'Sort food by type!',
    ),
    rounds: [
      SortRound(
        items: [
          SortItem(
            id: 'apple_5',
            label: 'Apple',
            icon: Icons.apple_rounded,
            categoryId: 'fruit',
            color: Color(0xFFFF8D91),
          ),
          SortItem(
            id: 'carrot_5',
            label: 'Carrot',
            icon: Icons.grass_rounded,
            categoryId: 'veggie',
            color: Color(0xFFFFF68C),
          ),
          SortItem(
            id: 'bread_5',
            label: 'Bread',
            icon: Icons.bakery_dining_rounded,
            categoryId: 'grain',
            color: Color(0xFFFFDAC7),
          ),
          SortItem(
            id: 'banana_5',
            label: 'Banana',
            icon: Icons.emoji_food_beverage_rounded,
            categoryId: 'fruit',
            color: Color(0xFFFFF68C),
          ),
          SortItem(
            id: 'broccoli_5',
            label: 'Broccoli',
            icon: Icons.grass_rounded,
            categoryId: 'veggie',
            color: Color(0xFF68D391),
          ),
          SortItem(
            id: 'rice_5',
            label: 'Rice',
            icon: Icons.rice_bowl_rounded,
            categoryId: 'grain',
            color: Color(0xFFFFDAC7),
          ),
        ],
        categories: [
          SortCategory(
            id: 'fruit',
            label: 'Fruit',
            icon: Icons.apple_rounded,
            color: Color(0xFFFF8D91),
          ),
          SortCategory(
            id: 'veggie',
            label: 'Veggie',
            icon: Icons.grass_rounded,
            color: Color(0xFF68D391),
          ),
          SortCategory(
            id: 'grain',
            label: 'Grain',
            icon: Icons.rice_bowl_rounded,
            color: Color(0xFFFFDAC7),
          ),
        ],
        hintEnabled: true,
      ),
      SortRound(
        items: [
          SortItem(
            id: 'orange_6',
            label: 'Orange',
            icon: Icons.apple_rounded,
            categoryId: 'fruit',
            color: Color(0xFFFFF68C),
          ),
          SortItem(
            id: 'potato_6',
            label: 'Potato',
            icon: Icons.grass_rounded,
            categoryId: 'veggie',
            color: Color(0xFFFFDAC7),
          ),
          SortItem(
            id: 'pasta_6',
            label: 'Pasta',
            icon: Icons.rice_bowl_rounded,
            categoryId: 'grain',
            color: Color(0xFFFFF68C),
          ),
          SortItem(
            id: 'grape_6',
            label: 'Grape',
            icon: Icons.emoji_food_beverage_rounded,
            categoryId: 'fruit',
            color: Color(0xFFDDD0F4),
          ),
          SortItem(
            id: 'corn_6',
            label: 'Corn',
            icon: Icons.grass_rounded,
            categoryId: 'veggie',
            color: Color(0xFFFFF68C),
          ),
          SortItem(
            id: 'oat_6',
            label: 'Oats',
            icon: Icons.rice_bowl_rounded,
            categoryId: 'grain',
            color: Color(0xFFFFDAC7),
          ),
        ],
        categories: [
          SortCategory(
            id: 'fruit',
            label: 'Fruit',
            icon: Icons.apple_rounded,
            color: Color(0xFFFF8D91),
          ),
          SortCategory(
            id: 'veggie',
            label: 'Veggie',
            icon: Icons.grass_rounded,
            color: Color(0xFF68D391),
          ),
          SortCategory(
            id: 'grain',
            label: 'Grain',
            icon: Icons.rice_bowl_rounded,
            color: Color(0xFFFFDAC7),
          ),
        ],
        hintEnabled: false,
      ),
    ],
    starsRequired: 4,
  );

  /// Level 5: Emotions (Hard) - 4 categories, 6 items, hints off
  static const _emotionsHard = SortGameLevel(
    id: 'emotions_hard',
    name: 'Feelings',
    difficulty: SortDifficulty.hard,
    theme: SortTheme(
      name: 'Emotions',
      primaryColor: Color(0xFFF1B4D3),
      secondaryColor: Color(0xFFD0ABDF),
      icon: Icons.emoji_emotions_rounded,
      instructionText: 'Sort the feelings!',
    ),
    rounds: [
      SortRound(
        items: [
          SortItem(
            id: 'happy_7',
            label: 'Happy',
            icon: Icons.sentiment_very_satisfied_rounded,
            categoryId: 'good',
            color: Color(0xFFFFF68C),
          ),
          SortItem(
            id: 'sad_7',
            label: 'Sad',
            icon: Icons.sentiment_dissatisfied_rounded,
            categoryId: 'bad',
            color: Color(0xFF8FBCEC),
          ),
          SortItem(
            id: 'angry_7',
            label: 'Angry',
            icon: Icons.sentiment_very_dissatisfied_rounded,
            categoryId: 'bad',
            color: Color(0xFFFF8D91),
          ),
          SortItem(
            id: 'calm_7',
            label: 'Calm',
            icon: Icons.sentiment_satisfied_rounded,
            categoryId: 'good',
            color: Color(0xFF9DE7CB),
          ),
          SortItem(
            id: 'surprised_7',
            label: 'Surprised',
            icon: Icons.sentiment_satisfied_rounded,
            categoryId: 'neutral',
            color: Color(0xFFF1B4D3),
          ),
          SortItem(
            id: 'scared_7',
            label: 'Scared',
            icon: Icons.sentiment_very_dissatisfied_rounded,
            categoryId: 'bad',
            color: Color(0xFFD0ABDF),
          ),
        ],
        categories: [
          SortCategory(
            id: 'good',
            label: 'Good',
            icon: Icons.thumb_up_rounded,
            color: Color(0xFF9DE7CB),
          ),
          SortCategory(
            id: 'bad',
            label: 'Bad',
            icon: Icons.thumb_down_rounded,
            color: Color(0xFFFF8D91),
          ),
          SortCategory(
            id: 'neutral',
            label: 'Neutral',
            icon: Icons.sentiment_neutral_rounded,
            color: Color(0xFFF1B4D3),
          ),
        ],
        hintEnabled: false,
      ),
      SortRound(
        items: [
          SortItem(
            id: 'proud_8',
            label: 'Proud',
            icon: Icons.emoji_events_rounded,
            categoryId: 'good',
            color: Color(0xFFFBD38D),
          ),
          SortItem(
            id: 'worried_8',
            label: 'Worried',
            icon: Icons.sentiment_very_dissatisfied_rounded,
            categoryId: 'bad',
            color: Color(0xFF8FBCEC),
          ),
          SortItem(
            id: 'excited_8',
            label: 'Excited',
            icon: Icons.celebration_rounded,
            categoryId: 'good',
            color: Color(0xFFFFF68C),
          ),
          SortItem(
            id: 'bored_8',
            label: 'Bored',
            icon: Icons.sentiment_neutral_rounded,
            categoryId: 'neutral',
            color: Color(0xFFCBD5E0),
          ),
          SortItem(
            id: 'confused_8',
            label: 'Confused',
            icon: Icons.psychology_rounded,
            categoryId: 'neutral',
            color: Color(0xFFD0ABDF),
          ),
          SortItem(
            id: 'lonely_8',
            label: 'Lonely',
            icon: Icons.sentiment_dissatisfied_rounded,
            categoryId: 'bad',
            color: Color(0xFF8FBCEC),
          ),
        ],
        categories: [
          SortCategory(
            id: 'good',
            label: 'Good',
            icon: Icons.thumb_up_rounded,
            color: Color(0xFF9DE7CB),
          ),
          SortCategory(
            id: 'bad',
            label: 'Bad',
            icon: Icons.thumb_down_rounded,
            color: Color(0xFFFF8D91),
          ),
          SortCategory(
            id: 'neutral',
            label: 'Neutral',
            icon: Icons.sentiment_neutral_rounded,
            color: Color(0xFFF1B4D3),
          ),
        ],
        hintEnabled: false,
      ),
    ],
    starsRequired: 5,
  );

  /// Level 6: Daily Objects (Hard) - 4 categories, 8 items, distractors
  static const _dailyObjectsHard = SortGameLevel(
    id: 'daily_hard',
    name: 'Daily Things',
    difficulty: SortDifficulty.hard,
    theme: SortTheme(
      name: 'Daily Objects',
      primaryColor: Color(0xFF8AD0E9),
      secondaryColor: Color(0xFFF1B4D3),
      icon: Icons.category_rounded,
      instructionText: 'Sort things by where they belong!',
    ),
    rounds: [
      SortRound(
        items: [
          SortItem(
            id: 'book_9',
            label: 'Book',
            icon: Icons.menu_book_rounded,
            categoryId: 'school',
            color: Color(0xFF8FBCEC),
          ),
          SortItem(
            id: 'spoon_9',
            label: 'Spoon',
            icon: Icons.soup_kitchen_rounded,
            categoryId: 'kitchen',
            color: Color(0xFFFFDAC7),
          ),
          SortItem(
            id: 'pencil_9',
            label: 'Pencil',
            icon: Icons.edit_rounded,
            categoryId: 'school',
            color: Color(0xFFFFF68C),
          ),
          SortItem(
            id: 'plate_9',
            label: 'Plate',
            icon: Icons.dinner_dining_rounded,
            categoryId: 'kitchen',
            color: Color(0xFFC7EBF8),
          ),
          SortItem(
            id: 'ball_9',
            label: 'Ball',
            icon: Icons.sports_soccer_rounded,
            categoryId: 'play',
            color: Color(0xFF9DE7CB),
          ),
          SortItem(
            id: 'soap_9',
            label: 'Soap',
            icon: Icons.soap_rounded,
            categoryId: 'bathroom',
            color: Color(0xFFD0ABDF),
          ),
          SortItem(
            id: 'toy_9',
            label: 'Toy',
            icon: Icons.toys_rounded,
            categoryId: 'play',
            color: Color(0xFFF1B4D3),
          ),
          SortItem(
            id: 'towel_9',
            label: 'Towel',
            icon: Icons.bathroom_rounded,
            categoryId: 'bathroom',
            color: Color(0xFFC7EBF8),
          ),
        ],
        categories: [
          SortCategory(
            id: 'school',
            label: 'School',
            icon: Icons.school_rounded,
            color: Color(0xFF8FBCEC),
          ),
          SortCategory(
            id: 'kitchen',
            label: 'Kitchen',
            icon: Icons.kitchen_rounded,
            color: Color(0xFFFFDAC7),
          ),
          SortCategory(
            id: 'play',
            label: 'Play',
            icon: Icons.sports_esports_rounded,
            color: Color(0xFF9DE7CB),
          ),
          SortCategory(
            id: 'bathroom',
            label: 'Bathroom',
            icon: Icons.bathroom_rounded,
            color: Color(0xFFD0ABDF),
          ),
        ],
        hintEnabled: false,
        distractorCount: 2,
      ),
      SortRound(
        items: [
          SortItem(
            id: 'ruler_10',
            label: 'Ruler',
            icon: Icons.straighten_rounded,
            categoryId: 'school',
            color: Color(0xFFFFF68C),
          ),
          SortItem(
            id: 'fork_10',
            label: 'Fork',
            icon: Icons.restaurant_rounded,
            categoryId: 'kitchen',
            color: Color(0xFFCBD5E0),
          ),
          SortItem(
            id: 'doll_10',
            label: 'Doll',
            icon: Icons.toys_rounded,
            categoryId: 'play',
            color: Color(0xFFF1B4D3),
          ),
          SortItem(
            id: 'brush_10',
            label: 'Brush',
            icon: Icons.brush_rounded,
            categoryId: 'bathroom',
            color: Color(0xFF8FBCEC),
          ),
          SortItem(
            id: 'bag_10',
            label: 'Bag',
            icon: Icons.backpack_rounded,
            categoryId: 'school',
            color: Color(0xFF9DE7CB),
          ),
          SortItem(
            id: 'cup_10',
            label: 'Cup',
            icon: Icons.local_drink_rounded,
            categoryId: 'kitchen',
            color: Color(0xFFC7EBF8),
          ),
          SortItem(
            id: 'blocks_10',
            label: 'Blocks',
            icon: Icons.extension_rounded,
            categoryId: 'play',
            color: Color(0xFFFFDAC7),
          ),
          SortItem(
            id: 'comb_10',
            label: 'Comb',
            icon: Icons.content_cut_rounded,
            categoryId: 'bathroom',
            color: Color(0xFFD0ABDF),
          ),
        ],
        categories: [
          SortCategory(
            id: 'school',
            label: 'School',
            icon: Icons.school_rounded,
            color: Color(0xFF8FBCEC),
          ),
          SortCategory(
            id: 'kitchen',
            label: 'Kitchen',
            icon: Icons.kitchen_rounded,
            color: Color(0xFFFFDAC7),
          ),
          SortCategory(
            id: 'play',
            label: 'Play',
            icon: Icons.sports_esports_rounded,
            color: Color(0xFF9DE7CB),
          ),
          SortCategory(
            id: 'bathroom',
            label: 'Bathroom',
            icon: Icons.bathroom_rounded,
            color: Color(0xFFD0ABDF),
          ),
        ],
        hintEnabled: false,
        distractorCount: 2,
      ),
    ],
    starsRequired: 5,
  );
}
