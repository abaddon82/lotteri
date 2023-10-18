FROM node:20-alpine AS build

#WORKDIR $GITHUB_WORKSPACE/lotteriapp/trekning-frontend/app
WORKDIR /build

COPY $GITHUB_WORKSPACE/lotteriapp/trekning-frontend/app .

RUN npm install

RUN npm run build

FROM node:20-alpine AS run

WORKDIR /app

COPY --from=build /build/package.json .
COPY --from=build /build/build ./build

EXPOSE 3000

CMD [ "node", "build/index.js" ]
