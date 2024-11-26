# 1. Base 이미지 설정 (Node.js LTS 버전 사용)
FROM node:18-alpine AS base

# 2. 작업 디렉토리 설정
WORKDIR /app

# 3. 의존성 설치 단계
FROM base AS dependencies
# package.json 및 package-lock.json 복사
COPY package*.json ./
# 의존성 설치
RUN npm install --frozen-lockfile

# 4. 빌드 단계
FROM dependencies AS build
# 전체 프로젝트 복사
COPY . .
# 프로덕션 빌드 생성
RUN npm run build

# 5. 실행 단계
FROM base AS production
# production 모드로만 필요한 의존성 설치
ENV NODE_ENV=production
COPY package*.json ./
RUN npm install --production --frozen-lockfile
# 빌드된 파일 복사
COPY --from=build /app/.next ./.next
COPY --from=build /app/public ./public
COPY --from=build /app/next.config.ts ./next.config.ts

# 앱 실행 포트
EXPOSE 3000

CMD [ "npm", "run", "start" ]
