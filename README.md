# AWS CloudWatch + Event + Lambda = Start/Stop Instances

Метою є створення автоматичного старту інстансів, які знаходяться у вимкнутому стані, при збільшені навантаження на **"NGINX proxy server"**.
Першим кроком є встановлення **"cloudwatch agent"** на **"nginx proxy server"** для постійного відправлення логів до **"CloudWatch"**. Отримані логи розбиваємо по паттерну в **"CloudWatch"** та створюємо **"alert"**.
**"Alert"** по тригеру активує **"Lambda"**, яка виконає дію **"Start"** або **"Stop"** для наших інстансів.

## [Create IAM policy and role]([https://console.aws.amazon.com/iam/](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/create-iam-roles-for-cloudwatch-agent-commandline.html)).

### Create role for EC2

В першу чергу треба створити роль для інстансу у котрий ми встановимо **"cloudwatch agent"**, щоб **"cloudwatch agent"** міг відправляти логи до **"CloudWatch"**. Заходимо до свого аккаунту **"AWS"**, та переходимо у сервіс **"[IAM](https://console.aws.amazon.com/iam/)"**. Натискаємо вкладку **"Roles"**, та вибираємо **"Create role"**. Для вікна **"Use case"** потрібно вибрати для **"ЕС2"**. При виборі політик для нашої ролі потрібно вибрати **"CloudWatchAgentServerPolicy"**, a роль AWS рекомендує назвати саме **"CloudWatchAgentServerRole"**. Натискаємо створити роль.

### Create role and policy for Lambda

![Знімок екрана 2024-04-24 164544](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/40ba48a5-5979-4674-b0d4-03ffd8ead5f9)

![Знімок екрана 2024-04-24 164631](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/4c6ec4d2-f1a5-4333-bedd-d01ea637abef)

