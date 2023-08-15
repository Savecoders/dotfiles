function $(c) {
  return document.querySelector(c);
}

function timePad(n) {
  return n >= 10 ? n.toString() : "0" + n;
}

Date.prototype.getDayOfWeek = () =>
  [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ][this.getDay()];

Date.prototype.getMonthName = () =>
  [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ][this.getMonth()];

class Login {
  constructor() {
    this.defaultUser = null;
    this.otherUsers = [];
    this.password = "";

    this.bindInactive();
    this.bindEvents();
    this.setupSessions();
    this.setupUsers();
    this.updateTime();
  }

  // time
  updateTime() {
    const d = new Date();
    $("#time-text").textContent = `${timePad(d.getHours())}:${timePad(
      d.getMinutes()
    )}`;
    $("#date-text").textContent =
      `${d.getDayOfWeek()}, ${d.getMonthName()} ${d.getDate()}`.toLowerCase();
    setTimeout(this.updateTime, 1000);
  }

  // events
  bindInactive() {
    let interval = 1;
    setInterval(() => {
      if (interval === 4) {
        $("#wrapper").className = "inactive";
        interval = 1;
        return;
      }
      interval++;
    }, 1000);
    document.body.onmousemove = document.body.onkeypress = () => {
      $("#wrapper").className = "active";
      interval = 1;
    };
  }

  bindEvents() {
    $("#main-user .avatar").onclick = () => {
      if ($("#alt-users").className === "shown") {
        $("#alt-users").className = "hidden";
      } else {
        $("#alt-users").className = "shown";
      }
    };

    $("#main-user .password").onkeydown = (e) => {
      if (e.keyCode == 13) {
        if (!lightdm._username)
          lightdm.start_authentication(this.defaultUser.name);
        this.password = $("#main-user .password").value;
      } else {
        $("#main-user .warn").style.display = "none";
      }
    };

    // actions
    $("#poweroff").onclick = () => lightdm.shutdown();
    $("#reboot").onclick = () => lightdm.restart();
    $("#suspend").onclick = () => lightdm.suspend();
    $("#hibernate").onclick = () => lightdm.hibernate();

    if (!lightdm.can_shutdown) $("#poweroff").style.display = "none";
    if (!lightdm.can_restart) $("#reboot").style.display = "none";
    if (!lightdm.can_suspend) $("#suspend").style.display = "none";
    if (!lightdm.can_hibernate) $("#hibernate").style.display = "none";
    if (
      !lightdm.can_shutdown &&
      !lightdm.can_restart &&
      !lightdm.can_suspend &&
      !lightdm.can_hibernate
    ) {
      // is this even necessary?
      $("#actions").style.display = "none";
    }
  }

  // users
  setupUsers() {
    this.updateDefault(-1);
  }

  updateDefault(idx) {
    if (lightdm._username) {
      lightdm.cancel_authentication();
    }
    lightdm.cancel_timed_login();

    $("#alt-users").className = "hidden";
    if (idx === -1)
      if (lightdm.select_user_hint)
        this.defaultUser = lightdm.users.find(
          (user) => user.username === lightdm.select_user_hint
        );
      else this.defaultUser = lightdm.users[0];
    else this.defaultUser = this.otherUsers[idx];
    if (this.defaultUser.session) {
      for (let i = 0; i < lightdm.sessions.length; i++) {
        if (lightdm.sessions[i].key === this.defaultUser.session) {
          this.changeSession(i);
          break;
        }
      }
    } else {
      this.changeSession(0);
    }

    // HACK: lightdm produces duplicate users for some reason
    const userHash = {};
    this.otherUsers = [];
    for (let user of lightdm.users) {
      if (
        user.username !== this.defaultUser.username &&
        !userHash.hasOwnProperty(user.username)
      ) {
        this.otherUsers.push(user);
        userHash[user.username] = true;
      }
    }
    lightdm.start_authentication(this.defaultUser.username);

    // main user
    $("#main-user h1").textContent = this.defaultUser.display_name;
    $("#main-user .avatar").style.backgroundImage =
      'url("' + (this.defaultUser.image || "./im-user.svg") + '")';
    $(".password").value = "";
    $(".password").focus();
    $("#main-user .warn").style.display = "none";

    // others
    let html = "";
    for (let i = 0; i < this.otherUsers.length; i++) {
      const user = this.otherUsers[i];
      html += `
            <div class="user" onClick="window.login.updateDefault(${i});">
                <div class="background"></div>
                <div style='display:table-cell; vertical-align: bottom;'>
                    <div class="avatar" style="background-image:url('${
                      user.image || "./im-user.svg"
                    }');"></div>
                </div>
                <div style='display:table-cell; vertical-align: middle;'>
                    <h1>${user.display_name}</h1>
                </div>
            </div>
            `;
    }
    $("#alt-users").innerHTML = html;
  }

  // sessions
  setupSessions() {
    let html = "";
    for (let i = 0; i < lightdm.sessions.length; i++) {
      const session = lightdm.sessions[i];
      html += `<li data-idx="${i}" onclick="window.login.changeSession(${i});">${session.name}</li>`;
    }
    $("#session-bar .container").innerHTML = html;
    $("#session-bar .container li:first-child").classList.add("active");
  }

  changeSession(idx) {
    $("#session-bar .container li.active").classList.remove("active");
    $(`#session-bar .container li[data-idx="${idx}"]`).classList.add("active");
  }
}

function authentication_complete() {
  console.log("complete?");
  if (lightdm.is_authenticated)
    lightdm.login(
      lightdm.authentication_user,
      lightdm.sessions[parseInt($("#session-bar .active").dataset.idx)].key
    );
  else if (window.login.password) {
    $("#main-user .warn").style.display = "block";
    $("#main-user .warn").textContent = "try again?";
  }
}

function show_message(msg) {
  $("#main-user .warn").textContent = err;
  $("#main-user .warn").style.display = "block";
}

function show_error() {
  console.log("error");
}

function show_prompt(text, type) {
  if (text === "Password: ") {
    lightdm.respond(window.login.password);
  }
}

__lightdm.then((result) => {
  window.lightdm = result;
  window.login = new Login();
});
