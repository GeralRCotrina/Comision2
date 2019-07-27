 
var personas = []
var personaBK =[]
var primero = true
var resultado = []

function alEscribeJS(){
	var val = document.getElementById('valor').value;
	LlenarDiccJS();
	LimpiarJS();
	Busqueda(val);
	InsertarTabla();
}

function Busqueda(txt){
	resultado = [];
	var cont0=0;
	for (var i = personas.length - 1; i >= 0; i--) {
		if(personas[i].dni.indexOf(txt.toUpperCase()) > -1 || personas[i].username.toUpperCase().indexOf(txt.toUpperCase()) > -1 || personas[i].first_name.toUpperCase().indexOf(txt.toUpperCase()) > -1 || personas[i].last_name.toUpperCase().indexOf(txt.toUpperCase()) > -1)
		{
			cont0 += 1;
			resultado.push(personas[i]);
		}
	}
	$('#txt_tit').text(cont0+' resultados...');
}

 
function InsertarTabla() {
	var fila ='<tbody id="cuerpo">';
	for (var i = resultado.length - 1; i >= 0; i--) 
	{
		fila +='<tr style="font-size: 0.8em;"><td>'
		+resultado[i].pk+"</td><td>"
		+resultado[i].username+"</td><td>"
		+resultado[i].first_name+"</td><td>"
		+resultado[i].last_name+"</td><td>"
		+resultado[i].email+"</td><td>"
		+resultado[i].last_login+"</td><td>"
		+resultado[i].dni+"</td><td>"
		+resultado[i].botones+"</td><tr>";
	}
	fila +="</tbody>";
	$('#dataTable').append(fila);
}
function LlenarDiccJS()
{
	var tableReg = document.getElementById('dataTable');
	var cellsOfRow="";
	var cont = 0;
	if(primero == true)
	{
		for (var i = 1; i < tableReg.rows.length; i++)
		{
			cont +=1;
			cellsOfRow = tableReg.rows[i].getElementsByTagName('td');
			
			personas.push({pk:cellsOfRow[0].innerHTML,username:cellsOfRow[1].innerHTML,
				first_name:cellsOfRow[2].innerHTML,last_name:cellsOfRow[3].innerHTML,
				email:cellsOfRow[4].innerHTML,last_login:cellsOfRow[5].innerHTML,
				dni:cellsOfRow[6].innerHTML,
				botones:cellsOfRow[7].innerHTML,});
		}
		personaBK=personas;
		primero = false;
		//alert("se creóo personas y su BK");
	}
	else
		personas=personaBK;

}



function LimpiarJS(){
	$('#cuerpo').remove();
}

