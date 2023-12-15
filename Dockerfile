# 第一階段：建構階段
FROM maven:3.9.6-sapmachine-21 AS build
# FROM maven:3.6.3-jdk-11-slim AS build

# speed up Maven JVM a bit
ENV MAVEN_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# 設定工作目錄
WORKDIR /build

# 先複製 pom.xml 和 maven 設定文件
COPY pom.xml .

# 下載依賴
RUN mvn dependency:go-offline

# 複製源代碼
COPY ./src ./src

# 進行構建，跳過測試
# RUN mvn clean install -Dmaven.test.skip=true
# RUN mvn clean package
RUN mvn -B package -DskipTests

# 第二階段：運行階段
FROM openjdk:21-jdk-slim
# FROM openjdk:11-jre-slim

# 設定工作目錄 /app
WORKDIR /app

# 從建構階段複製 JAR 文件到運行階段
COPY --from=build /build/target/bank-0.0.1-SNAPSHOT.jar app.jar

# 執行
ENTRYPOINT ["java", "-jar", "app.jar"]
