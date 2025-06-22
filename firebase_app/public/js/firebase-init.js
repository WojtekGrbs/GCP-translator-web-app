import { initializeApp } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-app.js";
import { getAuth } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-auth.js";

// Replace with your actual Firebase config (from console)
const firebaseConfig = {
  apiKey: "AIzaSyABGEnvXZjniShplQ4hQp1r2GGaV1CNmAs",
  authDomain: "micro-eye-455517-a2.firebaseapp.com",
  projectId: "micro-eye-455517-a2",
  appId: "1:903865273690:web:d736e0cb18b8b5210af763",
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);

export { auth };