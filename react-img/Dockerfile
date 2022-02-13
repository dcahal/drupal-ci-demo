FROM alpine:3
RUN apk add npm && \
    npx create-react-app hiworld
WORKDIR /hiworld
ADD App.js ./src/
RUN npm run build && \
    rm -rf src/ public/ node_modules/ README.md package* && \
    npm install -g serve && \
    serve -s build \
    
