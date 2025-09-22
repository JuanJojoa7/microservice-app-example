# Stage 1: Build the application
FROM maven:3.8.5-openjdk-11 AS builder

WORKDIR /app

# Copy the POM file and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy the source code
COPY src ./src

# Build the application
RUN mvn clean install -DskipTests

# Stage 2: Create the final lightweight image
FROM openjdk:8-jre-slim

WORKDIR /app

# Copy the JAR file from the builder stage
COPY --from=builder /app/target/users-api-0.0.1-SNAPSHOT.jar /app/users-api.jar

# Expose the port the app runs on
EXPOSE 8083

# Command to run the application
ENTRYPOINT ["java", "-jar", "/app/users-api.jar"]
