# Build frontend
FROM node:16.20.2-alpine3.18 as build-stage
WORKDIR /usr/src/app
COPY ./ ./
RUN npm install && npm run build

# Create image frontend
FROM nginx:stable-alpine3.20
COPY --from=build-stage /usr/src/app/dist/ /usr/share/nginx/html
EXPOSE 80
