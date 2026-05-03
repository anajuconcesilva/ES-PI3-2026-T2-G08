// loginTest.ts
import { initializeApp } from "firebase/app";
import { getAuth, signInWithEmailAndPassword } from "firebase/auth";

const firebaseConfig = {
  apiKey: "AIzaSyCMuMlyYV1d4Hg6VFfR63c0pl_JUa1GsGo",
  authDomain: "mesclainvest-b2967.firebaseapp.com",
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);

async function login() {
  const user = await signInWithEmailAndPassword(
    auth,
    "teste@email.com",
    "123456"
  );

  const token = await user.user.getIdToken();

  console.log("TOKEN:");
  console.log(token);
}

login();