import { auth } from "./firebase-init.js";

export async function callTranslateAPI(text, language_code = "en") {
  const user = auth.currentUser;
  if (!user) throw new Error("Not signed in");

  const token = await user.getIdToken();

  const response = await fetch("https://translator-gateway-bj8a1opm.ew.gateway.dev/translate", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${token}` // 👈 Send ID token
    },
    body: JSON.stringify({ text, language_code })
  });

  const data = await response.json();
  return data;
}