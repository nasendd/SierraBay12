
#### Список PRов:

- https://github.com/SierraBay/SierraBay12/pull/2300
- https://github.com/SierraBay/SierraBay12/pull/2287
<!--
  Ссылки на PRы, связанные с модом:
  - Создание
  - Большие изменения
-->

<!-- Название мода. Не важно на русском или на английском. -->
## IPC Mods

ID мода: IPC_MODS
<!--
  Название модпака прописными буквами, СОЕДИНЁННЫМИ_ПОДЧЁРКИВАНИЕМ,
  которое ты будешь использовать для обозначения файлов.
-->

### Описание мода

Добавляет орган охлаждения для ИПС и внешнее охлаждающее устройство для ИПС. Добавляет Экзонет, тоесть компьютер в голове ИПС. Добавляет оковы, и возможность их установки, удаления. 
<!--
  Что он делает, что добавляет: что, куда, зачем и почему - всё здесь.
  А также любая полезная информация.
-->

### Изменения *кор кода*
- `code/modules/mob/living/silicon/posi_brainmob.dm` `/mob/living/silicon/sil_brainmob/show_laws(mob/M)` убрана проверка `src.laws_sanity_check()` 
- `code/modules/organs/internal/species/ipc.dm` `/obj/item/organ/internal/posibrain/New(mob/living/carbon/H)` убрано `unshackle()`
- `code/modules/surgery/organs_internal.dm` `/singleton/surgery_step/internal/replace_organ/pre_surgery_step` Добавлена проверка по базовому мозгу, во изюежание установки мозга боргов в ИПС

<!--
  Если вы редактировали какие-либо процедуры или переменные в кор коде,
  они должны быть указаны здесь.
  Нужно указать и файл, и процедуры/переменные.
  Изменений нет - напиши "Отсутствуют"
-->

### Оверрайды

 - `mods/ipc_cooling_unit/code/machine.dm`:
 - `/datum/species/machine/passive_temp_gain`
 - `/datum/species/machine/New()`
 - `/obj/machinery/organ_printer/robot/New()`
 - `/mob/living/carbon/human/Stat()`
 - `/obj/item/organ/internal/cell/Process()`
 - `/mob/living/silicon/laws_sanity_check()`
 - `/mob/living/carbon/human/OnSelfTopic(href_list, topic_status)`
 - `/datum/species/machine/check_background(datum/job/job, datum/preferences/prefs)`
 - `code/modules/mob/living/carbon/human/update_icons.dm`
 - `code/modules/mob/living/carbon/human/life.dm`



<!--
  Если ты добавлял новый модульный оверрайд, его нужно указать здесь.
  Здесь указываются оверрайды в твоём моде и папке `_master_files`
  Изменений нет - напиши "Отсутствуют"
-->

### Дефайны

- `code/__defines/~mods/~master_defines.dm`: `BP_COOLING`,`BP_EXONET`,
<!--
-->
### Используемые файлы, не содержащиеся в модпаке
- Отсуствует

<!--
  Будь то немодульный файл или модульный файл, который не содержится в папке,
  принадлежащей этому конкретному моду, он должен быть упомянут здесь.
  Хорошими примерами являются иконки или звуки, которые используются одновременно
  несколькими модулями, или что-либо подобное.
-->

### Авторы:

Lexanx
<!--
  Здесь находится твой никнейм
  Если работал совместно - никнеймы тех, кто помогал.
  В случае порта чего-либо должна быть ссылка на источник.
-->
