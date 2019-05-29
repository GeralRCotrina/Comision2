function atajito(e) {
    evt = e || window.event;
    if ((evt.keyCode == 113) || (evt.keyCode == -113)) {
        window.location = ("mk:@MSITStore:C:/Desarrollo/ev1/comision2/static/helpdesk2/helpdesk2.chm::/e_usuario.html")
    }
}
document.onkeydown = atajito;
//la funcion va en el java scrip en la entidad o clase que quieres por ejemplo en producto
//o articulo, ese keycode son los codigos de las feclas f1, f2, en el caso de 113 es la de f2