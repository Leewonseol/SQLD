#!/bin/bash
# MariaDB(MySQL 호환) 준비 스크립트. 한 번만 실행하면 된다.
# 이 저장소 세션에서 실제로 이 순서대로 실행해 확인했다.
set -e

if ! command -v mariadbd >/dev/null 2>&1; then
    apt-get update
    apt-get install -y mariadb-server
fi

service mariadb start

mysql -u root -e "
CREATE DATABASE IF NOT EXISTS bigdata_exam CHARACTER SET utf8mb4;
CREATE USER IF NOT EXISTS 'examuser'@'localhost' IDENTIFIED BY 'exampass';
GRANT ALL PRIVILEGES ON bigdata_exam.* TO 'examuser'@'localhost';
FLUSH PRIVILEGES;
"

mysql -u examuser -pexampass bigdata_exam -e "SELECT VERSION();"
echo "MariaDB 준비 완료 (DB=bigdata_exam, user=examuser)"
