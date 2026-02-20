---
name: docker
description: Docker containerization expert for creating optimized, secure multi-stage Dockerfiles and docker-compose configurations. Use when writing or reviewing Dockerfiles, docker-compose files, optimizing image size, adding security hardening, configuring health checks, setting up container networking, or any Docker-related task.
---

# Docker Best Practices

## Multi-Stage Builds (default pattern)

Always use multi-stage builds for compiled languages and heavy build tools:

```dockerfile
# Stage 1: Dependencies (production only)
FROM node:18-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Stage 2: Build
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 3: Production
FROM node:18-alpine AS production
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
USER node
EXPOSE 3000
CMD ["node", "dist/main.js"]
```

Stage order: `deps → build → [test] → production`

## Base Images

- Prefer `alpine` or `slim` variants: `python:3.11-slim`, `node:18-alpine`
- Pin exact versions (no `latest` in production)
- Distroless for maximum security: `gcr.io/distroless/nodejs18-debian11`

## Layer Optimization

- Order: stable instructions first (deps install), volatile last (COPY source)
- Combine related `RUN` commands; clean in same layer:

```dockerfile
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

- Copy dependency files before source for cache efficiency:

```dockerfile
COPY package*.json ./   # cached unless deps change
RUN npm ci
COPY src/ ./src/        # invalidates only when source changes
```

## Security

Non-root user (required):
```dockerfile
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN chown -R appuser:appgroup /app
USER appuser
```

Never include secrets in image layers — use runtime secrets management (Kubernetes Secrets, Docker Secrets, Vault).

Drop capabilities at runtime: `docker run --cap-drop=ALL --security-opt=no-new-privileges`

## Health Checks

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl --fail http://localhost:8080/health || exit 1
```

## Environment & Configuration

```dockerfile
ENV NODE_ENV=production
ENV PORT=3000
ARG BUILD_VERSION
ENV APP_VERSION=$BUILD_VERSION
```

Use exec form for CMD/ENTRYPOINT (better signal handling):
```dockerfile
ENTRYPOINT ["/app/start.sh"]
CMD ["--config", "prod.conf"]
```

## .dockerignore (always include)

```
.git*
node_modules
__pycache__
dist
build
.env.*
*.log
coverage
.vscode
.idea
.DS_Store
tests/
docs/
```

## docker-compose patterns

Resource limits:
```yaml
deploy:
  resources:
    limits:
      cpus: '0.5'
      memory: 512M
    reservations:
      cpus: '0.25'
      memory: 256M
```

Network isolation:
```yaml
services:
  web:
    networks: [frontend, backend]
  api:
    networks: [backend]
networks:
  backend:
    internal: true
```

Persistent storage:
```yaml
services:
  db:
    volumes:
      - postgres_data:/var/lib/postgresql/data
volumes:
  postgres_data:
```

## Review Checklist

- [ ] Multi-stage build used?
- [ ] Minimal, versioned base image?
- [ ] Layers ordered for cache efficiency?
- [ ] `.dockerignore` present?
- [ ] Non-root USER defined?
- [ ] HEALTHCHECK defined?
- [ ] No secrets in image layers?
- [ ] Resource limits set (compose/k8s)?

## Troubleshooting

- Large image: `docker history <image>` → switch to multi-stage or alpine
- Slow builds: move `COPY . .` after dependency install
- Permissions: verify `chown` before `USER` switch
- Not starting: check CMD/ENTRYPOINT exec form, `docker logs <id>`
