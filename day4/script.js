const noteText = document.getElementById("note-text");
const charCount = document.getElementById("char-count");
const wordCount = document.getElementById("word-count");
const clearBtn = document.getElementById("clear-btn");
const themeToggle = document.getElementById("theme-toggle");

function updateCounts() {
    const text = noteText.value;
    const characters = text.length;

    const words = text.trim() === ""
        ? 0
        : text.trim().split(/\s+/).length;

    charCount.textContent = `${characters} / 200 characters`;
    wordCount.textContent = `${words} words`;

    charCount.classList.remove("warning", "over");

    if (characters > 200) {
        charCount.classList.add("over");
    } else if (characters > 180) {
        charCount.classList.add("warning");
    }
}

function saveDraft() {
    window.localStorage.setItem("draft", noteText.value);
}

function clearEverything() {
    noteText.value = "";
    window.localStorage.removeItem("draft");
    updateCounts();
}

noteText.addEventListener("input", function () {
    updateCounts();
    saveDraft();
});

clearBtn.addEventListener("click", function () {
    clearEverything();
    noteText.focus();
});

noteText.addEventListener("keydown", function (event) {
    if (event.key === "Escape") {
        clearEverything();
    }
});

themeToggle.addEventListener("click", function () {
    document.body.classList.toggle("dark");

    const isDark = document.body.classList.contains("dark");

    if (isDark) {
        themeToggle.textContent = "Light mode";
        window.localStorage.setItem("theme", "dark");
    } else {
        themeToggle.textContent = "Dark mode";
        window.localStorage.setItem("theme", "light");
    }
});

const savedDraft = window.localStorage.getItem("draft");

if (savedDraft !== null) {
    noteText.value = savedDraft;
}

const savedTheme = window.localStorage.getItem("theme");

if (savedTheme === "dark") {
    document.body.classList.add("dark");
    themeToggle.textContent = "Light mode";
} else {
    themeToggle.textContent = "Dark mode";
}

updateCounts();
