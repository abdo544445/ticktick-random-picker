# TickTick Random Picker

A Flutter application that integrates with the TickTick API to fetch your todo lists and randomly select tasks to work on.

## Features

- Connect to your TickTick account via OAuth authentication
- View all your TickTick lists/projects
- View tasks within each list
- Randomly select a task from a specific list
- Randomly select a task from all lists
- Mark tasks as complete/incomplete
- Beautiful and intuitive user interface

## Setup

### Prerequisites

- Flutter SDK installed (version 2.17.0 or higher)
- Dart SDK installed
- TickTick developer account and API credentials

### Getting TickTick API Credentials

1. Visit [TickTick Developer Portal](https://developer.ticktick.com/)
2. Create a new application
3. Configure the redirect URI (e.g., `ticktickrandompicker://oauth/callback`)
4. Get your Client ID and Client Secret

### Configure Environment Variables

1. Create a `.env` file in the root of the project
2. Add the following variables:

```
TICKTICK_CLIENT_ID=your_client_id_here
TICKTICK_CLIENT_SECRET=your_client_secret_here
TICKTICK_REDIRECT_URI=your_redirect_uri_here
TICKTICK_API_BASE_URL=https://api.ticktick.com/api/v2
```

### Install Dependencies

```bash
flutter pub get
```

### Run the App

```bash
flutter run
```

## Usage

1. Launch the app
2. Tap "Connect to TickTick" to authenticate
3. After being redirected to TickTick's login page, authorize the app
4. Copy the authorization code from the redirect URL
5. Paste the code in the app and submit
6. Browse your lists and tasks
7. Use the floating action button to pick a random task from all lists
8. Use the shuffle icon on a specific list to pick a random task from that list

## How Random Selection Works

The app filters out completed tasks and selects a random task from the remaining incomplete tasks. If a specific list has no incomplete tasks, you'll be notified accordingly.

## Troubleshooting

- If you encounter authentication issues, try logging out and logging back in
- Ensure your TickTick API credentials are correctly configured in the `.env` file
- Check your internet connection if you're having trouble loading data

## Privacy

This app stores authentication tokens securely on your device. No data is shared with any third parties.

## License

MIT 