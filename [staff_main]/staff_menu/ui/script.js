let rank = 0;
let players = [];
let selectedPlayer = null;

// Store the current drop target for modal submission
let currentDropTargetId = null;

window.addEventListener("message", function(event) {
    const data = event.data;

    if (data.action === "open") {
        rank = data.rank;
        players = data.players;
        selectedPlayer = null;

        document.getElementById("staffMenu").style.display = "block";
        document.getElementById("searchInput").value = "";
        document.getElementById("playerActions").innerHTML = "";
        renderPlayerList();
        populateServerOptions();
        showTab("players");

        // Hide modal in case it was open before
        closeReasonModal();
    }
});

function showTab(name) {
    document.querySelectorAll(".tab-content").forEach(el => el.classList.remove("active"));
    document.getElementById("tab-" + name).classList.add("active");
}

function closeMenu() {
    fetch(`https://${GetParentResourceName()}/closeMenu`, {
        method: "POST"
    });

    document.getElementById("staffMenu").style.display = "none";
    document.getElementById("playerList").innerHTML = "";
    document.getElementById("playerActions").innerHTML = "";
    document.getElementById("serverOptions").innerHTML = "";
    document.getElementById("searchInput").value = "";
    players = [];
    selectedPlayer = null;

    // Also close the modal if open
    closeReasonModal();
}

function renderPlayerList() {
    const list = document.getElementById("playerList");
    list.innerHTML = "";

    players.forEach(player => {
        const li = document.createElement("li");
        li.textContent = `[${player.id}] ${player.name}`;
        li.onclick = () => selectPlayer(player);
        list.appendChild(li);
    });
}

function selectPlayer(player) {
    selectedPlayer = player;
    const container = document.getElementById("playerActions");
    container.innerHTML = "";

    const actions = [
        { label: "Bring", action: "bring" },
        { label: "Go To", action: "goto" },
        { label: "Spectate", action: "spectate" },
        { label: "Drop", action: "drop" }
    ];

    if (rank >= 2) {
        actions.push({ label: "Revive", action: "revive" });
        actions.push({ label: "Slay", action: "slay" });
    }

    actions.forEach(a => {
        const btn = document.createElement("button");
        btn.textContent = a.label;
        btn.className = "actionBtn";
        btn.onclick = () => {
            if (a.action === "drop") {
                currentDropTargetId = player.id;
                openReasonModal();
            } else {
                doAction(a.action, player.id);
            }
        };
        container.appendChild(btn);
    });
}

function doAction(action, target, args = {}) {
    fetch(`https://${GetParentResourceName()}/performAction`, {
        method: "POST",
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action, target, args })
    });
}

function filterPlayers() {
    const search = document.getElementById("searchInput").value.toLowerCase();
    const items = document.querySelectorAll("#playerList li");
    items.forEach(item => {
        item.style.display = item.innerText.toLowerCase().includes(search) ? "block" : "none";
    });
}

function populateServerOptions() {
    const div = document.getElementById("serverOptions");
    div.innerHTML = "";

    if (rank >= 4) {
        div.innerHTML = `
            <input id="announceMsg" placeholder="Announcement message" />
            <button class="actionBtn" onclick="doAction('announce', -1, {message: document.getElementById('announceMsg').value})">Announce</button><br><br>
            
            <input id="timeHour" placeholder="Hour" type="number" />
            <input id="timeMinute" placeholder="Minute" type="number" />
            <button class="actionBtn" onclick="doAction('setTime', -1, {hour: document.getElementById('timeHour').value, minute: document.getElementById('timeMinute').value})">Set Time</button><br><br>
            
            <input id="weatherType" placeholder="Weather (CLEAR, RAIN...)" />
            <button class="actionBtn" onclick="doAction('setWeather', -1, {weatherType: document.getElementById('weatherType').value})">Set Weather</button>
        `;
    }
}

// Modal controls
const reasonModal = document.getElementById("reasonModal");
const dropReasonInput = document.getElementById("dropReasonInput");
const cancelReasonBtn = document.getElementById("cancelReasonBtn");
const submitReasonBtn = document.getElementById("submitReasonBtn");

function openReasonModal() {
    dropReasonInput.value = "";
    reasonModal.style.display = "flex";
    dropReasonInput.focus();
}

function closeReasonModal() {
    reasonModal.style.display = "none";
    currentDropTargetId = null;
}

// Cancel button handler
cancelReasonBtn.onclick = () => {
    closeReasonModal();
};

// Submit button handler
submitReasonBtn.onclick = () => {
    const reason = dropReasonInput.value.trim();
    if (!reason) {
        alert("Please enter a reason before submitting.");
        return;
    }
    if (currentDropTargetId !== null) {
        doAction("drop", currentDropTargetId, { reason });
        alert(`Player dropped for reason: "${reason}"`);
    }
    closeReasonModal();
};
