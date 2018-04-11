FROM ministryofjustice/ruby:2.3.3-webapp-onbuild

# Ensure the pdftk package is installed as a prereq for ruby PDF generation
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y pdftk unzip zip

EXPOSE 8080

CMD ["./run.sh"]
