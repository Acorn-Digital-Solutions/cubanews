import { initializeApp } from "firebase/app";

// Optionally import the services that you want to use
import { getAuth } from "firebase/auth";
// import {...} from 'firebase/database';
// import {...} from 'firebase/firestore';
// import {...} from 'firebase/functions';
import { getStorage } from "firebase/storage";

// Initialize Firebase
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
export const firebaseConfig = {
  apiKey: "AIzaSyBEdpj3q8rxQ4iTqJf1ps4YMpgGwO8C6vU",
  authDomain: "cubanews-fbaad.firebaseapp.com",
  projectId: "cubanews-fbaad",
  storageBucket: "cubanews-fbaad.firebasestorage.app",
  messagingSenderId: "364287175875",
  appId: "1:364287175875:web:cda629727a545968864676",
  measurementId: "G-W5WM6VMN6N",
};

export const app = initializeApp(firebaseConfig);
export const storage = getStorage(app);
