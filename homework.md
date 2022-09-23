# Домашка 0

## Схема сервисов
![scheme](/proto.jpeg)

## Сервисы

### Auth
Отдельный сервис для авторизации и, видимо, управления пользователями
Скорее всего OAuth 2.0

### Tack tracker
Сервис для работы с задачами. Позволяет управлять и просматривать задачи.

### Accounting
Сервис по учету шекелей. Показывает общую стату и информацию по счетам для попугов

### Analytics
Сервис для просмотра статистики по задачам

### Email service
Сервис для отправки писем

### Message broker
Брокер сообщений для асинхронной коммуникации


## Коммуникации

Все коммуникации асинхронные, кроме взаимодействия с сервисом авторизации.

### Auth
- pub "create user", user_payload
- pub "update user", user_payload
- pub "delete user", user_payload

### Tack tracker
- pub "create task", task_payload
- pub "assign task", task_id, user_id
- pub "resolve task", task_id, user_id
- sub "create user"
- sub "update user"
- sub "delete user"

### Accounting
- pub "send email", email_payload
- pub "payout", user_id, payment_payload
- sub "create task"
- sub "assign task"
- sub "resolve task"
- sub "create user"
- sub "update user"
- sub "delete user"

### Analytics
- sub *

### Email service
- sub "send email"


