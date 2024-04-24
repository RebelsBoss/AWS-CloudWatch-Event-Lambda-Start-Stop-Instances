# AWS CloudWatch + Event + Lambda = Start/Stop Instances

Метою є створення автоматичного старту інстансів, які знаходяться у вимкнутому стані, при збільшені навантаження на **"NGINX proxy server"**.
Першим кроком є встановлення **"cloudwatch agent"** на **"nginx proxy server"** для постійного відправлення логів до **"CloudWatch"**. Отримані логи розбиваємо по паттерну в **"CloudWatch"** та створюємо **"alert"**.
**"Alert"** по тригеру активує **"Lambda"**, яка виконає дію **"Start"** або **"Stop"** для наших інстансів.

## [Create IAM policy and role]([https://console.aws.amazon.com/iam/](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/create-iam-roles-for-cloudwatch-agent-commandline.html)).

### Create role for EC2

В першу чергу треба створити роль для інстансу у котрий ми встановимо **"cloudwatch agent"**, щоб **"cloudwatch agent"** міг відправляти логи до **"CloudWatch"**. Заходимо до свого аккаунту **"AWS"**, та переходимо у сервіс **"[IAM](https://console.aws.amazon.com/iam/)"**. Натискаємо вкладку **"Roles"**, та вибираємо **"Create role"**. Для вікна **"Use case"** потрібно вибрати для **"ЕС2"**. При виборі політик для нашої ролі потрібно вибрати **"CloudWatchAgentServerPolicy"**, a роль AWS рекомендує назвати саме **"CloudWatchAgentServerRole"**. Натискаємо створити роль.

![Знімок екрана 2024-04-24 164544](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/40ba48a5-5979-4674-b0d4-03ffd8ead5f9)

![Знімок екрана 2024-04-24 164631](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/4c6ec4d2-f1a5-4333-bedd-d01ea637abef)

![Знімок екрана 2024-04-24 164720](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/d78fbb81-316f-41ed-9834-73263e44dcfa)

### Create role and policy for Lambda

Створюємо політику для ролі **"Lambda function"**. Переходимо до вкладки **"Policies"** та натискаємо **"Create policy"**. У вкладенні **"Policy editor"** вибираємо **"JSON"**, копіюємо туди наш файл [**"lambda-policy.json"**](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/blob/main/lambda-policy.json) та вставляємо політику.

![Знімок екрана 2024-04-24 170838](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/2574d210-d887-496f-b93e-a022a88ab6f1)

![Знімок екрана 2024-04-24 170913](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/ddf0f36a-ece2-41ed-99b4-56d03c493993)

Далі створюємо роль по інструкції вище, та до ролі додаємо створену політику.

![Знімок екрана 2024-04-24 164544](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/51e6baf9-b48e-41a8-baf5-3eaa7c30b908)

![Знімок екрана 2024-04-24 170957](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/0d7557ea-e59a-4879-8fa0-27219d3e51b6)

## [Add role for EC2](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/iam-roles-for-amazon-ec2.html#attach-iam-role)

Вибираємо необхідний нам сервер. Натискаємо **"Actions"**, в розгорнутому списку вибираємо **"Security"**, та натискаємо **"Modify IAM role"**.

![Знімок екрана 2024-04-24 171818](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/a1a18625-ba49-430d-bed6-418d459cf74b)

## [Install CloudWatch agent](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Agent-commandline-fleet.html)

Вибираємо необхідну нам операційну систему, та копіюємо посилання для завантаження. Виконуємо ці команди на сервері куди встановлюємо агента. 

```
wget <необхідне нам посилання>
```

Після завантаження необхідно встановити залежно від нашої операційної системи команда може змінюватись (приклад для Linux server Deb package).


```
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
```

Перевірити стату нашого агенту можливо наступною командою.

```
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status
```
