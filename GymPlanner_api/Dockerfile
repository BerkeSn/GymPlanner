# 1. Node.js'in hafif sürümü
FROM node:20-alpine

# 2. Uygulama klasörü
WORKDIR /app

# 3. Bağımlılık yönetimi (Hızlı build için önce bunlar)
COPY package*.json ./
RUN npm install

# 4. Tüm kodları kopyala
COPY . .

# 5. Portu dışarı aç
EXPOSE 3000

# 6. Varsayılan başlatma komutu
CMD ["node", "index.js"]