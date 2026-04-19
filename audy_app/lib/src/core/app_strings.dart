/// Localization strings for AUDY app
/// Supports English (en) and Thai (th)
class AppStrings {
  /// Get localized string by key and language code
  static String get(String key, String lang) {
    final strings = _data[key];
    return strings?[lang] ?? strings?['en'] ?? key;
  }

  static const Map<String, Map<String, String>> _data = {
    // Dashboard
    'dashboard_greeting': {
      'en': 'Hi! What shall we learn?',
      'th': 'สวัสดี! จะเรียนรู้อะไรดี?',
    },
    'activities': {'en': 'Activities', 'th': 'กิจกรรม'},
    'games': {'en': 'Games', 'th': 'เกม'},
    'read_speak': {'en': 'Read & Speak', 'th': 'อ่านและพูด'},
    'social_chat': {'en': 'Social Chat', 'th': 'คุยแชท'},
    'rewards': {'en': 'Rewards', 'th': 'รางวัล'},
    'daily_quests': {'en': 'Daily Quests', 'th': 'ภารกิจประจำวัน'},
    'bonus': {'en': 'Bonus!', 'th': 'โบนัส!'},

    // Navigation
    'home': {'en': 'Home', 'th': 'หน้าหลัก'},
    'profile': {'en': 'Profile', 'th': 'โปรไฟล์'},
    'back_home': {'en': 'Back to Home', 'th': 'กลับหน้าหลัก'},

    // Games Hub
    'emotion_classify': {
      'en': 'What is this emotion?',
      'th': 'นี่คืออารมณ์อะไร?',
    },
    'emotion_mimic': {'en': 'Make this emotion!', 'th': 'ทำหน้าให้ถูก!'},
    'mini_puzzle': {'en': 'MiniPuzzle', 'th': 'แก้ปัญหาฝึกสมอง!'},
    'sorting_game': {'en': 'Sorting Game', 'th': 'จำแนกสิ่งของ!'},
    'reaction_time': {'en': 'Reaction Time', 'th': 'กดให้เร็วที่สุด!'},
    'play_and_learn': {
      'en': 'Play and learn with fun activities!',
      'th': 'เล่นและเรียนรู้ด้วยกิจกรรมสนุก!',
    },

    // Reaction Game
    'tap_to_start': {'en': 'Tap to start', 'th': 'แตะเพื่อเริ่ม'},
    'wait': {'en': 'Wait...', 'th': 'รอสักครู่...'},
    'tap_now': {'en': 'Tap now!', 'th': 'แตะเลย!'},
    'too_early': {'en': 'Too early!', 'th': 'เร็วเกินไป!'},
    'tap_when_green': {
      'en': 'Tap the container when it turns green.',
      'th': 'แตะที่จอเมื่อเป็นสีเขียว',
    },
    'average': {'en': 'Average', 'th': 'เฉลี่ย'},
    'round_times': {'en': 'Round Times', 'th': 'เวลาแต่ละรอบ'},
    'round': {'en': 'Round', 'th': 'รอบ'},
    'too_early_taps': {'en': 'Too early taps:', 'th': 'แตะเร็วเกินไป:'},
    'play_again': {'en': 'Play Again', 'th': 'เล่นอีกครั้ง'},
    'done': {'en': 'Done', 'th': 'เสร็จสิ้น'},
    'great_job_rounds': {
      'en': 'Great job completing all rounds!',
      'th': 'เก่งมาก! ทำครบทุกรอบแล้ว!',
    },
    'round_format': {
      'en': 'Round: {current} / {total}',
      'th': 'รอบ: {current} / {total}',
    },
    'items_left': {'en': '{count} left', 'th': 'เหลือ {count}'},

    // Sorting Game Feedback Messages
    'feedback_great_job': {'en': 'Great job! 🌟', 'th': 'เก่งมาก! 🌟'},
    'feedback_well_done': {'en': 'Well done!', 'th': 'ทำได้ดี!'},
    'feedback_you_did_it': {'en': 'You did it!', 'th': 'คุณทำได้!'},
    'feedback_amazing': {'en': 'Amazing!', 'th': 'สุดยอด!'},
    'feedback_perfect': {'en': 'Perfect!', 'th': 'สมบูรณ์แบบ!'},
    'feedback_fantastic': {'en': 'Fantastic!', 'th': 'ยอดเยี่ยม!'},
    'feedback_smart': {'en': 'You are so smart!', 'th': 'คุณฉลาดมาก!'},
    'feedback_keep_going': {'en': 'Keep going!', 'th': 'ทำต่อไป!'},
    'feedback_try_again': {'en': 'Let\'s try again!', 'th': 'ลองอีกครั้ง!'},
    'feedback_almost': {
      'en': 'Almost! Look carefully.',
      'th': 'เกือบแล้ว! ดูให้ดีๆ',
    },
    'feedback_not_quite': {
      'en': 'Not quite. Try the right one!',
      'th': 'ยังไม่ถูก ลองอีกครั้ง!',
    },
    'feedback_oops': {
      'en': 'Oops! Check the matching one.',
      'th': 'อุ๊ปส์! เช็คให้ตรงกัน',
    },
    'feedback_good_try': {
      'en': 'Good try! Try again.',
      'th': 'พยายามดี! ลองอีกครั้ง',
    },
    'feedback_round_complete': {
      'en': 'Round complete! 🎉',
      'th': 'จบรอบแล้ว! 🎉',
    },
    'feedback_round_finished': {
      'en': 'You finished the round!',
      'th': 'คุณจบรอบแล้ว!',
    },
    'feedback_wonderful_work': {'en': 'Wonderful work!', 'th': 'งานยอดเยี่ยม!'},
    'feedback_level_complete': {
      'en': 'Level complete! You are a star! ⭐',
      'th': 'จบระดับแล้ว! คุณเป็นดาว! ⭐',
    },
    'feedback_amazing_work': {
      'en': 'Amazing work! All done!',
      'th': 'งานยอดเยี่ยม! เสร็จหมดแล้ว!',
    },
    'feedback_you_did_it_great': {
      'en': 'You did it! Great job!',
      'th': 'คุณทำได้! เก่งมาก!',
    },
    'rounds_format': {'en': '{count} rounds', 'th': '{count} รอบ'},
    'round_complete': {
      'en': 'Round {round} Complete',
      'th': 'รอบที่ {round} เสร็จสิ้น',
    },
    'correct_count': {'en': 'Correct: {correct}', 'th': 'ถูกต้อง: {correct}'},
    'try_again_count': {'en': 'Try again: {count}', 'th': 'ลองใหม่: {count}'},
    'see_results': {'en': 'See Results', 'th': 'ดูผลลัพธ์'},
    'next_round': {'en': 'Next Round', 'th': 'รอบถัดไป'},
    'level_complete': {'en': '{level} Complete', 'th': '{level} เสร็จสิ้น'},
    'your_score': {'en': 'Your Score', 'th': 'คะแนนของคุณ'},
    'stars_format': {
      'en': '{earned} / {max} stars',
      'th': '{earned} / {max} ดาว',
    },
    'summary': {'en': 'Summary', 'th': 'สรุป'},
    'accuracy': {'en': 'Accuracy', 'th': 'ความแม่นยำ'},
    'correct': {'en': 'Correct', 'th': 'ถูกต้อง'},
    'try_again': {'en': 'Try Again', 'th': 'ลองใหม่'},
    'hints_used': {'en': 'Hints Used', 'th': 'ใช้คำใบ้'},
    'round_breakdown': {'en': 'Round Breakdown', 'th': 'รายละเอียดแต่ละรอบ'},
    'insight_harder_levels': {
      'en': 'You are ready for harder levels!',
      'th': 'คุณพร้อมสำหรับระดับที่ยากขึ้นแล้ว!',
    },
    'insight_good_progress': {
      'en': 'Good progress! Keep practicing!',
      'th': 'ก้าวหน้าดี! ฝึกฝนต่อไป!',
    },
    'insight_easier_levels': {
      'en': 'Try the easier levels to build confidence!',
      'th': 'ลองระดับที่ง่ายกว่าเพื่อสร้างความมั่นใจ!',
    },

    // Sorting Game
    'tap_piece_then_basket': {
      'en': 'Tap a piece, then tap the matching basket.',
      'th': 'แตะชิ้นงาน แล้วแตะตะกร้าที่ตรงกัน',
    },
    'correct_exclamation': {'en': 'Correct!', 'th': 'ถูกต้อง!'},
    'try_again_period': {'en': 'Try again.', 'th': 'ลองใหม่'},
    'round_1_color': {
      'en': 'Round 1: Sort by color',
      'th': 'รอบที่ 1: จัดเรียงตามสี',
    },
    'round_2_shape': {
      'en': 'Round 2: Color & shape',
      'th': 'รอบที่ 2: สีและรูปทรง',
    },
    'round_3_distractors': {
      'en': 'Round 3: Watch for fakes!',
      'th': 'รอบที่ 3: ระวังของปลอม!',
    },
    'select_level': {'en': 'Select Level', 'th': 'เลือกระดับ'},
    'choose_challenge': {
      'en': 'Choose your challenge!',
      'th': 'เลือกความท้าทายของคุณ!',
    },
    'time': {'en': 'Time', 'th': 'เวลา'},
    'stars': {'en': 'Stars', 'th': 'ดาว'},
    'perfect_score': {'en': 'Perfect Score!', 'th': 'คะแนนเต็ม!'},
    'you_completed': {
      'en': 'You completed all rounds!',
      'th': 'คุณทำครบทุกรอบแล้ว!',
    },
    'back_to_levels': {'en': 'Back to Levels', 'th': 'กลับไปเลือกระดับ'},
    'good_job': {'en': 'Good job!', 'th': 'เก่งมาก!'},
    'you_sorted': {
      'en': 'You sorted all the items!',
      'th': 'คุณจัดเรียงทุกอย่างเสร็จแล้ว!',
    },

    // Emotion Game
    'what_emotion': {'en': 'What is this emotion?', 'th': 'นี่คืออารมณ์อะไร?'},
    'make_this_face': {'en': 'Make this face', 'th': 'ทำหน้าแบบนี้'},
    'take_photo': {'en': 'Take Photo', 'th': 'ถ่ายรูป'},
    'score_format': {'en': 'Score: {score}', 'th': 'คะแนน: {score}'},
    'wonderful': {'en': 'Wonderful!', 'th': 'ยอดเยี่ยม!'},
    'emotion_practice_complete': {
      'en': 'Emotion practice complete!',
      'th': 'ฝึกอารมณ์เสร็จแล้ว!',
    },
    'choose_matching': {
      'en': 'Choose the matching emotion.',
      'th': 'เลือกอารมณ์ที่ตรงกัน',
    },

    // Emotions
    'happy': {'en': 'Happy', 'th': 'มีความสุข'},
    'sad': {'en': 'Sad', 'th': 'เศร้า'},
    'angry': {'en': 'Angry', 'th': 'โกรธ'},
    'surprised': {'en': 'Surprised', 'th': 'ประหลาดใจ'},
    'scared': {'en': 'Scared', 'th': 'กลัว'},
    'calm': {'en': 'Calm', 'th': 'สงบ'},
    'proud': {'en': 'Proud', 'th': 'ภาคภูมิใจ'},

    // Chat
    'chat_with_auday': {'en': 'Chat with AUDY', 'th': 'คุยกับเพื่อน AUDY'},
    'type_message': {'en': 'Type your message...', 'th': 'พิมพ์ข้อความ...'},
    'thinking': {'en': 'Thinking...', 'th': 'กำลังคิด...'},
    'social_practice': {'en': 'Social Practice', 'th': 'ฝึกสังคม'},

    // Reading & Pronunciation
    'letters_practice': {'en': 'Letters Practice', 'th': 'ฝึกตัวอักษร'},
    'words_practice': {'en': 'Words Practice', 'th': 'ฝึกคำศัพท์'},
    'sentences_practice': {'en': 'Sentences Practice', 'th': 'ฝึกประโยค'},
    'listen_repeat': {
      'en': 'Listen, repeat, and build confidence one sound at a time.',
      'th': 'ฟัง พูดตาม และสร้างความมั่นใจทีละเสียง',
    },
    'simple_words': {
      'en': 'Simple familiar words with listening and speaking practice.',
      'th': 'คำง่ายๆ ที่คุ้นเคย พร้อมฝึกฟังและพูด',
    },
    'short_sentences': {
      'en': 'Say short sentences clearly and at a relaxed pace.',
      'th': 'พูดประโยคสั้นๆ ให้ชัดเจนและใจเย็น',
    },
    'reading_hub': {'en': 'Read & Speak', 'th': 'อ่านและพูด'},
    'improve_pronunciation': {
      'en': 'Improve your pronunciation with guided practice.',
      'th': 'พัฒนาการออกเสียงด้วยการฝึกแบบแนะนำ',
    },

    // Profile
    'your_progress': {'en': 'Your Progress', 'th': 'ความก้าวหน้าของคุณ'},
    'learning_points': {'en': 'Learning Points', 'th': 'คะแนนการเรียนรู้'},
    'games_played': {'en': 'Games Played', 'th': 'เกมที่เล่น'},
    'day_streak': {'en': 'Day Streak', 'th': 'วันต่อเนื่อง'},
    'achievements': {'en': 'Achievements', 'th': 'ความสำเร็จ'},
    'completed': {'en': 'completed', 'th': 'สำเร็จแล้ว'},
    'locked': {'en': 'Locked', 'th': 'ล็อก'},
    'reset_progress': {'en': 'Reset Progress', 'th': 'รีเซ็ตความก้าวหน้า'},

    // Rewards
    'your_rewards': {'en': 'Your Rewards', 'th': 'รางวัลของคุณ'},
    'collect_accessories': {
      'en': 'Collect accessories and customize your profile!',
      'th': 'สะสมอุปกรณ์ตกแต่งและปรับแต่งโปรไฟล์ของคุณ!',
    },
    'accessories': {'en': 'Accessories', 'th': 'อุปกรณ์ตกแต่ง'},
    'available': {'en': 'Available', 'th': 'ที่มีอยู่'},
    'owned': {'en': 'Owned', 'th': 'ที่มีแล้ว'},
    'points_needed': {
      'en': 'Need {points} more points',
      'th': 'ต้องการอีก {points} คะแนน',
    },
    'unlock': {'en': 'Unlock', 'th': 'ปลดล็อก'},

    // Common
    'continue': {'en': 'Continue', 'th': 'ดำเนินการต่อ'},
    'skip': {'en': 'Skip', 'th': 'ข้าม'},
    'cancel': {'en': 'Cancel', 'th': 'ยกเลิก'},
    'yes': {'en': 'Yes', 'th': 'ใช่'},
    'no': {'en': 'No', 'th': 'ไม่'},
    'close': {'en': 'Close', 'th': 'ปิด'},
    'next': {'en': 'Next', 'th': 'ถัดไป'},
    'previous': {'en': 'Previous', 'th': 'ก่อนหน้า'},
    'finish': {'en': 'Finish', 'th': 'เสร็จสิ้น'},
    'start': {'en': 'Start', 'th': 'เริ่ม'},

    // Mini Puzzle
    'puzzle': {'en': 'Puzzle', 'th': 'จิ๊กซอว์'},
    'drag_drop': {
      'en': 'Drag and drop the pieces to complete the picture.',
      'th': 'ลากและวางชิ้นส่วนเพื่อประกอบภาพ',
    },
    'puzzle_complete': {'en': 'Puzzle Complete!', 'th': 'จิ๊กซอว์เสร็จแล้ว!'},
    'well_done': {'en': 'Well done!', 'th': 'ทำได้ดีมาก!'},

    // Points Celebration
    'points_earned': {'en': '+{points} Points!', 'th': '+{points} คะแนน!'},
    'level_up': {'en': 'LEVEL UP!', 'th': 'เลเวลอัพ!'},
    'you_are_now': {
      'en': 'You are now a {levelName}!',
      'th': 'คุณตอนนี้เป็น {levelName} แล้ว!',
    },
    'level_progress': {'en': 'Level Progress', 'th': 'ความคืบหน้าเลเวล'},
    'next_level_format': {
      'en': 'Next: {levelName}',
      'th': 'ถัดไป: {levelName}',
    },

    // Difficulty
    'easy': {'en': 'Easy', 'th': 'ง่าย'},
    'medium': {'en': 'Medium', 'th': 'ปานกลาง'},
    'hard': {'en': 'Hard', 'th': 'ยาก'},

    // Level Names
    'beginner': {'en': 'Beginner', 'th': 'มือใหม่'},
    'learner': {'en': 'Learner', 'th': 'ผู้เรียนรู้'},
    'explorer': {'en': 'Explorer', 'th': 'นักสำรวจ'},
    'expert': {'en': 'Expert', 'th': 'ผู้เชี่ยวชาญ'},
    'master': {'en': 'Master', 'th': 'มาสเตอร์'},

    // MiniPuzzle Game
    'minipuzzle_title': {'en': 'Mini Puzzle Games', 'th': 'เกมจิ๊กซอว์ย่อย'},
    'minipuzzle_pattern': {'en': 'Pattern Game', 'th': 'เกมลายลวดลาย'},
    'minipuzzle_sorting': {'en': 'Sorting Game', 'th': 'เกมจัดเรียง'},
    'minipuzzle_puzzle': {'en': 'Puzzle Game', 'th': 'เกมจิ๊กซอว์'},
    'minipuzzle_pattern_desc': {
      'en': 'Find the next shape in the pattern',
      'th': 'หารูปทรงถัดไปในลายลวดลาย',
    },
    'minipuzzle_sorting_desc': {
      'en': 'Sort items into the right groups',
      'th': 'จัดเรียงสิ่งของเข้ากลุ่มที่ถูกต้อง',
    },
    'minipuzzle_puzzle_desc': {
      'en': 'Match shapes to their slots',
      'th': 'จับคู่รูปทรงกับช่องที่ถูกต้อง',
    },
    'minipuzzle_select_game': {
      'en': 'Choose a game to play',
      'th': 'เลือกเกมที่จะเล่น',
    },
    'minipuzzle_select_level': {
      'en': 'Select Difficulty',
      'th': 'เลือกระดับความยาก',
    },
    'minipuzzle_easy': {'en': 'Easy', 'th': 'ง่าย'},
    'minipuzzle_medium': {'en': 'Medium', 'th': 'ปานกลาง'},
    'minipuzzle_hard': {'en': 'Hard', 'th': 'ยาก'},
    'minipuzzle_easy_desc': {
      'en': '2 items - Perfect for beginners',
      'th': '2 รายการ - เหมาะสำหรับผู้เริ่มต้น',
    },
    'minipuzzle_medium_desc': {
      'en': '3 items - A bit more challenging',
      'th': '3 รายการ - ท้าทายขึ้นเล็กน้อย',
    },
    'minipuzzle_hard_desc': {
      'en': '4 items - For puzzle masters',
      'th': '4 รายการ - สำหรับเซียนจิ๊กซอว์',
    },
    'minipuzzle_round': {'en': 'Round {n}', 'th': 'รอบ {n}'},
    'minipuzzle_correct': {'en': '{n} Correct!', 'th': '{n} ถูกต้อง!'},
    'minipuzzle_attempts': {'en': 'Attempts', 'th': 'ครั้งที่ลอง'},
    'back': {'en': 'Back', 'th': 'กลับ'},
  };

  // Format string with placeholders
  static String format(String template, Map<String, String> values) {
    String result = template;
    values.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }
}
