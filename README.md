# AWS CloudWatch + EventBridge + Lambda

Метою є створення автоматичного старту інстансів, які знаходяться у вимкнутому стані, при збільшені навантаження на **"NGINX proxy server"**.
Першим кроком є встановлення **"cloudwatch agent"** на **"nginx proxy server"** для постійного відправлення логів до **"CloudWatch"**. Отримані логи розіб'ємо по паттерну в **"CloudWatch"** та створюємо **"alert"**.
**"Alert"** має по тригеру активувати **"Lambda"**, яка виконає дію **"Start"** або **"Stop"** для наших інстансів.

## [Create IAM policy and role](https://console.aws.amazon.com/iam/).

