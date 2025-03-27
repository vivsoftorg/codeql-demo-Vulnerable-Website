FROM node:16

WORKDIR /usr/src/app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Create necessary directories
RUN mkdir -p uploads files
RUN chmod 777 uploads files

# Copy server files
COPY . .

# Expose port for API
EXPOSE 3001

# Start the server
CMD ["node", "server.js"]
