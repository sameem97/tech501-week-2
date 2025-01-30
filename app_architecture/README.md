# Application Architecture

## Intro to Two-Tier Architecture

- A two-tier architecture is a software architecture pattern where a client communicates directly with a server. It consists of two layers:

1. **Presentation Layer (Client)**: This is the **user interface** layer, where users interact with the application. It can be a web browser, desktop application, or mobile app.

2. **Data Layer (Server)**: This is the **backend** where the app logic and the database reside, usually in the same VM. The app logic is the code that processes user requests, applies rules and interacts with the database (CRUD operations) e.g. to store or retrive user data.

- In a two-tier architecture, the client and server are tightly coupled, which can lead to performance bottlenecks and scalability issues as the number of clients increases.

## Our App Architecture

- In our specific architecture, the MongoDB instance is running in a separate VM in a private subnet, to the Node.js instance running on another VM in a public subnet. Both VMs are part of the same Azure VNet and with the amended db BindIp, they app can communicate with the database.

- Even though in our case, two VMs are involved, the app still directly interacts with our database (without an additional intermediary tier), which is what makes our architecture two-tier rather than three-tier.

- Overall, our setup ensures that the database is not directly exposed to the internet, enhancing security. The Node.js application in the public subnet can communicate with the MongoDB instance in the private subnet through the VNet, allowing for secure and efficient data transactions.

Key points of this architecture:

- **Security**: The MongoDB instance is protected from direct internet access.
- **Scalability**: The Node.js application can be scaled independently of the database.
- **Performance**: Network latency is minimised as both VMs are within the same VNet.

This architecture leverages Azure's networking capabilities to create a secure and scalable environment for our application.
