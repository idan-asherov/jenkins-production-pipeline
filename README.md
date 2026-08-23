# Jenkins Blue-Green Pipeline

# 🛡️ מסמך ארכיטקטורה: Jenkins CI/CD & Blue-Green Deployment

מסמך זה מתאר את ארכיטקטורת קו הייצור האוטומטי (CI/CD Pipeline) של הפרויקט. המערכת תוכננה ועוצבה בסטנדרטים של סביבת Production, תוך מתן דגש על שרידות גבוהה, אפס זמן נפילה (Zero Downtime), מנגנוני Rollback אוטומטיים, והפרדת רשתות מאובטחת.

## 🛠️ טכנולוגיות מרכזיות (Tech Stack)

- **תשתיות ואוטומציה:** Jenkins, Docker, Docker Compose, Bash Scripting.
- **ניתוב תעבורה (Reverse Proxy):** Nginx.
- **צד שרת (Backend):** Node.js, Express.js.
- **בדיקות תוכנה:** Jest (Unit Tests & Coverage).

---

## 📐 זרימת הנתונים והתהליכים (Pipeline Flow)

```mermaid
graph TD
    A[Git Push] --> B{Branch Check}
    B -- dev branch --> C[Test & Build Only - No Deploy]
    B -- main branch --> D[Pipeline Starts]

    D --> E[1. Checkout & Install Dependencies]
    E --> F[2. Test & Coverage Gate]
    F -- Under 80% Coverage --> G((Fail: Red Build))
    F -- Pass --> H[3. Build Images & Inject Metadata]

    H --> I[4. Integration Test]
    I -- Network/Fetch Error --> G
    I -- Pass: Web talks to API --> J[5. Blue-Green Deploy]

    J --> K[Spin up NEW Env on bg-network]
    K --> L{Health Check /health}
    L -- Sabotage / Error 500 --> M[Rollback: Kill NEW, Keep OLD]
    M --> G

    L -- Pass 200 OK --> N[Nginx: Zero Downtime Swap]
    N --> O[Tear down OLD Env]
    O --> P((Success: Green Build))
```
