# TODO: Need to check this file

# Base
FROM node:23.6.1-alpine AS base
RUN apk add --no-cache g++ make py3-pip libc6-compat
ARG PORT=3000
ENV NEXT_TELEMETRY_DISABLED=1
WORKDIR /app
COPY package.json package-lock.json ./
EXPOSE $PORT


# Build
FROM base AS builder
WORKDIR /app
COPY . .
ARG NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY
ENV NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=$NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY
RUN npm run build


# Production
FROM base AS production

ENV NODE_ENV=production
ENV PORT=$PORT
ENV HOSTNAME="0.0.0.0"

RUN npm ci

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
RUN mkdir .next
RUN chown nextjs:nodejs .next

COPY --from=builder --chown=nextjs:nodejs /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/public ./public

USER nextjs

CMD ["npm", "start"]


# Development
FROM base as dev
ENV NODE_ENV=development
RUN npm install 
COPY . .
CMD ["npm", "run", "dev", "--", "-H", "0.0.0.0"]
