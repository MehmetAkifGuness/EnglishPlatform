INSERT INTO grammar_lessons (concept_id, explanation)
SELECT id,
       'Özne zamirleri cümlede işi yapan kişiyi veya varlığı belirtir ve İngilizcede genellikle fiilden önce gelir. I ben, you sen veya siz, he erkekler için o, she kadınlar için o, it nesneler ve hayvanlar için o, we biz, they ise onlar anlamına gelir. Türkçedeki “o” zamirinin İngilizcede he, she veya it olarak ayrıldığını unutma.'
FROM grammar_concepts
WHERE code = 'subject-pronouns';

UPDATE grammar_concepts SET has_lesson = TRUE WHERE code = 'subject-pronouns';

INSERT INTO grammar_examples (lesson_id, english_text, turkish_translation, order_index)
SELECT lesson.id, example.english_text, example.turkish_translation, example.order_index
FROM grammar_lessons lesson
JOIN grammar_concepts concept ON concept.id = lesson.concept_id
CROSS JOIN (VALUES
    ('I study English.', 'İngilizce çalışırım.', 1),
    ('You speak slowly.', 'Yavaş konuşursun.', 2),
    ('He works at home.', 'O evden çalışır.', 3),
    ('She likes music.', 'O müziği sever.', 4),
    ('It is a cat.', 'O bir kedidir.', 5),
    ('We learn together.', 'Birlikte öğreniriz.', 6),
    ('They live in Ankara.', 'Ankara’da yaşarlar.', 7)
) AS example(english_text, turkish_translation, order_index)
WHERE concept.code = 'subject-pronouns';

INSERT INTO grammar_exercises (
    concept_id, exercise_type, prompt, options_json, correct_answer, explanation, order_index)
SELECT concept.id, 'MULTIPLE_CHOICE',
       '“Maya ve ben İngilizce öğreniyoruz.” cümlesini tamamla: ___ learn English.',
       '["We", "They", "She"]'::jsonb,
       'We',
       'Maya ve ben “biz” anlamına gelir. İngilizcede “biz” zamiri we şeklindedir.',
       1
FROM grammar_concepts concept
WHERE concept.code = 'subject-pronouns';
