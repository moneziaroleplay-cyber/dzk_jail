// Fonction pour masquer le body au démarrage (sécurité)
document.body.style.display = "none";

window.addEventListener('message', function(event) {
    const data = event.data;

    // 1. GESTION DU PANEL (OUVERTURE)
    if (data.action === "openPanel") {
        const wrapper = document.getElementById('admin-wrapper');
        const listContainer = document.getElementById('player-list');

        // On vérifie si les éléments existent avant de manipuler
        if (wrapper && listContainer) {
            document.body.style.display = "flex"; // On affiche le fond
            wrapper.classList.remove('hidden');
            
            listContainer.innerHTML = ""; // Reset de la liste

            if (data.jailedList && data.jailedList.length > 0) {
                data.jailedList.forEach(p => {
                    listContainer.innerHTML += `
                        <div class="player-card">
                            <div style="color:#3b82f6; font-weight:bold;">ID: ${p.id} | ${p.name}</div>
                            <div style="font-size:13px; margin-top:5px;">Raison: ${p.reason} (${p.time} min)</div>
                            <div style="font-size:11px; color:#666; margin-top:5px;">Par: ${p.staffName}</div>
                        </div>`;
                });
            } else {
                listContainer.innerHTML = "<p style='color:#666; text-align:center; padding-top:20px;'>Aucun joueur en prison.</p>";
            }
        } else {
            console.error("ERREUR : 'admin-wrapper' ou 'player-list' est introuvable dans le HTML !");
        }
    }

    // 2. GESTION DES SONS
    if (data.action === "playSound") {
        const sound = document.getElementById(data.sound);
        if (sound) {
            sound.currentTime = 0;
            sound.play().catch(e => console.log("L'audio n'a pas pu être lancé :", e));
        }
    }

    // 3. GESTION DES NOTIFICATIONS
    if (data.action === "showNotification") {
        const container = document.getElementById('jail-notification');
        const textElem = document.getElementById('jail-text');
        
        if (container && textElem) {
            textElem.textContent = data.text || '';
            container.classList.remove('hidden');
            
            if (data.duration) {
                setTimeout(() => {
                    container.classList.add('hidden');
                }, data.duration);
            }
        }
    }
});

// FONCTION POUR ENVOYER LE JAIL AU SERVEUR
function submitJail() {
    const idElem = document.getElementById('target-id');
    const timeElem = document.getElementById('jail-duration');
    const reasonElem = document.getElementById('jail-reason');

    if (idElem && timeElem && reasonElem) {
        const id = idElem.value;
        const time = timeElem.value;
        const reason = reasonElem.value;

        if (id && time && reason) {
            fetch(`https://${GetParentResourceName()}/validateJail`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ id, time, reason })
            });
            closeMenu();
        } else {
            console.log("Champs incomplets");
        }
    }
}

// FONCTION FERMETURE
function closeMenu() {
    const wrapper = document.getElementById('admin-wrapper');
    if (wrapper) {
        wrapper.classList.add('hidden');
        document.body.style.display = "none";
        fetch(`https://${GetParentResourceName()}/close`, { 
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    }
}

// Touche Echap
window.addEventListener('keyup', (e) => {
    if (e.key === "Escape") closeMenu();
});