window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.action === "playSound") {
        const sound = document.getElementById(data.sound);
        if (sound) {
            sound.currentTime = 0;
            sound.play();
        }
    }

    if (data.action === "showNotification") {
        const container = document.getElementById('jail-notification');
        const text = document.getElementById('jail-text');
        text.textContent = data.text || '';
        container.classList.remove('hidden');

        if (data.duration) {
            setTimeout(() => {
                container.classList.add('hidden');
            }, data.duration);
        }
    }
});
