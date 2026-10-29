INSERT INTO grammar_lessons (concept_id, explanation)
SELECT concept.id, lesson.explanation
FROM grammar_concepts concept
JOIN (VALUES
    ('be-verb', 'Be fiili, kişileri, nesneleri ve durumları anlatırken kullanılır. Özneye göre am, is veya are seçilir: I ile am; he, she ve it ile is; you, we ve they ile are kullanılır. Bu fiil İngilizcede çoğu zaman cümlede bulunması gereken temel fiildir.'),
    ('articles', 'A ve an, tekil ve sayılabilen bir isimden ilk kez söz ederken kullanılır. A sessiz harf sesiyle başlayan kelimelerden, an sesli harf sesiyle başlayan kelimelerden önce gelir. The ise konuşanların hangi kişi veya şeyden söz edildiğini bildiği durumlarda kullanılır.'),
    ('present-simple', 'Geniş zaman alışkanlıkları, rutinleri ve genel doğruları anlatır. I, you, we ve they ile fiilin yalın hâli kullanılır. He, she ve it öznelerinde fiile genellikle -s veya -es eklenir: I work, she works.'),
    ('connectors', 'Bağlaçlar kelimeleri ve cümleleri anlam ilişkisi kurarak birleştirir. And benzer fikirleri ekler, but karşıtlık kurar, because ise bir neden açıklar. Bağlacı seçerken iki cümle arasındaki anlama dikkat et.'),
    ('past-simple', 'Geçmiş zaman, geçmişte başlayıp tamamlanmış olayları anlatır. Düzenli fiillere çoğunlukla -ed eklenir: watch → watched. Bazı fiiller düzensizdir ve ikinci hâlleri öğrenilmelidir: go → went.'),
    ('present-continuous', 'Şimdiki zaman, konuşma anında devam eden veya geçici durumları anlatır. Özneye uygun am, is veya are fiilinden sonra ana fiile -ing eklenir: I am reading, she is reading, they are reading.')
) AS lesson(code, explanation) ON concept.code = lesson.code;

UPDATE grammar_concepts
SET has_lesson = TRUE
WHERE code IN ('be-verb', 'articles', 'present-simple', 'connectors', 'past-simple', 'present-continuous');

INSERT INTO grammar_examples (lesson_id, english_text, turkish_translation, order_index)
SELECT lesson.id, example.english_text, example.turkish_translation, example.order_index
FROM (VALUES
    ('be-verb', 'I am ready.', 'Hazırım.', 1),
    ('be-verb', 'She is at home.', 'O evde.', 2),
    ('be-verb', 'They are friends.', 'Onlar arkadaş.', 3),
    ('articles', 'I have an apple.', 'Bir elmam var.', 1),
    ('articles', 'She is a teacher.', 'O bir öğretmen.', 2),
    ('articles', 'The sun is bright.', 'Güneş parlak.', 3),
    ('present-simple', 'I walk to school.', 'Okula yürüyerek giderim.', 1),
    ('present-simple', 'She studies English.', 'O İngilizce çalışır.', 2),
    ('present-simple', 'They work on Mondays.', 'Pazartesileri çalışırlar.', 3),
    ('connectors', 'I like tea and coffee.', 'Çay ve kahveyi severim.', 1),
    ('connectors', 'I stayed home because it was raining.', 'Yağmur yağdığı için evde kaldım.', 2),
    ('connectors', 'The bus was late, but we arrived on time.', 'Otobüs gecikti ama zamanında vardık.', 3),
    ('past-simple', 'We watched a film last night.', 'Dün gece bir film izledik.', 1),
    ('past-simple', 'He visited his friend.', 'Arkadaşını ziyaret etti.', 2),
    ('past-simple', 'They played tennis yesterday.', 'Dün tenis oynadılar.', 3),
    ('present-continuous', 'I am reading now.', 'Şu an kitap okuyorum.', 1),
    ('present-continuous', 'She is cooking dinner.', 'Akşam yemeğini hazırlıyor.', 2),
    ('present-continuous', 'They are playing outside.', 'Dışarıda oynuyorlar.', 3)
) AS example(code, english_text, turkish_translation, order_index)
JOIN grammar_concepts concept ON concept.code = example.code
JOIN grammar_lessons lesson ON lesson.concept_id = concept.id;

INSERT INTO grammar_exercises (
    concept_id, exercise_type, prompt, options_json, correct_answer, explanation, order_index)
SELECT concept.id, 'MULTIPLE_CHOICE', exercise.prompt, exercise.options_json::jsonb,
       exercise.correct_answer, exercise.explanation, 1
FROM (VALUES
    ('be-verb', 'My friends ___ at school.', '["am", "is", "are"]', 'are', 'Friends çoğul olduğu için are kullanılır.'),
    ('articles', 'I saw ___ elephant at the zoo.', '["a", "an", "the"]', 'an', 'Elephant sesli harf sesiyle başladığı için an kullanılır.'),
    ('present-simple', 'She ___ English every day.', '["study", "studies", "is studying"]', 'studies', 'Geniş zamanda she öznesiyle fiile -s/-es eklenir: studies.'),
    ('connectors', 'I stayed home ___ I was tired.', '["and", "but", "because"]', 'because', 'İkinci bölüm evde kalmanın nedenini açıkladığı için because kullanılır.'),
    ('past-simple', 'Yesterday, we ___ a film.', '["watch", "watched", "watching"]', 'watched', 'Yesterday geçmiş zamanı belirtir; watch fiilinin düzenli geçmiş hâli watched olur.'),
    ('present-continuous', 'Look! They ___ football now.', '["play", "are playing", "played"]', 'are playing', 'Now eylemin şu anda sürdüğünü belirtir; they ile are + fiil-ing kullanılır.')
) AS exercise(code, prompt, options_json, correct_answer, explanation)
JOIN grammar_concepts concept ON concept.code = exercise.code;
