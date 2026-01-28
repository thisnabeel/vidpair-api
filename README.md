# VidRoom API

Rails 8 API-only backend for VidRoom pairing and chat application.

## Setup

1. Install dependencies:
```bash
bundle install
```

2. Configure database in `config/application.yml` (already gitignored):
```yaml
DATABASE_URL: "postgresql://user:password@host:port/database"
```

3. Run migrations:
```bash
rails db:create
rails db:migrate
```

4. Start the server:
```bash
rails server
```

The API will run on `http://localhost:3000`

## Features

- User authentication with Devise (email, username, password)
- Pairing system to match users
- Real-time chat with ActionCable
- RESTful API endpoints

## API Endpoints

### Authentication
- `POST /users` - Sign up
- `POST /users/sign_in` - Login
- `DELETE /users/sign_out` - Logout

### Pairing
- `POST /pairing/begin` - Start looking for a match
- `POST /pairing/leave` - Leave pairing queue
- `GET /pairing/status` - Check pairing status

### Chat
- `GET /chat_rooms` - List user's chat rooms
- `GET /chat_rooms/:id` - Get chat room details
- `GET /chat_rooms/:id/chat_messages` - Get messages
- `POST /chat_rooms/:id/chat_messages` - Send message

## WebSocket

ActionCable is mounted at `/cable` for real-time features:
- `PairingChannel` - Real-time pairing updates
- `ChatChannel` - Real-time chat messages

# vidpair-api
