window.addEventListener("message", (event) => {
    if (event.data.action === "requestCode") {
        document.getElementById("codePanel").style.display = "flex"; 
        document.getElementById("rentalMenu").classList.add("hidden");
    } else if (event.data.action === "openMenu") {
        const vehicleList = document.getElementById("vehicleList");
        vehicleList.innerHTML = "";

        Object.keys(event.data.vehicles).forEach(vehicleType => {
            const vehicleDiv = document.createElement("div");
            vehicleDiv.classList.add("vehicle");

            const vehicleData = event.data.vehicles[vehicleType];
            const vehicleImg = document.createElement("img");
            
            if (vehicleData.img && vehicleData.img.trim() !== "") {
                vehicleImg.src = vehicleData.img;
            } else {
                vehicleImg.src = `https://fast-rp.fr/cardealer/img/vehicles/${vehicleType}.png`;
            }
            
            vehicleImg.alt = vehicleType;
            vehicleDiv.appendChild(vehicleImg);

            const name = document.createElement("span");
            name.textContent = `${vehicleType} - Disponible : ${vehicleData.stock}`;
            vehicleDiv.appendChild(name);

            const button = document.createElement("button");
            button.innerHTML = `<i class="fas fa-car"></i> Louer`;
            button.onclick = () => rentVehicle(vehicleType);
            vehicleDiv.appendChild(button);

            vehicleList.appendChild(vehicleDiv);
        });

        document.getElementById("rentalMenu").classList.remove("hidden");
    } else if (event.data.action === "hideCodePanel") {
        document.getElementById("codePanel").style.display = "none";
    } else if (event.data.action === "showNotification") {
        showNotification(event.data.type, event.data.message);
    } else if (event.data.action === "closeMenu") {
        document.getElementById("rentalMenu").classList.add("hidden"); 
        document.getElementById("codePanel").style.display = "none"; 
        SetNuiFocus(false, false);
    }
});





function showNotification(type, message) {
    const container = document.getElementById("notificationContainer");

    const notification = document.createElement("div");
    notification.classList.add("notification", type);

    const icon = document.createElement("i");
    icon.classList.add("notification-icon");

    switch (type) {
        case "success":
            icon.classList.add("fas", "fa-check-circle");
            break;
        case "error":
            icon.classList.add("fas", "fa-times-circle");
            break;
        case "warning":
            icon.classList.add("fas", "fa-exclamation-triangle");
            break;
        case "info":
            icon.classList.add("fas", "fa-info-circle");
            break;
        default:
            icon.classList.add("fas", "fa-info-circle");
    }

    const messageElement = document.createElement("span");
    messageElement.classList.add("notification-message");
    messageElement.textContent = message;

    notification.appendChild(icon);
    notification.appendChild(messageElement);
    container.appendChild(notification);

    setTimeout(() => {
        notification.classList.add("hidden");
        setTimeout(() => {
            container.removeChild(notification);
        }, 300);
    }, 3000);
}

function submitCode() {
    const code = document.getElementById("accessCode").value;
    fetch(`https://${GetParentResourceName()}/submitCode`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ code }),
    });
}

function rentVehicle(vehicle) {
    fetch(`https://${GetParentResourceName()}/rentVehicle`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ vehicle }),
    });
}

function closeMenu() {
    fetch(`https://${GetParentResourceName()}/closeMenu`, {
        method: "POST",
    });

    document.getElementById("rentalMenu").classList.add("hidden");
}
function closeCodePanel() {

    fetch(`https://${GetParentResourceName()}/closeMenu`, {
        method: "POST",
    });

    
    document.getElementById("codePanel").classList.add("hidden");
}
