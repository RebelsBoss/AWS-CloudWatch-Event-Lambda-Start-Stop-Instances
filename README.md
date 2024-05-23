# AWS CloudWatch + Event + Lambda = Start/Stop Instances

Метою є створення автоматичного старту інстансів, які знаходяться у вимкнутому стані, при збільшені навантаження на **"NGINX proxy server"**.
Необхідно встановити **"cloudwatch agent"** на **"nginx proxy server"** для постійного відправлення логів до **"CloudWatch"**. Отримані логи розбиваємо по паттерну в **"CloudWatch"** та створюємо **"alert"**.
**"Alert"** по тригеру активує **"Lambda"**, яка виконає дію **"Start"** або **"Stop"** для наших інстансів.

## [Create IAM policy and role](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/create-iam-roles-for-cloudwatch-agent-commandline.html).

### Create role for EC2

В першу чергу треба створити роль для інстансу у котрий ми встановимо **"cloudwatch agent"**, щоб **"agent"** міг відправляти логи до **"CloudWatch"**. Заходимо до свого аккаунту **"AWS"**, та переходимо у сервіс **"[IAM](https://console.aws.amazon.com/iam/)"**. Натискаємо вкладку **"Roles"**, та вибираємо **"Create role"**. Для вікна **"Use case"** потрібно вибрати для **"ЕС2"**. При виборі політик для нашої ролі потрібно вибрати **"CloudWatchAgentServerPolicy"**, в полі ім'я для ролі AWS рекомендує називати її **"CloudWatchAgentServerRole"**. Натискаємо створити роль.

![Знімок екрана 2024-04-24 164544](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/40ba48a5-5979-4674-b0d4-03ffd8ead5f9)

![Знімок екрана 2024-04-24 164631](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/4c6ec4d2-f1a5-4333-bedd-d01ea637abef)

![Знімок екрана 2024-04-24 164720](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/d78fbb81-316f-41ed-9834-73263e44dcfa)

### [Create role and policy for Lambda](https://repost.aws/knowledge-center/start-stop-lambda-eventbridge#:~:text=Create%20an%20IAM%20policy%20and%20IAM%20role%20for%20your%20Lambda%20function)

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

![Знімок екрана 2024-04-29 115801](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/8f90ce8c-830c-498b-8941-c2c790b56316)


```
wget <необхідне нам посилання>
```

Після завантаження необхідно встановити залежно від нашої операційної системи команда може змінюватись (приклад для **"Linux server Debian package"**).


```
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
```

Перевірити стату нашого агенту можливо наступною командою.

```
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status
```

## [Config log nginx](https://docs.nginx.com/nginx/admin-guide/monitoring/logging/#:~:text=All%20time%20values%20are%20measured%20in%20seconds%20with%20millisecond%20resolution).

Необхідно налаштувати логування **"nginx"** так, щоб він писав необхідні логи для **"CloudWatch alarm"**. На сервері треба додати до файлу конфігурації **"nginx"** наступні метрики, які він буде логувати (шлях до файлу **"/etc/nginx/nginx.conf"**).

```
http {
    #CloudWatch Log Format 
    log_format clwatch 		'$remote_addr - $remote_user [$time_local] '
                            		'"$request" $status $body_bytes_sent '
                             		'"$http_referer" "$http_user_agent"'
                             		'$request_time $upstream_connect_time
                                      $upstream_header_time $upstream_response_time';
}
```
![Знімок екрана 2024-04-29 170648](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/4ea57101-5246-415d-a0f8-85fd1f1692e6)

Тепер додаємо в файли **"nginx"** конфігурації наш лог по створеному вище лог формату (шлях до файлів **"/etc/nginx/sites-available/"**).

```
# Add log with CloudWatch format
access_log     /var/log/nginx/<your_server_name>.clwatch clwatch;
```
![Знімок екрана 2024-04-29 171550](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/64d5bbb9-032d-4c5d-a0f1-3a58c66e278b)

**"Важливо!!!"** Додати в **"ssl"** конфігах зміни у двох місцях (також **"location"** блоці конфіга).
Після всіх налаштувань, необхідно перезапустити **"nginx"** під юзером, яким він налаштований та запущений. 
Також додаю непогану документацію по налаштуванню логування [**"nginx"**](https://www.ertugral.dev/blog/monitoring-nginx-with-cloudwatch) саме для **"CloudWatch"**.

## [Create config file for amazon-cloudwatch-agent.json](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Agent-Configuration-File-Details.html#CloudWatch-Agent-Configuration-File-Agentsection).

Пропоную створити простий конфіг файл, без налаштування **"Agent section, Metrics section та Traces section"**. По цьому файлу буде працювати наш **"cloudwatch agent"**. Шлях розташування цього файлу **"/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json"**. 
Додаю [приклад](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/blob/main/amazon-cloudwatch-agent.json).

Опис полів:
1. **"file_path"** шлях до створених вище **"nginx"** логів.
2. **"log_group_name"** имя лог групи у **"AWS CloudWatch"**.
3. **"log_stream_name"** тип логу.

![Знімок екрана 2024-04-29 172550](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/d23b961e-0c59-4a23-a07a-43224b7ee99c)

Тепер можемо [**"стартувати"**](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Agent-commandline-fleet.html#:~:text=Start%20the%20CloudWatch%20agent%20using%20the%20command%20line) нашого агента наступною командою.

```
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:<шлях до нашого файлу>
```

## [Create Lambda function for EC2 Start/Stop](https://repost.aws/knowledge-center/start-stop-lambda-eventbridge#:~:text=Create%20Lambda%20functions%20that%20stop%20and%20start%20your%20instances).

[Заходимо](https://console.aws.amazon.com/lambda/) до інструменту та вибираємо **"Create function"**. Окремо має бути дві функції, одна для **"Start"**, друга для **"Stop"**.

![Знімок екрана 2024-04-30 090921](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/ae6eac77-fce6-4d18-b3d5-b7f02d2eda2e)

Вибираємо **"Author from scratch"**. Для **"Basic information"** пишемо ім'я функції, **"Runtime"** вибираємо **"Python 3.9"** а також додаємо створену вище роль.

![Знімок екрана 2024-04-30 091436](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/b2880d3f-f5a1-41dd-8825-fed4f1e8a37b)

![Знімок екрана 2024-04-30 091617](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/05ed4e8f-4bfc-496b-bf70-24f0e8805e87)

Створюємо функцію. Після створення функції, заходемо до неї та у вкладці **"Code"** додаємо наступний код для [**"Stop"**](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/blob/main/stop-instance.py), для[**"Start"**](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/blob/main/start-instance.py).
Натискаємо **"Deploy"**.

![Знімок екрана 2024-04-30 092827](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/b0d4c6d9-a863-4469-aec9-5c17642ff31e)

## [Access CloudWatch for Lambda](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html#alarms-and-actions:~:text=Lambda%20alarm%20actions).

**"AWS"** пропонує два варіанти для виконання всіх можливих завдань, кодом через **"cloudshell"** або через веб, так само й тут. Треба створити **"AssumeRole"** для **"Lambda"**, яка дозволить **"CloudWatch"** запускати її. Приклад [ролі](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/blob/main/lambda-assume-role.json). Я використовував і рекомендую, запустити цей скрипт вказав свої перемінні у **"cloudshell"** :

```
aws lambda add-permission \
--function-name <name_function> \
--statement-id AlarmAction \
--action 'lambda:InvokeFunction' \
--principal lambda.alarms.cloudwatch.amazonaws.com \
--source-account <number_account> \
--source-arn arn:aws:cloudwatch:<region>:<number_account>:alarm:<name_your_alarm>
```

![Знімок екрана 2024-04-30 111000](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/f886d738-46b9-4321-ad7a-ac56b0b20e17)

Після цієї команди **"AssumeRole"** з'явиться в наступній секції :

![Знімок екрана 2024-04-30 112946](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/6714aa8f-7b4e-4d24-9b05-d0d9df3c3238)

В цій вкладці опускаємось нижче і знаходимо наступну вкладку :

![Знімок екрана 2024-04-30 113041](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/fcf94361-b279-43fc-8c5f-87e7f40380dd)

## Setting AWS CloudWatch

Створення **"metric filter"**. Зліва у меню знаходимо **"Log group"**. У списку груп знаходимо необхідну нам групу та заходимо в неї (лог група береться з налаштування поля **"log_group_name"** у конфігурації **"amazon-cloudwatch-agent.json"**, яку описано вище). У групі натискаємо **"Metric filters"** та **"Create metric filter"**.

![Знімок екрана 2024-05-23 170434](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/51319850-a657-4570-be6a-024496cbf0c7)

![Знімок екрана 2024-05-23 170532](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/9fdb6028-5386-499c-a392-2514b0268a9c)

Вказуємо наш **"Filter pattern"**, для розбивання полотна логів :

```
[ip, user, username, timestamp, request, status_code, bytes, http_referer, http_user_agent, request_time, upstream_connect_time, upstream_header_time, upstream_response_time]
```

Для поля **"Select log data to test"** вибираємо наш лог **"Access log"** та тестуємо.

![Знімок екрана 2024-05-23 171512](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/0a5330dd-385a-4d76-87b8-5ac49bde292f)

Далі пишемо **"Filter name"**, вибираємо наш namespace (або створюємо новий, по офіційній документації створення може зайняти до двох діб), вказуємо **"Metric name"** та вказуємо **"Metric value"** по якій буде відбуватись фільтрування (та в подальшому побудований **"alarm"**).

![Знімок екрана 2024-05-23 172028](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/8582719c-3de0-4b0e-8cc9-bc156cbb4135)

Після створення метрики, у вкладці **"Metric filters"** з'явиться нова метрика. Тепер ми з цієї метрики можемо створити на alarm натиснувши **"Create alarm"**.

![Знімок екрана 2024-05-23 172445](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/22d88501-46d9-4183-83c3-ae17a063f3b3)

Створюємо **"alarm"**. Вибираємо необхідний **"Statistic"** по групуванню.
**"Period"** це час за котрий буде створений **"datapoint"**.

![Знімок екрана 2024-05-23 172959](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/f3d79d92-533a-42f7-bb50-faec01c30c1d)

**"Threshold type"** рекомендую залишати по дефолту.
Обираємо **"Whenever … is"**, на вибір що більше підійде.
Поле **"than…"** це виставлений рівень (порог), воно має бути числовим.

![Знімок екрана 2024-05-23 173017](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/43cb7d62-6823-4f5f-8c52-65750c2ce32f)

**"Datapoints to alarm"** означає скільки має пройти циклів отримання **"datapoint"**, щоб спрацював **"alarm"**.

![Знімок екрана 2024-05-23 173408](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/21998827-0f2f-448c-b7ab-16e9cb4ff9f5)

Наступним кроком маємо створити три **"Add Lambda action"**.

![Знімок екрана 2024-05-23 173547](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/e5762d3f-c3d8-4398-89ef-26d77c050624)

![Знімок екрана 2024-05-23 173722](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/3338943c-ae98-44e3-b43a-513574de0b13)

Три дії під кожен стан **"alarm"**. Вибираємо створену функцію (також є можливість вибору версіонування функції). Далі пишемо назву **"alarm"**. 

![Знімок екрана 2024-05-23 173955](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/07b01147-70a2-4ae7-b77c-399640fd2981)

Після створення **"alarm"**, він з'явиться в консолі.

![Знімок екрана 2024-05-23 174133](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/0aa40591-2b13-43e9-87e9-d5cae8e3c442)

Зайшовши до нього, можна побачити його стан **"Insufficient data"**, а також графічний дашборд на якому червоною лінією виставлений наш поріг (перевищивши цю мітку спрацює **"alarm"**).

![Знімок екрана 2024-05-23 174329](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/7f8e42c5-053a-4c7f-800d-0920b76e4038)

Також нижче є можливість прочитати детальну інформацію про **"alarm"**, історію, дії.

![Знімок екрана 2024-05-23 174524](https://github.com/RebelsBoss/AWS-CloudWatch-Event-Lambda-Start-Stop-Instances/assets/126337643/144ba7c6-c7bf-465c-bc7c-063ff2816fe3)

Залишилось тестувати та вибирати підходящу метрику для спрацювання **"alarm"**.
