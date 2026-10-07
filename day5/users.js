const loadButton = document.querySelector("#load-users");
const filterInput = document.querySelector("#filter-input");
const status = document.querySelector("#status");
const usersList = document.querySelector("#users-list");

let users = [];

async function loadUsers() {
    loadButton.disabled = true;
    status.textContent = "Loading users...";

    try {
        const response = await fetch("https://jsonplaceholder.typicode.com/users");

        if (!response.ok) {
            throw new Error("Failed to load users");
        }

        users = await response.json();

        renderUsers(users);

        status.textContent = "Users loaded successfully.";
    } catch (error) {
        usersList.replaceChildren();
        status.textContent = "Error loading users.";
    } finally {
        loadButton.disabled = false;
    }
}

function renderUsers(list) {
    usersList.replaceChildren();

    if (list.length === 0) {
        const message = document.createElement("li");
        message.textContent = "No users match your filter.";
        usersList.appendChild(message);
        return;
    }

    list.forEach(function (user) {
        const item = document.createElement("li");

        const name = document.createElement("h3");
        name.textContent = user.name;

        const email = document.createElement("p");
        email.textContent = "Email: " + user.email;

        const city = document.createElement("p");
        city.textContent = "City: " + user.address.city;

        const company = document.createElement("p");
        company.textContent = "Company: " + user.company.name;

        item.appendChild(name);
        item.appendChild(email);
        item.appendChild(city);
        item.appendChild(company);

        usersList.appendChild(item);
    });
}

loadButton.addEventListener("click", loadUsers);

filterInput.addEventListener("input", function () {
    const text = filterInput.value.toLowerCase();

    const filteredUsers = users.filter(function (user) {
        return user.name.toLowerCase().includes(text);
    });

    renderUsers(filteredUsers);
});