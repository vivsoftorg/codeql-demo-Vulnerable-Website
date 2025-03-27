FROM node:16

WORKDIR /usr/src/app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy frontend files
COPY . .

# Expose port for React dev server
EXPOSE 3000

# Start the React development server
CMD ["npm", "start"]
