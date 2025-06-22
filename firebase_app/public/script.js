async function translateText() {
    const text = document.getElementById("text-input").value;
    const targetLang = document.getElementById("language-select").value;
  
    const response = await fetch("translator-gateway-bj8a1opm.nw.gateway.dev", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ text, targetLang })
    });
  
    if (response.ok) {
      const data = await response.json();
      document.getElementById("result").innerText = data.translation || "No translation found.";
    } else {
      document.getElementById("result").innerText = "Error: Unable to translate.";
    }
  }

function showPopup(message, type = "success") {
  const overlay = document.getElementById("popupOverlay");
  const popup = document.getElementById("popup");

  popup.textContent = message;
  popup.className = `popup ${type}`;
  overlay.classList.add("show");


  setTimeout(() => {
    overlay.classList.remove("show");
  }, 3000);


  overlay.onclick = () => {
    overlay.classList.remove("show");
  };
}

