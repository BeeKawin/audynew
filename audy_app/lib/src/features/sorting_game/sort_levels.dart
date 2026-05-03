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
            icon: 'assets/images/sorting/cat.png',
            categoryId: 'land',
            color: Color(0xFFFFDAC7),
          ),
          SortItem(
            id: 'fish_1',
            label: 'Fish',
            icon: 'assets/images/sorting/fish.png',
            categoryId: 'water',
            color: Color(0xFF8FBCEC),
          ),
          SortItem(
            id: 'bird_1',
            label: 'Bird',
            icon: 'assets/images/sorting/bird.png',
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
            icon: 'assets/images/sorting/dog.png',
            categoryId: 'land',
            color: Color(0xFFFFDAC7),
          ),
          SortItem(
            id: 'duck_2',
            label: 'Duck',
            icon: 'assets/images/sorting/duck.png',
            categoryId: 'water',
            color: Color(0xFF8FBCEC),
          ),
          SortItem(
            id: 'butterfly_2',
            label: 'Butterfly',
            icon: 'assets/images/sorting/butterfly.png',
            categoryId: 'sky',
            color: Color(0xFFF8C7DF),
          ),
          SortItem(
            id: 'rabbit_2',
            label: 'Rabbit',
            icon: 'assets/images/sorting/rabbit.png',
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
    starsRequired: 5,
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
            icon: 'assets/images/sorting/circle.png',
            categoryId: 'round',
            color: Color(0xFF8AD0E9),
          ),
          SortItem(
            id: 'square_1',
            label: 'Square',
            icon: 'assets/images/sorting/square.png',
            categoryId: 'pointy',
            color: Color(0xFFD0ABDF),
          ),
          SortItem(
            id: 'triangle_1',
            label: 'Triangle',
            icon: 'assets/images/sorting/triangle.png',
            categoryId: 'pointy',
            color: Color(0xFFD0ABDF),
          ),
          SortItem(
            id: 'oval_1',
            label: 'Oval',
            icon: 'assets/images/sorting/oval.png',
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
            icon: 'assets/images/sorting/star.png',
            categoryId: 'pointy',
            color: Color(0xFFD0ABDF),
          ),
          SortItem(
            id: 'diamond_2',
            label: 'Diamond',
            icon: 'assets/images/sorting/diamond.png',
            categoryId: 'pointy',
            color: Color(0xFFD0ABDF),
          ),
          SortItem(
            id: 'hexagon_2',
            label: 'Hexagon',
            icon: 'assets/images/sorting/hexagon.png',
            categoryId: 'pointy',
            color: Color(0xFFD0ABDF),
          ),
          SortItem(
            id: 'dot_2',
            label: 'Dot',
            icon: 'assets/images/sorting/dot.png',
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
    starsRequired: 6,
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
            icon: 'assets/images/sorting/lion.png',
            categoryId: 'land',
            color: Color(0xFFFBD38D),
          ),
          SortItem(
            id: 'whale_3',
            label: 'Whale',
            icon: 'assets/images/sorting/whale.png',
            categoryId: 'sea',
            color: Color(0xFF8FBCEC),
          ),
          SortItem(
            id: 'eagle_3',
            label: 'Eagle',
            icon: 'assets/images/sorting/eagle.png',
            categoryId: 'air',
            color: Color(0xFFC9E8C1),
          ),
          SortItem(
            id: 'frog_3',
            label: 'Frog',
            icon: 'assets/images/sorting/frog.png',
            categoryId: 'land',
            color: Color(0xFFFBD38D),
          ),
          SortItem(
            id: 'dolphin_3',
            label: 'Dolphin',
            icon: 'assets/images/sorting/dolphin.png',
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
            icon: 'assets/images/sorting/bear.png',
            categoryId: 'land',
            color: Color(0xFFFBD38D),
          ),
          SortItem(
            id: 'shark_4',
            label: 'Shark',
            icon: 'assets/images/sorting/shark.png',
            categoryId: 'sea',
            color: Color(0xFF8FBCEC),
          ),
          SortItem(
            id: 'owl_4',
            label: 'Owl',
            icon: 'assets/images/sorting/owl.png',
            categoryId: 'air',
            color: Color(0xFFC9E8C1),
          ),
          SortItem(
            id: 'turtle_4',
            label: 'Turtle',
            icon: 'assets/images/sorting/turtle.png',
            categoryId: 'land',
            color: Color(0xFFFBD38D),
          ),
          SortItem(
            id: 'octopus_4',
            label: 'Octopus',
            icon: 'assets/images/sorting/octopus.png',
            categoryId: 'sea',
            color: Color(0xFF8FBCEC),
          ),
          SortItem(
            id: 'parrot_4',
            label: 'Parrot',
            icon: 'assets/images/sorting/parrot.png',
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
    starsRequired: 8,
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
            icon: 'assets/images/sorting/apple.png',
            categoryId: 'fruit',
            color: Color(0xFFFF8D91),
          ),
          SortItem(
            id: 'carrot_5',
            label: 'Carrot',
            icon: 'assets/images/sorting/carrot.png',
            categoryId: 'veggie',
            color: Color(0xFFFFF68C),
          ),
          SortItem(
            id: 'bread_5',
            label: 'Bread',
            icon: 'assets/images/sorting/bread.png',
            categoryId: 'grain',
            color: Color(0xFFFFDAC7),
          ),
          SortItem(
            id: 'banana_5',
            label: 'Banana',
            icon: 'assets/images/sorting/banana.png',
            categoryId: 'fruit',
            color: Color(0xFFFFF68C),
          ),
          SortItem(
            id: 'broccoli_5',
            label: 'Broccoli',
            icon: 'assets/images/sorting/broccoli.png',
            categoryId: 'veggie',
            color: Color(0xFF68D391),
          ),
          SortItem(
            id: 'rice_5',
            label: 'Rice',
            icon: 'assets/images/sorting/rice.png',
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
            icon: 'assets/images/sorting/orange.png',
            categoryId: 'fruit',
            color: Color(0xFFFFF68C),
          ),
          SortItem(
            id: 'potato_6',
            label: 'Potato',
            icon: 'assets/images/sorting/potato.png',
            categoryId: 'veggie',
            color: Color(0xFFFFDAC7),
          ),
          SortItem(
            id: 'pasta_6',
            label: 'Pasta',
            icon: 'assets/images/sorting/pasta.png',
            categoryId: 'grain',
            color: Color(0xFFFFF68C),
          ),
          SortItem(
            id: 'grape_6',
            label: 'Grape',
            icon: 'assets/images/sorting/grape.png',
            categoryId: 'fruit',
            color: Color(0xFFDDD0F4),
          ),
          SortItem(
            id: 'corn_6',
            label: 'Corn',
            icon: 'assets/images/sorting/corn.png',
            categoryId: 'veggie',
            color: Color(0xFFFFF68C),
          ),
          SortItem(
            id: 'oat_6',
            label: 'Oats',
            icon: 'assets/images/sorting/oat.png',
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
    starsRequired: 9,
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
            icon: 'assets/images/sorting/happy.png',
            categoryId: 'good',
            color: Color(0xFFFFF68C),
          ),
          SortItem(
            id: 'sad_7',
            label: 'Sad',
            icon: 'assets/images/sorting/sad.png',
            categoryId: 'bad',
            color: Color(0xFF8FBCEC),
          ),
          SortItem(
            id: 'angry_7',
            label: 'Angry',
            icon: 'assets/images/sorting/angry.png',
            categoryId: 'bad',
            color: Color(0xFFFF8D91),
          ),
          SortItem(
            id: 'calm_7',
            label: 'Calm',
            icon: 'assets/images/sorting/calm.png',
            categoryId: 'good',
            color: Color(0xFF9DE7CB),
          ),
          SortItem(
            id: 'surprised_7',
            label: 'Surprised',
            icon: 'assets/images/sorting/surprised.png',
            categoryId: 'neutral',
            color: Color(0xFFF1B4D3),
          ),
          SortItem(
            id: 'scared_7',
            label: 'Scared',
            icon: 'assets/images/sorting/scared.png',
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
            icon: 'assets/images/sorting/proud.png',
            categoryId: 'good',
            color: Color(0xFFFBD38D),
          ),
          SortItem(
            id: 'worried_8',
            label: 'Worried',
            icon: 'assets/images/sorting/worried.png',
            categoryId: 'bad',
            color: Color(0xFF8FBCEC),
          ),
          SortItem(
            id: 'excited_8',
            label: 'Excited',
            icon: 'assets/images/sorting/excited.png',
            categoryId: 'good',
            color: Color(0xFFFFF68C),
          ),
          SortItem(
            id: 'bored_8',
            label: 'Bored',
            icon: 'assets/images/sorting/bored.png',
            categoryId: 'neutral',
            color: Color(0xFFCBD5E0),
          ),
          SortItem(
            id: 'confused_8',
            label: 'Confused',
            icon: 'assets/images/sorting/confused.png',
            categoryId: 'neutral',
            color: Color(0xFFD0ABDF),
          ),
          SortItem(
            id: 'lonely_8',
            label: 'Lonely',
            icon: 'assets/images/sorting/lonely.png',
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
    starsRequired: 9,
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
            icon: 'assets/images/sorting/book.png',
            categoryId: 'school',
            color: Color(0xFF8FBCEC),
          ),
          SortItem(
            id: 'spoon_9',
            label: 'Spoon',
            icon: 'assets/images/sorting/spoon.png',
            categoryId: 'kitchen',
            color: Color(0xFFFFDAC7),
          ),
          SortItem(
            id: 'pencil_9',
            label: 'Pencil',
            icon: 'assets/images/sorting/pencil.png',
            categoryId: 'school',
            color: Color(0xFFFFF68C),
          ),
          SortItem(
            id: 'plate_9',
            label: 'Plate',
            icon: 'assets/images/sorting/plate.png',
            categoryId: 'kitchen',
            color: Color(0xFFC7EBF8),
          ),
          SortItem(
            id: 'ball_9',
            label: 'Ball',
            icon: 'assets/images/sorting/ball.png',
            categoryId: 'play',
            color: Color(0xFF9DE7CB),
          ),
          SortItem(
            id: 'soap_9',
            label: 'Soap',
            icon: 'assets/images/sorting/soap.png',
            categoryId: 'bathroom',
            color: Color(0xFFD0ABDF),
          ),
          SortItem(
            id: 'toy_9',
            label: 'Toy',
            icon: 'assets/images/sorting/toy.png',
            categoryId: 'play',
            color: Color(0xFFF1B4D3),
          ),
          SortItem(
            id: 'towel_9',
            label: 'Towel',
            icon: 'assets/images/sorting/towel.png',
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
            icon: 'assets/images/sorting/ruler.png',
            categoryId: 'school',
            color: Color(0xFFFFF68C),
          ),
          SortItem(
            id: 'fork_10',
            label: 'Fork',
            icon: 'assets/images/sorting/fork.png',
            categoryId: 'kitchen',
            color: Color(0xFFCBD5E0),
          ),
          SortItem(
            id: 'doll_10',
            label: 'Doll',
            icon: 'assets/images/sorting/doll.png',
            categoryId: 'play',
            color: Color(0xFFF1B4D3),
          ),
          SortItem(
            id: 'brush_10',
            label: 'Brush',
            icon: 'assets/images/sorting/brush.png',
            categoryId: 'bathroom',
            color: Color(0xFF8FBCEC),
          ),
          SortItem(
            id: 'bag_10',
            label: 'Bag',
            icon: 'assets/images/sorting/bag.png',
            categoryId: 'school',
            color: Color(0xFF9DE7CB),
          ),
          SortItem(
            id: 'cup_10',
            label: 'Cup',
            icon: 'assets/images/sorting/cup.png',
            categoryId: 'kitchen',
            color: Color(0xFFC7EBF8),
          ),
          SortItem(
            id: 'blocks_10',
            label: 'Blocks',
            icon: 'assets/images/sorting/blocks.png',
            categoryId: 'play',
            color: Color(0xFFFFDAC7),
          ),
          SortItem(
            id: 'comb_10',
            label: 'Comb',
            icon: 'assets/images/sorting/comb.png',
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
    starsRequired: 12,
  );
}
