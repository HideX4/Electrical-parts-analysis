# Electrical component identification app

This project consists of a **Flutter** frontend and a **Flask** backend for project. The backend processes requests and returns sentiment predictions (0=transistor, 1=resistor, or 2=capacitor).

### 🧩 My Contributions

I was responsible for the complete development lifecycle of the **Electrical Components Identification App**, covering both machine learning and application development. My work included:

- **Data Acquisition & Preparation:**  
  - Collected and labeled image data for electrical components.  
  - Handled data cleaning, augmentation, and normalization to improve model robustness and generalization.

- **Model Development:**  
  - Trained image classification models (CNN-based architecture) to identify different components.  
  - Performed model evaluation using accuracy, confusion matrices, and cross-validation to optimize performance.

- **Application Development:**  
  - Designed and built a user-friendly interface for the app.
  - Integrated the trained model into the application for real-time predictions.

- **Deployment:**  
  - Packaged and deployed the app to a production-ready environment.  
  - Ensured smooth end-to-end functionality, from image upload to component prediction.
---

## Project Structure

- **Backend/**: Flask backend for handling API requests and making predictions.
- **Frontend/**: Flutter mobile application that interacts with the backend.
- **Documentation/**: Jupyter notebook used for creating and training the machine learning models detailing the process and a video demo of the app.

---

## Backend (Flask)

### Option 1: Run Locally (Without Docker)

1. Clone the repository:
   ```
   git clone https://github.com/HideX4/Electrical-parts-analysis.git
   cd Backend
   ```

2. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

3. Run the Flask application:
   ```
   python server.py
   ```

### Option 2: Run With Docker

1. Clone the repository:
   ```
   git clone https://github.com/HideX4/Electrical-parts-analysis.git
   cd Backend
   ```

2. Build the Docker image:
   ```
   docker build -t electrical-backend .
   ```

3. Run the Docker container:
   ```
   docker run -p 8000:8000 electrical-backend
   ```

---

## Frontend (Flutter)

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/HideX4/Electrical-parts-analysis.git
   cd Frontend
   ```

2. Install Flutter dependencies:
   ```
   flutter pub get
   ```

3. Run the Flutter app:
   ```
   flutter run
   ```
