#/bin/bash
#Указываем откуда и куда делать бэкапы
from="Путь к папке из которой будем копировать"
archive="Путь к папке с Я.Диском"

#Создаем переменную указывающую на скрипт, отвечающий за отправку в телеграм
tg='./telegram.sh'

#Указываем папки для бэкапа, если нужна не вся
which_dir="перечислить имена папок через пробел"

#Создание папки с бэкапами по дате
mkdir -p $archive/$(date +"%Y-%m-%d")

#Создание папки с датой бэкапа
backup_dir="$archive/$(date +"%Y-%m-%d")"

# Начинаем цикл for, где для каждого значения переменной (списка в ней) делаем (do) набор действий
for dir in $which_dir; do
echo "Копируем $from в $backup_dir"

# Рекурсивное копирование (-a), с выводом процесса (-v) и форматированием (-h)
rsync -avh  $from$dir $backup_dir
done

# Архивируем всю папку, в которой лежит бекап со сжатием gzip (-z)
# c – создает новый файл .tar;
# v – выводит подробное описание процесса сжатия;
# f – имя файла.
# z - сжатие gzip, чтобы уменьшить размер архива.
tar -cvzf $archive/backup_$(date +"%Y-%m-%d").tar.gz $backup_dir

# освобождаем место
rm -rf $backup_dir

#Перезапуск яд
yandex-disk stop
yandex-disk start

#Отправляем сообщение с названием бэкапа в телеграм. Если не хотим в тг - меняем $tg на echo
$tg "backup_$(date +"%Y-%m-%d").tar.gz готов" >> /dev/null

# Получаем список бекапов из папки, в которой они хранятся.
backup_list=$(ls $archive/ | grep backup)

# Создаем переменную с текущим месяцем
month=$(date +"%m")

# Задаем дату, когда бекап будет считаться устаревшим.
expire_date=$(date +"%d" -d '-3 day')
echo "Удаляем бекапы, старше $(date +"%d.%m.%Y" -d '-3 day')"
for file in $backup_list; do

# Получаем дату бекапа
backup_date=$(echo $file | awk -F"-" '{print $2}')

echo "backup_2022-$backup_date-$month.tar.gz"

done
# Создаем условие, если переменная backup_date меньше чем expire_date
# тогда удаляем файл бекапа
if [[ $backup_date < $expire_date ]]
then
	echo "Удаляем файл  backup_2022-$backup_date-$month.tar.gz"
	rm -f $archive/backup_2021-$backup_date-$month.tar.gz
fi

#Сообщаем о том, что новые бэкапы сделаны, а старые удалены. Если не хотим в тг - меняем $tg на echo
$tg "Бэкапы актуализированы" >> /dev/null
