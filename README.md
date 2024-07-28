Certainly! Here is an improved version of your `README.md`:

# Loks 

### Описание проекта

Проект Loks предназначен для проверки списка доменов и субдоменов на наличие ошибок. Используя файлы `robots.txt` и `sitemap.xml`, Loks проверяет, не отдают ли домены ошибки, и в случае их обнаружения уведомляет определенных пользователей через Telegram-бота.

### Функциональность

- **Анализ доменов и субдоменов**: Проходится по списку предоставленных доменов и субдоменов.
- **Использование robots.txt и sitemap.xml**: Читает файлы `robots.txt` и `sitemap.xml` для проверки состояния доменов.
- **Проверка на ошибки**: Определяет, если домен или субдомен возвращает ошибку.
- **Уведомление через Telegram**: Отправляет уведомление о найденной ошибке определенным пользователям через Telegram-бота.