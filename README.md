# Django + Podman Compose Setup

This project is a basic Django application containerized using **Podman Compose** with a development-focused Dockerfile. It supports live-reloading via volume mounting and exposes the Django development server on `localhost:8000`.

You can also use this interchangeably with **Docker Compose**.

---

## 📁 Directory Structure

```
.
├── Docker
│   └── web.dev.Dockerfile         # Dockerfile for the web service
├── docker-compose
│   └── docker-compose.dev.yml     # Compose file for development
├── README.md                      # This file
├── requirements.txt               # Python dependencies
└── src                            # Django project source
    ├── app                        # Django app/module
    ├── db.sqlite3                 # SQLite DB (for dev only)
    └── manage.py                  # Entry point for Django
```

---

## 🚀 Getting Started

### 📦 1. Build and Run with Podman Compose

From the repo root, run:

```bash
podman-compose -f docker-compose/docker-compose.dev.yml up --build
```

This will:
- Build the image using `Docker/web.dev.Dockerfile`
- Mount the `src/` directory into the container for live development
- Start the Django development server on `http://localhost:8000`

---

### ⚙️ 2. docker-compose.dev.yml (Summary)

```yaml
version: '3.9'

services:
  web:
    build:
      context: ..
      dockerfile: ./Docker/web.dev.Dockerfile
    command: python3 manage.py runserver 0.0.0.0:8000
    ports:
      - "8000:8000"
    volumes:
      - ../src:/home/app/web
```

- `ports`: Exposes port `8000` to the host.
- `volumes`: Mounts `src/` to `/home/app/web` inside the container.
- `command`: Runs Django’s development server.

---

### 🐳 Dockerfile Overview

Located at `Docker/web.dev.Dockerfile`, this multi-stage Dockerfile:

1. Builds Python wheels in a builder stage (to reduce final image size).
2. Installs runtime dependencies (PostgreSQL headers, Pillow support, etc.).
3. Adds a non-root user for security.
4. Copies and installs the app in the final container image.

---

### 📎 Requirements

Make sure `requirements.txt` contains Django and any other dependencies

Example:
```txt
Django>=4.0,<5.0
psycopg2-binary
```

You can install locally with:

```bash
pip install -r requirements.txt
```

It's suggested you create and run a Python virtual environment so that you don't
install Python packages system wide. This will also save you the trouble of 
listing everything that was ever install when creating a `requirements.txt` file 
with `pip freeze > requirements.txt`

---

## 🛠 Development Tips

- To see container logs. From repo root:
  ```bash
  podman-compose -f docker-compose/docker-compose.dev.yml logs
  ```

- To rebuild from scratch:
  ```bash
  podman-compose -f docker-compose/docker-compose.dev.yml down
  podman-compose -f docker-compose/docker-compose.dev.yml up --build
  ```

- If you are using it, make sure `entrypoint.sh` is executable and handles tasks like migration or static collection.

---

## 🧼 To Do

- Add database support (PostgreSQL service)
- Add volume for persistent data (e.g. `pgdata`)
- Configure `.env` and secrets management

---

## 📚 Resources

- [Django Docs](https://docs.djangoproject.com/en/stable/)
- [Podman Compose](https://github.com/containers/podman-compose)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

---

Happy coding! ⚡
