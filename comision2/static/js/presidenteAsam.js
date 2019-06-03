 
var personas = []
var personaBK =[]
var primero = true
var resultado = []

function alEscribeJS1(){
	var val = document.getElementById('valor1').value;
	LlenarDiccJS1();
	LimpiarJS1();
	Busqueda1(val);
	InsertarTabla1();
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
			+'<button class="btn btn-outline-warning" onclick="UrlJS2('+resultado[i].pk+',\'Tarde\')"><i class="far fa-clock"></i></button>'
			+'<button class="btn btn-outline-danger" onclick="UrlJS2('+resultado[i].pk+',\'Falto\')"><i class="far fa-times-circle"></i></button>'
		+'</div></td></tr>';						
	}
	console.log("  >>> "+fila);
	fila +="</tbody>";
	$('#dataTable1').append(fila);
}



function UrlJS2(pkh,msj){
	alert(">> pkh: "+pkh+"     >> mdj: "+msj);
}