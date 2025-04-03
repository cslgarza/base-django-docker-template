######################################################
# BUILDER:
# Used to install dependencies and everything needed #
#   to build the app
######################################################

# Pull the official base image
FROM python:3.12.9-alpine3.21 as builder

WORKDIR /usr/src/app

# Set environment variables
# Disable writing .pyc files
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install psycopg2 dependencies (for PostgreSQL)
RUN apk update \
    && apk add gcc libc-dev linux-headers postgresql-dev python3-dev musl-dev jpeg-dev zlib-dev

# Install dependencies
RUN pip install --upgrade pip
COPY . .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /usr/src/app/wheels -r requirements.txt


#####################################################################
# FINAL:
# Should be smaller without compiler and other non-dependency tools.
#####################################################################

# Pull official base image
FROM python:3.12.9-alpine3.21

# Create directory for the app user
RUN mkdir -p /home/app

# Create the app user
RUN addgroup -S app && adduser -S app -G app

# Create the appropriate directories
ENV HOME=/home/app
ENV APP_HOME=/home/app/web
RUN mkdir $APP_HOME
# Uncomment if these directories are required
# RUN mkdir $APP_HOME/staticfiles
# RUN mkdir $APP_HOME/media
WORKDIR $APP_HOME

# Install dependencies
RUN apk update && apk add libpq python3-dev musl-dev jpeg-dev zlib-dev
COPY --from=builder /usr/src/app/wheels /wheels
COPY --from=builder /usr/src/app/requirements.txt .
RUN pip install --no-cache /wheels/*

# Copy entrypoint.sh for migrations
# COPY ./entrypoint.sh .
# Remove Windows enline characters in case the file has them
# RUN sed -i 's/\r$\\g' $AP_HOME/entrypoint.sh
# RUN chmod +x $APP_HOME/entrypoing.sh

# Copy project
COPY ./src $APP_HOME

# chown all the files to the app user
RUN chown -R app:app $APP_HOME

# Change to the app user
User app

# Run entrypoint.sh
# ENTRYPOINT ["/home/app/web/entrypoint.sh"]
