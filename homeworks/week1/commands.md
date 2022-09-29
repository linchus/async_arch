# Разделение требований на состовляющие (команды)

## Таск-трекер
2 Авторизация в таск-трекере должна выполняться через общий сервис авторизации

    Actor:      User
    Command:    Login
    Data:       User, User.Role
    Event:      User.Logined

4 Новые таски может создавать кто угодно (администратор, начальник, разработчик, менеджер и любая другая роль). У задачи должны быть описание, статус (выполнена или нет) и рандомно выбранный попуг (кроме менеджера и администратора), на которого заассайнена задача.

    Actor:      User
    Command:    Create task
    Data:       Task, Task.Status, Task.AssignAmount, Task.ResolveAmount, Task.AssignedUser
    Event:      Task.Created

5 Менеджеры или администраторы должны иметь кнопку «заассайнить задачи», которая возьмёт все открытые задачи и рандомно заассайнит каждую на любого из сотрудников (кроме менеджера и администратора)

    Actor:      User
    Command:    Assign task
    Data:       Task, Task.Status, AssignedUser.id
    Event:      Task.Assigned

6 Каждый сотрудник должен иметь возможность отметить задачу выполненной.

    Actor:      User
    Command:    Resolve task
    Data:       Task, Task.Status, Task.AssignedUser
    Event:      Task.Resolved


## Аккаунтинг
2 Авторизация в дешборде аккаунтинга должна выполняться через общий сервис аутентификации.

    Actor:      User
    Command:    Login
    Data:       User, User.Role
    Event:      User.Logined

3 У счёта должен быть аудитлог того, за что были списаны или начислены деньги, с подробным описанием каждой из задач.

    Actor:      Task.Created, Task.Resolved, Task.Assigned
    Command:    Create audit log
    Data:       AccountTransactionLog, Task, Task.AssignAmount, Task.ResolveAmount, Task.AssignedUser, Account.id
    Event:      -

4a деньги списываются сразу после ассайна на сотрудника

    Actor:      Task.Created, Task.Assigned
    Command:    Withdraw account
    Data:       Task, Task.AssignAmount, AssignedUser.id, Account
    Event:      Account.Withdraw

4б деньги начисляются после выполнения задачи

    Actor:      Task.Resolved
    Command:    Fund account
    Data:       Task, Task.ResolveAmount, AssignedUser.id, Account
    Event:      Account.Fund

6a В конце дня необходимо считать сколько денег сотрудник получил за рабочий день

    Actor:      Cron/Timer
    Command:    Close day
    Data:       User.id, Date, Account, Account.Balance
    Event:      Account.CloseDay

6b отправлять на почту сумму выплаты.

    Actor:      Account.CloseDay
    Command:    Send report
    Data:       User.Email, Date, Account, Account.Balance
    Event:      -

7 После выплаты баланса (в конце дня) он должен обнуляться, и в аудитлоге всех операций аккаунтинга должно быть отображено, что была выплачена сумма.

    Actor:      Account.CloseDay
    Command:    Adjust account
    Data:       Date, Account, Account.Balance
    Event:      Account.Withdraw


## Аналитика
1 Авторизация в дашборде аналитики должна выполняться через общий сервис аутентификации.

    Actor:      User
    Command:    Login
    Data:       User
    Event:      User.Logined

2 Нужно указывать, сколько заработал топ-менеджмент за сегодня и сколько попугов ушло в минус.

    Actor:      Task.Created, Task.Resolved, Task.Assigned, Account.CloseDay
    Command:    Upsert stat
    Data:       DailyStat, DailyStat.Revenue, DailyStat.DebtorsAmount
    Event:      -

3 Нужно показывать самую дорогую задачу за день, неделю или месяц.

    Actor:      Task.Resolved
    Command:    Upsert task stat
    Data:       TaskStat, TaskStat.Date, TaskStat.TopTask, TaskStat.TopTaskAmount
    Event:      -


