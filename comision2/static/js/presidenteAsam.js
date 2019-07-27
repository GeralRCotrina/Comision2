
window.onload = function() {
	LlenarDiccJS1();
};







function SelctTipoAsamblea(){
	var divv =document.getElementById("LstCanales");
	var t_as =document.getElementById("tip_asamb").value;
	if(t_as == "Simple"){
		divv.classList.remove("d-none");
		divv.classList.remove("rotateOutDownRight");
		divv.classList.add("bounceInDown");
	}
	else{
		divv.classList.remove("bounceInDown");
		divv.classList.add("rotateOutDownRight");
	}
}


var cont_agnd = 99;
function AgregarAgnd(){
	var itm_agnd=document.getElementById("txt_itm");
	var Agnd = document.getElementById("Agnd");
	var cant_itm = document.getElementById("itm_cant");
	var txt_agnd = Agnd.innerHTML;
	cont_agnd +=1;
	Agnd.innerHTML= txt_agnd +'<p class="alert alert-success alert-dismissable">'+
						'<button type="button" class="close" data-dismiss="alert">×</button>'+
						'<strong>'+(cont_agnd-99)+'.- </strong> '+itm_agnd.value+
						'</p><input name="'+cont_agnd+'" type="hidden" value="'+(cont_agnd-99)+'.- '+itm_agnd.value+'">';
	cant_itm.value=cont_agnd;
	itm_agnd.value="";
}

/*
'<p name="agnd_itm_'+cont_agnd+'" class="alert alert-success alert-dismissable">'+
						'<button type="button" class="close" data-dismiss="alert">×</button>'+
						'<strong>'+cont_agnd+'.- </strong> '+itm_agnd.value+'</p>';


						 '<input type="text" name="agnd_itm_'+cont_agnd+'" value="'+itm_agnd.value+'"/>';
						*/









var personas = []
var personaBK =[]
var primero = true
var resultado = []
var pk_usuario = 0;



function alEscribeJS1(){
	var dn = document.getElementById('valor1').value;

	if (dn.length == 8) {
		console.log(">>Podría ser un DNI.");
		LlenarDiccJS1();
		LimpiarJS1();
		Busqueda1(dn);
		MarcarAsis();
		InsertarTabla1();
	}
	else{
		LlenarDiccJS1();
		LimpiarJS1();
		Busqueda1(dn);
		InsertarTabla1();
	}
}

function MarcarAsis(){
	UrlJS2(pk_usuario,'Asistio');
}



function LlenarDiccJS1(){
	var tableReg = document.getElementById('dataTable1');
	var cellsOfRow="";
	var cont = 0;
	if(primero == true)
	{
		for (var i = 1; i < tableReg.rows.length; i++)
		{
			cont +=1;
			cellsOfRow = tableReg.rows[i].getElementsByTagName('td');
			personas.push({pk:cellsOfRow[0].innerHTML,asamblea:cellsOfRow[1].innerHTML,usuario:cellsOfRow[2].innerHTML,
							dni:cellsOfRow[3].innerHTML,estado:cellsOfRow[4].innerHTML,hora:cellsOfRow[5].innerHTML});
		}
		personaBK=personas;
		primero = false;
	}
	else
		personas=personaBK;
}


function Busqueda1(txt){
	resultado = [];
	var cont0=0;
	var strr = "";
	for (var i = personas.length - 1; i >= 0; i--) {
		if(personas[i].usuario.toUpperCase().indexOf(txt.toUpperCase()) > -1 || personas[i].dni.toUpperCase().indexOf(txt.toUpperCase()) > -1)
		{
			cont0 += 1;
			resultado.push(personas[i]);
			pk_usuario = personas[i].pk
		}
		strr = strr+"-"+i;
	}
	$('#txt_tit').text(cont0+' resultados...');
}



function LimpiarJS1(){
	$('#cuerpo1').remove();
}


function InsertarTabla1() {
	var fila ='<tbody id="cuerpo1">';
	for (var i = resultado.length - 1; i >= 0; i--) 
	{
		fila +='<tr><td>'
		+resultado[i].pk+"</td><td>"
		+resultado[i].asamblea+"</td><td>"
		+resultado[i].usuario+"</td><td>"
		+resultado[i].dni+"</td><td>"
		+resultado[i].estado+"</td><td>"
		+resultado[i].hora+"</td><td>"
		+'<div class="btn-group">'
			+'<button class="btn btn-outline-success" onclick="UrlJS2('+resultado[i].pk+',\'Asistio\')"><i class="fas fa-check"></i></button>'
			+'<button class="btn btn-outline-info" onclick="UrlJS2('+resultado[i].pk+',\'Tarde\')"><i class="far fa-clock"></i></button>'
			+'<button class="btn btn-outline-secondary" onclick="UrlJS2('+resultado[i].pk+',\'Falto\')"><i class="far fa-times-circle"></i></button>'
		+'</div></td></tr>';						
	}
	fila +="</tbody>";
	$('#dataTable1').append(fila);
}



function UrlJS2(pkh,msj){
	CambiarEst(pkh,msj);
}



function CambiarEst(pkh,msj){
	var xhr = new XMLHttpRequest();
	var cad = "/presidente/p_hasis_est/?id_hje="+pkh+"&&std="+msj;

	xhr.open('GET',cad,true); // sincrono o asincrono
	xhr.onreadystatechange = function(){
		if(xhr.readyState == 4 && xhr.status == 200){
			console.log("retornó successfull");
			var sp=document.getElementById(pkh);
			sp.classList.remove("badge-success");
			sp.classList.remove("badge-info");
			sp.classList.remove("badge-light");
			if(msj == 'Falto')
			{
				sp.classList.add("badge-secondary");
				sp.innerHTML = 'FALTÓ';
				for (var i = personaBK.length - 1; i >= 0; i--) {
					if(personaBK[i].pk == pkh){
						personaBK[i].estado ='<span id="'+pkh+'" class="badge badge-pill badge-secondary">FALTÓ</span>';
					}
				}
			}
			else if( msj == 'Asistio')
			{
				sp.classList.add("badge-success");
				sp.innerHTML = 'ASISTIÓ';
				for (var i = personaBK.length - 1; i >= 0; i--) {
					if(personaBK[i].pk == pkh){
						personaBK[i].estado ='<span id="'+pkh+'" class="badge badge-pill badge-success">ASISTIÓ</span>';
					}
				}
			}
			else if( msj == 'Tarde')
			{
				sp.classList.add("badge-info");
				sp.innerHTML = 'TARDE';
				for (var i = personaBK.length - 1; i >= 0; i--) {
					if(personaBK[i].pk == pkh){
						personaBK[i].estado ='<span id="'+pkh+'" class="badge badge-pill badge-info">TARDE</span>';
					}
				}
			}
			else{
				alert("ERR:     >>pkh:"+pkh+"     >> mdj: "+msj);
			}
		}
	}
	xhr.send();

 }





function EliminarAsamb(pka){
	var rpta = confirm("¿Está seguro que desea eliminar la asamblea?");
	if(rpta == true){
		var xhr = new XMLHttpRequest();
		var cad = "../p_asamb_del/?pka="+pka;

		xhr.open('GET',cad,true); // sincrono o asincrono
		xhr.onreadystatechange = function(){
			if(xhr.readyState == 4 && xhr.status == 200){
				console.log("----------------------");
				
				alert(" >> "+xhr.response);
			}
		}
		xhr.send();

	}else{
		console.log("continue");
	}
}
