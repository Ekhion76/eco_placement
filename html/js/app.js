window.addEventListener('message', function (event) {

    let item = event.data;
    switch (item.subject) {
        case 'OPEN':
            document.getElementById('container').style.display = 'block';
            break;
        case 'SET_MOVEMENT_STATE':
            setMoveState(item.state);
            break;
        case 'COPY':
            let input = document.createElement('input');
            input.value = item.string;
            document.body.appendChild(input);
            input.select();
            document.execCommand('copy');
            document.body.removeChild(input);

            let message = document.getElementById('message');
            document.getElementById('subject').innerText = item.string;
            message.style.display = 'block';

            setTimeout(function () {
                message.style.display = 'none';
            }, 8000);
            break;
        case 'CLOSE':
            document.getElementById('container').style.display = 'none';
            break;
    }
});

function setMoveState(state) {
    let moveElement = document.getElementById('movement');
    if (state) {
        moveElement.classList.replace("movement_disabled", "movement_enabled");
        moveElement.innerHTML = 'Enabled'
    } else {
        moveElement.classList.replace("movement_enabled", "movement_disabled");
        moveElement.innerHTML = 'Disabled'
    }
}

fetch(`https://${GetParentResourceName()}/nuiSync`)
    .then(resp => resp.json())
    .then(resp => {
        let commandContainer = document.getElementById('command');
        commandContainer.innerHTML = `/${resp}`
    });



