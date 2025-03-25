# **Connections** 🚀  
*A social platform powered by FastAPI & Flutter*  

## **Project Overview**  
Connections is a modern social platform built using **FastAPI** for the backend and **Flutter** for the frontend. This guide will help you set up the project in a **GitHub Codespace** or your local machine.  

Setting Up Connections Project
Identify Tech Stack
Choose Setup Environment
Clone Repository
Install Dependencies
Setup PostgreSQL
Start FastAPI Backend
Determine the technologies used for the project
Decide between GitHub Codespace or local machine
Download the project's codebase from GitHub
Install necessary libraries and packages
Configure the database for the project
Launch the backend server to handle requests![image](https://github.com/user-attachments/assets/f01113aa-41c3-4748-80de-5755cf380c2a)

---

## **Tech Stack**  
- **Backend**: FastAPI + PostgreSQL  
- **Frontend**: Flutter  
- **Database**: PostgreSQL  

---

## **Setup Instructions**  

### **1️⃣ Clone the Repository**  
```sh
git clone https://github.com/your-username/connections.git
cd connections
```

---

## **Backend Setup**  

### **2️⃣ Install Dependencies**  
Inside the `backend` folder, install the required Python dependencies:  
```sh
cd backend
python -m venv .
source ./bin/activate  # On Windows use: venv\Scripts\activate
pip install -r requirements.txt
```

### **3️⃣ Setup PostgreSQL**  

#### **🔹 Create Database & User**
```sh
sudo -u postgres psql
```
Then, inside PostgreSQL:  
```sql
CREATE DATABASE connections;
CREATE USER connections WITH ENCRYPTED PASSWORD 'change_me';
GRANT ALL PRIVILEGES ON DATABASE connections TO connections;
ALTER ROLE connections SUPERUSER;
```
Exit with `\q`.

#### **🔹 Create a `.env` File**  
Inside `backend/`, create a `.env` file:  
```ini

DB_USER=connections
DB_PASSWORD=change_me
DB_NAME=connections
DB_HOST=localhost
DB_PORT=5432

JWT_SECRET=your_secret_key_here
```

#### **🔹 Run SQL Scripts**  
Apply the schema:  
```sh
psql -U connections -d test -f create_tables_and_keys.sql
psql -U connections -d test -f insert_mock_data.sql
psql -U connections -d test -f update_schema_for_frontend.sql
```

### **4️⃣ Start FastAPI Backend**  
```sh
uvicorn main:app --reload
```
Your FastAPI backend will now be running at: **http://127.0.0.1:8000**

---

## **Frontend Setup**  

### **5️⃣ Initialize Flutter**  
Navigate to `frontend/` and reinitialize Flutter:  
```sh
cd ../frontend
flutter create .
flutter pub get
```

### **6️⃣ Run Flutter Web App**  
```sh
flutter run -d web-server --web-port 9339
```
Your Flutter frontend should now be accessible in the browser at: **http://127.0.0.1:9339**

---

## **🎯 Testing the Setup**  

- Open **http://127.0.0.1:8000/docs** to check FastAPI's auto-generated API documentation.  
- Use the frontend at **http://localhost:9339** (or the provided URL from `flutter run`).  

FastAPI Documentation Access
Access the API documentation through a web link.
Test Backend
Access the frontend application via the specified URL.
Use Frontend![image](https://github.com/user-attachments/assets/0ca75457-c891-40dc-a4d2-767c355f2c7e)

---

## **🤝 Contributing**  
Want to improve Connections? Feel free to fork the repo and submit a pull request!  

---

## **🚀 Future Enhancements**  
- Docker support for easy deployment  
- User authentication improvements  
- Mobile app integration  

---
