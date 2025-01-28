# Connect the App to the database

- Once the app and the database have been provisioned, the next step is to connect them up!
- Ensure the app is running and can be accessed via your browser.
- Ensure db is up and running.
- Keep both terminals on hand.

## Connect app to db and reseed the db

### Define the environment variable connection string

- Export the DB_host environment variable as below.
- This step needs to be done with every new terminal window e.g. if the VM restarts.

```bash
export DB_HOST=mongodb://<db_private_ip>:27017/posts
```

### Check db connection, clear and reseed (populate) the database

```bash
npm install
```

### Start the nodejs app, check app and database records are displaying

```bash
npm start
```

