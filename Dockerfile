FROM openjdk:8
COPY petclinic.jar /app/petclinic.jar
WORKDIR /app
EXPOSE 8080
CMD ["java", "-jar", "petclinic.jar"]
