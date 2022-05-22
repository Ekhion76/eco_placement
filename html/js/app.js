window.addEventListener('message', function (event) {

    let item = event.data;

    if(item.subject === 'OPEN') {

        document.getElementById('container').style.display = 'block';

    } else if(item.subject === 'COPY') {

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


    } else if(item.subject === 'CLOSE') {

        document.getElementById('container').style.display = 'none';
    }
});



