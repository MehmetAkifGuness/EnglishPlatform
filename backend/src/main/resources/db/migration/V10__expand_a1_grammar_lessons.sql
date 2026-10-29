UPDATE grammar_lessons lesson
SET explanation = content.explanation
FROM grammar_concepts concept
JOIN (VALUES
    ('sentence-basics',
     'Temel olumlu İngilizce cümlelerde yaygın sıra Özne + Fiil + Nesnedir (Subject + Verb + Object). Özne işi yapanı, fiil eylemi, nesne ise eylemden etkileneni belirtir: “I (özne) read (fiil) books (nesne).” Türkçede fiil çoğunlukla sonda olsa da İngilizcede fiil genellikle özneden hemen sonra gelir. İngilizce cümlede özneyi çoğu zaman yazmalısın; Türkçedeki gibi yalnızca “Am ready” demek doğru değildir, “I am ready” denir. Sıfatlar da genellikle isimden önce gelir: a small house (küçük bir ev). Sık hata: Türkçe sırayı kelime kelime aktarıp “I coffee drink” demek; doğru sıra “I drink coffee.” şeklindedir.'),
    ('subject-pronouns',
     'Özne zamirleri, cümlede işi yapan kişi veya varlığın yerine kullanılır ve genellikle fiilden önce gelir. I = ben, you = sen/siz, he = erkekler için o, she = kadınlar için o, it = nesne veya hayvanlar için o, we = biz, they = onlar. You hem tekil hem çoğul olabilir. İngilizcede I her zaman büyük yazılır. Türkçedeki “o” zamiri İngilizcede he, she veya it olarak seçilir; kişi biliniyorsa uygun zamiri, birden fazla kişi veya varlık için they kullan. İsim grubunu zamirle değiştirirken anlamı koru: “Maya and I” yerine “we”, “the books” yerine “they”. Sık hata: “Maya and I” için they kullanmak; konuşan kişi grubun içindeyse doğru zamir we olur.'),
    ('be-verb',
     'Be fiilinin şimdiki zamandaki biçimi özneye göre değişir: I am; he/she/it is; you/we/they are. Be fiili kişiyi, kimliği, yaşı, konumu ve durumu anlatır: “I am a student.” (Öğrenciyim.), “She is at home.” (O evde.). Olumsuz cümlede be fiilinden sonra not gelir: is not, are not, am not. Soruda be fiilini öznenin önüne al: “Are you ready?” (Hazır mısın?). Günlük kullanımda I am → I’m, she is → she’s, we are → we’re biçimleri yaygındır. Sık hata: özneyle yanlış biçimi eşleştirmek veya be fiilini atlamak; “They happy” yerine “They are happy” denir.'),
    ('articles',
     'A ve an, tekil ve sayılabilen bir isimden belirsiz ya da ilk kez söz ederken kullanılır: a book, an apple. Seçim yazılan harfe değil, sonraki kelimenin ilk sesine bağlıdır: a university ama an hour. The, konuşanların hangi kişi veya şey olduğunu bildiği belirli isimden söz ederken kullanılır: “I saw a dog. The dog was small.” (Bir köpek gördüm. Köpek küçüktü.) Çoğul isimler ve sayılamayan isimler genel anlamda kullanıldığında çoğunlukla artikel almaz: “I like books.”, “We drink water.” Sık hata: her ismin önüne a/an koymak; a ve an yalnızca tekil, sayılabilen isimlerle kullanılır.'),
    ('present-simple',
     'Present Simple rutinleri, alışkanlıkları ve genel doğruları anlatır. I/you/we/they ile fiilin yalın biçimini kullan: “They work.” He/she/it ile fiile genellikle -s eklenir; -ch, -sh, -ss, -x veya -o ile biten fiiller çoğunlukla -es alır; ünsüz + y ise -ies olur: watch → watches, study → studies. Olumsuzda do not/don’t veya does not/doesn’t + yalın fiil kullanılır: “She doesn’t work.” Soruda Do/Does özneden önce gelir: “Does he live here?” Does kullanıldığında ana fiile tekrar -s eklenmez. Usually ve often gibi sıklık zarfları çoğunlukla ana fiilden önce gelir: “We often walk.” Sık hata: “She doesn’t likes” demek; doğru biçim “She doesn’t like” olur.')
) AS content(code, explanation) ON concept.code = content.code
WHERE lesson.concept_id = concept.id;

INSERT INTO grammar_examples (lesson_id, english_text, turkish_translation, order_index)
SELECT lesson.id, example.english_text, example.turkish_translation, example.order_index
FROM (VALUES
    ('sentence-basics', 'Birds build nests.', 'Kuşlar yuva yapar.', 4),
    ('sentence-basics', 'My sister reads stories.', 'Kız kardeşim hikâyeler okur.', 5),
    ('sentence-basics', 'We drink water.', 'Su içeriz.', 6),
    ('sentence-basics', 'The children play outside.', 'Çocuklar dışarıda oynar.', 7),
    ('sentence-basics', 'He opens the window.', 'Pencereyi açar.', 8),
    ('sentence-basics', 'Our teacher speaks slowly.', 'Öğretmenimiz yavaş konuşur.', 9),
    ('sentence-basics', 'They watch a film.', 'Bir film izlerler.', 10),
    ('subject-pronouns', 'Mina is my friend. She is kind.', 'Mina benim arkadaşım. O naziktir.', 8),
    ('subject-pronouns', 'My parents are at work. They are busy.', 'Annemle babam işte. Onlar meşgul.', 9),
    ('subject-pronouns', 'The book is new. It is interesting.', 'Kitap yeni. O ilginç.', 10),
    ('be-verb', 'I am 20 years old.', '20 yaşındayım.', 4),
    ('be-verb', 'You are very kind.', 'Çok naziksin.', 5),
    ('be-verb', 'My brother is a doctor.', 'Erkek kardeşim doktordur.', 6),
    ('be-verb', 'We are not late.', 'Geç kalmadık.', 7),
    ('be-verb', 'Is your sister at home?', 'Kız kardeşin evde mi?', 8),
    ('be-verb', 'It is cold today.', 'Bugün hava soğuk.', 9),
    ('be-verb', 'They are happy with the result.', 'Sonuçtan memnunlar.', 10),
    ('articles', 'She has a small garden.', 'Küçük bir bahçesi var.', 4),
    ('articles', 'He wants an orange.', 'Bir portakal istiyor.', 5),
    ('articles', 'Please close the door.', 'Lütfen kapıyı kapat.', 6),
    ('articles', 'I saw a bird. The bird was blue.', 'Bir kuş gördüm. Kuş maviydi.', 7),
    ('articles', 'We need an hour.', 'Bir saate ihtiyacımız var.', 8),
    ('articles', 'Children need sleep.', 'Çocukların uykuya ihtiyacı vardır.', 9),
    ('articles', 'Water is important.', 'Su önemlidir.', 10),
    ('present-simple', 'He goes to work by bus.', 'İşe otobüsle gider.', 4),
    ('present-simple', 'I do not eat meat.', 'Et yemem.', 5),
    ('present-simple', 'Does your brother play tennis?', 'Erkek kardeşin tenis oynar mı?', 6),
    ('present-simple', 'We usually have breakfast at home.', 'Genellikle evde kahvaltı yaparız.', 7),
    ('present-simple', 'The shop closes at six.', 'Dükkân saat altıda kapanır.', 8),
    ('present-simple', 'She studies English every evening.', 'Her akşam İngilizce çalışır.', 9),
    ('present-simple', 'They do not watch television in the morning.', 'Sabahları televizyon izlemezler.', 10)
) AS example(code, english_text, turkish_translation, order_index)
JOIN grammar_concepts concept ON concept.code = example.code
JOIN grammar_lessons lesson ON lesson.concept_id = concept.id;

INSERT INTO grammar_exercises (
    concept_id, exercise_type, prompt, options_json, correct_answer, explanation, order_index)
SELECT concept.id, 'MULTIPLE_CHOICE', exercise.prompt, exercise.options_json::jsonb,
       exercise.correct_answer, exercise.explanation, exercise.order_index
FROM (VALUES
    ('sentence-basics', '“Kuşlar yuva yapar.” cümlesinin doğru İngilizce sırası hangisidir?',
     '["Birds build nests.", "Build birds nests.", "Nests birds build."]', 'Birds build nests.',
     'İngilizcede temel sıra özne + fiil + nesnedir: Birds + build + nests.', 2),
    ('sentence-basics', '“I read books.” cümlesinde işi yapan kimdir?',
     '["I", "read", "books"]', 'I',
     'I özne, read fiil, books nesnedir.', 3),
    ('sentence-basics', 'Doğru kelime sırasını seç: “Kız kardeşim hikâyeler okur.”',
     '["My sister reads stories.", "Reads my sister stories.", "Stories my sister reads."]',
     'My sister reads stories.', 'Özne olan My sister fiilden önce gelir; nesne stories fiilden sonra gelir.', 4),
    ('sentence-basics', '“The little cat sleeps.” cümlesinde fiil hangisidir?',
     '["The little cat", "sleeps", "little"]', 'sleeps',
     'Sleeps eylemi bildirir ve cümlenin fiilidir.', 5),
    ('subject-pronouns', '“Mina is my friend. ___ is kind.” cümlesini tamamla.',
     '["She", "He", "They"]', 'She',
     'Mina tek bir kadın kişiyi ifade ettiği için she kullanılır.', 2),
    ('subject-pronouns', '“My brother and I” yerine hangi özne zamiri kullanılır?',
     '["We", "They", "You"]', 'We',
     'Konuşan kişi gruba dahil olduğunda “kardeşim ve ben” we olur.', 3),
    ('subject-pronouns', '“The keys are on the table. ___ are mine.” cümlesini tamamla.',
     '["They", "It", "He"]', 'They',
     'Keys çoğul olduğu için they kullanılır.', 4),
    ('subject-pronouns', '“The cat is hungry. ___ needs food.” cümlesini tamamla.',
     '["It", "They", "We"]', 'It',
     'Tek bir hayvanı, cinsiyeti özellikle belirtilmeden anlatırken it kullanılır.', 5),
    ('be-verb', '“My phone ___ new.” cümlesini tamamla.',
     '["am", "is", "are"]', 'is', 'My phone tekil olduğu için is kullanılır.', 2),
    ('be-verb', '“___ they ready?” sorusunu tamamla.',
     '["Am", "Is", "Are"]', 'Are', 'They öznesiyle are kullanılır; soruda are öznenin önüne gelir.', 3),
    ('be-verb', '“I ___ tired.” cümlesini olumsuz yap.',
     '["am not", "is not", "are not"]', 'am not', 'I öznesinin be biçimi am; olumsuzluk için ardından not gelir.', 4),
    ('be-verb', '“Mert and Duru ___ students.” cümlesini tamamla.',
     '["am", "is", "are"]', 'are', 'İki kişi çoğul özne oluşturur ve are ile kullanılır.', 5),
    ('articles', '“She has ___ umbrella.” cümlesini tamamla.',
     '["a", "an", "the"]', 'an', 'Umbrella kelimesi sesli harf sesiyle başladığı için an kullanılır.', 2),
    ('articles', '“I saw a cat. ___ cat was black.” cümlesini tamamla.',
     '["A", "An", "The"]', 'The', 'Kediden ikinci kez söz edildiği için artık belirli olan the kullanılır.', 3),
    ('articles', '“He is ___ doctor.” cümlesini tamamla.',
     '["a", "an", "the"]', 'a', 'Doctor tekil ve sayılabilen bir meslek ismidir; ilk tanıtımda a kullanılır.', 4),
    ('articles', '“We need ___ hour.” cümlesini tamamla.',
     '["a", "an", "the"]', 'an', 'Hour kelimesinde h okunmadığı için kelime sesli harf sesiyle başlar; an kullanılır.', 5),
    ('present-simple', '“He ___ to work by bus.” cümlesini tamamla.',
     '["go", "goes", "going"]', 'goes', 'He öznesinde go fiili -es alır: goes.', 2),
    ('present-simple', '“They ___ coffee in the evening.” cümlesini tamamla.',
     '["drink", "drinks", "are drinking"]', 'drink',
     'They öznesinde present simple fiil yalın biçimdedir: drink.', 3),
    ('present-simple', '“She does not ___ meat.” cümlesini tamamla.',
     '["eats", "eat", "eating"]', 'eat',
     'Does not sonrasında ana fiil yalın biçimde kullanılır: eat.', 4),
    ('present-simple', '“___ your brother play tennis?” sorusunu tamamla.',
     '["Do", "Does", "Is"]', 'Does',
     'Your brother tekil üçüncü kişi olduğu için Does kullanılır; play yalın kalır.', 5)
) AS exercise(code, prompt, options_json, correct_answer, explanation, order_index)
JOIN grammar_concepts concept ON concept.code = exercise.code;
