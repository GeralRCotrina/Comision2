//document.location.href="/canalero/c_orden_apr/?id_ord="+iOr+"&&id_rep="+iRe+"&&est="+est;

/*
	var xhr = new XMLHttpRequest();
	.abort() // aborta una petición
	.getAllResponseHeades() //retorna información del header
	.open() // Informacción básica del request
	.send() // envia el request al servidor.

	xhr.open('POST',"url",true); // sincrono o asincrono
*/
/*
	xhr.setRequestHeader("Content-type","application/x-www-form-urlencoded");
	xhr.send("nombre=juan&apellido=delatorre");
*/
 

 function UrlJS(iOr,iRe,est){


	var xhr = new XMLHttpRequest();

	var cad = "/canalero/c_orden_apr/?id_ord="+iOr+"&&id_rep="+iRe+"&&est="+est;

	xhr.open('GET',cad,true); // sincrono o asincrono
	xhr.onreadystatechange = function(){
		if(xhr.readyState == 4 && xhr.status == 200){
			var sp=document.getElementById("sp_"+iOr);
			sp.classList.remove("badge-success");
			sp.classList.remove("badge-danger");
			sp.classList.remove("badge-warning");
			if(est == "Rechazada")
			{
				sp.classList.add("badge-danger");
				sp.innerHTML = '<i class="fas fa-ban"></i>  RECHAZADA';
			}
			else if(est == "Aprobada")
			{
				sp.classList.add("badge-success");
				sp.innerHTML = '<i class="fas fa-check"></i> APROBADA';
			}
			else if(est == "Solicitada")
			{
				sp.classList.add("badge-warning");
				sp.innerHTML = '<i class="fas fa-sign-in-alt"></i>  SOLICITADA';
			}
		}
	}
	xhr.send();

 }