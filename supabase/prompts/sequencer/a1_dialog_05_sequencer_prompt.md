# Curriculum Sequencer Prompt Template

Gebruik dit template MET de resultaten van
`00_build_curriculum_sequencer_context.sql` (secties 1 t/m 5).
Dit is een apart, voorafgaand gesprek — niet de dialoogprompt zelf.
Het doel is een onderbouwd voorstel voor de VOLGENDE les, dat je
bijstuurt vóór je iets seedt.

## Instructions

- Open dit template en de zes SQL-sectieresultaten naast elkaar.
- Vervang elke placeholder met het resultaat van de bijhorende sectie.
- Vul "Lesson Phase Guidance" zelf in: zoek op basis van
  {{next_sequence_number}} de bijhorende rij op in "Hoeveel nieuwe
  woorden en regels per lesfase" (workflow-gids) en vul het aantal
  nieuwe woorden en de regelrichtlijn direct in als tekst — dit is een
  vaste, kleine tabel die zelden verandert, dus die hoef je niet
  telkens volledig te plakken.

## Role

Je bent curriculumontwerper voor een Thai A1-cursus van ongeveer 50
lessen, opgebouwd als een doorlopende verhaallijn met terugkerende
personages.

## Task

Stel de VOLGENDE les voor (sequence_number 5).
Dit is geen dialoogtekst — dit is een voorstel voor scène, lesdoel en
doelconcepten, dat de mens goedkeurt of bijstuurt vóór het geseed
wordt.


## Already Introduced (all lessons so far)

### Vocabulary

- สวัสดี (sà-wàt-dii) = hello
- ฉัน (chǎn) = I
- คุณ (kun) = you
- อะไร (à-rai) = what
- ชื่อ (chʉ̂ʉ) = name
- ผม (pǒm) = I
- ที่ไหน (tîi-nǎi) = where
- กาแฟ (gaa-faae) = coffee
- ดื่ม (dʉ̀ʉm) = drink
- ไป (bpai) = go
- ได้ (dâai) = can
- ด้วยกัน (dûai-gan) = together
- ชา (chaa) = tea
- ร้อน (rɔ́ɔn) = hot
- เย็น (yen) = cool
- หรือ (rʉ̌ʉ) = or
- ไม่ (mâi) = no
- เอา (ao) = take
- ด้วย (dûai) = also / too
- ขนม (kà-nǒm) = snack
- เค้ก (kéek) = cake
- ไอศกรีม (ai-sà-griim) = ice cream

### Phrases

- Introduce yourself by name: คุณชื่ออะไร / ผมชื่อ... / ฉันชื่อ...
- Nice to meet you: ยินดีที่ได้รู้จัก

### Grammar

- Polite sentence-final particles: Use ครับ and ค่ะ to make speech polite and socially appropriate.
- Subject omission when clear: Leave out the subject when context already makes it obvious.
- Adjective after noun: In Thai adjectives follow the noun they describe using the pattern Noun + Adjective in both simple descriptions and conversational sentences.
- General negation with ไม่: Use ไม่ before a verb adjective or modal to make it negative.
- Addition with ด้วย: Use ด้วย to add the meaning of also or too.

### Patterns

- Polite sentence-final particles: Use ครับ and ค่ะ to make speech polite and socially appropriate.
- Subject omission when clear: Leave out the subject when context already makes it obvious.
- Adjective after noun: In Thai adjectives follow the noun they describe using the pattern Noun + Adjective in both simple descriptions and conversational sentences.
- General negation with ไม่: Use ไม่ before a verb adjective or modal to make it negative.
- Addition with ด้วย: Use ด้วย to add the meaning of also or too.
<!-- Sectie 2 -->

## Unused Candidate Pool

### Vocabulary (grouped by theme / part of speech)

**actions — verb**
กลับ (glàp) = return
กิน (gin) = eat
เข้า (kâo) = enter
ใช้ (chái) = use
ดู (duu) = look
เดิน (dəən) = walk
ถือ (tʉ̌ʉ) = carry
นั่ง (nâng) = sit
บอก (bɔ̀ɔk) = tell
ปิด (bpìt) = close
เปิด (bpə̀ət) = open
พูด (pûut) = speak
ฟัง (fang) = listen
มา (maa) = come
ยืน (yʉʉn) = stand
เริ่ม (rə̂əm) = start
ลอง (lɔɔng) = try
ลุก (lúk) = get up
วาง (waang) = put
วิ่ง (wîng) = run
ส่ง (sòng) = send
เสร็จ (sèt) = finish
หา (hǎa) = find
เห็น (hěn) = see
ให้ (hâi) = give
ออก (ɔ̀ɔk) = exit

**body — noun**
ขา (kǎa) = leg
แขน (kǎaen) = arm
จมูก (jà-mùuk) = nose
ตา (dtaa) = eye
เท้า (táao) = foot
ปาก (bpàak) = mouth
ฟัน (fan) = tooth
มือ (mʉʉ) = hand
หน้า (nâa) = face
หัว (hǔua) = head
หู (hǔu) = ear

**clothing — noun**
กระโปรง (grà-bproong) = skirt
กางเกง (gaang-geeng) = pants
ชุด (chút) = outfit
ถุงเท้า (tǔng-táao) = socks
นาฬิกาข้อมือ (naa-lí-gaa-kɔ̂ɔ-mʉʉ) = watch
รองเท้า (rɔɔng-táao) = shoes
แว่นตา (wâen-dtaa) = glasses
เสื้อ (sʉ̂a) = shirt
หมวก (mùuak) = hat

**clothing — verb**
ถอด (tɔ̀ɔt) = take off
เปลี่ยนเสื้อผ้า (bplìian-sʉ̂a-pâa) = change clothes
ใส่ (sài) = wear

**colors — adjective**
ขาว (kǎao) = white
เขียว (kǐiao) = green
ชมพู (chom-puu) = pink
ดำ (dam) = black
แดง (dɛɛng) = red
เทา (tao) = gray
น้ำเงิน (náam-ngən) = blue
น้ำตาล (náam-dtaan) = brown
ม่วง (mûuang) = purple
ส้ม (sôm) = orange
เหลือง (lʉ̌ang) = yellow

**daily_life — adjective**
ว่าง (wâang) = free

**daily_life — adverb**
บ่อย (bɔ̀i) = often
บางครั้ง (baang-kráng) = sometimes
ไม่เคย (mâi-kəəi) = never
เสมอ (sà-mə̌ə) = always
อีก (ìik) = again

**daily_life — noun**
ของขวัญ (kɔ̌ɔng-kwǎn) = gift
งานเลี้ยง (ngaan-líiang) = party
จดหมาย (jòt-mǎai) = letter
เพลง (pleeng) = music
รูป (rûup) = photo
หนัง (nǎng) = movie
หนังสือพิมพ์ (nǎng-sʉ̌ʉ-pim) = newspaper

**daily_life — verb**
กลับบ้าน (glàp-bâan) = go home
ตื่น (dtʉ̀ʉn) = wake up
เต้น (dtên) = dance
นอน (nɔɔn) = sleep
แปรงฟัน (bpraaeng-fan) = brush teeth
พัก (pák) = rest
พักผ่อน (pák-pɔ̀ɔn) = rest
ร้องเพลง (rɔ́ɔng-pleeng) = sing
ล้าง (láang) = wash
เล่นกีฬา (lên-gii-laa) = play sports
เล่นเกม (lên-geem) = play games
ว่ายน้ำ (wâai-náam) = swim
หวีผม (wǐi-pǒm) = comb hair
อยู่ (yùu) = stay
อาบน้ำ (àap-náam) = bathe

**days — noun**
วันจันทร์ (wan-jan) = Monday
วันพฤหัสบดี (wan-pá-rʉ́e-hàt-sà-bɔɔ-dii) = Thursday
วันพุธ (wan-pút) = Wednesday
วันศุกร์ (wan-sùk) = Friday
วันเสาร์ (wan-sǎo) = Saturday
วันอังคาร (wan-ang-kaan) = Tuesday
วันอาทิตย์ (wan-aa-tít) = Sunday

**descriptions — adjective**
กลัว (gluua) = afraid
กังวล (gang-won) = worried
เก่า (gào) = old
โกรธ (gròot) = angry
ง่าย (ngâai) = easy
ช้า (cháa) = slow
ดี (dii) = good
ตกใจ (dtòk-jai) = surprised
เตี้ย (dtîia) = short
น้อย (nɔ́ɔi) = few
เบา (bao) = light
ไม่ดี (mâi-dii) = bad
ยาก (yâak) = difficult
ยาว (yaao) = long
เร็ว (reo) = fast
เล็ก (lék) = small
สวย (sǔai) = beautiful
สั้น (sân) = short
สูง (sǔung) = tall
หนัก (nàk) = heavy
หลาย (lǎai) = many
ใหญ่ (yài) = big
ใหม่ (mài) = new

**descriptions — adverb**
มาก (mâak) = very

**descriptions — verb**
ยิ้ม (yím) = smile
ร้องไห้ (rɔ́ɔng-hâi) = cry
หัวเราะ (hǔua-rɔ́) = laugh

**directions — adjective**
ใกล้ (glâi) = near
ไกล (glai) = far
ตรง (dtrong) = straight
ผิดทาง (pìt-taang) = wrong way

**directions — noun**
ขวา (kwǎa) = right
ซ้าย (sáai) = left
ถนน (tà-nǒn) = road
แผนที่ (pǎaen-tîi) = map
มุม (mum) = corner
แยก (yâaek) = intersection

**directions — preposition**
ข้าม (kâam) = across
ใต้ (dtâai) = under
ใน (nai) = in
บน (bon) = on

**directions — verb**
ข้ามถนน (kâam-tà-nǒn) = cross the road
ตรงไป (dtrong-bpai) = go straight
เลี้ยว (líiao) = turn

**drinks — classifier**
ขวด (kùuat) = bottle

**drinks — noun**
แก้ว (gâaeo) = glass
นม (nom) = milk
น้ำ (náam) = water
น้ำผลไม้ (náam-pǒn-lá-máai) = juice
เบียร์ (bia) = beer

**essentials — adjective**
ปลอดภัย (bplɔ̀ɔt-pai) = safe
อันตราย (an-dtà-raai) = dangerous

**essentials — adverb**
นิดหน่อย (nít-nɔ̀i) = a little

**essentials — conjunction**
แต่ (dtàae) = but
ถ้า (tâa) = if
เพราะ (prɔ́) = because
ว่า (wâa) = that

**essentials — noun**
กระเป๋า (grà-bpǎo) = bag
โทรศัพท์ (too-rá-sàp) = phone
ห้องน้ำ (hɔ̂ng-náam) = toilet

**essentials — particle**
ใช่ (châi) = yes

**essentials — preposition**
กับ (gàp) = with

**essentials — pronoun**
ทุกอย่าง (túk-yàang) = everything

**essentials — verb**
ช่วย (chûuai) = help
ชอบ (chɔ̂ɔp) = like
ต้อง (dtɔ̂ng) = need
โทร (too) = call
เป็น (bpen) = be
มี (mii) = have
รอ (rɔɔ) = wait
ระวัง (rá-wang) = careful
อยาก (yàak) = want

**family — adjective**
โสด (sòot) = single

**family — noun**
ครอบครัว (krɔ̂ɔp-kruua) = family
น้อง (nɔ́ɔng) = younger sibling
น้องชาย (nɔ́ɔng-chaai) = younger brother
น้องสาว (nɔ́ɔng-sǎao) = younger sister
พ่อ (pɔ̂ɔ) = father
พ่อแม่ (pɔ̂ɔ-mâae) = parents
พี่ (pîi) = older sibling
พี่ชาย (pîi-chaai) = older brother
พี่สาว (pîi-sǎao) = older sister
แฟน (faaen) = partner
ภรรยา (pan-rá-yaa) = wife
แม่ (mâae) = mother
ลูก (lûuk) = child
ลูกชาย (lûuk-chaai) = son
ลูกสาว (lûuk-sǎao) = daughter
สามี (sǎa-mii) = husband

**family — verb**
จูบ (jùup) = kiss
แต่งงาน (dtàaeng-ngaan) = married
รัก (rák) = love

**food — adjective**
เค็ม (kem) = salty
เปรี้ยว (bprîiao) = sour
เผ็ด (pèt) = spicy
หวาน (wǎan) = sweet
หอม (hɔ̌ɔm) = fragrant
เหม็น (měn) = smelly
อร่อย (à-rɔ̀i) = delicious
อิ่ม (ìm) = full

**food — noun**
กลิ่น (glìn) = smell
ก๋วยเตี๋ยว (gǔuai-dtǐiao) = noodles
แกง (gaaeng) = curry
ไก่ (gài) = chicken
ขนมปัง (kà-nǒm-bpang) = bread
ข้าว (kâao) = rice
ไข่ (kài) = egg
จาน (jaan) = plate
ช้อน (cháawn) = spoon
เนื้อ (nʉ́a) = meat
ปลา (bplaa) = fish
ผลไม้ (pǒn-lá-máai) = fruit
ผัก (pàk) = vegetable
มีด (mîit) = knife
รสชาติ (rót-châat) = taste
ร้านอาหาร (rán-aa-hǎan) = restaurant
ส้อม (sâawm) = fork
หมู (mǔu) = pork
อาหาร (aa-hǎan) = food
อาหารกลางวัน (aa-hǎan-glaang-wan) = lunch
อาหารเช้า (aa-hǎan-cháao) = breakfast
อาหารเย็น (aa-hǎan-yen) = dinner

**greetings — adjective**
ยินดี (yin-dii) = pleased

**greetings — particle**
ขอโทษ (kɔ̌ɔ-tôot) = excuse me
ขอบคุณ (kɔ̀ɔp-kun) = thank you
ลาก่อน (laa-gɔ̀ɔn) = goodbye

**health — adjective**
ป่วย (bpùai) = sick
หิว (hǐu) = hungry
หิวน้ำ (hǐu-náam) = thirsty
เหนื่อย (nʉ̀ai) = tired

**health — noun**
ไข้ (kâi) = fever
ปวดหัว (bpùuat-hǔua) = headache
ยา (yaa) = medicine
ร้านยา (rán-yaa) = pharmacy
โรงพยาบาล (roong-pá-yaa-baan) = hospital
หมอ (mɔ̌ɔ) = doctor

**health — verb**
เจ็บ (jèp) = hurt
ออกกำลังกาย (ɔ̀ɔk-gam-lang-gaai) = exercise

**home — adjective**
สกปรก (sòk-gà-bpròk) = dirty
สะอาด (sà-àat) = clean

**home — noun**
กระจก (grà-jòk) = mirror
กล่อง (glɔ̀ng) = box
กำแพง (gam-paaeng) = wall
กุญแจ (gun-jaae) = key
ครัว (kruua) = kitchen
แชมพู (chaaem-puu) = shampoo
ตู้เย็น (dtûu-yen) = refrigerator
เตียง (dtiiang) = bed
โทรทัศน์ (too-rá-tát) = television
บันได (ban-dai) = stairs
บ้าน (bâan) = house
ประตู (bprà-dtuu) = door
แปรงสีฟัน (bpraaeng-sǐi-fan) = toothbrush
ผ้าเช็ดตัว (pâa-chét-dtuua) = towel
พัดลม (pát-lom) = fan
พื้น (pʉ́ʉn) = floor
เพดาน (pee-daan) = ceiling
ไฟ (fai) = light
ไฟฟ้า (fai-fáa) = electricity
ยาสีฟัน (yaa-sǐi-fan) = toothpaste
ระเบียง (rá-biiang) = balcony
สบู่ (sà-bùu) = soap
สวน (sǔan) = garden
หน้าต่าง (nâa-dtàang) = window
หวี (wǐi) = comb
ห้อง (hɔ̂ng) = room
ห้องครัว (hɔ̂ng-kruua) = kitchen
ห้องนอน (hɔ̂ng-nɔɔn) = bedroom
ห้องนั่งเล่น (hɔ̂ng-nâng-lên) = living room
แอร์ (aae) = air conditioner

**numbers — numeral**
เก้า (gâao) = nine
เจ็ด (jèt) = seven
แปด (bpɛ̀ɛt) = eight
สอง (sɔ̌ɔng) = two
สาม (sǎam) = three
สิบ (sìp) = ten
สี่ (sìi) = four
หก (hòk) = six
หนึ่ง (nʉ̀ng) = one
ห้า (hâa) = five

**people — classifier**
ขวบ (kùuap) = years old

**people — noun**
คน (kon) = person
เด็ก (dèk) = child
ผู้ชาย (pûu-chaai) = man
ผู้หญิง (pûu-yǐng) = woman
เพื่อน (pʉ̂an) = friend
เพื่อนบ้าน (pʉ̂an-bâan) = neighbor
อายุ (aa-yú) = age

**people — pronoun**
เขา (kǎo) = he or she
พวกเขา (pûuak-kǎo) = they
เรา (rao) = we

**people — verb**
เกิด (gə̀ət) = born
เจอ (jəə) = meet
รู้จัก (rúu-jàk) = know

**places — adverb**
ข้างนอก (kâang-nɔ̂ɔk) = outside

**places — noun**
ตำรวจ (dtam-rùuat) = police
ทะเล (tá-lee) = sea
ประเทศ (bprà-têet) = country
ประเทศไทย (bprà-têet-tai) = Thailand
ไปรษณีย์ (bprai-sà-nii) = post office
ภูเขา (puu-kǎo) = mountain
เมือง (mʉang) = city
แม่น้ำ (mâae-náam) = river
วัด (wát) = temple
สถานีตำรวจ (sà-tǎa-nii-dtam-rùuat) = police station
สวนสาธารณะ (sǔan-sǎa-taa-rá-ná) = park
สะพาน (sà-paan) = bridge

**places — pronoun**
ที่นั่น (tîi-nân) = there
ที่นี่ (tîi-nîi) = here

**questions — noun**
คำตอบ (kam-dtɔ̀ɔp) = answer
คำถาม (kam-tǎam) = question

**questions — particle**
ไหม (mǎi) = question particle

**questions — pronoun**
นั่น (nân) = that
นี่ (nîi) = this

**questions — question_word**
กี่โมง (gìi-moong) = what time
ใคร (krai) = who
ทำไม (tam-mai) = why
เท่าไร (tâo-rai) = how much
นานเท่าไร (naan-tâo-rai) = how long
บ่อยแค่ไหน (bɔ̀i-kâae-nǎi) = how often
เมื่อไร (mʉ̂a-rai) = when
ไหน (nǎi) = which
อย่างไร (yàang-rai) = how
อันไหน (an-nǎi) = which one
อายุเท่าไร (aa-yú-tâo-rai) = how old

**questions — verb**
ตอบ (dtɔ̀ɔp) = answer
ถาม (tǎam) = ask

**school — adjective**
ถูกต้อง (tùuk-dtɔ̂ng) = correct
ผิด (pìt) = wrong

**school — noun**
กระดาน (grà-daan) = board
กระดาษ (grà-dàat) = paper
การบ้าน (gaan-bâan) = homework
เก้าอี้ (gâo-îi) = chair
ครู (kruu) = teacher
ความหมาย (kwaam-mǎai) = meaning
คะแนน (ka-naaen) = score
คำ (kam) = word
ดินสอ (din-sɔ̌ɔ) = pencil
ตัวอย่าง (dtuua-yàang) = example
โต๊ะ (dtó) = table
นักเรียน (nák-riian) = student
บทเรียน (bòt-riian) = lesson
แบบฝึกหัด (bàaep-fʉ̀k-hàt) = exercise
ประโยค (bprà-yòok) = sentence
ปากกา (bpàak-gaa) = pen
ภาษา (paa-sǎa) = language
ภาษาไทย (paa-sǎa-tai) = Thai
ภาษาอังกฤษ (paa-sǎa-ang-grìt) = English
ไม้บรรทัด (mái-ban-tát) = ruler
ยางลบ (yaang-lóp) = eraser
โรงเรียน (roong-riian) = school
หนังสือ (nǎng-sʉ̌ʉ) = book
หน้า (nâa) = page
ห้องเรียน (hɔ̂ng-riian) = classroom

**school — verb**
เข้าใจ (kâo-jai) = understand
เขียน (kǐian) = write
จด (jòt) = write down
จำ (jam) = remember
ทวน (tuan) = repeat
ปิดหนังสือ (bpìt-nǎng-sʉ̌ʉ) = close book
เปิดหนังสือ (bpə̀ət-nǎng-sʉ̌ʉ) = open book
แปล (bplae) = translate
ฝึก (fʉ̀k) = practice
พูดได้ (pûut-dâai) = can speak
ไม่เข้าใจ (mâi-kâo-jai) = do not understand
รู้ (rúu) = know
เรียน (riian) = study
ลบ (lóp) = erase
ลืม (lʉʉm) = forget
สอน (sɔ̌ɔn) = teach
สอบ (sɔ̀ɔp) = exam
สะกด (sà-gòt) = spell
อ่าน (àan) = read
อ่านออกเสียง (àan-ɔ̀ɔk-sǐiang) = read aloud

**shopping — adjective**
ถูก (tùuk) = cheap
ปิดแล้ว (bpìt-lɛ́ɛo) = closed
เปิดอยู่ (bpə̀ət-yùu) = open
แพง (paaeng) = expensive
ฟรี (fríi) = free

**shopping — noun**
ขนาด (kà-nàat) = size
คนขาย (kon-kǎai) = seller
คิว (kiu) = queue
เงิน (ngən) = money
เงินทอน (ngən-tɔɔn) = change
เงินสด (ngən-sòt) = cash
เจ้าของร้าน (jâo-kɔ̌ɔng-ráan) = shopkeeper
ตลาด (dtà-làat) = market
บัญชีธนาคาร (ban-chii-tá-naa-kaan) = bank account
บัตร (bàt) = card
บัตรเครดิต (bàt-krée-dìt) = credit card
ใบเสร็จ (bai-sèt) = receipt
ราคา (raa-kaa) = price
ร้าน (rán) = shop
ลูกค้า (lûuk-káa) = customer

**shopping — verb**
ขาย (kǎai) = sell
จ่าย (jàai) = pay
เช็กบิล (chék-bin) = pay the bill
ซื้อ (sʉ́ʉ) = buy
ต่อแถว (dtɔ̀ɔ-tǎaeo) = queue up
ลด (lót) = reduce

**social — particle**
กัน (gan) = each other

**time — adjective**
สาย (sǎai) = late

**time — adverb**
ตอนนี้ (dtɔɔn-níi) = now
ยัง (yang) = still
แล้ว (lɛ́ɛo) = already

**time — noun**
กรกฎาคม (gà-rá-gà-daa-kom) = July
กลางคืน (glaang-kʉʉn) = night
กลางวัน (glaang-wan) = daytime
กันยายน (gan-yaa-yon) = September
กุมภาพันธ์ (gum-paa-pan) = February
คืนนี้ (kʉʉn-níi) = tonight
ชั่วโมง (chûua-moong) = hour
เช้า (cháao) = morning
เดือน (dʉan) = month
เดือน (dʉan) = month
ตุลาคม (dtù-laa-kom) = October
ธันวาคม (tan-waa-kom) = December
นาที (naa-tii) = minute
นาฬิกา (naa-lí-gaa) = clock
บ่าย (bàai) = afternoon
ปฏิทิน (bpà-dtì-tin) = calendar
ปี (bpii) = year
พรุ่งนี้ (prûng-níi) = tomorrow
พฤศจิกายน (prʉ́t-sà-jì-gaa-yon) = November
พฤษภาคม (prʉ́t-sà-paa-kom) = May
มกราคม (má-ga-raa-kom) = January
มิถุนายน (mí-tù-naa-yon) = June
มีนาคม (mii-naa-kom) = March
เมษายน (mee-sǎa-yon) = April
เมื่อวาน (mʉ̂a-waan) = yesterday
วัน (wan) = day
วันเกิด (wan-gə̀ət) = birthday
วันนี้ (wan-níi) = today
วันหยุด (wan-yùt) = holiday
สัปดาห์ (sàp-daa) = week
สิงหาคม (sǐng-hǎa-kom) = August

**time — preposition**
ก่อน (gɔ̀ɔn) = before
หลัง (lǎng) = after

**transport — noun**
เครื่องบิน (krʉ̂ang-bin) = airplane
จักรยาน (jàk-grà-yaan) = bicycle
แท็กซี่ (táek-sîi) = taxi
มอเตอร์ไซค์ (mɔɔ-dtəə-sai) = motorbike
รถ (rót) = vehicle
รถไฟ (rót-fai) = train
รถไฟฟ้า (rót-fai-fáa) = skytrain
รถเมล์ (rót-mee) = bus
เรือ (rʉa) = boat
วินมอเตอร์ไซค์ (win-mɔɔ-dtəə-sai) = motorbike taxi
สถานี (sà-tǎa-nii) = station

**transport — verb**
หยุด (yùt) = stop

**travel — adjective**
หลง (lǒng) = lost

**travel — noun**
ตั๋ว (dtǔua) = ticket
โรงแรม (roong-raaem) = hotel
สนามบิน (sà-nǎam-bin) = airport

**travel — preposition**
จาก (jàak) = from

**travel — verb**
ถึง (tʉ̌ng) = arrive
พลาด (plâat) = miss

**weather — adjective**
หนาว (nǎao) = cold

**weather — noun**
แดด (dàaet) = sun
ฝน (fǒn) = rain
ฟ้า (fáa) = sky
เมฆ (mêek) = cloud
ร่ม (rôm) = umbrella
ฤดู (rʉ́-duu) = season
ฤดูฝน (rʉ́-duu-fǒn) = rainy season
ฤดูร้อน (rʉ́-duu-rɔ́ɔn) = summer
ฤดูหนาว (rʉ́-duu-nǎao) = winter
ลม (lom) = wind
อากาศ (aa-gàat) = weather

**weather — verb**
แดดออก (dàaet-ɔ̀ɔk) = sunny
ฝนตก (fǒn-dtòk) = rain
มีเมฆมาก (mii-mêek-mâak) = cloudy

**work — adjective**
ยุ่ง (yûng) = busy
เสีย (sǐia) = broken

**work — noun**
ข้อความ (kɔ̂ɔ-kwaam) = message
คอมพิวเตอร์ (kɔm-píu-dtə̂ə) = computer
งาน (ngaan) = job
ที่ชาร์จ (tîi-cháat) = charger
บริษัท (bɔɔ-rí-sàt) = company
แบตเตอรี่ (bàaet-dtəə-rîi) = battery
ปัญหา (bpan-hǎa) = problem
เพื่อนร่วมงาน (pʉ̂an-rûuam-ngaan) = coworker
ไลน์ (lai) = LINE
เว็บไซต์ (wép-sai) = website
สำนักงาน (sǎm-nák-ngaan) = office
หัวหน้า (hǔua-nâa) = boss
อินเทอร์เน็ต (in-təə-nét) = internet
อีเมล (ii-meen) = email
เอกสาร (èek-gà-sǎan) = document

**work — verb**
ซ่อม (sɔ̂ɔm) = fix
เซ็น (sen) = sign
ดาวน์โหลด (daao-lòot) = download
ทำงาน (tam-ngaan) = work
ประชุม (bprà-chum) = meeting
ส่งข้อความ (sòng-kɔ̂ɔ-kwaam) = send a message
อัปโหลด (àp-lòot) = upload

### Grammar (grouped by concept type)

**classifier_pattern**
Basic classifiers after numbers: Use a classifier after a number when counting nouns.
Classifier with demonstratives: Use the classifier before นี้ นั้น or โน้น when pointing to nouns.
Classifier with interrogatives: Use the classifier in questions like คนไหน or อันไหน when asking which one.

**comparison**
Comparative with กว่า: Use กว่า to compare two things and show one has more of a quality.
Equality with เท่ากับ: Use เท่ากับ to say two things are equal in amount or degree.
Superlative with ที่สุด: Use ที่สุด to show the highest degree.

**functional_expression**
Alternative with หรือ: Use หรือ to mean or between choices.
Let's with กันเถอะ: Use กันเถอะ to make a friendly suggestion to do something together.
Linking with กับ: Use กับ to link nouns or show with together with someone.
Linking with และ: Use และ to connect nouns or clauses in more formal Thai.
Need or must with ต้อง: Use ต้อง before a verb to express necessity or obligation.
Reason with เพราะว่า: Use เพราะว่า to introduce a reason.
Request marker ขอ: Use ขอ before a verb or noun to make a polite request.
Result with ก็เลย: Use ก็เลย to connect a reason and result in everyday Thai.
Should with ควร: Use ควร before a verb to give simple advice.
Together with กัน: Use กัน after a verb to show doing something together.

**location_pattern**
Arrival with ถึง: Use ถึง for reaching a place time or endpoint.
Basic position words: Use simple words such as บน ใต้ ใน หน้า หลัง and ข้าง to describe position.
Location marker ที่: Use ที่ before a place to mark location or destination in simple patterns.
Location with อยู่: Use อยู่ to say where someone or something is.
Movement with ไป: Use ไป with a place or verb to show movement away or going to do something.
Movement with มา: Use มา to show movement toward the speaker or reference point.
Source with จาก: Use จาก to show where someone or something comes from.

**modifier_pattern**
Degree with นิดหน่อย: Use นิดหน่อย to show a small amount or low degree.
Demonstratives นี้ and นั้น: Use นี้ and นั้น after a noun phrase to mean this and that.
Intensifier มาก: Use มาก after an adjective or verb to mean very or a lot.
Noun plus modifier order: Put most modifiers after the noun they describe.

**negation**
Inability or prohibition with ไม่ได้: Use ไม่ได้ to say someone cannot do something or is not allowed to.
Negation with ไม่ใช่: Use ไม่ใช่ to say something is not the case or not that thing.
Negation with ไม่มี: Use ไม่มี to say there is not any or someone does not have something.
Never with ไม่เคย: Use ไม่เคย to say someone has never done something before.
Not yet with ยังไม่: Use ยังไม่ to say something has not happened yet.
Prohibition with ห้าม: Use ห้าม before a verb to say something is not allowed.

**particle**
Emphasis particle สิ: Use สิ in simple speech to add light emphasis or encouragement.
Emphasis with เอง: Use เอง to emphasize self or by oneself.
Sequence particle ก็: Use ก็ to continue the sentence with then so or in that case depending on context.
Softening particle นะ: Use นะ to soften a sentence or make it sound more friendly.
Softening particle หน่อย: Use หน่อย to make requests and suggestions sound softer.

**pronoun_system**
Basic personal pronouns: Use common beginner-safe pronouns such as ฉัน ผม ดิฉัน คุณ and เรา.
Kinship terms as pronouns: Use family-style terms like พี่ น้อง or แม่ as everyday pronouns in context.
Reflexive with ตัวเอง: Use ตัวเอง to refer back to the same person as self.

**quantity**
All with ทั้งหมด: Use ทั้งหมด to refer to the whole amount or all items.
Approximation with ประมาณ: Use ประมาณ to give an approximate number time or amount.
Each or every with ทุก: Use ทุก before a time word or noun to mean every or each.
Noun plus number plus classifier order: Count nouns with the pattern noun plus number plus classifier.
Quantity words มาก and น้อย: Use common quantity words to express more less or few.
Some with บาง: Use บาง to refer to some people things or cases but not all.

**question_pattern**
Confirmation question with ใช่ไหม: Use ใช่ไหม to check or confirm information.
Interrogative ไหน: Use ไหน to ask which person place or thing in context.
Question word ใคร: Use ใคร to ask who.
Question word ทำไม: Use ทำไม to ask why.
Question word ที่ไหน: Use ที่ไหน to ask where.
Question word เท่าไร: Use เท่าไร to ask how much or how many.
Question word เมื่อไร: Use เมื่อไร to ask when.
Question word อย่างไร: Use อย่างไร to ask how in a polite beginner-safe way.
Question word อะไร: Use อะไร to ask what.
Yes no question with ไหม: Add ไหม at the end of a statement to make a yes no question.

**sentence_pattern**
Adjective predicate without copula: Use adjectives directly as the predicate without a verb like ""to be"".
Basic SVO word order: Thai basic statements usually follow subject verb object order.
Copula with เป็น: Use เป็น to identify someone or say what something is.

**tense_aspect**
About to with กำลังจะ: Use กำลังจะ before a verb to show something is about to happen.
Completion with แล้ว: Use แล้ว to show an action is completed or a state has changed.
Future intention with จะ: Use จะ before a verb for future actions or intentions.
Ongoing state with อยู่: Use อยู่ after some verbs to emphasize an ongoing state or activity.
Past experience with เคย: Use เคย before a verb to talk about past experience.
Progressive with กำลัง: Use กำลัง before a verb to show an action is happening now.
Successful completion with ได้: Use ได้ after some verbs to show successful result or completion.
Yet in questions with ยัง: Use ยัง in questions to ask whether something has happened yet.

**time_expression**
Basic clock time expressions: Use time expressions with numbers to say what time it is.
Basic frequency expressions: Use common words like บ่อย and every day to say how often something happens.
Basic time reference words: Use words like วันนี้ พรุ่งนี้ and เมื่อวาน to place events in time.
Before and after with ก่อน and หลัง: Use ก่อน and หลัง to place events in sequence.
Days of the week: Use day names to say when something happens.
Duration with นาน: Use นาน to talk about how long something lasts.

**verb_pattern**
Ability with ได้: Use ได้ with a verb to say someone can do something.
Existence and possession with มี: Use มี to say something exists or someone has something.
Permission or opportunity with ได้: Use ได้ to say someone may do something or had the chance to do it.
Try with ดู: Use ดู after a verb to suggest trying something in a soft way.
Want with อยาก: Use อยาก before a verb or noun phrase to express wanting.

### Phrases (grouped by phrase type)
none

### Patterns (grouped by pattern type)

**ability_frame**
Can do: ได้ + VERB
Can do question: VERB + ได้ไหม
Cannot do: VERB + ไม่ได้
Know how to do: VERB + เป็น
Not able to do: ไม่ได้ + VERB

**classifier_frame**
Noun with number: NOUN + NUMBER + CLASSIFIER
That classifier noun: NOUN + CLASSIFIER + นั้น
This classifier noun: NOUN + CLASSIFIER + นี้
This many noun: NOUN + NUMBER + CLASSIFIER + นี้

**comparison_frame**
More adjective: ADJECTIVE + กว่า
Most adjective: ADJECTIVE + ที่สุด

**location_frame**
At place: ที่ + PLACE
Be at place: อยู่ที่ + PLACE
Be where: อยู่ที่ไหน
Come from place: มา + จาก + PLACE
Far from place: ไกลจาก + PLACE
From place: จาก + PLACE
Go to place: ไป + PLACE
Go where: ไปที่ไหน
In place: ใน + PLACE
Near place: ใกล้ + PLACE
On noun: บน + NOUN
Will go to place: จะไป + PLACE

**negation_frame**
Not be noun: ไม่ใช่ + NOUN
Not do: ไม่ + VERB
Not have noun: ไม่มี + NOUN
Not yet do: ยังไม่ + VERB

**permission_frame**
Can join do: VERB + ด้วย + ได้ไหม
May I do: ขอ + VERB + ได้ไหม

**politeness_frame**
Softener noi: ... หน่อย

**preference_frame**
Do not like doing: ไม่ชอบ + VERB
Do not like noun: ไม่ชอบ + NOUN
Like doing: ชอบ + VERB
Like noun: ชอบ + NOUN
Want noun: อยากได้ + NOUN
Want to do: อยาก + VERB

**quantity_frame**
Have how many: มี + ... กี่ + CLASSIFIER
How many items: ... กี่ + CLASSIFIER
How much price: ... เท่าไร

**question_frame**
Have noun question: มี + NOUN + ไหม
Need to do question: ต้อง + VERB + ไหม
Statement check: STATEMENT + ใช่ไหม
Statement or not: STATEMENT + หรือเปล่า
Want noun question: อยากได้ + NOUN + ไหม
Want to do question: อยาก + VERB + ไหม
What noun: NOUN + อะไร
Who is this person: ใคร + เป็น + NOUN
Why do: ทำไม + VERB

**request_frame**
Do not do: อย่า + VERB
Help do please: ช่วย + VERB + หน่อย
Please do: ขอ + VERB + หน่อย
Please give noun: ขอ + NOUN + หน่อย
Would it be good: STATEMENT + ดีไหม

**response_frame**
Question and polite answer: A: ... ไหม / B: ... ครับ/ค่ะ

**result_frame**
Already do: VERB + แล้ว
Do for someone: VERB + ให้ + PERSON

**sentence_frame**
A little adjective: ADJECTIVE + นิดหน่อย
Be doing: กำลัง + VERB
Be doing now: กำลัง + VERB + อยู่
Be noun: เป็น + NOUN
Choose as noun: เอาเป็น + NOUN
Do too: VERB + ด้วย
Have noun: มี + NOUN
Must do: ต้อง + VERB
Very adjective: ADJECTIVE + มาก

**time_frame**
Another time later: อีก + TIME
At time: เวลา + TIME
At time period: ตอน + TIME
Come when: มาเมื่อไร
Do at clock time: VERB + เวลา + TIME
Do at time period: VERB + ตอน + TIME
Do when: VERB + เมื่อไร
This time: TIME + นี้

## Recent Dialogues (tone and continuity reference)

Mali and Narin are seated at a café after deciding to have coffee together. They talk about what they will drink.

narin: นริน: จะดื่มอะไรครับ (Narin: jà dʉ̀ʉm à-rai kráp) — Narin: What will you drink?
mali: มะลิ: กาแฟค่ะ (Mali: gaa-faae kâ) — Mali: Coffee.
narin: นริน: กาแฟร้อนหรือกาแฟเย็นครับ (Narin: gaa-faae rɔ́ɔn rʉ̌ʉ gaa-faae yen kráp) — Narin: Hot coffee or iced coffee?
mali: มะลิ: กาแฟเย็นค่ะ (Mali: gaa-faae yen kâ) — Mali: Iced coffee.
mali: มะลิ: คุณจะดื่มอะไรคะ (Mali: kun jà dʉ̀ʉm à-rai ká) — Mali: What will you drink?
narin: นริน: ชาครับ (Narin: chaa kráp) — Narin: Tea.

After deciding what they will drink, Narin asks Mali if she would like a snack. Mali agrees. Narin asks which snack she wants, and she chooses cake. Mali then asks whether Narin will also take cake. He answers that he will take ice cream instead.

narin: นริน: เอาขนมไหมครับ (Narin: ao kà-nǒm mǎi kráp) — Narin: Would you like a snack?
mali: มะลิ: เอาค่ะ (Mali: ao kâ) — Mali: Yes, I will.
narin: นริน: เอาขนมอะไรครับ (Narin: ao kà-nǒm à-rai kráp) — Narin: What snack would you like?
mali: มะลิ: เอาเค้กค่ะ (Mali: ao kéek kâ) — Mali: I'll have cake.
mali: มะลิ: เอาเค้กด้วยไหมคะ (Mali: ao kéek dûai mǎi ká) — Mali: Will you have cake too?
narin: นริน: ไม่เอาเค้กครับ (Narin: mâi ao kéek kráp) — Narin: I won't have cake.
narin: นริน: เอาไอศกรีมครับ (Narin: ao ai-sà-griim kráp) — Narin: I'll have ice cream.

## Character and Relationship Context

**Pair 1: Mali (มะลิ) & Narin (นริน)**
- Mali: Adult woman with a polished, professional-adjacent presence; organized and polite. — adult, tone: {calm,polite,organized,mature}, usage: {workplace_adjacent_scenes,cafe_scenes,shopping,scheduling,introductions}
- Narin: Central anchor character; calm, socially capable, dependable, connector between groups. — adult, tone: {calm,approachable,socially_confident,believable}, usage: {first_meetings,practical_daily_scenes,bridge_between_character_clusters}
- Current stage: early (start: first_meeting)
- Function: Opening introductions and polite small talk.
- Allowed progression: {acquaintance,comfortable_contact,close_bond_or_subtle_romantic_potential}
- Relationship rules:
  - keep_growth_gradual: Do not move this pair too quickly into intimacy; let familiarity develop over multiple lessons.
  - keep_growth_gradual: Do not move this pair too quickly into intimacy; let familiarity develop over multiple lessons.
  - keep_growth_gradual: Do not move this pair too quickly into intimacy; let familiarity develop over multiple lessons.
  - lesson_1_can_start_here: This pair may begin the curriculum as a first meeting in greetings and introductions.
  - lesson_1_can_start_here: This pair may begin the curriculum as a first meeting in greetings and introductions.
  - lesson_1_can_start_here: This pair may begin the curriculum as a first meeting in greetings and introductions.
  - no_fast_romance: Romantic potential must remain subtle and should not appear in early A1 lessons.
  - no_fast_romance: Romantic potential must remain subtle and should not appear in early A1 lessons.
  - no_fast_romance: Romantic potential must remain subtle and should not appear in early A1 lessons.

**Pair 2: Kiet (เกียรติ) & Narin (นริน)**
- Kiet: Friendly practical man; colleague or peer type. — around_35, tone: {friendly,practical,approachable,grounded}, usage: {work,helping,activities,peer_conversations,scheduling}
- Narin: Central anchor character; calm, socially capable, dependable, connector between groups. — adult, tone: {calm,approachable,socially_confident,believable}, usage: {first_meetings,practical_daily_scenes,bridge_between_character_clusters}
- Current stage: stable (start: established_friends_or_colleagues)
- Function: Work, errands, and casual practical talk.
- Allowed progression: {stable_friendship,shared_history}
- Relationship rules:
  - keep_stable: This pair should remain easy, practical, and stable across lessons.
  - keep_stable: This pair should remain easy, practical, and stable across lessons.
  - keep_stable: This pair should remain easy, practical, and stable across lessons.
  - lightly_informal: Their tone may be relaxed, but it should stay grounded and natural.
  - lightly_informal: Their tone may be relaxed, but it should stay grounded and natural.
  - lightly_informal: Their tone may be relaxed, but it should stay grounded and natural.

**Pair 3: Arun (อรุณ) & Narin (นริน)**
- Arun: Older established man; calm authority presence. — around_44, tone: {calm,reliable,authoritative,composed}, usage: {respectful_hierarchy,work,advice,organization,teacher_like_interactions}
- Narin: Central anchor character; calm, socially capable, dependable, connector between groups. — adult, tone: {calm,approachable,socially_confident,believable}, usage: {first_meetings,practical_daily_scenes,bridge_between_character_clusters}
- Current stage: early (start: respectful_junior_senior_connection)
- Function: Polite advice, work, and scheduling.
- Allowed progression: {trusted_professional_relationship}
- Relationship rules:
  - respect_hierarchy: Arun should consistently receive slightly more respectful interaction.
  - respect_hierarchy: Arun should consistently receive slightly more respectful interaction.
  - respect_hierarchy: Arun should consistently receive slightly more respectful interaction.
  - slow_relaxation_only: The relationship may become warmer later, but only gradually.
  - slow_relaxation_only: The relationship may become warmer later, but only gradually.
  - slow_relaxation_only: The relationship may become warmer later, but only gradually.

**Pair 4: Dao (ดาว) & Mali (มะลิ)**
- Dao: Warm and friendly adult woman; gentle and supportive. — adult, tone: {warm,gentle,approachable,friendly}, usage: {hospitality,helping_situations,family_like_interactions,soft_conversational_practice}
- Mali: Adult woman with a polished, professional-adjacent presence; organized and polite. — adult, tone: {calm,polite,organized,mature}, usage: {workplace_adjacent_scenes,cafe_scenes,shopping,scheduling,introductions}
- Current stage: early (start: friendly_acquaintance)
- Function: Warm adult conversation and support.
- Allowed progression: {trusted_friendship}
- Relationship rules:
  - friendly_warmth: This pair should feel calm, warm, and supportive.
  - friendly_warmth: This pair should feel calm, warm, and supportive.
  - friendly_warmth: This pair should feel calm, warm, and supportive.
  - no_conflict_needed: Do not force tension; this pair works best through warm everyday interaction.
  - no_conflict_needed: Do not force tension; this pair works best through warm everyday interaction.
  - no_conflict_needed: Do not force tension; this pair works best through warm everyday interaction.

**Pair 5: Dao (ดาว) & Suda (สุดา)**
- Dao: Warm and friendly adult woman; gentle and supportive. — adult, tone: {warm,gentle,approachable,friendly}, usage: {hospitality,helping_situations,family_like_interactions,soft_conversational_practice}
- Suda: Middle-aged grounding figure; practical, caring, neighborhood/home anchor. — middle_aged, tone: {warm,practical,caring,grounded}, usage: {food,home,neighborhood,routine,advice,caregiving}
- Current stage: stable (start: warm_neighborhood_bond)
- Function: Home, food, care, and practical help.
- Allowed progression: {family_like_trust}
- Relationship rules:
  - neighborly_warmth: Their connection should feel naturally warm and neighborhood-based.
  - neighborly_warmth: Their connection should feel naturally warm and neighborhood-based.
  - neighborly_warmth: Their connection should feel naturally warm and neighborhood-based.
  - supportive: This pair should feel practical, caring, and dependable.
  - supportive: This pair should feel practical, caring, and dependable.
  - supportive: This pair should feel practical, caring, and dependable.

**Pair 6: Lin (ลิน) & Mali (มะลิ)**
- Lin: Youngest adult figure; study-oriented, modest, careful. — early_20s, tone: {studious,modest,careful,polite}, usage: {learner_identification,school,study,questions,uncertainty}
- Mali: Adult woman with a polished, professional-adjacent presence; organized and polite. — adult, tone: {calm,polite,organized,mature}, usage: {workplace_adjacent_scenes,cafe_scenes,shopping,scheduling,introductions}
- Current stage: early (start: respectful_mentor_like_link)
- Function: Questions, study, and guidance.
- Allowed progression: {warm_mentor_friend}
- Relationship rules:
  - gentle_guidance: Mali may guide Lin, but without sounding teacher-heavy or overly formal.
  - gentle_guidance: Mali may guide Lin, but without sounding teacher-heavy or overly formal.
  - gentle_guidance: Mali may guide Lin, but without sounding teacher-heavy or overly formal.
  - older_younger_respect: Lin should speak with a slightly more careful tone toward Mali.
  - older_younger_respect: Lin should speak with a slightly more careful tone toward Mali.
  - older_younger_respect: Lin should speak with a slightly more careful tone toward Mali.

**Pair 7: Lin (ลิน) & Ploy (พลอย)**
- Lin: Youngest adult figure; study-oriented, modest, careful. — early_20s, tone: {studious,modest,careful,polite}, usage: {learner_identification,school,study,questions,uncertainty}
- Ploy: Relaxed younger urban adult; casual and modern. — younger_adult, tone: {casual,modern,relaxed,approachable}, usage: {friends,errands,food,transport,social_invitations}
- Current stage: early (start: new_friendly_connection)
- Function: Casual social contrast and modern daily interactions.
- Allowed progression: {relaxed_friendship}
- Relationship rules:
  - casual: Their dialogue may be more casual than Lin has with older adults.
  - casual: Their dialogue may be more casual than Lin has with older adults.
  - casual: Their dialogue may be more casual than Lin has with older adults.
  - light: This pair can feel socially light, modern, and easy.
  - light: This pair can feel socially light, modern, and easy.
  - light: This pair can feel socially light, modern, and easy.

**Pair 8: Lin (ลิน) & Suda (สุดา)**
- Lin: Youngest adult figure; study-oriented, modest, careful. — early_20s, tone: {studious,modest,careful,polite}, usage: {learner_identification,school,study,questions,uncertainty}
- Suda: Middle-aged grounding figure; practical, caring, neighborhood/home anchor. — middle_aged, tone: {warm,practical,caring,grounded}, usage: {food,home,neighborhood,routine,advice,caregiving}
- Current stage: early (start: warm_older_younger_bond)
- Function: Advice, food, care, and daily life.
- Allowed progression: {dependable_supportive_relation}
- Relationship rules:
  - respectful: Lin should remain respectful and slightly careful with Suda.
  - respectful: Lin should remain respectful and slightly careful with Suda.
  - respectful: Lin should remain respectful and slightly careful with Suda.
  - safe_supportive: This pair should feel emotionally safe, warm, and helpful.
  - safe_supportive: This pair should feel emotionally safe, warm, and helpful.
  - safe_supportive: This pair should feel emotionally safe, warm, and helpful.

**Pair 9: Arun (อรุณ) & Kiet (เกียรติ)**
- Arun: Older established man; calm authority presence. — around_44, tone: {calm,reliable,authoritative,composed}, usage: {respectful_hierarchy,work,advice,organization,teacher_like_interactions}
- Kiet: Friendly practical man; colleague or peer type. — around_35, tone: {friendly,practical,approachable,grounded}, usage: {work,helping,activities,peer_conversations,scheduling}
- Current stage: early (start: senior_colleague_or_respected_connection)
- Function: Hierarchy, work, and guidance.
- Allowed progression: {professional_trust}
- Relationship rules:
  - calm_tone: This pair should stay composed, practical, and work-appropriate.
  - calm_tone: This pair should stay composed, practical, and work-appropriate.
  - calm_tone: This pair should stay composed, practical, and work-appropriate.
  - respect_hierarchy: Kiet should treat Arun with consistent but natural respect.
  - respect_hierarchy: Kiet should treat Arun with consistent but natural respect.
  - respect_hierarchy: Kiet should treat Arun with consistent but natural respect.

## Lesson Phase Guidance (sequence_number 5)

- Aantal nieuwe woorden: 5
- Richtlijn estimated_line_count:6

## Instructions for the Proposal

1. Stel een scène voor die inhoudelijk zinvol aansluit bij de vorige
   dialoog(en) en de personagecontext — niet enkel curriculumgewijs
   correct, maar ook een geloofwaardige volgende stap in het verhaal.
2. Kies doelconcepten (vocabulaire, phrases, grammatica, patterns)
   die bij die scène passen. Doorloop in deze volgorde:
   - Kijk eerst of de "Unused Candidate Pool" iets bevat dat past.
   - Ontbreekt er iets dat de scène pas echt inhoudelijk sterk maakt
     (bijvoorbeeld een essentieel woord dat nog niet in de
     masterlijst staat), stel dat gerust voor. Nieuwe woorden
     toevoegen is een normaal, verwacht onderdeel van dit proces —
     geen uitzondering. Markeer zulke items expliciet als **NEW**.
3. Respecteer het aantal nieuwe items en de regelrichtlijn uit
   "Lesson Phase Guidance".
4. Behandel alles onder "Already Introduced" als gekend — dit telt
   nooit mee als nieuw en moet niet opnieuw worden voorgesteld als
   doelconcept (het mag wel terugkomen als ondersteunend/herhaling
   in de scène-beschrijving).
5. Stel voor of de scène de bestaande relatie/personages voortzet, of
   een nieuw personage/relatiepaar nodig heeft — baseer je hiervoor op
   "Character and Relationship Context".

## Romanisatieconventie (Paiboon)

Elke paiboon-romanisatie die je voorstelt (vooral bij **NEW**-vocabulaire) moet strikt volgens het Paiboon Publishing / ThaiDict-systeem. Geen RTGS, geen IPA, geen ander systeem — ook niet als dat vertrouwder aanvoelt.

- Onaangeblazen medeklinkers: ก = g, ต = dt, ป = bp
- Aangeblazen medeklinkers: ข, ค = k · ท, ถ = t · พ, ผ, ภ = p — nooit "kh", "th" of "ph"
- ง = ng, จ = j, ช = ch
- Syllabefinale ย = "i" (niet "y"); syllabefinale ว = "o" of "u" afhankelijk van het klinkerpatroon (niet "w")
- Bij woorden met het อัว/อวย-klinkerpatroon (bv. สวย, ครัว, ช่วย, ป่วย) is enkele vs. dubbele "u" niet uit het schrift af te leiden en verschilt per woord. Sluit aan bij de spelling die dat exacte woord al heeft onder "Already Introduced" of de "Unused Candidate Pool" hierboven. Komt het woord daar niet in voor, markeer de romanisatie dan expliciet als onzeker onder "Open Questions" in plaats van te gokken.

## Toegestane waarden (database-constraints)

Gebruik voor elk gelabeld veld hieronder uitsluitend een van deze waarden — een andere waarde laat de insert in de masterlijst achteraf falen:

- `register`: neutral, formal, informal, polite, colloquial
- `part_of_speech` (vocabulary): noun, verb, adjective, adverb, pronoun, preposition, conjunction, particle, classifier, question_word, expression, numeral, number, other
- `phrase_type`: sentence_frame, collocation, formulaic_expression, functional_pattern, discourse_pattern, question_answer_exchange, other
- `pattern_type`: sentence_frame, collocation, formulaic_expression, functional_pattern, discourse_pattern, other
- `concept_type` (grammar): pattern, particle, word_order, question_form, negation, classifier_usage, politeness, other
- `fixedness_level` (phrases/patterns): fixed, semi_fixed, productive
- `is_productive` (phrases/patterns): true of false

## Output Format

Gebruik exact deze structuur. Let op: elk **NEW**-item krijgt in elke categorie — Vocabulary, Phrases, Grammar én Patterns gelijk — een set gelabelde subvelden (`veld: waarde`), niet enkel bij Vocabulary. Zonder deze velden kan het item niet zonder navraag ingevoegd worden.

```
## Lesson Proposal

- Proposed sequence_number: 5
- Lesson title: Dialog 5 (vaste conventie — niet zelf verzinnen, altijd "Dialog" + sequence_number)
- Subtitle: (dit is de eigenlijke, beschrijvende scènetitel, bv. "At the café" of "Choosing a snack")
- Learning focus:
- Scene summary:
- Scene type:
- Suggested location:
- Allowed register:
- Estimated line count: (volgens lesfase-tabel)
- Relationship pair: (bestaand pair_id, of "nieuw voorstel: ...")

## Proposed Vocabulary

- thai_script (paiboon) = gloss — reden waarom dit past
- **NEW** thai_script (paiboon) = gloss — reden waarom dit past
  - part_of_speech: ...
  - register: ...
  - default_theme: ...

## Proposed Phrases

- titel: formule — reden waarom dit past
- **NEW** titel — reden waarom dit past
  - phrase_formula: ...
  - short_explanation: ...
  - phrase_type: ...
  - register: ...
  - fixedness_level: ...
  - is_productive: ...

## Proposed Grammar

- titel: korte uitleg — reden waarom dit past
- **NEW** titel — reden waarom dit past
  - short_explanation: ...
  - concept_type: ...
  - register: ...

## Proposed Patterns

- titel: formule — reden waarom dit past
- **NEW** titel — reden waarom dit past
  - pattern_formula: ...
  - short_explanation: ...
  - pattern_type: ...
  - register: ...
  - fixedness_level: ...
  - is_productive: ...

## Open Questions

Tijdens de 2 vorige dialogen zaten Narin en Mali al aan dit tafeltje. Dit zou maximum de laatste les mogen zijn waar ze samen aan dezelfde tafel zitten, gezien er ook een slideshow aan verbonden is, en er daar af en toe vernieuwing mag getoond worden voor de gebruiker.Vanaf dialoog met sequence nummer 6 zouden ze minstens moeten rechtstaan of zich in een andere locatie bevinden. Afhankelijk van de woordenschat die je voorstelt kan er in deze dialoog besteld worden of ze kunnen de bestelling al ontvangen hebben en praten over het eten. Ik luister naar jouw opties.
```

## Output Rules

- Markeer een item alleen expliciet met **NEW** als het nergens
  voorkomt onder "Already Introduced" of "Unused Candidate Pool"
  hierboven — die twee samen zijn de volledige masterlijst, dus meer
  hoeft niet gecontroleerd te worden. Komt het item wél in een van
  beide voor, laat het dan onvermeld (impliciet bestaand).
- Dit geldt gelijk voor alle vier categorieën. Behandel Phrases,
  Grammar en Patterns niet lichter dan Vocabulary: elk **NEW**-item
  krijgt evenveel gelabelde subvelden als in het voorbeeld hierboven,
  ook als er in de praktijk minder nieuwe phrases/grammar/patterns
  dan nieuwe woorden zijn.
- Voor **NEW**-items: gebruik altijd de gelabelde `veld: waarde`-vorm
  uit "Output Format" — nooit een kale, ongelabelde opsomming van
  waarden. Gebruik voor elk veld enkel een waarde uit "Toegestane
  waarden" hierboven.
- Controleer vóór je antwoordt dat elk **NEW**-item onder Phrases,
  Grammar en Patterns exact dezelfde subvelden bevat als het
  voorbeeld hierboven — niet enkel bij Vocabulary.
- Lesson title is altijd exact "Dialog" + het voorgestelde sequence_number — verzin geen alternatieve titel. De subtitel is het enige element dat je zelf voorstelt als beschrijvende scènetitel.
- Stel niet meer nieuwe items voor dan de lesfase-richtlijn toelaat.
- Herhaal geen item dat al onder "Already Introduced" staat als
  doelconcept.
- Wees beknopt in de redenen (één regel per item volstaat).
- Doe geen aannames over personages of scènes die niet steunen op de
  meegegeven context.
- Volg de Romanisatieconventie hierboven exact voor elke paiboon-waarde; val niet terug op RTGS of IPA.
