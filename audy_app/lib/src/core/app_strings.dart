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
    'assignments': {'en': 'Assignments', 'th': 'งานที่มอบหมาย'},
    'add_assignment': {'en': 'Add', 'th': 'เพิ่ม'},
    'create_assignment': {
      'en': 'Create Assignment',
      'th': 'สร้างงานที่มอบหมาย',
    },
    'assignment_feature_label': {'en': 'Feature', 'th': 'กิจกรรม'},
    'difficulty_label': {'en': 'Difficulty', 'th': 'ระดับความยาก'},
    'assignment_target_label': {'en': 'Times today', 'th': 'จำนวนครั้งวันนี้'},
    'assignment_limit_reached': {'en': '3 today', 'th': 'ครบ 3 งาน'},
    'no_assignments_today': {
      'en': 'No assignments yet',
      'th': 'ยังไม่มีงานวันนี้',
    },
    'create_assignment_hint': {
      'en': 'Add up to 3 calm tasks for today.',
      'th': 'เพิ่มงานที่สงบได้สูงสุด 3 งานสำหรับวันนี้',
    },
    'assignment_recommendations': {
      'en': 'Recommended',
      'th': 'แนะนำ',
    },
    'assignment_recommendations_desc': {
      'en': 'Based on features above 80% accuracy.',
      'th': 'อ้างอิงจากกิจกรรมที่แม่นยำมากกว่า 80%',
    },
    'assignment_recommendations_loading': {
      'en': 'Checking recent progress...',
      'th': 'กำลังดูความก้าวหน้าล่าสุด...',
    },
    'assignment_recommendations_empty': {
      'en': 'No strong match yet. Keep today simple.',
      'th': 'ยังไม่มีคำแนะนำที่ชัดเจน วันนี้ทำแบบง่ายก่อน',
    },
    'assignment_accuracy_value': {
      'en': '{percent}% accuracy',
      'th': 'แม่นยำ {percent}%',
    },
    'use': {'en': 'Use', 'th': 'ใช้'},
    'my_device': {'en': 'My Device', 'th': 'อุปกรณ์ของฉัน'},
    'reset_count': {'en': 'Reset count', 'th': 'รีเซ็ตจำนวน'},
    'break_time_now': {'en': 'Time for a break!', 'th': 'ได้เวลาพักแล้ว!'},
    'break_time_soon': {
      'en': 'Almost time for a break...',
      'th': 'ใกล้ถึงเวลาพักแล้ว...',
    },

    // Navigation
    'home': {'en': 'Home', 'th': 'หน้าหลัก'},
    'profile': {'en': 'Profile', 'th': 'โปรไฟล์'},
    'back_home': {'en': 'Back to Home', 'th': 'กลับหน้าหลัก'},
    'back': {'en': 'Back', 'th': 'กลับ'},

    // Games Hub
    'emotion_classify': {
      'en': 'What is this emotion?',
      'th': 'นี่คืออารมณ์อะไร?',
    },
    'emotion_mimic': {'en': 'Make this emotion!', 'th': 'ทำหน้าให้ถูก!'},
    'mini_puzzle': {'en': 'MiniPuzzle', 'th': 'แก้ปัญหาฝึกสมอง!'},
    'sorting_game': {'en': 'Sorting Game', 'th': 'จำแนกสิ่งของ!'},
    'reaction_time': {'en': 'Reaction Time', 'th': 'กดให้เร็วที่สุด!'},
    // Flash Card game
    'flashcard_game': {'en': 'Flash Card', 'th': 'การ์ดคำศัพท์'},
    'flashcard_guide': {
      'en': 'Drag cards into the middle to build a sentence, then tap Submit!',
      'th': 'ลากการ์ดมาวางตรงกลางให้เป็นประโยค แล้วกดส่งคำตอบ!',
    },
    'flashcard_instruction_easy': {
      'en': 'Make a short sentence.',
      'th': 'สร้างประโยคสั้น ๆ',
    },
    'flashcard_instruction_medium': {
      'en': 'Build the full sentence in order.',
      'th': 'เรียงคำให้เป็นประโยคที่สมบูรณ์',
    },
    'flashcard_instruction_hard': {
      'en': 'Order every word carefully.',
      'th': 'เรียงทุกคำให้ถูกต้อง',
    },
    'flashcard_hand_empty': {
      'en': 'All cards are placed!',
      'th': 'วางการ์ดครบแล้ว!',
    },
    'flashcard_clear_answer': {'en': 'Clear', 'th': 'ล้าง'},
    'flashcard_your_cards': {'en': 'Your cards', 'th': 'การ์ดของคุณ'},
    'flashcard_expand': {'en': 'Expand', 'th': 'ขยาย'},
    'flashcard_collapse': {'en': 'Collapse', 'th': 'ย่อ'},
    'flashcard_sentences_built': {
      'en': 'Sentences built',
      'th': 'ประโยคที่สร้างได้',
    },
    'pos_noun': {'en': 'Noun', 'th': 'คำนาม'},
    'pos_pronoun': {'en': 'Pronoun', 'th': 'สรรพนาม'},
    'pos_verb': {'en': 'Verb', 'th': 'คำกริยา'},
    'pos_adjective': {'en': 'Adjective', 'th': 'คำคุณศัพท์'},
    'pos_adverb': {'en': 'Adverb', 'th': 'คำกริยาวิเศษณ์'},
    'pos_preposition': {'en': 'Preposition', 'th': 'คำบุพบท'},
    'submit': {'en': 'Submit', 'th': 'ส่งคำตอบ'},
    'play_and_learn': {
      'en': 'Play and learn with fun activities!',
      'th': 'เล่นและเรียนรู้ด้วยกิจกรรมสนุก!',
    },

    // Game Entry Guides
    'guide_emotion_classify': {
      'en': 'Look at the face. Tap the matching emotion.',
      'th': 'ดูใบหน้า แล้วแตะอารมณ์ที่ตรงกัน',
    },
    'guide_emotion_mimic': {
      'en': 'Make the same face. Then take a photo.',
      'th': 'ทำหน้าเหมือนตัวอย่าง แล้วถ่ายรูป',
    },
    'guide_reaction_time': {
      'en': 'Wait for green. Then tap fast.',
      'th': 'รอให้เป็นสีเขียว แล้วแตะเร็วๆ',
    },
    'guide_sorting_game': {
      'en': 'Tap a piece. Then tap the matching basket.',
      'th': 'แตะชิ้นงาน แล้วแตะตะกร้าที่ตรงกัน',
    },
    'guide_minipuzzle_pattern': {
      'en': 'Look at the pattern. Tap what comes next.',
      'th': 'ดูลำดับรูปแบบ แล้วแตะสิ่งที่มาต่อไป',
    },
    'guide_minipuzzle_odd_one_out': {
      'en': 'Find the one that is different.',
      'th': 'หาสิ่งที่แตกต่าง',
    },
    'guide_minipuzzle_puzzle': {
      'en': 'Match each shape to its place.',
      'th': 'จับคู่รูปทรงกับตำแหน่งของมัน',
    },
    'guide_read_pronounce': {
      'en': 'Tap the mic. Say what you see.',
      'th': 'แตะไมค์ แล้วพูดตามที่เห็น',
    },

    // Device Connection
    'bluetooth_test': {'en': 'Bluetooth Test', 'th': 'ทดสอบบลูทูธ'},
    'device_not_found': {'en': 'Device not found', 'th': 'ไม่พบอุปกรณ์'},
    'connected_to_audy': {
      'en': 'Connected to AUDY!',
      'th': 'เชื่อมต่อกับ AUDY แล้ว!',
    },
    'connection_failed': {
      'en': 'Connection failed: {error}',
      'th': 'เชื่อมต่อไม่สำเร็จ: {error}',
    },
    'disconnected': {'en': 'Disconnected', 'th': 'ตัดการเชื่อมต่อแล้ว'},
    'connected': {'en': 'CONNECTED', 'th': 'เชื่อมต่อแล้ว'},
    'not_connected': {'en': 'NOT CONNECTED', 'th': 'ยังไม่เชื่อมต่อ'},
    'device_format': {'en': 'Device: {device}', 'th': 'อุปกรณ์: {device}'},
    'looking_for_device': {
      'en': 'Looking for: {device}',
      'th': 'กำลังหา: {device}',
    },
    'scan_connect': {'en': 'Scan & Connect', 'th': 'ค้นหาและเชื่อมต่อ'},
    'scanning': {'en': 'Scanning...', 'th': 'กำลังค้นหา...'},
    'connecting': {'en': 'Connecting...', 'th': 'กำลังเชื่อมต่อ...'},
    'ble_messages': {'en': 'BLE Messages', 'th': 'ข้อความ BLE'},
    'last_sent_empty': {'en': 'Last sent: -', 'th': 'ส่งล่าสุด: -'},
    'last_sent': {'en': 'Last sent: {value}', 'th': 'ส่งล่าสุด: {value}'},
    'last_received_empty': {'en': 'Last received: -', 'th': 'รับล่าสุด: -'},
    'last_received': {
      'en': 'Last received: {raw} ({description})',
      'th': 'รับล่าสุด: {raw} ({description})',
    },
    'disconnect': {'en': 'Disconnect', 'th': 'ตัดการเชื่อมต่อ'},
    'send': {'en': 'Send', 'th': 'ส่ง'},
    'sending': {'en': 'Sending...', 'th': 'กำลังส่ง...'},
    'sent_format': {'en': 'Sent: {payload}', 'th': 'ส่งแล้ว: {payload}'},
    'send_failed': {
      'en': 'Send failed: {error}',
      'th': 'ส่งไม่สำเร็จ: {error}',
    },
    'command_value': {'en': 'Command value', 'th': 'ค่าคำสั่ง'},
    'arms_channel': {'en': 'Arms Channel', 'th': 'ช่องแขน'},
    'emotion_channel': {'en': 'Emotion Channel', 'th': 'ช่องอารมณ์'},
    'led_channel': {'en': 'LED Channel', 'th': 'ช่องไฟ LED'},
    'flutter_to_esp32': {'en': 'Flutter -> ESP32', 'th': 'Flutter -> ESP32'},
    'device_normal': {'en': 'Normal', 'th': 'ปกติ'},
    'left_hand_raised': {'en': 'Left hand raised', 'th': 'ยกมือซ้าย'},
    'right_hand_raised': {'en': 'Right hand raised', 'th': 'ยกมือขวา'},
    'both_hands_raised': {'en': 'Both hands raised', 'th': 'ยกมือทั้งสองข้าง'},
    'pose_back_normal': {
      'en': 'Pose and back to normal',
      'th': 'ทำท่าแล้วกลับสู่ปกติ',
    },
    'normal_eyes': {'en': 'Normal eyes', 'th': 'ตาปกติ'},
    'heart_eyes': {'en': 'Heart eyes', 'th': 'ตารูปหัวใจ'},
    'glittering_eyes': {'en': 'Glittering eyes', 'th': 'ตาเปล่งประกาย'},
    'sad_eyes': {'en': 'Sad eyes', 'th': 'ตาเศร้า'},
    'ears_off_arms_off_tummy_white': {
      'en': 'Ears off / Arms off / Tummy white',
      'th': 'ปิดหู / ปิดแขน / ท้องสีขาว',
    },
    'all_red_tummy_cyan': {
      'en': 'All red / Tummy cyan',
      'th': 'ทั้งหมดสีแดง / ท้องสีฟ้า',
    },
    'all_green_tummy_magenta': {
      'en': 'All green / Tummy magenta',
      'th': 'ทั้งหมดสีเขียว / ท้องสีม่วงแดง',
    },
    'all_blue_tummy_yellow': {
      'en': 'All blue / Tummy yellow',
      'th': 'ทั้งหมดสีน้ำเงิน / ท้องสีเหลือง',
    },
    'all_yellow_tummy_blue': {
      'en': 'All yellow / Tummy blue',
      'th': 'ทั้งหมดสีเหลือง / ท้องสีน้ำเงิน',
    },
    'all_cyan_tummy_red': {
      'en': 'All cyan / Tummy red',
      'th': 'ทั้งหมดสีฟ้า / ท้องสีแดง',
    },
    'all_magenta_tummy_green': {
      'en': 'All magenta / Tummy green',
      'th': 'ทั้งหมดสีม่วงแดง / ท้องสีเขียว',
    },
    'all_white_tummy_off': {
      'en': 'All white / Tummy off',
      'th': 'ทั้งหมดสีขาว / ปิดท้อง',
    },
    'ears_dim_red_arms_green_tummy_yellow': {
      'en': 'Ears dim red / Arms green / Tummy yellow',
      'th': 'หูแดงอ่อน / แขนเขียว / ท้องเหลือง',
    },
    'ears_dim_green_arms_blue_tummy_blue': {
      'en': 'Ears dim green / Arms blue / Tummy blue',
      'th': 'หูเขียวอ่อน / แขนน้ำเงิน / ท้องน้ำเงิน',
    },
    'ears_dim_blue_arms_yellow_tummy_red': {
      'en': 'Ears dim blue / Arms yellow / Tummy red',
      'th': 'หูน้ำเงินอ่อน / แขนเหลือง / ท้องแดง',
    },
    'ears_dim_yellow_arms_cyan_tummy_green': {
      'en': 'Ears dim yellow / Arms cyan / Tummy green',
      'th': 'หูเหลืองอ่อน / แขนฟ้า / ท้องเขียว',
    },
    'ears_dim_cyan_arms_magenta_tummy_off': {
      'en': 'Ears dim cyan / Arms magenta / Tummy off',
      'th': 'หูฟ้าอ่อน / แขนม่วงแดง / ปิดท้อง',
    },
    'ears_dim_magenta_arms_white_tummy_cyan': {
      'en': 'Ears dim magenta / Arms white / Tummy cyan',
      'th': 'หูม่วงแดงอ่อน / แขนขาว / ท้องฟ้า',
    },
    'ears_dim_white_arms_red_tummy_magenta': {
      'en': 'Ears dim white / Arms red / Tummy magenta',
      'th': 'หูขาวอ่อน / แขนแดง / ท้องม่วงแดง',
    },
    'split_ears_split_arms_tummy_white': {
      'en': 'Split ears / Split arms / Tummy white',
      'th': 'หูแยกสี / แขนแยกสี / ท้องขาว',
    },
    'ears_split_arms_off_tummy_green': {
      'en': 'Ears split / Arms off / Tummy green',
      'th': 'หูแยกสี / ปิดแขน / ท้องเขียว',
    },
    'ears_split_arms_off_tummy_white': {
      'en': 'Ears split / Arms off / Tummy white',
      'th': 'หูแยกสี / ปิดแขน / ท้องขาว',
    },
    'rainbow': {'en': 'Rainbow', 'th': 'สายรุ้ง'},
    'all_off': {'en': 'All off', 'th': 'ปิดทั้งหมด'},
    'nose_lights': {'en': 'Nose lights', 'th': 'ไฟจมูก'},
    'tummy_clicked': {'en': 'Tummy clicked', 'th': 'แตะที่ท้อง'},
    'tummy_not_clicked': {'en': 'Tummy not clicked', 'th': 'ไม่ได้แตะที่ท้อง'},
    'nose_clicked': {'en': 'Nose clicked', 'th': 'แตะที่จมูก'},
    'nose_not_clicked': {'en': 'Nose not clicked', 'th': 'ไม่ได้แตะที่จมูก'},
    'not_squeezed': {'en': 'Not squeezed', 'th': 'ไม่ได้บีบ'},
    'squeeze_left': {'en': 'Squeeze left', 'th': 'บีบด้านซ้าย'},
    'squeeze_right': {'en': 'Squeeze right', 'th': 'บีบด้านขวา'},
    'no_ear_clicked': {'en': 'No ear clicked', 'th': 'ไม่ได้แตะหู'},
    'left_ear_clicked': {'en': 'Left ear clicked', 'th': 'แตะหูซ้าย'},
    'right_ear_clicked': {'en': 'Right ear clicked', 'th': 'แตะหูขวา'},
    'unknown_message': {'en': 'Unknown message', 'th': 'ข้อความไม่รู้จัก'},

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
    'start_conversation': {
      'en': 'Start a conversation with a short message.',
      'th': 'เริ่มคุยด้วยข้อความสั้นๆ',
    },

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
    'reading': {'en': 'Reading', 'th': 'การอ่าน'},
    'read_pronounce': {'en': 'Read & Pronounce', 'th': 'อ่านและออกเสียง'},
    'choose_learning_level': {
      'en': 'Choose your learning level.',
      'th': 'เลือกระดับการเรียนรู้',
    },
    'letters': {'en': 'Letters', 'th': 'ตัวอักษร'},
    'words': {'en': 'Words', 'th': 'คำศัพท์'},
    'sentences': {'en': 'Sentences', 'th': 'ประโยค'},
    'abc_sounds': {'en': 'A B C sounds', 'th': 'เสียง A B C'},
    'simple_vocabulary': {'en': 'Simple vocabulary', 'th': 'คำศัพท์ง่ายๆ'},
    'short_phrases': {'en': 'Short phrases', 'th': 'วลีสั้นๆ'},
    'full_sentences': {'en': 'Full sentences', 'th': 'ประโยคเต็ม'},
    'improve_pronunciation': {
      'en': 'Improve your pronunciation with guided practice.',
      'th': 'พัฒนาการออกเสียงด้วยการฝึกแบบแนะนำ',
    },
    'tap_mic_say_clearly': {
      'en': 'Tap the microphone and say it clearly.',
      'th': 'แตะไมค์แล้วพูดให้ชัดเจน',
    },
    'stt_unavailable': {
      'en': 'This feature is not available on your device.',
      'th': 'ฟีเจอร์นี้ยังใช้ไม่ได้บนอุปกรณ์นี้',
    },
    'recording_time': {'en': 'Recording {time}', 'th': 'กำลังบันทึก {time}'},
    'tap_mic_to_check': {
      'en': 'Tap mic to check',
      'th': 'แตะไมค์เพื่อตรวจ',
    },
    'ready': {'en': 'Ready', 'th': 'พร้อม'},
    'all_done': {'en': 'All Done!', 'th': 'เสร็จแล้ว!'},
    'session_complete': {
      'en': 'You completed the session!',
      'th': 'ทำกิจกรรมครบแล้ว!',
    },
    'correct_from_tries': {
      'en': '{correct} correct from {total} tries',
      'th': 'ถูก {correct} จาก {total} ครั้ง',
    },
    'time_format': {'en': 'Time: {time}', 'th': 'เวลา: {time}'},
    'did_not_hear': {
      'en': 'I did not hear it. Try again.',
      'th': 'ไม่ได้ยินเสียง ลองอีกครั้ง',
    },
    'try_shorter_answer': {
      'en': 'Try a shorter answer.',
      'th': 'ลองตอบให้สั้นลง',
    },
    'close_try_again': {
      'en': 'Close. Try saying it again.',
      'th': 'ใกล้แล้ว ลองพูดอีกครั้ง',
    },
    'can_skip': {
      'en': 'Good try. You can skip this one.',
      'th': 'พยายามได้ดี ข้ามข้อนี้ได้',
    },

    // Profile
    'your_progress': {'en': 'Your Progress', 'th': 'ความก้าวหน้าของคุณ'},
    'Progress': {'en': 'Progress', 'th': 'ความก้าวหน้า'},
    'learning_points': {'en': 'Learning Points', 'th': 'คะแนนการเรียนรู้'},
    'points': {'en': 'Points', 'th': 'คะแนน'},
    'games_played': {'en': 'Games Played', 'th': 'เกมที่เล่น'},
    'day_streak': {'en': 'Day Streak', 'th': 'วันต่อเนื่อง'},
    'achievements': {'en': 'Achievements', 'th': 'ความสำเร็จ'},
    'completed': {'en': 'Completed', 'th': 'สำเร็จแล้ว'},
    'locked': {'en': 'Locked', 'th': 'ล็อก'},
    'reset_progress': {'en': 'Reset Progress', 'th': 'รีเซ็ตความก้าวหน้า'},
    'user': {'en': 'User', 'th': 'ผู้ใช้'},
    'age_format': {'en': 'Age: {age}', 'th': 'อายุ: {age}'},
    'member_since': {'en': 'Member since {date}', 'th': 'เป็นสมาชิกตั้งแต่ {date}'},
    'log_out': {'en': 'Log Out', 'th': 'ออกจากระบบ'},
    'parent_dashboard': {'en': 'Parent Dashboard', 'th': 'แดชบอร์ดผู้ปกครอง'},
    'institution_panel': {'en': 'Institution Panel', 'th': 'แผงสถาบัน'},
    'settings': {'en': 'Settings', 'th': 'ตั้งค่า'},
    'your_learning_journey': {
      'en': 'Your learning journey',
      'th': 'เส้นทางการเรียนรู้ของคุณ',
    },
    'learning_analytics': {'en': 'Learning Analytics', 'th': 'วิเคราะห์การเรียนรู้'},
    'daily_activity': {'en': 'Daily Activity', 'th': 'กิจกรรมรายวัน'},
    'daily_activity_desc': {
      'en': 'Completed learning sessions each day',
      'th': 'จำนวนกิจกรรมการเรียนรู้ที่ทำเสร็จในแต่ละวัน',
    },
    'learning_features': {'en': 'Learning Features', 'th': 'ทักษะการเรียนรู้'},
    'recent_sessions': {'en': 'Recent Sessions', 'th': 'กิจกรรมล่าสุด'},
    'seven_day_sessions': {'en': '7-Day Sessions', 'th': 'กิจกรรม 7 วัน'},
    'seven_day_minutes': {'en': '7-Day Minutes', 'th': 'นาที 7 วัน'},
    'scored_average': {'en': 'Scored Average', 'th': 'คะแนนเฉลี่ย'},
    'latest_activity': {'en': 'Latest Activity', 'th': 'กิจกรรมล่าสุด'},
    'current_child_overview': {
      'en': 'Current Child Overview',
      'th': 'ภาพรวมเด็กปัจจุบัน',
    },
    'joined_format': {'en': 'Joined: {date}', 'th': 'เข้าร่วม: {date}'},
    'games_label': {'en': 'Games', 'th': 'เกม'},
    'streak': {'en': 'Streak', 'th': 'ต่อเนื่อง'},
    'single_child_summary': {'en': 'Single Child Summary', 'th': 'สรุปเด็กคนเดียว'},
    'current_child_statistics': {
      'en': 'Current Child Statistics',
      'th': 'สถิติเด็กปัจจุบัน',
    },
    'children_shown': {'en': 'Children Shown', 'th': 'จำนวนเด็กที่แสดง'},
    'games_completed': {'en': 'Games Completed', 'th': 'เกมที่ทำเสร็จ'},
    'current_streak': {'en': 'Current Streak', 'th': 'ต่อเนื่องปัจจุบัน'},
    'skill_progress': {'en': 'Skill Progress', 'th': 'ความก้าวหน้าทักษะ'},
    'difficulty_instruction_title': {
      'en': 'Difficulty Guidance',
      'th': 'คำแนะนำระดับความยาก',
    },
    'difficulty_instruction_parent_desc': {
      'en': 'These skills look strong this week. Try a harder level next.',
      'th': 'ทักษะเหล่านี้ทำได้ดีในสัปดาห์นี้ ลองระดับที่ยากขึ้นครั้งต่อไป',
    },
    'difficulty_instruction_institution_desc': {
      'en': 'These skills are strong for this child. Caretakers can offer harder practice.',
      'th': 'ทักษะเหล่านี้เป็นจุดแข็งของเด็ก ผู้ดูแลสามารถเพิ่มความยากได้',
    },
    'difficulty_instruction_empty': {
      'en': 'Keep the current level for now and review again after more sessions.',
      'th': 'ใช้ระดับปัจจุบันไปก่อน แล้วตรวจดูอีกครั้งหลังเล่นเพิ่ม',
    },
    'try_harder_difficulty': {
      'en': 'Try harder difficulty',
      'th': 'ลองระดับที่ยากขึ้น',
    },
    'export_report': {'en': 'Export Report', 'th': 'ส่งออกรายงาน'},
    'export_report_desc': {
      'en': 'Generate and export progress reports for documentation and sharing with parents or therapists.',
      'th': 'สร้างและส่งออกรายงานความก้าวหน้าเพื่อบันทึกและแบ่งปันกับผู้ปกครองหรือนักบำบัด',
    },
    'report_exported': {'en': 'Report Exported!', 'th': 'ส่งออกรายงานแล้ว!'},
    'report_saved': {
      'en': 'The report has been generated and saved to your device.',
      'th': 'สร้างรายงานและบันทึกลงอุปกรณ์แล้ว',
    },
    'great': {'en': 'Great!', 'th': 'เยี่ยม!'},
    'communication': {'en': 'Communication', 'th': 'การสื่อสาร'},
    'sensory_sensitivity': {'en': 'Sensory Sensitivity', 'th': 'ความไวต่อประสาทสัมผัส'},
    'favorite_interests': {'en': 'Favorite Interests', 'th': 'ความสนใจที่ชอบ'},
    'edit_preferences': {'en': 'Edit Preferences', 'th': 'แก้ไขการตั้งค่า'},
    'none_selected': {'en': 'None selected', 'th': 'ยังไม่ได้เลือก'},
    'your_achievements': {'en': 'Your Achievements', 'th': 'ความสำเร็จของคุณ'},
    'unlocked': {'en': 'Unlocked', 'th': 'ปลดล็อกแล้ว'},
    'sessions': {'en': 'Sessions', 'th': 'กิจกรรม'},
    'minutes': {'en': 'Minutes', 'th': 'นาที'},
    'participation': {'en': 'Participation', 'th': 'การมีส่วนร่วม'},
    'average_score': {'en': 'Average Score', 'th': 'คะแนนเฉลี่ย'},
    'recorded_activity': {'en': 'Recorded activity', 'th': 'มีกิจกรรมที่บันทึกแล้ว'},
    'no_sessions_yet': {'en': 'No sessions yet', 'th': 'ยังไม่มีกิจกรรม'},
    'percent_correct': {'en': '{percent}% correct', 'th': 'ถูกต้อง {percent}%'},
    'no_learning_sessions': {
      'en': 'No learning sessions recorded yet.',
      'th': 'ยังไม่มีการบันทึกกิจกรรมการเรียนรู้',
    },
    'not_enough_session_data': {
      'en': 'Not enough session data yet',
      'th': 'ยังมีข้อมูลกิจกรรมไม่พอ',
    },
    'just_now': {'en': 'Just now', 'th': 'เมื่อสักครู่'},
    'minutes_ago': {'en': '{count}m ago', 'th': '{count} นาทีที่แล้ว'},
    'hours_ago': {'en': '{count}h ago', 'th': '{count} ชั่วโมงที่แล้ว'},
    'days_ago': {'en': '{count}d ago', 'th': '{count} วันที่แล้ว'},
    'points_count': {'en': '{points} points', 'th': '{points} คะแนน'},
    'points_to_next_level': {
      'en': '{points} to next level',
      'th': 'อีก {points} คะแนนถึงเลเวลถัดไป',
    },

    // Rewards
    'your_rewards': {'en': 'Your Rewards', 'th': 'รางวัลของคุณ'},
    'Manage your rewards': {
      'en': 'Manage your rewards',
      'th': 'จัดการรางวัลของคุณ',
    },
    'my_rewards': {'en': 'My Rewards', 'th': 'รางวัลของฉัน'},
    'add_reward': {'en': 'Add Reward', 'th': 'เพิ่มรางวัล'},
    'active_rewards': {'en': 'Active', 'th': 'กำลังทำ'},
    'completed_rewards': {'en': 'Completed', 'th': 'สำเร็จแล้ว'},
    'claimed_rewards': {'en': 'Claimed', 'th': 'รับแล้ว'},
    'claimed': {'en': 'Claimed', 'th': 'รับแล้ว'},
    'claim': {'en': 'Claim', 'th': 'รับรางวัล'},
    'no_rewards_yet': {'en': 'No Rewards Yet', 'th': 'ยังไม่มีรางวัล'},
    'create_reward_hint': {
      'en': 'Tap "Add Reward" to create your first reward!',
      'th': 'แตะ "เพิ่มรางวัล" เพื่อสร้างรางวัลแรกของคุณ!',
    },
    'max_rewards_reached': {
      'en': 'Max 3 rewards',
      'th': 'สูงสุด 3 รางวัล',
    },
    'skins': {'en': 'Skins', 'th': 'สกิน'},
    'available_points': {'en': 'Available Points', 'th': 'คะแนนที่ใช้ได้'},
    'skin_price': {'en': '{points} each', 'th': '{points} ต่อชิ้น'},
    'skin_cost': {'en': '{points} points', 'th': '{points} คะแนน'},
    'free_skin': {'en': 'Free', 'th': 'ฟรี'},
    'buy_skin': {'en': 'Buy', 'th': 'ซื้อ'},
    'select': {'en': 'Select', 'th': 'เลือก'},
    'selected': {'en': 'Selected', 'th': 'เลือกแล้ว'},
    'need_points': {'en': 'Need points', 'th': 'คะแนนไม่พอ'},
    'awesome': {'en': 'Awesome!', 'th': 'สุดยอด!'},
    'max_level': {'en': 'Max Level', 'th': 'เลเวลสูงสุด'},
    'max_level_exclamation': {'en': 'Max Level!', 'th': 'เลเวลสูงสุด!'},
    'points_progress_to_level': {
      'en': '{current} / {next} to {levelName}',
      'th': '{current} / {next} ไปสู่ {levelName}',
    },
    'achievement_unlocked': {
      'en': 'Achievement Unlocked!',
      'th': 'ปลดล็อกความสำเร็จ!',
    },

    // Create Reward Dialog
    'create_reward': {'en': 'Create Reward', 'th': 'สร้างรางวัล'},
    'prize_label': {'en': 'Prize', 'th': 'รางวัล'},
    'prize_hint': {
      'en': 'e.g. 10 minutes of playtime',
      'th': 'เช่น เล่นเกม 10 นาที',
    },
    'condition_label': {'en': 'Condition', 'th': 'เงื่อนไข'},
    'target_label': {'en': 'How many?', 'th': 'ทำกี่ครั้ง?'},
    'create': {'en': 'Create', 'th': 'สร้าง'},

    // Reward Conditions (using existing keys from games section)

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

    // Auth
    'learning_buddy': {'en': 'Your Learning Buddy', 'th': 'เพื่อนเรียนรู้ของคุณ'},
    'sign_in': {'en': 'Sign In', 'th': 'เข้าสู่ระบบ'},
    'sign_up': {'en': 'Sign Up', 'th': 'สมัครสมาชิก'},
    'email': {'en': 'Email', 'th': 'อีเมล'},
    'password': {'en': 'Password', 'th': 'รหัสผ่าน'},
    'your_name': {'en': 'Your Name', 'th': 'ชื่อของคุณ'},
    'age': {'en': 'Age', 'th': 'อายุ'},
    'create_account': {'en': 'Create Account', 'th': 'สร้างบัญชี'},
    'creating_account': {
      'en': 'Creating account...',
      'th': 'กำลังสร้างบัญชี...',
    },
    'signing_in': {'en': 'Signing in...', 'th': 'กำลังเข้าสู่ระบบ...'},
    'enter_email': {'en': 'Please enter your email.', 'th': 'กรุณากรอกอีเมล'},
    'enter_password': {
      'en': 'Please enter your password.',
      'th': 'กรุณากรอกรหัสผ่าน',
    },
    'enter_name': {'en': 'Please enter your name.', 'th': 'กรุณากรอกชื่อ'},

    // Preferences
    'lets_personalize': {'en': 'Let\'s Personalize!', 'th': 'มาตั้งค่าให้เหมาะกับคุณ!'},
    'your_preferences': {'en': 'Your Preferences', 'th': 'การตั้งค่าของคุณ'},
    'personalize_help': {
      'en': 'Help us make AUDY perfect for you!',
      'th': 'ช่วยให้ AUDY เหมาะกับคุณมากขึ้น!',
    },
    'customize_experience': {
      'en': 'Customize your experience',
      'th': 'ปรับประสบการณ์ของคุณ',
    },
    'communication_question': {
      'en': 'How do you communicate?',
      'th': 'คุณสื่อสารอย่างไร?',
    },
    'sound_sensitivity': {'en': 'Sound sensitivity?', 'th': 'ไวต่อเสียงแค่ไหน?'},
    'learning_pace': {'en': 'Learning pace?', 'th': 'จังหวะการเรียนรู้?'},
    'favorite_things': {'en': 'Favorite things?', 'th': 'สิ่งที่ชอบ?'},
    'non_verbal': {'en': 'Non-verbal', 'th': 'ไม่ใช้คำพูด'},
    'single_words': {'en': 'Single words', 'th': 'คำเดี่ยว'},
    'low': {'en': 'Low', 'th': 'ต่ำ'},
    'high': {'en': 'High', 'th': 'สูง'},
    'slower': {'en': 'Slower', 'th': 'ช้าลง'},
    'standard': {'en': 'Standard', 'th': 'มาตรฐาน'},
    'faster': {'en': 'Faster', 'th': 'เร็วขึ้น'},
    'animals': {'en': 'Animals', 'th': 'สัตว์'},
    'vehicles': {'en': 'Vehicles', 'th': 'ยานพาหนะ'},
    'music': {'en': 'Music', 'th': 'ดนตรี'},
    'nature': {'en': 'Nature', 'th': 'ธรรมชาติ'},
    'colors': {'en': 'Colors', 'th': 'สี'},
    'numbers': {'en': 'Numbers', 'th': 'ตัวเลข'},
    'saving': {'en': 'Saving...', 'th': 'กำลังบันทึก...'},
    'start_learning': {'en': 'Start Learning!', 'th': 'เริ่มเรียนรู้!'},
    'save_changes': {'en': 'Save Changes', 'th': 'บันทึกการเปลี่ยนแปลง'},

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
    'minipuzzle_odd_one_out': {'en': 'Odd One Out', 'th': 'หาตัวที่ต่าง'},
    'minipuzzle_visual_match': {'en': 'Visual Match', 'th': 'จับคู่ภาพ'},
    'minipuzzle_pattern_desc': {
      'en': 'Find the next shape in the pattern',
      'th': 'หารูปทรงถัดไปในลายลวดลาย',
    },
    'minipuzzle_sorting_desc': {
      'en': 'Sort items into the right groups',
      'th': 'จัดเรียงสิ่งของเข้ากลุ่มที่ถูกต้อง',
    },
    'minipuzzle_odd_one_out_desc': {
      'en': 'Find the item that is different',
      'th': 'หาสิ่งที่แตกต่าง',
    },
    'minipuzzle_visual_match_desc': {
      'en': 'Match shapes to their slots',
      'th': 'จับคู่รูปทรงกับช่องของมัน',
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
    'minipuzzle_easy_desc_generic': {'en': 'Gentle start', 'th': 'เริ่มแบบง่ายๆ'},
    'minipuzzle_medium_desc_generic': {'en': 'More choices', 'th': 'ตัวเลือกมากขึ้น'},
    'minipuzzle_hard_desc_generic': {'en': 'Bigger challenge', 'th': 'ท้าทายมากขึ้น'},
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
    'attempts': {'en': 'Attempts', 'th': 'จำนวนครั้งที่ลอง'},
    'minipuzzle_pattern_prompt': {'en': 'What comes next?', 'th': 'อะไรคือตัวถัดไป?'},
    'minipuzzle_odd_prompt': {'en': 'Find the different one', 'th': 'หาสิ่งที่แตกต่าง'},
    'minipuzzle_match_prompt': {'en': 'Match each shape', 'th': 'จับคู่รูปทรงแต่ละชิ้น'},
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
