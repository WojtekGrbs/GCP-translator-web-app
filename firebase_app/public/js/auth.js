import {
    signInWithEmailAndPassword,
    createUserWithEmailAndPassword,
    signOut,
    onAuthStateChanged,
  } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-auth.js";
  
  import { auth } from "./firebase-init.js";
  
  // Login
  export function login(email, password) {
    return signInWithEmailAndPassword(auth, email, password);
  }
  
  // Sign up
  export function signup(email, password) {
    return createUserWithEmailAndPassword(auth, email, password);
  }
  
  // Logout
  export function logout() {
    return signOut(auth);
  }
  
  // Listen for login state changes
  export function onAuth(callback) {
    onAuthStateChanged(auth, callback);
  }