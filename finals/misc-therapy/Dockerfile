FROM node:21
ADD *.json /
ADD *.js /
ADD game_commands game_commands
ADD events events
ADD commands commands
RUN npm install
CMD ["node", "."]
